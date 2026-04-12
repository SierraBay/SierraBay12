#define SETTINGS_SCREEN "settings"
#define GOODS_SCREEN "goods"
#define EXPORT_SCREEN "export"
#define CART_SCREEN "cart"
#define ORDER_SCREEN "orders"
#define CONTRACT_SCREEN "contracts"
#define SAVED_SCREEN "saved"
#define LOG_SCREEN "logs"
#define LOG_SHIPPING "Shipping"
#define LOG_EXPORT "Export"
#define LOG_ORDER "Order"
#define LOG_CONTRACT "Contract"

/datum/computer_file/program/supply
	filename = "supply"
	filedesc = "Supply Management"
	nanomodule_path = null
	ui_header = null
	program_icon_state = "supply"
	program_key_state = "rd_key"
	program_menu_icon = "cart"
	extended_desc = "Trade network management for purchasing, exporting, and approving supply orders."
	size = 21
	available_on_ntnet = TRUE
	requires_ntnet = FALSE
	category = PROG_SUPPLY
	usage_flags = PROGRAM_ALL

	var/faction = FACTION_INDEPENDENT
	var/trade_screen = GOODS_SCREEN
	var/log_screen = LOG_SHIPPING

	var/obj/machinery/trade_beacon/sending/sending
	var/obj/machinery/trade_beacon/receiving/receiving
	var/datum/money_account/account

	var/list/shopping_list = list()
	var/list/saved_shopping_lists = list()
	var/saved_cart_id = 0

	var/datum/trading_station/station
	var/chosen_category
	var/current_order
	var/orders_locked = FALSE
	var/list/known_market_intel = list()

	var/goods_quantity_target
	var/cart_form_mode
	var/trade_catalog_view_distance = 6

/datum/computer_file/program/supply/on_startup(mob/living/user, datum/extension/interactive/ntos/new_host)
	. = ..()
	if(. && faction == FACTION_INDEPENDENT)
		var/atom/host = computer ? computer.get_physical_host() : null
		if(istype(host) && (host.z in GLOB.using_map.station_levels))
			faction = GLOB.using_map.trade_faction

/datum/computer_file/program/supply/process_tick()
	..()
	if(length(SSsupply.order_queue))
		ui_header = "supply_new_order.gif"
	else if(length(shopping_list))
		ui_header = "supply_awaiting_delivery.gif"
	else
		ui_header = "supply_idle.gif"

/datum/computer_file/program/supply/proc/SetChosenCategory(value)
	if(!istype(station))
		chosen_category = null
		return
	if(isnum(value))
		value = station.inventory[value]
	if(!value && length(station.inventory))
		value = station.inventory[1]
	chosen_category = value

/datum/computer_file/program/supply/proc/CopyShopList(list/source)
	var/list/copied = list()
	if(!islist(source))
		return copied
	for(var/datum/trading_station/target_station as anything in source)
		var/list/categories = source[target_station]
		if(!islist(categories))
			continue
		var/list/category_copy = list()
		for(var/category_name in categories)
			var/list/goods = categories[category_name]
			if(!islist(goods))
				continue
			category_copy[category_name] = goods.Copy()
		if(length(category_copy))
			copied[target_station] = category_copy
	return copied

/datum/computer_file/program/supply/proc/OpenShopList(datum/trading_station/target_station = station, target_category = chosen_category)
	if(!istype(target_station) || !target_category)
		return null
	if(!islist(shopping_list[target_station]))
		shopping_list[target_station] = list()
	var/list/categories = shopping_list[target_station]
	if(!islist(categories[target_category]))
		categories[target_category] = list()
	return categories[target_category]

/datum/computer_file/program/supply/proc/SanitizeShopList()
	for(var/datum/trading_station/target_station as anything in shopping_list.Copy())
		var/list/categories = shopping_list[target_station]
		if(!islist(categories))
			shopping_list -= target_station
			continue
		for(var/category_name in categories.Copy())
			var/list/goods = categories[category_name]
			if(!islist(goods) || !length(goods))
				categories -= category_name
		if(!length(categories))
			shopping_list -= target_station

/datum/computer_file/program/supply/proc/AddToShopList(good_id, amount, limit)
	if(!good_id || !amount)
		return
	var/list/inventory_list = OpenShopList()
	if(!islist(inventory_list))
		return
	inventory_list[good_id] = (inventory_list[good_id] || 0) + amount
	if(limit && inventory_list[good_id] > limit)
		inventory_list[good_id] = limit

/datum/computer_file/program/supply/proc/RemoveFromShopList(good_id, amount, datum/trading_station/target_station = station, target_category = chosen_category)
	if(!good_id || !amount)
		return
	var/list/inventory_list = OpenShopList(target_station, target_category)
	if(!islist(inventory_list) || !(good_id in inventory_list))
		return
	inventory_list[good_id] -= amount
	if(inventory_list[good_id] < 1)
		inventory_list -= good_id
	SanitizeShopList()

/datum/computer_file/program/supply/proc/ResetShopList()
	shopping_list = list()

/datum/computer_file/program/supply/proc/SaveShopList(name, list/shop_list = null)
	var/list/source = islist(shop_list) ? shop_list : shopping_list
	var/list/copy = CopyShopList(source)
	if(!length(copy))
		return FALSE
	var/list_name = name ? name : "Saved Cart #[++saved_cart_id]"
	saved_shopping_lists[list_name] = copy
	return TRUE

/datum/computer_file/program/supply/proc/LoadShopList(name)
	if(!(name in saved_shopping_lists))
		return null
	return CopyShopList(saved_shopping_lists[name])

/datum/computer_file/program/supply/proc/DeleteShopList(name)
	if(name in saved_shopping_lists)
		saved_shopping_lists -= name

/datum/computer_file/program/supply/proc/UnlockOrdering()
	orders_locked = FALSE

/datum/computer_file/program/supply/proc/GetMasterAccount()
	return get_supply_department_account()

/datum/computer_file/program/supply/proc/GetInsertedIdCard()
	var/obj/item/stock_parts/computer/card_slot/card_slot = computer ? computer.get_component(PART_CARD) : null
	return istype(card_slot) ? card_slot.stored_card : null

/datum/computer_file/program/supply/proc/HasCargoApprovalAccess(mob/user)
	var/obj/item/card/id/id_card = user ? user.GetIdCard() : null
	if(!istype(id_card))
		return FALSE
	return (access_cargo in id_card.access) || (access_qm in id_card.access) || (access_bridge in id_card.access)

/datum/computer_file/program/supply/proc/GetLogCollection()
	switch(log_screen)
		if(LOG_EXPORT)
			return SSsupply.export_log
		if(LOG_ORDER)
			return SSsupply.order_log
		if(LOG_CONTRACT)
			return SSsupply.contract_log
		else
			return SSsupply.shipping_log

/datum/computer_file/program/supply/proc/FormatCountdown(deciseconds)
	if(!isnum(deciseconds))
		return "00:00"
	var/seconds = max(0, round(deciseconds / 10))
	return "[pad_left(num2text((seconds / 60) % 60), 2, "0")]:[pad_left(num2text(seconds % 60), 2, "0")]"

/datum/computer_file/program/supply/proc/ResetUiForms()
	goods_quantity_target = null
	cart_form_mode = null

/datum/computer_file/program/supply/proc/CloseGoodsQuantityForm()
	goods_quantity_target = null

/datum/computer_file/program/supply/proc/OpenGoodsQuantityForm(good_id)
	goods_quantity_target = good_id
	cart_form_mode = null

/datum/computer_file/program/supply/proc/CloseCartForm()
	cart_form_mode = null

/datum/computer_file/program/supply/proc/OpenCartForm(mode)
	if(mode != "save" && mode != "order")
		return
	cart_form_mode = mode
	goods_quantity_target = null

/datum/computer_file/program/supply/proc/GetBeaconDisplayId(obj/machinery/trade_beacon/beacon)
	if(istype(beacon) && !QDELETED(beacon) && beacon.loc)
		return beacon.GetId()
	return null

/datum/computer_file/program/supply/proc/IsReceivingSelected()
	return !!GetBeaconDisplayId(receiving)

/datum/computer_file/program/supply/proc/IsSendingSelected()
	return !!GetBeaconDisplayId(sending)

/datum/computer_file/program/supply/proc/EnsureSelectedStation()
	if(!length(SSsupply.visible_trading_stations))
		station = null
		chosen_category = null
		return null

	if(!istype(station) || !(station in SSsupply.visible_trading_stations))
		station = SSsupply.visible_trading_stations[1]

	if(!chosen_category || !(chosen_category in station.inventory))
		SetChosenCategory()

	RememberMarketIntel(station)
	return station

/datum/computer_file/program/supply/proc/RememberMarketIntel(datum/trading_station/target_station)
	if(!istype(target_station))
		return
	var/list/intel = SSsupply.BuildStationMarketIntel(target_station, faction)
	if(!islist(intel))
		return
	if(!islist(known_market_intel))
		known_market_intel = list()
	known_market_intel[target_station.uid] = intel

/datum/computer_file/program/supply/proc/GetMarketIntelAgeText(timestamp)
	if(!isnum(timestamp))
		return "Unknown"
	return FormatCountdown(world.time - timestamp)

/datum/computer_file/program/supply/proc/SerializeKnownMarketIntel()
	var/list/result = list()
	if(!islist(known_market_intel))
		return result
	for(var/station_uid in known_market_intel)
		var/list/intel = known_market_intel[station_uid]
		if(!islist(intel))
			continue
		result.Add(list(list(
			"station_uid" = intel["station_uid"],
			"station_name" = intel["station_name"],
			"status_label" = intel["status_label"] || "Stable Market",
			"status_tone" = intel["status_tone"] || "good",
			"status_desc" = intel["status_desc"] || "",
			"quality" = intel["quality"] || "limited",
			"age" = GetMarketIntelAgeText(intel["timestamp"]),
			"quotes" = intel["quotes"] || list()
		)))
	return result

/datum/computer_file/program/supply/proc/ResolveGoodId(category_name = null, good_ref)
	if(!istype(station))
		return null
	if(!category_name)
		category_name = chosen_category
	var/list/category = station.inventory[category_name]
	if(!islist(category) || !good_ref)
		return null
	if(good_ref in category)
		return good_ref
	var/index = text2num(good_ref)
	if(index >= 1 && index <= length(category))
		return category[index]
	return null

/datum/computer_file/program/supply/proc/GetTradeSource()
	return computer ? computer.get_physical_host() : null

/datum/computer_file/program/supply/proc/GetTradeSourceSector()
	var/atom/trade_source = GetTradeSource()
	if(!trade_source)
		return null
	return SSsupply.GetOvermapSectorFor(trade_source)

/datum/computer_file/program/supply/proc/IsLocalTradeBeacon(obj/machinery/trade_beacon/beacon)
	if(!istype(beacon) || QDELETED(beacon) || !beacon.loc)
		return FALSE
	var/obj/overmap/visitable/source_sector = GetTradeSourceSector()
	if(!istype(source_sector))
		return FALSE
	return SSsupply.GetOvermapSectorFor(beacon) == source_sector

/datum/computer_file/program/supply/proc/ValidateSelectedTradeBeacons()
	if(receiving && !IsLocalTradeBeacon(receiving))
		receiving = null
	if(sending && !IsLocalTradeBeacon(sending))
		sending = null

/datum/computer_file/program/supply/proc/GetLocalReceivingBeaconsById()
	var/list/result = list()
	for(var/obj/machinery/trade_beacon/receiving/beacon as anything in SSsupply.beacons_receiving)
		if(!IsLocalTradeBeacon(beacon))
			continue
		result[beacon.GetId()] = beacon
	return result

/datum/computer_file/program/supply/proc/GetLocalSendingBeaconsById()
	var/list/result = list()
	for(var/obj/machinery/trade_beacon/sending/beacon as anything in SSsupply.beacons_sending)
		if(!IsLocalTradeBeacon(beacon))
			continue
		result[beacon.GetId()] = beacon
	return result

/datum/computer_file/program/supply/proc/GetStationCatalogBlockReason(datum/trading_station/target_station, buyer_faction = faction)
	if(!istype(target_station))
		return "Station unavailable."

	var/datum/trade_faction/station_faction = SSsupply.GetFaction(target_station.faction)
	if(istype(station_faction) && (buyer_faction in station_faction.embargo))
		return "Economic embargo in effect. Trading denied."
	if(length(target_station.whitelist_factions) && !(buyer_faction in target_station.whitelist_factions))
		return "This station trades only with approved factions."
	if(length(target_station.blacklist_factions) && (buyer_faction in target_station.blacklist_factions))
		return "This station refuses trade with your faction."
	var/availability_block = target_station.GetAvailabilityBlockReason(GetTradeSource())
	if(availability_block)
		return availability_block
	return null

/datum/computer_file/program/supply/proc/GetStationTradeBlockReason(datum/trading_station/target_station, buyer_faction = faction)
	var/catalog_block = GetStationCatalogBlockReason(target_station, buyer_faction)
	if(catalog_block)
		return catalog_block

	if(!GLOB.using_map.use_overmap || !istype(target_station) || !target_station.overmap_location)
		return null

	var/atom/trade_source = GetTradeSource()
	if(!trade_source)
		return null

	var/obj/overmap/visitable/current_sector = GetTradeSourceSector()
	if(!istype(current_sector))
		return "Trade catalog is available only while your vessel is present on the overmap."
	if(current_sector.z != target_station.overmap_location.z)
		return "This trade beacon is outside your current overmap region."

	var/distance = get_dist(current_sector, target_station.overmap_location)
	if(distance >= trade_catalog_view_distance)
		return "Move closer than [trade_catalog_view_distance] overmap tiles to browse this trade beacon's catalog."
	return null

/datum/computer_file/program/supply/proc/GetStationStatusData(datum/trading_station/target_station, buyer_faction = faction, has_local_receiving_beacon = null)
	if(!istype(target_station))
		return list(
			"label" = "Unavailable",
			"tone" = "bad"
		)

	var/datum/trade_faction/station_faction = SSsupply.GetFaction(target_station.faction)
	if(istype(station_faction) && (buyer_faction in station_faction.embargo))
		return list(
			"label" = "Embargoed",
			"tone" = "bad"
		)

	if(length(target_station.whitelist_factions) && !(buyer_faction in target_station.whitelist_factions))
		return list(
			"label" = "Wrong faction",
			"tone" = "bad"
		)

	if(length(target_station.blacklist_factions) && (buyer_faction in target_station.blacklist_factions))
		return list(
			"label" = "Wrong faction",
			"tone" = "bad"
		)

	var/list/availability_status = target_station.GetAvailabilityStatusData()
	if(islist(availability_status) && target_station.GetAvailabilityBlockReason(GetTradeSource()))
		return availability_status

	if(isnull(has_local_receiving_beacon))
		has_local_receiving_beacon = length(GetLocalReceivingBeaconsById()) > 0
	if(!has_local_receiving_beacon)
		return list(
			"label" = "No local beacon",
			"tone" = "average"
		)

	if(GetStationTradeBlockReason(target_station, buyer_faction))
		return list(
			"label" = "Out of range",
			"tone" = "bad"
		)

	return list(
		"label" = "In range",
		"tone" = "good"
	)

/datum/computer_file/program/supply/proc/TryAddToCart(good_ref, amount)
	if(!istype(station) || !chosen_category || !amount)
		return FALSE
	var/good_id = ResolveGoodId(chosen_category, good_ref)
	if(!good_id)
		return FALSE
	var/path = station.GetGoodPath(chosen_category, good_id)
	if(!ispath(path, /atom/movable))
		return FALSE
	var/good_amount = station.GetGoodAmount(chosen_category, good_id)
	if(!good_amount)
		return FALSE
	AddToShopList(good_id, max(1, round(amount)), good_amount)
	return TRUE

/datum/computer_file/program/supply/proc/GetGoodMarkupText(basic_price, price)
	if(!basic_price || price == basic_price)
		return ""
	var/markup_percent = round(((price / basic_price) * 100) - 100)
	if(price > basic_price)
		return " (+[markup_percent]%)"
	return " ([markup_percent]%)"

/datum/computer_file/program/supply/proc/SerializeVisibleStations()
	var/list/result = list()
	var/has_local_receiving_beacon = length(GetLocalReceivingBeaconsById()) > 0
	for(var/datum/trading_station/target_station as anything in SSsupply.visible_trading_stations)
		var/datum/trade_faction/station_faction = SSsupply.GetFaction(target_station.faction)
		var/faction_color = TradeRelationsColor(station_faction ? station_faction.relationship[faction] : null) || "#ffffff"
		var/list/status_data = GetStationStatusData(target_station, faction, has_local_receiving_beacon)
		var/list/availability_status = target_station.GetAvailabilityStatusData()
		result.Add(list(list(
			"uid" = target_station.uid,
			"name" = target_station.name,
			"faction" = target_station.faction,
			"faction_color" = faction_color,
			"selected" = target_station == station,
			"market_label" = target_station.GetLiveMarketStatusLabel(),
			"market_tone" = target_station.GetLiveMarketStatusTone(),
			"status_label" = status_data["label"],
			"status_tone" = status_data["tone"],
			"availability_label" = islist(availability_status) ? availability_status["label"] : "",
			"availability_tone" = islist(availability_status) ? availability_status["tone"] : ""
		)))
	return result

/datum/computer_file/program/supply/proc/SerializeCategories(datum/trading_station/target_station = null)
	var/list/result = list()
	if(!istype(target_station))
		target_station = station
	if(!istype(target_station))
		return result
	for(var/category_name in target_station.inventory)
		result.Add(list(list(
			"name" = category_name,
			"selected" = category_name == chosen_category
		)))
	return result

/datum/computer_file/program/supply/proc/SerializeSelectedStation(datum/trading_station/target_station = null)
	if(!istype(target_station))
		target_station = station
	if(!istype(target_station))
		return null
	var/datum/trade_faction/station_faction = SSsupply.GetFaction(target_station.faction)
	var/faction_color = TradeRelationsColor(station_faction ? station_faction.relationship[faction] : null) || "#ffffff"
	var/time_remaining = max(0, (target_station.update_timer_start + target_station.update_time) - world.time)
	var/block_reason = GetStationTradeBlockReason(target_station)
	var/purchase_block_reason = GetStationTradeBlockReason(target_station)
	var/list/status_data = GetStationStatusData(target_station)
	var/list/availability_status = target_station.GetAvailabilityStatusData()
	var/trade_window_remaining = target_station.GetAvailabilityWindowRemaining()
	var/desc_text = target_station.desc || ""
	if(isnum(trade_window_remaining) && trade_window_remaining > 0)
		desc_text += " Departs in [FormatCountdown(trade_window_remaining)]."
	return list(
		"uid" = target_station.uid,
		"name" = target_station.name,
		"faction" = target_station.faction,
		"faction_color" = faction_color,
		"desc" = desc_text,
		"favor" = round(target_station.favor),
		"unlock_favor" = round(target_station.unlock_favor),
		"restock_in" = FormatCountdown(time_remaining),
		"status_label" = status_data["label"],
		"status_tone" = status_data["tone"],
		"availability_label" = islist(availability_status) ? availability_status["label"] : "",
		"availability_tone" = islist(availability_status) ? availability_status["tone"] : "",
		"market_label" = target_station.GetLiveMarketStatusLabel(),
		"market_tone" = target_station.GetLiveMarketStatusTone(),
		"market_desc" = target_station.GetLiveMarketStatusDescription(),
		"block_reason" = block_reason || "",
		"can_trade" = !purchase_block_reason,
		"trade_window_remaining" = isnum(trade_window_remaining) ? FormatCountdown(trade_window_remaining) : ""
	)

/datum/computer_file/program/supply/proc/SerializeGoods(datum/trading_station/target_station = null)
	var/list/result = list()
	if(!istype(target_station))
		target_station = station
	if(!istype(target_station) || !chosen_category)
		return result
	var/list/category = target_station.inventory[chosen_category]
	if(!islist(category))
		return result

	var/block_reason = GetStationTradeBlockReason(target_station)
	var/can_add_goods = istype(account) && !block_reason
	for(var/good_id in category)
		var/path = target_station.GetGoodPath(chosen_category, good_id)
		if(!ispath(path, /atom/movable))
			continue
		var/stock = target_station.GetGoodAmount(chosen_category, good_id)
		var/basic_price = SSsupply.GetStationTradeBasePrice(good_id, target_station, faction, chosen_category)
		var/price = SSsupply.GetStationBuyPrice(good_id, target_station, faction, chosen_category)
		var/sell_price = SSsupply.GetStationSellPrice(good_id, target_station, chosen_category)
		result.Add(list(list(
			"id" = good_id,
			"name" = target_station.GetGoodName(chosen_category, good_id),
			"stock" = stock,
			"price" = round(price),
			"sell_price" = round(sell_price),
			"markup_text" = GetGoodMarkupText(basic_price, price),
			"can_add" = can_add_goods && stock > 0,
			"quantity_form_open" = goods_quantity_target == good_id
		)))
	return result

/datum/computer_file/program/supply/proc/SerializeExportItems()
	var/list/result = list()
	if(!IsSendingSelected())
		return result
	var/datum/trading_station/target_station = EnsureSelectedStation()
	for(var/atom/movable/exported as anything in sending.GetObjects())
		if(istype(exported, /obj/structure/closet/crate/trade_contract))
			continue
		if(!SSsupply.CanExportAtom(exported))
			continue
		var/cost = SSsupply.GetExportValue(exported, target_station)
		if(!cost)
			continue
		result.Add(list(list(
			"name" = exported.name,
			"value" = round(cost),
			"target_station" = target_station ? target_station.name : "Trade Network"
		)))
	return result

/datum/computer_file/program/supply/proc/SerializeShopListGroups(list/shop_list, buyer_faction = null, list/price_snapshot = null)
	var/list/result = list()
	if(!islist(shop_list))
		return result
	if(isnull(buyer_faction))
		buyer_faction = faction

	for(var/datum/trading_station/target_station as anything in shop_list)
		var/list/categories = shop_list[target_station]
		if(!istype(target_station) || !islist(categories))
			continue

		var/list/category_entries = list()
		for(var/category_name in categories)
			var/list/goods = categories[category_name]
			if(!islist(goods) || !length(goods))
				continue

			var/list/item_entries = list()
			for(var/good_id in goods)
				var/amount = goods[good_id]
				if(!isnum(amount) || amount < 1)
					continue
				var/unit_price = SSsupply.GetStationBuyPrice(good_id, target_station, buyer_faction, category_name)
				if(islist(price_snapshot))
					var/snapshot_price = SSsupply.GetSnapshotUnitPrice(price_snapshot, target_station, category_name, good_id)
					if(isnum(snapshot_price))
						unit_price = snapshot_price
				item_entries.Add(list(list(
					"good_id" = good_id,
					"name" = target_station.GetGoodName(category_name, good_id),
					"amount" = amount,
					"price" = round(unit_price * amount),
					"category_name" = category_name,
					"station_uid" = target_station.uid
				)))
			if(length(item_entries))
				category_entries.Add(list(list(
					"name" = category_name,
					"items" = item_entries
				)))
		if(length(category_entries))
			result.Add(list(list(
				"station_uid" = target_station.uid,
				"station_name" = target_station.name,
				"categories" = category_entries
			)))
	return result

/datum/computer_file/program/supply/proc/SerializeOrders()
	var/list/result = list()
	for(var/order_id in SSsupply.order_queue)
		var/list/order_data = SSsupply.order_queue[order_id]
		var/datum/money_account/requestor = order_data["requesting_acct"]
		result.Add(list(list(
			"id" = order_id,
			"requestor_name" = requestor ? requestor.owner_name : "Unknown",
			"total" = round(order_data["cost"] + order_data["fee"]),
			"selected" = current_order == order_id
		)))
	return result

/datum/computer_file/program/supply/proc/GetContractAcceptBlockReason(datum/trade_contract/contract)
	if(!istype(contract))
		return "Contract data is unavailable."
	if(!account)
		return "Link an account before accepting contracts."
	return contract.GetAcceptBlockReason(receiving)

/datum/computer_file/program/supply/proc/GetContractDeliverBlockReason(datum/trade_contract/contract)
	if(!istype(contract))
		return "Contract data is unavailable."
	return contract.GetDeliverBlockReason(sending)

/datum/computer_file/program/supply/proc/SerializeContractEntry(datum/trade_contract/contract)
	if(!istype(contract))
		return null
	var/datum/trading_station/source_station = contract.GetSourceStation()
	var/datum/trading_station/destination_station = contract.GetDestinationStation()
	var/block_reason = null
	switch(contract.status)
		if("available")
			block_reason = GetContractAcceptBlockReason(contract)
		if("active")
			block_reason = GetContractDeliverBlockReason(contract)
		if("failed")
			block_reason = contract.failure_reason || "Contract failed."
	var/can_act = contract.status == "available" || contract.status == "active"
	can_act = can_act && !block_reason
	return list(
		"id" = contract.id,
		"serial" = contract.contract_serial || "",
		"type_label" = contract.GetTypeLabel(),
		"source_name" = source_station ? source_station.name : "Unknown",
		"destination_name" = destination_station ? destination_station.name : "Unknown",
		"cargo" = contract.GetDisplayCargoText(),
		"reward" = round(contract.reward),
		"penalty" = round(contract.penalty),
		"distance" = round(contract.distance),
		"base_value" = round(contract.base_value),
		"accepted_by" = contract.accepted_by || "",
		"status" = contract.GetStatusLabel(),
		"status_tone" = contract.GetStatusTone(),
		"instruction_text" = contract.GetInstructionText(),
		"status_text" = block_reason || contract.GetStatusText(),
		"block_reason" = block_reason || "",
		"action_hint" = contract.GetActionHint() || "",
		"resolved_note" = contract.GetResolvedNote() || "",
		"can_act" = can_act,
		"action_label" = contract.status == "active" ? contract.GetActiveActionLabel() : "Accept"
	)

/datum/computer_file/program/supply/proc/SerializeContracts(status)
	var/list/result = list()
	SSsupply.EnsureVisibleContractOffers()
	for(var/datum/trade_contract/contract as anything in SSsupply.trade_contracts)
		if(contract.status != status)
			continue
		if(status == "available" && !contract.ShouldDisplayAvailable())
			continue
		if(status == "active" && !contract.CanStayActive())
			contract.HandleActiveTargetLoss()
			continue
		var/list/entry = SerializeContractEntry(contract)
		if(islist(entry))
			result.Add(list(entry))
	return result

/datum/computer_file/program/supply/proc/SerializeSelectedOrder()
	if(current_order && !(current_order in SSsupply.order_queue))
		current_order = null
	if(!current_order)
		return null

	var/list/order_data = SSsupply.order_queue[current_order]
	if(!islist(order_data))
		return null

	var/datum/money_account/requestor = order_data["requesting_acct"]
	var/buyer_faction = order_data["buyer_faction"] || FACTION_INDEPENDENT
	var/list/price_snapshot = order_data["price_snapshot"]
	return list(
		"id" = current_order,
		"requestor_name" = requestor ? requestor.owner_name : "Unknown",
		"buyer_faction" = buyer_faction,
		"reason" = order_data["reason"] || "Not provided",
		"cost" = round(order_data["cost"]),
		"fee" = round(order_data["fee"]),
		"total" = round(order_data["cost"] + order_data["fee"]),
		"contents" = SerializeShopListGroups(order_data["contents"], buyer_faction, price_snapshot)
	)

/datum/computer_file/program/supply/proc/SerializeSavedCarts()
	var/list/result = list()
	for(var/i in 1 to length(saved_shopping_lists))
		var/cart_name = saved_shopping_lists[i]
		var/list/cart_data = saved_shopping_lists[cart_name]
		result.Add(list(list(
			"index" = i,
			"name" = cart_name,
			"count" = SSsupply.CollectCountsFrom(cart_data),
			"total" = round(SSsupply.CollectPriceForList(cart_data, faction))
		)))
	return result

/datum/computer_file/program/supply/proc/SerializeLogEntries()
	var/list/result = list()
	var/list/log_collection = GetLogCollection()
	if(!islist(log_collection))
		return result
	for(var/i = length(log_collection) to 1 step -1)
		var/list/log_entry = log_collection[i]
		result.Add(list(list(
			"id" = log_entry["id"],
			"time" = log_entry["time"],
			"ordering_acct" = log_entry["ordering_acct"],
			"total_paid" = round(log_entry["total_paid"])
		)))
	return result

/datum/computer_file/program/supply/proc/BuildTradeUiData(mob/user)
	var/list/data = get_header_data()
	if(!islist(data))
		data = list()

	ValidateSelectedTradeBeacons()

	var/datum/money_account/master_account = GetMasterAccount()
	var/receiving_id = GetBeaconDisplayId(receiving)
	var/sending_id = GetBeaconDisplayId(sending)
	var/datum/trading_station/selected_station = EnsureSelectedStation()
	var/list/stations = SerializeVisibleStations()
	var/list/export_items = SerializeExportItems()
	var/list/cart_groups = SerializeShopListGroups(shopping_list, faction)
	var/list/market_intel = SerializeKnownMarketIntel()
	var/list/orders = SerializeOrders()
	var/list/available_contracts = SerializeContracts("available")
	var/list/active_contracts = SerializeContracts("active")
	var/list/completed_contracts = SerializeContracts("completed")
	var/list/failed_contracts = SerializeContracts("failed")
	var/list/saved_carts = SerializeSavedCarts()
	var/list/log_entries = SerializeLogEntries()
	var/selected_order_data = SerializeSelectedOrder()
	var/cart_trade_block = receiving ? SSsupply.GetShopListTradeRangeBlockReason(receiving, shopping_list) : null
	var/export_block_reason = null
	if(!istype(account))
		export_block_reason = "Link an account before exporting goods."
	else if(!sending_id)
		export_block_reason = "Select a sending beacon first."
	else if(sending && sending.export_cooldown > world.time)
		export_block_reason = "The sending beacon is on cooldown."
	else if(istype(selected_station))
		export_block_reason = SSsupply.GetTradeRangeBlockReason(sending, selected_station)
	else if(!length(export_items))
		export_block_reason = "No exportable objects are inside the sending beacon range."

	data["src"] = ref(src)
	data["screen"] = trade_screen
	data["log_screen"] = log_screen
	data["currency"] = GLOB.using_map.local_currency_name
	data["currency_short"] = GLOB.using_map.local_currency_name_short
	data["faction"] = faction
	data["has_account"] = istype(account)
	data["account_owner_name"] = account ? account.owner_name : ""
	data["account_number"] = account ? account.account_number : 0
	data["account_money"] = account ? round(account.money) : 0
	var/obj/item/card/id/inserted_id = GetInsertedIdCard()
	data["has_inserted_id"] = istype(inserted_id)
	data["can_link_id_account"] = istype(inserted_id) && inserted_id.associated_account_number
	data["inserted_id_account_number"] = inserted_id ? inserted_id.associated_account_number : 0
	data["has_master_budget"] = istype(master_account)
	data["master_budget"] = master_account ? round(master_account.money) : 0
	data["receiving"] = receiving_id || ""
	data["has_receiving"] = !!receiving_id
	data["sending"] = sending_id || ""
	data["has_sending"] = !!sending_id
	data["goods_quantity_target"] = goods_quantity_target || ""
	data["cart_form_mode"] = cart_form_mode || ""
	data["has_printer"] = !!(computer && computer.get_component(PART_PRINTER))
	data["can_approve_orders"] = HasCargoApprovalAccess(user)
	data["can_manage_orders"] = data["can_approve_orders"]
	data["has_visible_stations"] = length(stations) ? TRUE : FALSE
	data["stations"] = stations
	data["has_selected_station"] = istype(selected_station)
	data["selected_category"] = chosen_category || ""
	data["categories"] = SerializeCategories(selected_station)
	data["goods"] = SerializeGoods(selected_station)
	if(istype(selected_station))
		data["selected_station"] = SerializeSelectedStation(selected_station)
		data["selected_station_intel"] = known_market_intel[selected_station.uid]
	data["market_intel"] = market_intel

	data["export_items"] = export_items
	data["export_total"] = 0
	for(var/list/export_item in export_items)
		data["export_total"] += export_item["value"]
	data["can_export"] = !export_block_reason
	data["export_block_reason"] = export_block_reason || ""
	data["export_target_station"] = selected_station ? selected_station.name : ""
	data["has_export_target_station"] = istype(selected_station)

	data["cart_groups"] = cart_groups
	data["cart_total"] = round(SSsupply.CollectPriceForList(shopping_list, faction))
	data["cart_count"] = SSsupply.CollectCountsFrom(shopping_list)
	data["cart_trade_block_reason"] = cart_trade_block || ""
	data["can_purchase_cart"] = istype(account) && !!receiving_id && length(shopping_list) && !cart_trade_block
	data["can_build_order"] = istype(account) && length(shopping_list) && !orders_locked
	data["can_save_cart"] = !!length(shopping_list)
	data["orders_locked"] = orders_locked

	data["order_count"] = length(SSsupply.order_queue)
	data["orders"] = orders
	data["has_selected_order"] = islist(selected_order_data)
	if(islist(selected_order_data))
		data["selected_order"] = selected_order_data

	data["saved_carts"] = saved_carts
	data["available_contracts"] = available_contracts
	data["available_contract_count"] = length(available_contracts)
	data["active_contracts"] = active_contracts
	data["active_contract_count"] = length(active_contracts)
	data["completed_contracts"] = completed_contracts
	data["completed_contract_count"] = length(completed_contracts)
	data["failed_contracts"] = failed_contracts
	data["failed_contract_count"] = length(failed_contracts)
	data["resolved_contract_count"] = length(completed_contracts) + length(failed_contracts)
	data["log_entries"] = log_entries

	return data

/datum/computer_file/program/supply/Topic(href, href_list)
	. = ..()
	if(href_list["close"])
		return TRUE
	if(.)
		return

	ValidateSelectedTradeBeacons()

	if(href_list["PRG_trade_screen"])
		trade_screen = href_list["PRG_trade_screen"]
		if(trade_screen == LOG_SCREEN && !log_screen)
			log_screen = LOG_SHIPPING
		ResetUiForms()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_log_screen"])
		log_screen = href_list["PRG_log_screen"]
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_faction"])
		var/obj/item/stock_parts/computer/card_slot/card_slot = computer.get_component(PART_CARD)
		if(!istype(card_slot))
			to_chat(usr, SPAN_WARNING("Card slot is not installed."))
			ui_interact(usr)
			return TRUE
		var/obj/item/card/id/id_card = card_slot.stored_card
		if(!istype(id_card))
			to_chat(usr, SPAN_WARNING("Insert an ID card first."))
			ui_interact(usr)
			return TRUE
		var/list/valid_factions = list()
		for(var/faction_name in SSsupply.factions)
			var/datum/trade_faction/trade_faction = SSsupply.factions[faction_name]
			if(!trade_faction.access_required || !(trade_faction.access_required in id_card.access))
				continue
			valid_factions += trade_faction.name
		if(!length(valid_factions))
			to_chat(usr, SPAN_WARNING("No eligible trade factions were found for this ID."))
			ui_interact(usr)
			return TRUE
		var/faction_choice = input(usr, "Select a faction to link.", "Faction Link") as null|anything in valid_factions
		if(faction_choice)
			faction = faction_choice
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_faction_unlink"])
		faction = FACTION_INDEPENDENT
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_account"])
		var/obj/item/stock_parts/computer/card_slot/card_slot = computer.get_component(PART_CARD)
		var/default_number = null
		if(istype(card_slot) && card_slot.stored_card)
			default_number = card_slot.stored_card.associated_account_number
		var/account_number = input(usr, "Enter account number.", "Account Link", default_number) as num|null
		if(!account_number)
			ui_interact(usr)
			return TRUE
		var/account_pin = input(usr, "Enter PIN.", "Account Link") as num|null
		if(!account_pin)
			ui_interact(usr)
			return TRUE
		var/card_check = istype(card_slot) && card_slot.stored_card && card_slot.stored_card.associated_account_number == account_number
		var/datum/money_account/linked_account = attempt_account_access(account_number, account_pin, card_check ? 2 : 1, TRUE)
		if(!linked_account)
			to_chat(usr, SPAN_WARNING("Unable to link account: access denied."))
		else
			account = linked_account
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_account_id"])
		var/obj/item/card/id/id_card = GetInsertedIdCard()
		if(!istype(id_card))
			to_chat(usr, SPAN_WARNING("Insert an ID card first."))
			ui_interact(usr)
			return TRUE
		if(!id_card.associated_account_number)
			to_chat(usr, SPAN_WARNING("This ID card is not linked to any bank account."))
			ui_interact(usr)
			return TRUE
		var/account_pin = input(usr, "Enter the PIN for account #[id_card.associated_account_number].", "ID Account Link") as num|null
		if(!account_pin)
			ui_interact(usr)
			return TRUE
		var/datum/money_account/linked_account = attempt_account_access(id_card.associated_account_number, account_pin, 2, TRUE)
		if(!linked_account)
			to_chat(usr, SPAN_WARNING("Unable to link the ID-linked account: access denied."))
		else
			account = linked_account
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_account_unlink"])
		account = null
		current_order = null
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_station"])
		station = SSsupply.GetVisibleStationByUid(href_list["PRG_station"])
		SetChosenCategory()
		CloseGoodsQuantityForm()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_goods_category"])
		SetChosenCategory(href_list["PRG_goods_category"])
		CloseGoodsQuantityForm()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_goods_quantity_target"])
		EnsureSelectedStation()
		OpenGoodsQuantityForm(href_list["PRG_goods_quantity_target"])
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_goods_quantity_cancel"])
		CloseGoodsQuantityForm()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_receiving"])
		var/list/beacons_by_id = GetLocalReceivingBeaconsById()
		if(!length(beacons_by_id))
			to_chat(usr, SPAN_WARNING("No receiving beacons are available on the current vessel."))
			ui_interact(usr)
			return TRUE
		var/chosen_id = input(usr, "Select a receiving beacon.", "Receiving Beacon") as null|anything in beacons_by_id
		if(chosen_id)
			receiving = beacons_by_id[chosen_id]
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_sending"])
		var/list/beacons_by_id = GetLocalSendingBeaconsById()
		if(!length(beacons_by_id))
			to_chat(usr, SPAN_WARNING("No sending beacons are available on the current vessel."))
			ui_interact(usr)
			return TRUE
		var/chosen_id = input(usr, "Select a sending beacon.", "Sending Beacon") as null|anything in beacons_by_id
		if(chosen_id)
			sending = beacons_by_id[chosen_id]
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_cart_add"] || href_list["PRG_cart_add_input"] || href_list["PRG_cart_add_good"] || href_list["PRG_cart_add_form"])
		if(!account)
			to_chat(usr, SPAN_WARNING("Link an account before adding goods to the cart."))
			ui_interact(usr)
			return TRUE
		EnsureSelectedStation()
		if(!istype(station) || !chosen_category)
			ui_interact(usr)
			return TRUE
		var/block_reason = GetStationCatalogBlockReason(station)
		if(block_reason)
			to_chat(usr, SPAN_WARNING(block_reason))
			ui_interact(usr)
			return TRUE

		var/good_ref = href_list["PRG_cart_add_good"] || href_list["PRG_cart_add_form"] || href_list["PRG_cart_add"] || href_list["PRG_cart_add_input"]
		var/count_to_buy = 1
		if(href_list["PRG_cart_add_input"])
			count_to_buy = max(1, round(input(usr, "How many do you want to add?", "Trade", 2) as num|null))
		else if(href_list["PRG_cart_add_form"])
			count_to_buy = max(1, round(text2num(href_list["PRG_cart_add_amount"])))

		if(TryAddToCart(good_ref, count_to_buy))
			CloseGoodsQuantityForm()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_cart_remove_direct"])
		var/datum/trading_station/target_station = SSsupply.GetStationByUid(href_list["PRG_cart_remove_direct"])
		var/target_category = href_list["PRG_cart_category_name"]
		var/target_good_id = href_list["PRG_cart_good_id"]
		if(istype(target_station) && target_category && target_good_id)
			station = target_station
			chosen_category = target_category
			RemoveFromShopList(target_good_id, 1, target_station, target_category)
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_cart_reset"])
		ResetShopList()
		ResetUiForms()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_cart_form"])
		OpenCartForm(href_list["PRG_cart_form"])
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_cart_form_cancel"])
		CloseCartForm()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_cart_save"])
		OpenCartForm("save")
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_cart_save_form"])
		var/name = sanitizeName(href_list["PRG_cart_save_name"], MAX_NAME_LEN)
		SaveShopList(name)
		CloseCartForm()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_cart_load"])
		var/name = input(usr, "Choose a saved cart.", "Load Cart") as null|anything in saved_shopping_lists
		if(name)
			shopping_list = LoadShopList(name)
			trade_screen = CART_SCREEN
			ResetUiForms()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_cart_load_direct"])
		var/name = saved_shopping_lists[text2num(href_list["PRG_cart_load_direct"])]
		if(name in saved_shopping_lists)
			shopping_list = LoadShopList(name)
			trade_screen = CART_SCREEN
			ResetUiForms()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_cart_delete"])
		var/name = saved_shopping_lists[text2num(href_list["PRG_cart_delete"])]
		DeleteShopList(name)
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_receive"])
		if(!account)
			to_chat(usr, SPAN_WARNING("Link an account before purchasing goods."))
			ui_interact(usr)
			return TRUE
		if(!receiving)
			to_chat(usr, SPAN_WARNING("Select a receiving beacon first."))
			ui_interact(usr)
			return TRUE
		if(!length(shopping_list))
			ui_interact(usr)
			return TRUE
		var/cart_range_block = SSsupply.GetShopListTradeRangeBlockReason(receiving, shopping_list)
		if(cart_range_block)
			to_chat(usr, SPAN_WARNING(cart_range_block))
			ui_interact(usr)
			return TRUE
		if(!SSsupply.Buy(receiving, account, shopping_list, FALSE, null, faction))
			to_chat(usr, SPAN_WARNING("Purchase failed. Check account balance, stock, and receiving area."))
		else
			ResetShopList()
			ResetUiForms()
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_contract_accept"])
		if(!account)
			to_chat(usr, SPAN_WARNING("Link an account before accepting contracts."))
			ui_interact(usr)
			return TRUE
		if(!receiving)
			to_chat(usr, SPAN_WARNING("Select a receiving beacon first."))
			ui_interact(usr)
			return TRUE
		var/datum/trade_contract/contract_to_accept = SSsupply.GetTradeContract(href_list["PRG_contract_accept"])
		var/accept_block = GetContractAcceptBlockReason(contract_to_accept)
		if(accept_block)
			to_chat(usr, SPAN_WARNING(accept_block))
			ui_interact(usr)
			return TRUE
		if(!SSsupply.AcceptTradeContract(receiving, account, href_list["PRG_contract_accept"]))
			if(istype(contract_to_accept, /datum/trade_contract/caravan_rendezvous))
				to_chat(usr, SPAN_WARNING("Market-intelligence briefing failed. Check source access and caravan availability."))
			else
				to_chat(usr, SPAN_WARNING("Contract acceptance failed. Check source stock and the receiving area."))
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_contract_deliver"])
		if(!sending)
			to_chat(usr, SPAN_WARNING("Select a sending beacon first."))
			ui_interact(usr)
			return TRUE
		var/datum/trade_contract/contract_to_deliver = SSsupply.GetTradeContract(href_list["PRG_contract_deliver"])
		var/deliver_block = GetContractDeliverBlockReason(contract_to_deliver)
		if(deliver_block)
			to_chat(usr, SPAN_WARNING(deliver_block))
			ui_interact(usr)
			return TRUE
		if(!SSsupply.DeliverTradeContract(sending, href_list["PRG_contract_deliver"]))
			if(istype(contract_to_deliver, /datum/trade_contract/caravan_rendezvous))
				to_chat(usr, SPAN_WARNING("Market-intelligence transmission failed. The caravan may have moved out of range or the beacon may be on cooldown."))
			else
				to_chat(usr, SPAN_WARNING("Contract delivery failed. The crate may be missing or the beacon may be on cooldown."))
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_export"])
		if(!account)
			to_chat(usr, SPAN_WARNING("Link an account before exporting goods."))
			ui_interact(usr)
			return TRUE
		if(!sending)
			to_chat(usr, SPAN_WARNING("Select a sending beacon first."))
			ui_interact(usr)
			return TRUE
		if(!length(SerializeExportItems()))
			to_chat(usr, SPAN_WARNING("No exportable objects were found near the sending beacon."))
			ui_interact(usr)
			return TRUE
		if(!SSsupply.Export(sending, account, EnsureSelectedStation()))
			to_chat(usr, SPAN_WARNING("Export failed. The beacon may still be on cooldown."))
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_build_order"])
		OpenCartForm("order")
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_build_order_form"])
		CloseCartForm()
		if(orders_locked)
			to_chat(usr, SPAN_WARNING("Wait a few seconds before submitting another order."))
			ui_interact(usr)
			return TRUE
		if(!account)
			to_chat(usr, SPAN_WARNING("Link an account before building an order."))
			ui_interact(usr)
			return TRUE
		if(!length(shopping_list))
			ui_interact(usr)
			return TRUE
		var/reason = sanitize(href_list["PRG_order_reason"], MAX_MESSAGE_LEN)
		current_order = SSsupply.BuildOrder(account, reason, shopping_list, faction)
		if(current_order)
			ResetShopList()
			ResetUiForms()
			trade_screen = ORDER_SCREEN
			orders_locked = TRUE
			addtimer(new Callback(src, .proc/UnlockOrdering), 10 SECONDS, TIMER_STOPPABLE)
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_view_order"])
		current_order = href_list["PRG_view_order"]
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_remove_order"])
		if(!HasCargoApprovalAccess(usr))
			to_chat(usr, SPAN_WARNING("Cargo approval access is required to remove orders."))
			ui_interact(usr)
			return TRUE
		var/order_id = href_list["PRG_remove_order"]
		if(order_id in SSsupply.order_queue)
			SSsupply.order_queue.Remove(order_id)
			if(current_order == order_id)
				current_order = null
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_save_order"])
		var/order_id = href_list["PRG_save_order"]
		if(order_id in SSsupply.order_queue)
			var/name = sanitizeName(input(usr, "Optional cart name.", "Save Order", ""), MAX_NAME_LEN)
			var/list/order_data = SSsupply.order_queue[order_id]
			SaveShopList(name, order_data["contents"])
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_approve_order"])
		if(!HasCargoApprovalAccess(usr))
			to_chat(usr, SPAN_WARNING("Cargo approval access is required to approve orders."))
			ui_interact(usr)
			return TRUE
		if(!receiving)
			to_chat(usr, SPAN_WARNING("Select a receiving beacon first."))
			ui_interact(usr)
			return TRUE
		var/order_id = href_list["PRG_approve_order"]
		if(order_id in SSsupply.order_queue)
			var/list/order_data = SSsupply.order_queue[order_id]
			var/order_range_block = SSsupply.GetShopListTradeRangeBlockReason(receiving, order_data["contents"])
			if(order_range_block)
				to_chat(usr, SPAN_WARNING(order_range_block))
				ui_interact(usr)
				return TRUE
		if(!SSsupply.PurchaseOrder(receiving, order_id))
			to_chat(usr, SPAN_WARNING("Order approval failed. Check department and requestor balances."))
		else
			SSsupply.order_queue.Remove(order_id)
			if(current_order == order_id)
				current_order = null
		ui_interact(usr)
		return TRUE

	if(href_list["PRG_print"] || href_list["PRG_print_internal"])
		if(!computer.get_component(PART_PRINTER))
			to_chat(usr, SPAN_WARNING("No printer is installed in this computer."))
			ui_interact(usr)
			return TRUE
		var/log_id = href_list["PRG_print"] || href_list["PRG_print_internal"]
		var/list/log_data = SSsupply.GetLogDataById(log_id)
		if(!length(log_data))
			to_chat(usr, SPAN_WARNING("Invoice #[log_id] was not found."))
			ui_interact(usr)
			return TRUE
		var/list/id_data = splittext(log_id, "-")
		var/log_type = LOG_SHIPPING
		switch(id_data.len >= 2 ? id_data[2] : null)
			if("E")
				log_type = LOG_EXPORT
			if("O")
				log_type = LOG_ORDER
			if("C")
				log_type = LOG_CONTRACT
		var/title = "[lowertext(log_type)] invoice - #[log_id]"
		if(href_list["PRG_print_internal"])
			title += " (internal)"
		var/text = ""
		text += "<h3>[log_type] Invoice - #[log_id]</h3><hr><font size='2'>"
		if(href_list["PRG_print_internal"])
			text += "FOR INTERNAL USE ONLY<br><br>"
		text += "Recipient: [log_data["ordering_acct"]]<br>"
		text += "Contents:<br><ul>[log_data["contents"]]</ul>"
		text += "Total Credits Paid: [log_data["total_paid"]]<br>"
		text += "</font>"
		computer.print_paper(text, title)
		ui_interact(usr)
		return TRUE

	ui_interact(usr)
	return TRUE

/datum/computer_file/program/supply/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	. = ..()
	if(!.)
		return

	var/list/data = BuildTradeUiData(user)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-cargo_trade_network.tmpl", "Trade Network", 1050, 800, state = GLOB.default_state)
		ui.set_initial_data(data)
		ui.open()

#undef SETTINGS_SCREEN
#undef GOODS_SCREEN
#undef EXPORT_SCREEN
#undef CART_SCREEN
#undef ORDER_SCREEN
#undef CONTRACT_SCREEN
#undef SAVED_SCREEN
#undef LOG_SCREEN
#undef LOG_SHIPPING
#undef LOG_EXPORT
#undef LOG_ORDER
#undef LOG_CONTRACT
