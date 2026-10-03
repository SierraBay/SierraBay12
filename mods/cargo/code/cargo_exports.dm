/datum/controller/subsystem/supply/proc/FindRnDInvoice(atom/movable/container)
	if(!istype(container))
		return null
	for(var/atom/movable/item as anything in GetExportTree(container, TRUE, TRUE))
		if(!istype(item, /obj/item/paper/manifest/rnd_invoice))
			continue
		var/obj/item/paper/manifest/rnd_invoice/invoice = item
		if(!invoice.is_copy && LAZYLEN(invoice.stamped) && invoice.target_account_number)
			return invoice
	return null

/datum/controller/subsystem/supply/proc/GetExportInvoiceBlockReason(list/plan)
	if(!islist(plan))
		return null
	var/list/checked_scopes = list()
	for(var/list/entry as anything in plan["entries"])
		var/atom/movable/scope = entry["scope"]
		if(!scope || checked_scopes[scope])
			continue
		checked_scopes[scope] = TRUE
		var/obj/item/paper/manifest/rnd_invoice/slip = FindRnDInvoice(scope)
		if(!slip)
			return "R&D invoice changed before the sale could complete."
		var/datum/money_account/payee = get_account(slip.target_account_number)
		if(!istype(payee) || payee.suspended)
			return "R&D invoice in [scope.name] targets an unavailable or suspended account."
	return null

/datum/controller/subsystem/supply/proc/GetExportTree(atom/movable/root, skip_protected_cargo = FALSE, stop_at_closets = FALSE)
	var/list/ordered = list()
	var/list/seen = list()
	var/list/pending = list(root)
	var/index = 1
	while(index <= length(pending))
		var/atom/movable/item = pending[index++]
		if(!istype(item) || QDELETED(item) || seen[item])
			continue
		seen[item] = TRUE
		if(skip_protected_cargo && (IsProtectedExportCargo(item) || IsInstalledExportPart(item)))
			continue
		ordered += item
		for(var/atom/movable/child as anything in item.contents)
			if(!seen[child] && !(stop_at_closets && istype(child, /obj/structure/closet)))
				pending += child
	return ordered

/datum/controller/subsystem/supply/proc/GetExportItemQuote(atom/movable/item, datum/trading_station/station, seller_faction, find_manifest, list/sold_counts, list/seen_strains)
	var/special_item = istype(item, /obj/item/virusdish) || istype(item, /obj/item/paper) || istype(item, /obj/item/disk/research_report) || istype(item, /obj/item/artefact) || istype(item, /obj/item/collector) || istype(item, /obj/item/disk/survey)
	var/list/match = special_item || HasNestedExportInvoice(item) ? null : FindCommodityForExport(item, station)
	if(islist(match))
		var/good_id = match["good_id"]
		var/amount = match["amount"]
		var/offset = sold_counts[good_id] || 0
		return list("price" = GetStationSellPrice(good_id, station, seller_faction, match["category"], amount, offset), "match" = match, "amount" = amount)
	var/price
	if(istype(item, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/crate = item
		price = initial(crate.points_per_crate) * CARGO_POINT_TO_THALLER
	else
		price = GetCrateItemLegacyValue(item, find_manifest, seen_strains)
	return list("price" = round(price, 0.01), "match" = null, "amount" = isstack(item) ? GetExportStackAmount(item) : 1)

/datum/controller/subsystem/supply/proc/BuildExportPlan(list/roots, datum/trading_station/station = null, seller_faction = null, budget = INFINITY, list/rejected = null, list/sold_counts = null, list/seen_strains = null)
	var/list/plan = list("entries" = list(), "total" = 0, "budget_limited" = FALSE)
	if(istype(station) && seller_faction && GetStationTradeRelationMultiplier(station, seller_faction) <= 0)
		return plan
	plan["entries"] = CollectExportPlanEntries(roots, station, rejected)
	PriceExportPlan(plan, station, seller_faction, budget, sold_counts, seen_strains)
	return plan

/datum/controller/subsystem/supply/proc/Export(obj/machinery/trade_beacon/sending/sender_beacon, datum/money_account/money_account, datum/trading_station/target_station = null, seller_faction = null)
	if(QDELETED(sender_beacon) || !istype(money_account) || money_account.suspended || !sender_beacon.CanExport())
		return FALSE
	if(istype(target_station) && (target_station.wealth <= 0 || GetTradeRangeBlockReason(sender_beacon, target_station) || (seller_faction && GetStationTradeRelationMultiplier(target_station, seller_faction) <= 0)))
		return FALSE
	var/list/rejected = list()
	var/list/roots = GetExportCandidates(sender_beacon, rejected)
	var/list/plan = BuildExportPlan(roots, target_station, seller_faction, istype(target_station) ? target_station.wealth : INFINITY, rejected)
	if(plan["total"] <= 0)
		if(length(rejected) && sender_beacon.StartExport())
			for(var/atom/movable/rejected_atom as anything in rejected)
				HandleRejectedExport(rejected_atom)
		return FALSE
	if(GetExportInvoiceBlockReason(plan) || GetExportCompletionBlockReason(plan))
		return FALSE
	var/list/payouts_by_account = list()
	var/list/root_accounts = list()
	var/list/invoices = list()
	var/list/plan_entries = plan["entries"]
	for(var/list/entry as anything in plan_entries)
		if(!entry["sell"])
			continue
		var/atom/movable/root = entry["scope"] || entry["root"]
		var/datum/money_account/payee = root_accounts[root]
		if(!payee)
			payee = money_account
			if(istype(root, /obj/structure/closet))
				var/obj/item/paper/manifest/rnd_invoice/slip = FindRnDInvoice(root)
				if(slip)
					invoices |= slip
					payee = get_account(slip.target_account_number)
					if(!istype(payee) || payee.suspended)
						return FALSE
			root_accounts[root] = payee
		entry["account"] = payee
		payouts_by_account[payee] = round(payouts_by_account[payee] + entry["price"], 0.01)
	plan["payouts"] = payouts_by_account
	plan["invoices"] = invoices
	if(!DepositExportPayouts(sender_beacon, money_account, payouts_by_account))
		return FALSE
	for(var/atom/movable/rejected_atom as anything in rejected)
		HandleRejectedExport(rejected_atom)
	if(istype(target_station))
		target_station.SubtractFromWealth(plan["total"])
	RecordExportPlan(sender_beacon, money_account, target_station, seller_faction, plan)
	return plan["budget_limited"] ? TRADE_EXPORT_PARTIAL : TRADE_EXPORT_SUCCESS

/datum/controller/subsystem/supply/proc/GetExportCandidates(obj/machinery/trade_beacon/sending/sender_beacon, list/rejected)
	var/list/candidates = list()
	for(var/atom/movable/exported as anything in sender_beacon.GetObjects())
		if(istype(exported, /obj/structure/closet/crate/trade_contract))
			continue
		if(istype(exported, /obj/item/disk/trade_data))
			continue
		if(!CanExportAtom(exported))
			rejected += exported
			continue
		candidates += exported
	return candidates

/datum/controller/subsystem/supply/proc/DepositExportPayouts(obj/machinery/trade_beacon/sending/sender_beacon, datum/money_account/money_account, list/payouts_by_account)
	var/list/successful_deposits = list()
	var/deposit_failed = FALSE
	for(var/datum/money_account/account as anything in payouts_by_account)
		var/amount = payouts_by_account[account]
		if(amount <= 0)
			continue
		var/description = (account == money_account) ? "Trade Network Export" : "R&D Invoice sale"
		if(!account.deposit(amount, description, "Trade Network"))
			deposit_failed = TRUE
			break
		successful_deposits += list(list(account, amount))

	if(!deposit_failed && sender_beacon.StartExport())
		return TRUE
	for(var/list/deposit in successful_deposits)
		var/datum/money_account/account = deposit[1]
		var/amount = deposit[2]
		account.withdraw(amount, "Export Transaction Rollback", "Trade Network")
	return FALSE

/datum/controller/subsystem/supply/proc/RecordExportPlan(obj/machinery/trade_beacon/sending/sender_beacon, datum/money_account/money_account, datum/trading_station/target_station, seller_faction, list/plan)
	var/list/items_by_account = list()
	var/list/entries = plan["entries"]
	for(var/list/entry as anything in entries)
		if(!entry["sell"])
			continue
		var/datum/money_account/payee = entry["account"] || money_account
		var/atom/movable/item = entry["item"]
		items_by_account[payee] = "[items_by_account[payee] || ""]<li>[item.name]</li>"
	ApplyExportMarketTransactions(target_station, seller_faction, entries)
	for(var/obj/item/paper/manifest/rnd_invoice/slip as anything in plan["invoices"])
		DetachExportChild(slip)
		qdel(slip)
	for(var/i = length(entries) to 1 step -1)
		var/list/entry = entries[i]
		if(entry["sell"])
			RecordExportScience(entry)
			DeleteExportEntry(entry)
	WriteExportPlanLogs(sender_beacon, target_station, seller_faction, items_by_account, plan["payouts"])

/datum/controller/subsystem/supply/proc/HasLivingOccupants(atom/movable/exported)
	if(!istype(exported) || QDELETED(exported))
		return FALSE
	if(isliving(exported))
		return TRUE
	for(var/atom/movable/content as anything in GetExportTree(exported))
		if(isliving(content))
			return TRUE
	return FALSE

/datum/controller/subsystem/supply/proc/CanExportAtom(atom/movable/exported)
	if(!istype(exported) || QDELETED(exported))
		return FALSE
	if(HasLivingOccupants(exported))
		return FALSE
	return TRUE

/datum/controller/subsystem/supply/proc/HandleRejectedExport(atom/movable/exported)
	if(!istype(exported) || QDELETED(exported))
		return
	if(isliving(exported))
		var/mob/living/living_mob = exported
		to_chat(living_mob, SPAN_DANGER("The export beacon rejects biological matter with a painful electric shock!"))
		living_mob.apply_damage(15, DAMAGE_BURN)
		return
	for(var/atom/movable/content as anything in GetExportTree(exported))
		if(!isliving(content))
			continue
		var/mob/living/living_mob = content
		to_chat(living_mob, SPAN_DANGER("The export beacon rejects biological matter inside the container with a buzzing jolt!"))
		living_mob.apply_damage(5, DAMAGE_BURN)

/datum/controller/subsystem/supply/proc/GetCrateItemLegacyValue(atom/movable/item, find_manifest = FALSE, list/seen_strains = null)
	if(!istype(item) || QDELETED(item))
		return 0
	if(istype(item, /obj/machinery/power/supermatter))
		return 0
	if(istype(item, /obj/machinery/portable_atmospherics/canister))
		return GetExportCanisterLegacyPrice(item)
	if(istype(item, /obj/item/paper/manifest/rnd_invoice))
		return 0
	if(istype(item, /obj/item/disk/research_report))
		var/obj/item/disk/research_report/report = item
		return max(0, report.cargo_value)
	if(istype(item, /obj/item/virusdish))
		var/obj/item/virusdish/dish = item
		if(dish.analysed && istype(dish.virus2) && dish.virus2.uniqueID)
			var/strain_id = dish.virus2.uniqueID
			if(!(strain_id in sold_virus_strains) && (!islist(seen_strains) || !(strain_id in seen_strains)))
				if(islist(seen_strains))
					seen_strains += strain_id
				return 5 * CARGO_POINT_TO_THALLER
		return 0
	if(find_manifest && istype(item, /obj/item/paper/manifest))
		var/obj/item/paper/manifest/slip = item
		if(!slip.is_copy && LAZYLEN(slip.stamped))
			return points_per_slip * CARGO_POINT_TO_THALLER
		return 0
	if(istype(item, /obj/item/paper))
		return 0
	if(istype(item, /obj/item/stack/material))
		var/obj/item/stack/material/material_stack = item
		var/val = 0
		if(material_stack.material && material_stack.material.sale_price > 0)
			val += material_stack.get_amount() * material_stack.material.sale_price * material_stack.matter_multiplier * CARGO_POINT_TO_THALLER
		if(material_stack.reinf_material && material_stack.reinf_material.sale_price > 0)
			val += material_stack.get_amount() * material_stack.reinf_material.sale_price * material_stack.matter_multiplier * 0.5 * CARGO_POINT_TO_THALLER
		return val
	if(istype(item, /obj/item/disk/survey))
		var/obj/item/disk/survey/survey_disk = item
		return round(survey_disk.Value() * 0.05) * CARGO_POINT_TO_THALLER
	if(istype(item, /obj/item/artefact))
		var/obj/item/artefact/artefact = item
		return artefact.cargo_price * CARGO_POINT_TO_THALLER
	if(istype(item, /obj/item/collector))
		// The recursive export plan values and disposes of the contained artefact.
		return 0
	if(istype(item, /obj/item/storage) || length(item.contents))
		return GetExportContainerValue(item)
	return round(get_value(item))

/datum/controller/subsystem/supply/proc/GetExportContainerValue(atom/movable/item)
	var/value = get_value(item)
	var/atom/priced_type = item.type
	while(priced_type && !(priced_type in worths))
		priced_type = type2parent(priced_type)
	// Fixed prices already describe the object itself. Dynamic obj.Value includes contents.
	if(priced_type && worths[priced_type] < 0)
		for(var/atom/movable/child as anything in item.contents)
			value -= get_value(child)
	return max(0, round(value))

/datum/controller/subsystem/supply/proc/GetCrateExportBreakdown(obj/structure/closet/crate, datum/trading_station/target_station, seller_faction = null, list/sold_counts = null, list/seen_strains = null)
	if(!istype(crate))
		return list("base_value" = 0, "contents_value" = 0, "total_value" = 0, "display_name" = "Crate", "sub_items" = list())
	var/list/plan = BuildExportPlan(list(crate), target_station, seller_faction, INFINITY, null, sold_counts, seen_strains)
	var/list/sub_items = list()
	var/base_value = 0
	var/contents_value = 0
	var/list/entries = plan["entries"]
	for(var/list/entry as anything in entries)
		if(!entry["sell"])
			continue
		var/atom/movable/item = entry["item"]
		var/amount = max(0.000001, entry["amount"])
		if(item == crate)
			base_value = entry["price"]
		else
			contents_value += entry["price"]
		sub_items.Add(list(list("name" = item == crate ? "[item.name] (packaging)" : item.name, "amount" = amount, "unit_value" = round(entry["price"] / amount, 0.01), "value" = entry["price"])))
	var/obj/item/paper/manifest/rnd_invoice/slip = FindRnDInvoice(crate)
	var/display_name = slip ? "[crate.name] (R&D #[slip.target_account_number])" : crate.name
	return list("base_value" = base_value, "contents_value" = contents_value, "total_value" = plan["total"], "display_name" = display_name, "sub_items" = sub_items)

/datum/controller/subsystem/supply/proc/GetExportValue(atom/movable/exported, datum/trading_station/target_station = null, seller_faction = null, list/sold_counts = null, list/seen_strains = null)
	var/list/plan = BuildExportPlan(list(exported), target_station, seller_faction, INFINITY, null, sold_counts, seen_strains)
	return plan["total"]
