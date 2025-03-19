// Subsystem for station/ship trade via supply program. Not to be mistaked with trade.dm, which is for merchant.
SUBSYSTEM_DEF(supply)
	name = "Supply"
	priority = SS_PRIORITY_SUPPLY
	flags = SS_NO_FIRE
	runlevels = RUNLEVELS_GAME
	wait = 30 MINUTES

	/// Budget for trading stations with spawn_always at FALSE
	var/trade_stations_budget = 5
	/// All available trading stations - visible, hidden, doesn't matter
	var/list/all_trading_stations = list()
	/// All visible and available stations
	var/list/visible_trading_stations = list()
	/// All hidden/unavailable stations
	var/list/hidden_trading_stations = list()
	/// All factions in the world; Assoc list Name = Datum.
	/// Trading stations get the datums from here
	var/list/factions = list()
	// Lists of available sending/receiving beacons
	var/list/beacons_sending = list()
	var/list/beacons_receiving = list()

	// For tracking/logging
	var/shipping_invoice_number = 0
	var/export_invoice_number = 0
	var/offer_invoice_number = 0
	var/order_number = 0

	var/list/shipping_log = list()
	var/list/export_log = list()
	var/list/offer_log = list()
	var/list/order_log = list()

	// For ordering
	var/handling_fee = 0.1
	var/order_queue_id = 0
	var/list/order_queue = list()


	// For exporting
	/// Maximum price of an atom before it becomes affected by an export modifier
	var/export_maximum = 25000
	var/list/export_modifier = list()
	var/list/export_counter = list()
	/// Paths of atoms that are entirely unaffected by export price modifiers
	var/list/export_modifier_exempt_types = list(
		/obj/item/ore,
		/obj/item/stack,
		/obj/item/reagent_containers,
		/obj/item/slime_extract,
		/obj/item/ammo_casing,
		/obj/machinery/artifact,
		/obj/machinery/portable_atmospherics/canister,
		/mob/living/carbon/slime,
		)

/datum/controller/subsystem/supply/Initialize(start_uptime)
	. = ..()
	for(var/faction_type in typesof(/datum/trade_faction))
		var/datum/trade_faction/TF = new faction_type
		factions[TF.name] = TF

	// Factions that aren't set in relationship list of the datum are set to neutral.
	for(var/tf in factions)
		var/datum/trade_faction/TF = factions[tf]
		for(var/tf2 in factions)
			var/datum/trade_faction/TF2 = factions[tf2]
			if(TF == TF2)
				// Technically not, but this will be how we declare same faction relations for now
				TF.relationship[TF2.name] = FACTION_STATE_PROTECTORATE
				continue

			// This ensures that relations are always mirrored between two datums
			SetFactionRelations(TF, TF2, TF.relationship[TF2])


	// Now we set it to neutral for the missing ones
	for(var/tf in factions)
		var/datum/trade_faction/TF = factions[tf]
		for(var/tf2 in factions)
			var/datum/trade_faction/TF2 = factions[tf2]
			if(!(TF2.name in TF.relationship))
				SetFactionRelations(TF, TF2, FACTION_STATE_NEUTRAL)

	InitTradeStations()

/datum/controller/subsystem/supply/Destroy()
	DeInitTradeStations()
	. = ..()

/datum/controller/subsystem/supply/fire()
	for(var/datum/money_account/A in all_money_accounts)
		A.PayrollTick()
	for(var/A in export_counter)
		var/reduction = max(export_maximum, export_counter[A] * 0.5)
		export_counter[A] = max(0, export_counter[A] -= reduction)
	ExportCounterCheck()


/datum/controller/subsystem/supply/proc/GetFaction(fac)
	if(!(fac in factions))
		return null
	return factions[fac]

/// Sets equal relations between two factions
/datum/controller/subsystem/supply/proc/SetFactionRelations(fac1, fac2, relation)
	if(!(fac1 in factions) || !(fac2 in factions) || fac1 == fac2 || !relation)
		return FALSE

	var/datum/trade_faction/F1 = factions[fac1]
	var/datum/trade_faction/F2 = factions[fac2]
	F1.ModifyRelationsWith(fac2, relation)
	F2.ModifyRelationsWith(fac1, relation)
	return TRUE

// === TRADE STATIONS ===

/datum/controller/subsystem/supply/proc/DiscoverAllTradeStations()
	visible_trading_stations = all_trading_stations.Copy()

/datum/controller/subsystem/supply/proc/ReInitTradeStations()
	DeInitTradeStations()
	InitTradeStations()

/datum/controller/subsystem/supply/proc/DeInitTradeStations()
	for(var/datum/trading_station/TS in all_trading_stations)
		TS.RegainTradeStationsBudget()
		qdel(TS)
		visible_trading_stations -= TS
		all_trading_stations -= TS

/datum/controller/subsystem/supply/proc/InitTradeStations()
	var/list/weightstationlist = CollectTradeStations()
	var/list/stations_to_init = CollectSpawnAlways()

	while(trade_stations_budget && length(weightstationlist))
		var/datum/trading_station/TS = pickweight(weightstationlist)
		if(istype(TS))
			stations_to_init += TS
			TS.SpendTradeStationsBudget()
		weightstationlist.Remove(TS)
	InitTradeStationsByList(stations_to_init)

/datum/controller/subsystem/supply/proc/InitTradeStation(stype)
	var/datum/trading_station/station
	if(istype(stype, /datum/trading_station))
		station = stype
		if(!station.name)
			station.InitSrc()
	else if(ispath(stype, /datum/trading_station))
		station = new stype(TRUE)
	. = station

/datum/controller/subsystem/supply/proc/InitTradeStationsByList(list/L)
	. = list()
	for(var/i in L)
		var/a = InitTradeStation(i)
		if(a)
			. += a

/datum/controller/subsystem/supply/proc/DiscoverByUid(list/uid_list)
	for(var/target_uid in uid_list)
		for(var/datum/trading_station/station in all_trading_stations)
			if(station.uid == target_uid)
				visible_trading_stations |= station
				GLOB.entered_event.unregister(station.overmap_location, station, /datum/trading_station/proc/Discovered)

/datum/controller/subsystem/supply/proc/GetStationByUid(target_uid)
	for(var/datum/trading_station/station in all_trading_stations)
		if(station.uid == target_uid)
			return station
	return FALSE

/datum/controller/subsystem/supply/proc/GetVisibleStationByUid(target_uid)
	for(var/datum/trading_station/station in visible_trading_stations)
		if(station.uid == target_uid)
			return station
	return FALSE

/datum/controller/subsystem/supply/proc/CollectSpawnAlways()
	. = list()
	for(var/path in subtypesof(/datum/trading_station))
		var/datum/trading_station/TS = path
		if(!initial(TS.spawn_always))
			continue
		. += new path()

/datum/controller/subsystem/supply/proc/CollectTradeStations()
	. = list()
	for(var/path in subtypesof(/datum/trading_station))
		var/datum/trading_station/TS = path
		if(initial(TS.spawn_always) || !initial(TS.spawn_probability))
			continue
		.[new path] = initial(TS.spawn_probability)

// Get a weighted list of all stations that have not already been spawned
/datum/controller/subsystem/supply/proc/CollectAvailableTradeStations()
	. = list()
	for(var/path in subtypesof(/datum/trading_station))
		var/is_available = TRUE
		for(var/datum/trading_station/TS in SSsupply.all_trading_stations)
			if(istype(TS, path))
				is_available = FALSE
		if(!is_available)
			continue
		var/datum/trading_station/TS = path
		if(!initial(TS.spawn_probability))
			continue
		. += new path()

// Cost of the item with ONLY markup added
/datum/controller/subsystem/supply/proc/GetBasicImportCost(path, datum/trading_station/station)
	. = station?.GetGoodPrice(path)								// get_good_price() gets the custom price of the item, if it exists
	if(!.)
		. = get_value(path)
		if(istype(station))
			. *= station.markup

// This one is modified by faction relations and will display "(+50%)" near the price if cost is different from basic one
/datum/controller/subsystem/supply/proc/GetImportCost(path, datum/trading_station/station, datum/trade_faction/buyer_faction = null)
	. = GetBasicImportCost(path, station)
	if(!buyer_faction)
		return

	if(!istype(buyer_faction))
		buyer_faction = GetFaction(buyer_faction)

	var/datum/trade_faction/seller_faction = GetFaction(station.faction)
	if(!seller_faction)
		return

	. *= station.GetFactionMarkup(buyer_faction)

	if(buyer_faction.name in seller_faction.trade_markup)
		. *= seller_faction.trade_markup[buyer_faction.name]

/datum/controller/subsystem/supply/proc/CollectCountsFrom(list/shopList)
	. = 0
	for(var/station in shopList)
		var/list/shoplist_station = shopList[station]
		for(var/category_name in shoplist_station)
			var/list/category = shoplist_station[category_name]
			if(length(category))
				for(var/path in category)
					. += category[path]

/datum/controller/subsystem/supply/proc/CollectPriceForCategory(list/category, datum/trading_station/station)
	. = 0
	if(!length(category))
		return

	for(var/path in category)
		. += GetImportCost(path, station) * category[path]

/datum/controller/subsystem/supply/proc/CollectPriceForList(list/shopList)
	. = 0
	for(var/station in shopList)
		var/list/shoplist_station = shopList[station]
		for(var/category_name in shoplist_station)
			var/category = shoplist_station[category_name]
			if(length(category))
				for(var/path in category)
					. += GetImportCost(path, station) * category[path]


#define LOG_TYPE_SHIPPING "Shipping"
#define LOG_TYPE_EXPORT "Export"
#define LOG_TYPE_SPECIAL_OFFER "Special Offer"
#define LOG_TYPE_ORDER "Order"

// Ordering

/datum/controller/subsystem/supply/proc/BuildOrder(requesting_account, reason, list/shopping_list)
	if(!requesting_account || !shopping_list || !length(shopping_list))
		return

	var/cost = CollectPriceForList(shopping_list)
	var/order_contents_info
	var/list/goods = list()
	var/datum/money_account/requesting_acct = requesting_account
	var/datum/money_account/master_acct = department_accounts["Supply"]
	var/is_requestor_master = (requesting_acct == master_acct) ? TRUE : FALSE

	for(var/station in shopping_list)
		var/list/shoplist_categories = shopping_list[station]
		for(var/category in shoplist_categories)
			var/list/shoplist_goods = shoplist_categories[category]
			for(var/good in shoplist_goods)
				goods |= good

				var/amount_to_add = shoplist_goods[good]

				goods[good] += amount_to_add

				var/atom/movable/AM = good
				order_contents_info += "<li>[amount_to_add]x [initial(AM.name)]</li>"

	var/list/new_order = list(
		"requesting_acct" = requesting_account,
		"reason" = reason,
		"cost" = cost,
		"fee" = (is_requestor_master ? 0 : cost * handling_fee),
		"contents" = shopping_list,
		"viewable_contents" = order_contents_info
	)

	var/order_queue_slot = "order_[++order_queue_id]"
	order_queue |= order_queue_slot
	order_queue[order_queue_slot] = new_order

	return order_queue_slot

/datum/controller/subsystem/supply/proc/PurchaseOrder(obj/machinery/trade_beacon/receiving/beacon, order_id, used_faction = FACTION_INDEPENDENT)
	if(QDELETED(beacon) || !beacon || !order_id)
		return

	if(order_queue.Find(order_id))
		var/list/order = order_queue[order_id]

		var/datum/money_account/master_account = department_accounts["Supply"]
		var/datum/money_account/requesting_account = order["requesting_acct"]
		var/list/shopping_list = order["contents"]
		var/list/viewable_contents = order["viewable_contents"]
		var/total_cost = order["cost"] + order["fee"]
		var/is_requestor_master = (requesting_account == master_account) ? TRUE : FALSE

		Buy(beacon, master_account, shopping_list, !is_requestor_master, requesting_account.owner_name, used_faction)
		if(!is_requestor_master)
			requesting_account.transfer(master_account, total_cost, "Order Request")
		CreateLogEntry(LOG_TYPE_ORDER, requesting_account.owner_name, used_faction, viewable_contents, total_cost)

/datum/controller/subsystem/supply/proc/Buy(obj/machinery/trade_beacon/receiving/senderBeacon, datum/money_account/account, list/shopList, is_order = FALSE, buyer_name = null, used_faction = FACTION_INDEPENDENT)
	if(QDELETED(senderBeacon) || !istype(senderBeacon) || !account || !RecursiveLen(shopList))
		return FALSE

	var/count_of_all = CollectCountsFrom(shopList)
	var/price_for_all = CollectPriceForList(shopList)

	if(price_for_all && account.money < price_for_all)
		return FALSE

	var/obj/structure/closet/secure_closet/personal/trade/C

	if(isnum(count_of_all) && count_of_all > 1)
		C = senderBeacon.DropItem(/obj/structure/closet/secure_closet/personal/trade)
		if(is_order)
			C.locked = TRUE
			C.registered_name = buyer_name
			C.name = "[initial(C.name)] ([C.registered_name])"
			C.update_icon()

	var/order_contents_info
	var/invoice_location

	for(var/datum/trading_station/station in shopList)
		var/list/shoplist_station = shopList[station]
		var/to_station_wealth = 0
		for(var/category_name in shoplist_station)
			var/list/shoplist_category = shoplist_station[category_name]
			var/list/inventory_category = station.inventory[category_name] + station.hidden_inventory[category_name]
			to_station_wealth += CollectPriceForCategory(shoplist_category, station)
			if(length(shoplist_category) && length(inventory_category))
				for(var/good_path in shoplist_category)
					var/count_of_good = shoplist_category[good_path] //in shoplist
					var/index_of_good = inventory_category.Find(good_path) //in inventory
					for(var/i in 1 to count_of_good)
						if(istype(C))
							new good_path(C)
						else
							var/atom/movable/new_item = senderBeacon.DropItem(good_path)
							invoice_location = new_item.loc
					if(isnum(index_of_good))
						station.SetGoodAmount(category_name, index_of_good, max(0, station.GetGoodAmount(category_name, index_of_good) - count_of_good))

					// invoice gen stuff
					var/atom/movable/AM = good_path
					var/list/good_packet = inventory_category[good_path]
					var/item_name = initial(AM.name)
					if(islist(good_packet))
						item_name = good_packet["name"] ? good_packet["name"] : item_name
					order_contents_info += "<li>[count_of_good]x [item_name]</li>"
		station.AddToWealth(to_station_wealth)

	if(count_of_all > 1)
		invoice_location = C

	CreateLogEntry(LOG_TYPE_SHIPPING, account.owner_name, used_faction, order_contents_info, price_for_all, FALSE, invoice_location)
	account.withdraw(price_for_all, "Purchase", "Trade Network")
	return TRUE

/datum/controller/subsystem/supply/proc/Export(obj/machinery/trade_beacon/sending/senderBeacon, datum/money_account/moneyAccount, used_faction = FACTION_INDEPENDENT)
	// Check if the sender beacon has been deleted.
	if(QDELETED(senderBeacon))
		return

	// Attempt to start the export process on the sender beacon.
	if(!senderBeacon.StartExport())
		return

	var/invoice_contents_info
	var/export_count = 0
	var/cost = 0

	for(var/atom/movable/AM in senderBeacon.GetObjects())
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			H.apply_damage(15, DAMAGE_BURN)
			continue

		var/list/contents_incl_self = AM.GetAllContents(3, TRUE)

		if(is_path_in_list(/mob/living/carbon/human, contents_incl_self))
			continue

		// We go backwards, so it'll be innermost objects sold first
		for(var/atom/movable/item in reverseRange(contents_incl_self))
			if(istype(item, /obj/screen))
				continue

			var/item_price = GetExportValue(item)
			var/export_value = item_price

			if(export_value)
				invoice_contents_info += "<li>[item.name]</li>"
				cost += export_value
				if(!(is_path_in_list(item.type, export_modifier_exempt_types)))
					if(!(item.type in export_counter))
						export_counter[item.type] = 0
					if(export_counter[item.type] < export_maximum * 2)
						export_counter[item.type] += round(min(export_value, export_maximum * 0.25))
				//SEND_SIGNAL(src, COMSIG_TRADE_BEACON, item)
				qdel(item)
				++export_count
			else if(item != AM)
				if(!isobj(item) || !ismob(item))
					qdel(item)
				else
					item.forceMove(get_turf(AM))		// Should be the same tile

		// The max is a soft cap
		if(export_count > 100)
			break

	ExportCounterCheck()

	moneyAccount.deposit(cost, LOG_TYPE_EXPORT, "Trade Network")

	if(invoice_contents_info)	// If no info, then nothing was exported
		CreateLogEntry(LOG_TYPE_EXPORT, moneyAccount.owner_name, used_faction, invoice_contents_info, cost, FALSE, get_turf(senderBeacon))
	return TRUE

/datum/controller/subsystem/supply/proc/GetExportValue(atom/A)
	/// Returns the value of this atom for export purposes. If the item is in the export modifier list, we multiply the value by the modifier.
	/// This is used to limit the amount of money that can be made from exporting certain items, by dynamically adjusting the export price.
	. = get_value(A)
	if(A.type in export_modifier)
		. *= export_modifier[A.type]

/datum/controller/subsystem/supply/proc/ExportCounterCheck()
	// Checks the export counter and adjusts the export modifiers as needed.
	// If an item has been exported too many times, the export modifier is set to a value between 0.5 and 2.0, which will scale the export price down.
	// If an item has not been exported too many times, its export modifier is removed.
	for(var/A in export_counter)
		if(export_counter[A] > export_maximum)
			export_modifier[A] = clamp(round(export_maximum / export_counter[A], 0.01), 0.5, 2.0)
		else if(A in export_modifier)
			export_modifier -= A

// Logging

/datum/controller/subsystem/supply/proc/CreateLogEntry(type, ordering_account, assoc_faction = FACTION_INDEPENDENT, contents, total_paid, create_invoice = FALSE, invoice_location = null)

	var/log_id

	switch(type)
		if(LOG_TYPE_SHIPPING)
			log_id = "[++shipping_invoice_number]-S"
			shipping_log.Add(list(list("id" = log_id, "ordering_acct" = ordering_account, "assoc_faction" = assoc_faction, "contents" = contents, "total_paid" = total_paid, "time" = time2text(world.time, "hh:mm"))))
		if(LOG_TYPE_EXPORT)
			log_id = "[++export_invoice_number]-E"
			export_log.Add(list(list("id" = log_id, "ordering_acct" = ordering_account, "assoc_faction" = assoc_faction, "contents" = contents, "total_paid" = total_paid, "time" = time2text(world.time, "hh:mm"))))
		if(LOG_TYPE_SPECIAL_OFFER)
			log_id = "[++offer_invoice_number]-SO"
			offer_log.Add(list(list("id" = log_id, "ordering_acct" = ordering_account, "assoc_faction" = assoc_faction, "contents" = contents, "total_paid" = total_paid, "time" = time2text(world.time, "hh:mm"))))
		if(LOG_TYPE_ORDER)
			log_id = "[++order_number]-O"
			order_log.Add(list(list("id" = log_id, "ordering_acct" = ordering_account, "assoc_faction" = assoc_faction, "contents" = contents, "total_paid" = total_paid, "time" = time2text(world.time, "hh:mm"))))
		else
			return

	if(create_invoice && invoice_location && log_id)
		PrintInvoice(type, log_id, ordering_account, contents, total_paid, FALSE, invoice_location)
		if(type == LOG_TYPE_SHIPPING)
			PrintInvoice(type, log_id, ordering_account, contents, total_paid, TRUE, invoice_location)

/datum/controller/subsystem/supply/proc/PrintInvoice(type, log_id, ordering_account, contents, total_paid, is_internal = FALSE, location)
	if(!location)
		return

	var/title
	title = "[lowertext(type)] invoice - #[log_id]"
	title += is_internal ? " (internal)" : null

	var/text
	text += "<h3>[type] Invoice - #[log_id]</h3>"
	text += "<hr><font size = \"2\">"
	text += is_internal ? "FOR INTERNAL USE ONLY<br><br>" : null
	text += type != LOG_TYPE_SHIPPING && type ? "Recipient: [ordering_account]<br>" : "Recipient: \[field\]<br>"
	text += type == LOG_TYPE_SHIPPING ? "Package Name: \[field\]<br>" : null
	text += "Contents:<br>"
	text += "<ul>"
	text += contents
	text += "</ul>"
	text += is_internal ? "Order Cost: [total_paid]<br>" : null
	text += type == LOG_TYPE_SHIPPING ? "Total Credits Paid: \[field\]<br>" : "Total Credits Paid: [total_paid]<br>"
	text += "</font>"
	text += type == LOG_TYPE_SHIPPING ? "<hr><h5>Stamp below to confirm receipt of goods:</h5>" : null

	new/obj/item/paper(location, text, title)

/datum/controller/subsystem/supply/proc/GetLogDataById(log_id)
	var/id_data = splittext(log_id, "-")
	var/log_num = text2num(id_data[1])
	var/log_type = id_data[2]
	switch(log_type)
		if("S")
			return shipping_log[log_num]
		if("E")
			return export_log[log_num]
		if("SO")
			return offer_log[log_num]
		if("O")
			return order_log[log_num]
		else
			return
