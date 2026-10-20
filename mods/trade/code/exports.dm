/datum/controller/subsystem/trade/proc/export(obj/machinery/trade_beacon/sending/beacon)
	if(transaction_busy || !beacon?.is_ready() || world.time < beacon.export_ready_at)
		return FALSE
	transaction_busy = TRUE
	var/exported = 0
	for(var/atom/movable/root as anything in beacon.get_objects())
		exported += export_root(root, beacon, TRADE_EXPORT_LIMIT - exported)
		if(exported >= TRADE_EXPORT_LIMIT)
			break
	transaction_busy = FALSE
	if(exported)
		beacon.start_export()
	return exported

/datum/controller/subsystem/trade/proc/export_root(atom/movable/root, obj/machinery/trade_beacon/sending/beacon, limit = TRADE_EXPORT_LIMIT)
	var/datum/trade_appraisal/quote = appraise(root)
	var/datum/money_account/account = export_account(root)
	if(!quote.total || length(quote.items) > limit || !account || !account.deposit(quote.total, "Bluespace export", beacon.name))
		qdel(quote)
		return FALSE
	log_transaction("Export", root.name, quote.total, account.owner_name, get_export_rows(quote), account.account_number)
	var/count = length(quote.items)
	commit_export(root, quote)
	qdel(quote)
	return count

/datum/controller/subsystem/trade/proc/export_account(atom/movable/root)
	if(istype(root, /obj/structure/closet/crate))
		for(var/obj/item/paper/manifest/rnd_invoice/invoice as anything in get_contents_tree(root))
			if(istype(invoice) && invoice.target_account_number && !invoice.is_copy && length(invoice.stamped))
				return get_account(invoice.target_account_number)
	return TRADE_SUPPLY_ACCOUNT

/datum/controller/subsystem/trade/proc/get_export_rows(datum/trade_appraisal/quote)
	var/list/rows = list()
	for(var/atom/movable/item as anything in quote.items)
		var/size = 0
		if(istype(item, /obj/item/stack))
			var/obj/item/stack/stack = item
			size = stack.amount
		rows += list(list("name" = item.name, "quantity" = 1, "stack_size" = size, "unit_price" = quote.items[item], "subtotal" = quote.items[item]))
	return rows

/datum/controller/subsystem/trade/proc/commit_export(atom/movable/root, datum/trade_appraisal/quote)
	SSsupply.sold_virus_strains |= quote.virus_strains
	SSanom.earned_cargo_points += quote.artefact_points
	for(var/source in quote.sources)
		SSsupply.point_sources[source] += quote.sources[source]
		SSsupply.point_sources["total"] += quote.sources[source]
	var/turf/floor = get_turf(root)
	var/list/tree = get_contents_tree(root)
	for(var/atom/movable/item as anything in tree)
		if(item in quote.items)
			export_hook(item, floor)
	for(var/index = length(tree); index >= 1; index--)
		var/atom/movable/item = tree[index]
		if(QDELETED(item) || !(item in quote.items))
			continue
		remove_exported_item(item, floor)

/datum/controller/subsystem/trade/proc/export_hook(atom/movable/item, turf/floor)
	if(istype(item, /obj/structure/closet/crate))
		callHook("sell_crate", list(item, get_area(floor)))
	if(istype(item, /obj/machinery/stasis_cage))
		callHook("sell_animal", list(item, get_area(floor)))
	if(istype(item, /obj/machinery/anomaly_container))
		callHook("sell_anomalycage", list(item, get_area(floor)))

/datum/controller/subsystem/trade/proc/fulfill_offer(obj/machinery/trade_beacon/sending/beacon, datum/trade_offer/offer, hacked = FALSE, datum/money_account/account = null, is_slaved = FALSE)
	if(!can_fulfill_offers(beacon, account, is_slaved) || !is_offer_available(offer, hacked))
		return FALSE
	var/list/plan = reserve_offers(list(offer), get_bounty_candidates(beacon))
	return execute_offers(beacon, plan, account, is_slaved)

/datum/controller/subsystem/trade/proc/fulfill_all_offers(obj/machinery/trade_beacon/sending/beacon, hacked = FALSE, datum/money_account/account = null, is_slaved = FALSE)
	if(!can_fulfill_offers(beacon, account, is_slaved))
		return FALSE
	var/list/plan = reserve_offers(get_active_offers(hacked), get_bounty_candidates(beacon))
	return execute_offers(beacon, plan, account, is_slaved)

/datum/controller/subsystem/trade/proc/can_fulfill_offers(obj/machinery/trade_beacon/sending/beacon, datum/money_account/account = null, is_slaved = FALSE)
	var/datum/money_account/supply = TRADE_SUPPLY_ACCOUNT
	if(is_slaved && !account)
		return FALSE
	account ||= supply
	return enabled && !transaction_busy && beacon?.is_ready() && world.time >= beacon.export_ready_at && account && !account.suspended && supply && !supply.suspended

/datum/controller/subsystem/trade/proc/is_offer_available(datum/trade_offer/offer, hacked)
	return offer && !QDELETED(offer) && !offer.completed && offer.station?.discovered && (!offer.station.black_market || hacked)

/datum/controller/subsystem/trade/proc/get_active_offers(hacked)
	var/list/active = list()
	for(var/uid in stations)
		var/datum/trade_station/station = stations[uid]
		for(var/id in station.offers)
			var/datum/trade_offer/offer = station.offers[id]
			if(is_offer_available(offer, hacked))
				insert_specific_offer(active, offer)
	return active

/datum/controller/subsystem/trade/proc/insert_specific_offer(list/active, datum/trade_offer/offer)
	var/priority = offer.get_priority()
	for(var/index in 1 to length(active))
		var/datum/trade_offer/existing = active[index]
		if(priority > existing.get_priority())
			active.Insert(index, offer)
			return
	active += offer

/datum/controller/subsystem/trade/proc/is_safe_bounty_tree(list/tree)
	if(!length(tree))
		return FALSE
	for(var/atom/movable/item as anything in tree)
		if(is_protected(item))
			return FALSE
	return TRUE

/datum/controller/subsystem/trade/proc/get_bounty_candidates(obj/machinery/trade_beacon/sending/beacon)
	var/list/candidates = list()
	for(var/atom/movable/root as anything in beacon.get_objects())
		var/list/tree = get_contents_tree(root)
		if(!is_safe_bounty_tree(tree))
			continue
		for(var/atom/movable/item as anything in tree)
			if(!item.anchored && !(TRADE_TAG_NONEXPORTABLE in item.trade_export_tags))
				candidates |= item
		if(length(candidates) >= TRADE_EXPORT_LIMIT)
			return candidates.Copy(1, TRADE_EXPORT_LIMIT + 1)
	return candidates

/datum/controller/subsystem/trade/proc/reserve_offers(list/active, list/candidates)
	var/list/plan = list()
	var/list/reserved = list()
	for(var/datum/trade_offer/offer as anything in active)
		var/list/matches = list()
		for(var/atom/movable/item as anything in candidates)
			if(!(item in reserved) && !length(offer.get_installed_parts(item) & reserved) && offer.matches(item))
				matches += item
			if(length(matches) == offer.amount)
				break
		if(length(matches) != offer.amount)
			continue
		plan[offer] = matches
		reserved |= matches
		for(var/atom/movable/item as anything in matches)
			reserved |= offer.get_installed_parts(item)
		candidates -= reserved
	return plan

/datum/controller/subsystem/trade/proc/execute_offers(obj/machinery/trade_beacon/sending/beacon, list/plan, datum/money_account/account = null, is_slaved = FALSE)
	if(!length(plan) || !can_fulfill_offers(beacon, account, is_slaved))
		return FALSE
	transaction_busy = TRUE
	var/count = 0
	try
		count = commit_offers(beacon, plan, account, is_slaved)
	catch(var/exception/error)
		transaction_busy = FALSE
		throw error
	transaction_busy = FALSE
	return count

/datum/controller/subsystem/trade/proc/commit_offers(obj/machinery/trade_beacon/sending/beacon, list/plan, datum/money_account/account = null, is_slaved = FALSE)
	var/total = 0
	for(var/datum/trade_offer/offer as anything in plan)
		total += offer.unit_price * offer.amount
	account ||= TRADE_SUPPLY_ACCOUNT
	if(!pay_bounty(total, account, is_slaved))
		return FALSE
	for(var/datum/trade_offer/offer as anything in plan)
		offer.completed = TRUE
		offer.station.add_to_wealth(offer.unit_price * offer.amount, is_offer = TRUE)
		var/list/rows = list(list("name" = offer.name, "station" = offer.station.name, "quantity" = offer.amount, "unit_price" = offer.unit_price, "subtotal" = offer.amount * offer.unit_price))
		log_transaction("Bounty", offer.name, offer.unit_price * offer.amount, account.owner_name, rows, account.account_number, is_slaved && account != TRADE_SUPPLY_ACCOUNT ? offer.unit_price * offer.amount * TRADE_HANDLING_FEE : 0)
	beacon.start_export()
	for(var/datum/trade_offer/offer as anything in plan)
		consume_offer(offer, plan[offer])
	return length(plan)

/datum/controller/subsystem/trade/proc/pay_bounty(total, datum/money_account/account, is_slaved)
	var/datum/money_account/supply = TRADE_SUPPLY_ACCOUNT
	var/fee = is_slaved && account != supply ? total * TRADE_HANDLING_FEE : 0
	if(!account || account.suspended || !supply || supply.suspended || !account.deposit(total - fee, "Trade bounties", "Frontier Trade Network"))
		return FALSE
	if(fee && !supply.deposit(fee, "Local trade commission", "Frontier Trade Network"))
		account.withdraw(total - fee, "Failed bounty rollback", "Frontier Trade Network")
		return FALSE
	return TRUE

/datum/controller/subsystem/trade/proc/consume_offer(datum/trade_offer/offer, list/items)
	for(var/atom/movable/item as anything in items)
		if(offer.reagent_type)
			item.reagents.remove_reagent(offer.reagent_type, offer.reagent_volume)
			continue
		for(var/obj/item/part as anything in offer.get_installed_parts(item))
			if(istype(part) && part.loc == item)
				qdel(part)
		if(offer.live_required && istype(item.loc, /obj/machinery/stasis_cage))
			var/obj/machinery/stasis_cage/cage = item.loc
			cage.release()
		remove_exported_item(item, get_turf(item))

/datum/controller/subsystem/trade/proc/remove_exported_item(atom/movable/item, turf/floor)
	if(QDELETED(item))
		return
	for(var/atom/movable/child as anything in item.contents.Copy())
		child.forceMove(floor)
	qdel(item)
