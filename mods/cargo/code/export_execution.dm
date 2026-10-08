/datum/controller/subsystem/supply/proc/GetExportInvoiceScope(atom/movable/item, atom/movable/root)
	var/atom/movable/owner = item
	while(istype(owner))
		if(istype(owner, /obj/structure/closet) && FindRnDInvoice(owner))
			return owner
		if(owner == root)
			break
		owner = owner.loc
	return null

/datum/controller/subsystem/supply/proc/HasNestedExportInvoice(atom/movable/item)
	for(var/atom/movable/child as anything in GetExportTree(item, TRUE))
		if(child != item && istype(child, /obj/structure/closet) && FindRnDInvoice(child))
			return TRUE
	return FALSE

/datum/controller/subsystem/supply/proc/CollectExportPlanEntries(list/roots, datum/trading_station/station, list/rejected)
	var/list/entries = list()
	var/list/visited = list()
	for(var/atom/movable/root as anything in roots)
		if((root in visited) || IsProtectedExportCargo(root))
			continue
		if(!CanExportAtom(root))
			if(islist(rejected))
				rejected |= root
			continue
		for(var/atom/movable/item as anything in GetExportTree(root, TRUE))
			if(item in visited)
				continue
			var/list/entry = CreateExportPlanEntry(item, root, station)
			visited |= entry["owned"] || list(item)
			entries.Add(list(entry))
	return entries

/datum/controller/subsystem/supply/proc/CreateExportPlanEntry(atom/movable/item, atom/movable/root, datum/trading_station/station)
	var/list/owned
	if((istype(item, /obj/item/storage) || istype(item, /obj/structure/closet) || istype(item, /obj/item/clothing)) && !HasNestedExportInvoice(item))
		var/list/match = FindCommodityForExport(item, station)
		if(islist(match) && length(GetExportCargoContents(item)))
			owned = GetExportTree(item, TRUE)
	return list("item" = item, "root" = root, "parent" = item.loc, "scope" = GetExportInvoiceScope(item, root), "owned" = owned)

/datum/controller/subsystem/supply/proc/IsProtectedExportCargo(atom/movable/item)
	return istype(item, /obj/structure/closet/crate/trade_contract) || istype(item, /obj/item/disk/trade_data)

/datum/controller/subsystem/supply/proc/KeepExportPackaging(atom/movable/item, atom/movable/root, list/keep)
	var/atom/movable/owner = item.loc
	while(istype(owner))
		keep[owner] = TRUE
		if(owner == root)
			break
		owner = owner.loc

/datum/controller/subsystem/supply/proc/PriceExportPlan(list/plan, datum/trading_station/station, seller_faction, budget, list/sold_counts, list/seen_strains)
	var/list/entries = plan["entries"]
	var/list/keep = list()
	for(var/list/entry as anything in entries)
		if(istype(entry["item"], /obj/machinery/power/supermatter))
			KeepExportPackaging(entry["item"], entry["root"], keep)
	var/previous_kept = -1
	while(previous_kept != length(keep))
		previous_kept = length(keep)
		plan["total"] = 0
		plan["budget_limited"] = FALSE
		var/list/counts = islist(sold_counts) ? sold_counts.Copy() : list()
		var/list/strains = islist(seen_strains) ? seen_strains.Copy() : list()
		var/list/manifests = list()
		for(var/list/entry as anything in entries)
			PriceExportPlanEntry(plan, entry, station, seller_faction, budget, counts, strains, manifests, keep)
	plan["total"] = round(plan["total"], 0.01)

/datum/controller/subsystem/supply/proc/PriceExportPlanEntry(list/plan, list/entry, datum/trading_station/station, seller_faction, budget, list/counts, list/strains, list/manifests, list/keep)
	var/atom/movable/item = entry["item"]
	var/atom/movable/scope = entry["scope"] || entry["root"]
	var/find_manifest = istype(scope, /obj/structure/closet) && !manifests[scope]
	var/list/trial_strains = strains.Copy()
	var/list/quote = GetExportItemQuote(item, station, seller_faction, find_manifest, counts, trial_strains)
	entry["price"] = quote["price"]
	entry["match"] = quote["match"]
	entry["amount"] = quote["amount"]
	entry["sell"] = !keep[item] && (quote["price"] > 0 || islist(quote["match"])) && quote["price"] <= round(budget - plan["total"], 0.01)
	if(!keep[item] && quote["price"] > round(budget - plan["total"], 0.01))
		plan["budget_limited"] = TRUE
	if(entry["sell"])
		AcceptExportPlanQuote(plan, entry, counts, strains, trial_strains, manifests, scope)
	else if(islist(entry["owned"]))
		KeepExportPackaging(item, entry["root"], keep)

/datum/controller/subsystem/supply/proc/AcceptExportPlanQuote(list/plan, list/entry, list/counts, list/strains, list/trial_strains, list/manifests, atom/movable/scope)
	var/list/match = entry["match"]
	if(islist(match))
		var/good_id = match["good_id"]
		counts[good_id] = (counts[good_id] || 0) + entry["amount"]
	strains.Cut()
	strains |= trial_strains
	if(istype(entry["item"], /obj/item/paper/manifest) && !istype(entry["item"], /obj/item/paper/manifest/rnd_invoice))
		manifests[scope] = TRUE
	plan["total"] = round(plan["total"] + entry["price"], 0.01)

/datum/controller/subsystem/supply/proc/GetExportCompletionBlockReason(list/plan)
	for(var/list/entry as anything in plan["entries"])
		var/atom/movable/item = entry["item"]
		if(QDELETED(item) || item.loc != entry["parent"] || !CanExportAtom(item))
			return "Export cargo changed before the sale could complete."
		if(entry["sell"] && !get_turf(item))
			return "Export cargo has no safe unloading location."
		var/list/owned = entry["owned"] || list(item)
		for(var/atom/movable/owner as anything in owned)
			if(QDELETED(owner) || !HasValidExportOwnership(owner))
				return "Export cargo has inconsistent ownership."
	return null

/datum/controller/subsystem/supply/proc/HasValidExportOwnership(atom/movable/item)
	var/datum/component/cargo_contents/component = item.GetComponent(/datum/component/cargo_contents)
	return !component || component.ValidateOwnership()

/datum/controller/subsystem/supply/proc/DetachExportChild(atom/movable/item)
	var/atom/movable/owner = item.loc
	if(istype(owner))
		var/datum/component/cargo_contents/component = owner.GetComponent(/datum/component/cargo_contents)
		component?.Detach(item)

/datum/controller/subsystem/supply/proc/DeleteExportItem(atom/movable/item)
	if(QDELETED(item))
		return
	DetachExportChild(item)
	var/turf/floor = get_turf(item)
	for(var/atom/movable/child as anything in GetExportCargoContents(item))
		DetachExportChild(child)
		child.forceMove(floor)
	qdel(item)

/datum/controller/subsystem/supply/proc/DeleteExportEntry(list/entry)
	var/list/owned = entry["owned"] || list(entry["item"])
	for(var/i = length(owned) to 1 step -1)
		DeleteExportItem(owned[i])

/datum/controller/subsystem/supply/proc/ApplyExportMarketTransactions(datum/trading_station/station, seller_faction, list/entries)
	var/list/totals = list()
	var/list/categories = list()
	for(var/list/entry as anything in entries)
		var/list/match = entry["match"]
		if(!entry["sell"] || !islist(match))
			continue
		var/good_id = match["good_id"]
		totals[good_id] += entry["amount"]
		categories[good_id] = match["category"]
	for(var/good_id in totals)
		ApplyTradeTransaction(station, categories[good_id], good_id, totals[good_id], "sell", seller_faction)

/datum/controller/subsystem/supply/proc/RecordExportScience(list/entry)
	var/list/owned = entry["owned"] || list(entry["item"])
	for(var/atom/movable/item as anything in owned)
		if(QDELETED(item))
			continue
		if(istype(item, /obj/item/virusdish))
			var/obj/item/virusdish/dish = item
			if(dish.analysed && istype(dish.virus2) && dish.virus2.uniqueID)
				sold_virus_strains |= dish.virus2.uniqueID
		if(istype(item, /obj/item/artefact) && SSanom)
			var/obj/item/artefact/artefact = item
			SSanom.earned_cargo_points += artefact.cargo_price

/datum/controller/subsystem/supply/proc/WriteExportPlanLogs(obj/machinery/trade_beacon/sending/beacon, datum/trading_station/station, seller_faction, list/items_by_account, list/payouts)
	for(var/datum/money_account/payee as anything in items_by_account)
		CreateLogEntry("Export", payee.owner_name, items_by_account[payee], payouts[payee], TRUE, get_turf(beacon), seller_faction, station ? station.name : null)
