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
	parent_type = /datum/computer_file/program/supply_base
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
	required_access = list(access_cargo, access_qm, access_bridge)

	var/trade_screen = GOODS_SCREEN
	var/log_screen = LOG_SHIPPING
	var/account_linked_from_card = FALSE

	var/obj/machinery/trade_beacon/sending/sending
	var/obj/machinery/trade_beacon/receiving/receiving

	var/list/known_market_intel = list()
	var/save_order_id

/datum/computer_file/program/supply/proc/ValidateLinkedAccount()
	if(!account)
		return FALSE
	if(account_linked_from_card)
		var/obj/item/card/id/id_card = GetInsertedIdCard()
		if(!istype(id_card) || id_card.associated_account_number != account.account_number)
			account = null
			account_linked_from_card = FALSE
			return FALSE
	return TRUE

/datum/computer_file/program/supply/can_run(mob/living/user, loud = FALSE, access_to_check)
	if(!requires_access_to_run)
		return TRUE
	if(!access_to_check)
		access_to_check = required_access
	if(!access_to_check)
		return TRUE
	if(isghost(user) && check_rights(R_ADMIN, 0, user))
		return TRUE
	if(!istype(user))
		return FALSE
	var/obj/item/card/id/I = user.GetIdCard()
	if(!I)
		if(loud)
			to_chat(user, SPAN_NOTICE("\The [computer] flashes an \"RFID Error - Unable to scan ID\" warning."))
		return FALSE
	if(islist(access_to_check))
		for(var/acc in access_to_check)
			if(acc in I.access)
				return TRUE
	else if(access_to_check in I.access)
		return TRUE
	if(loud)
		to_chat(user, SPAN_NOTICE("\The [computer] flashes an \"Access Denied\" warning."))
	return FALSE

/datum/computer_file/program/supply/Destroy()
	sending = null
	receiving = null
	save_order_id = null
	if(known_market_intel)
		for(var/station_uid in known_market_intel)
			var/list/intel = known_market_intel[station_uid]
			if(islist(intel))
				var/list/quotes = intel["quotes"]
				if(islist(quotes))
					quotes.Cut()
				intel.Cut()
		known_market_intel.Cut()
		known_market_intel = null
	return ..()

/datum/computer_file/program/supply/process_tick()
	..()
	if(length(SSsupply.order_queue))
		ui_header = "supply_new_order.gif"
	else if(length(shopping_list))
		ui_header = "supply_awaiting_delivery.gif"
	else
		ui_header = "supply_idle.gif"

/datum/computer_file/program/supply/OnStationSelected(datum/trading_station/target_station)
	RememberMarketIntel(target_station)

/datum/computer_file/program/supply/RequiresReceivingBeaconForStatus()
	return TRUE

/datum/computer_file/program/supply/HasLocalReceivingBeacon()
	return length(GetLocalReceivingBeaconsById()) > 0

/datum/computer_file/program/supply/proc/GetMasterAccount()
	return get_supply_department_account()

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

/datum/computer_file/program/supply/proc/GetBeaconDisplayId(obj/machinery/trade_beacon/beacon)
	if(istype(beacon) && !QDELETED(beacon) && beacon.loc)
		return beacon.GetId()
	return null

/datum/computer_file/program/supply/proc/IsReceivingSelected()
	return !!GetBeaconDisplayId(receiving)

/datum/computer_file/program/supply/proc/IsSendingSelected()
	return !!GetBeaconDisplayId(sending)

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

/datum/computer_file/program/supply/proc/SerializeLocalBeacons(beacon_type)
	var/list/result = list()
	var/list/beacons_by_id = (beacon_type == "receiving") ? GetLocalReceivingBeaconsById() : GetLocalSendingBeaconsById()
	for(var/beacon_id in beacons_by_id)
		result.Add(list(list("id" = beacon_id)))
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

/datum/computer_file/program/supply/proc/SerializeCrateExportItem(obj/structure/closet/crate, datum/trading_station/target_station, list/sold_counts, list/seen_strains = null)
	var/list/breakdown = SSsupply.GetCrateExportBreakdown(crate, target_station, faction, sold_counts, seen_strains)
	return list(
		"name" = breakdown["display_name"],
		"amount" = 1,
		"unit_value" = breakdown["total_value"],
		"value" = breakdown["total_value"],
		"target_station" = target_station ? target_station.name : "Trade Network",
		"sub_items" = breakdown["sub_items"]
	)

/datum/computer_file/program/supply/proc/SerializeExportItems()
	var/list/result = list()
	if(!IsSendingSelected())
		return result
	var/datum/trading_station/target_station = EnsureSelectedStation()
	var/list/grouped = list()
	var/list/sold_counts = list()
	var/list/seen_strains = list()
	for(var/atom/movable/exported as anything in sending.GetObjects())
		if(istype(exported, /obj/structure/closet/crate/trade_contract))
			continue
		if(!SSsupply.CanExportAtom(exported))
			continue
		if(istype(exported, /obj/structure/closet) && istype(target_station))
			result.Add(list(SerializeCrateExportItem(exported, target_station, sold_counts, seen_strains)))
			continue
		var/cost = SSsupply.GetExportValue(exported, target_station, faction, sold_counts, seen_strains)
		if(!cost)
			continue
		var/item_name = exported.name
		var/item_amount = 1
		if(isstack(exported))
			var/obj/item/stack/S = exported
			item_amount = S.get_amount()
		if(!grouped[item_name])
			grouped[item_name] = list(
				"name" = item_name,
				"amount" = item_amount,
				"unit_value" = round(cost / item_amount, 0.01),
				"value" = round(cost, 0.01),
				"target_station" = target_station ? target_station.name : "Trade Network"
			)
		else
			var/list/entry = grouped[item_name]
			entry["amount"] += item_amount
			entry["value"] = round(entry["value"] + cost, 0.01)
			entry["unit_value"] = round(entry["value"] / entry["amount"], 0.01)

	for(var/item_name in grouped)
		result.Add(list(grouped[item_name]))
	return result

/datum/computer_file/program/supply/proc/SerializeOrders()
	var/list/result = list()
	var/total_serialized = 0
	for(var/order_id as anything in SSsupply.order_queue)
		if(total_serialized >= 50)
			break
		var/list/order_data = SSsupply.order_queue[order_id]
		if(!islist(order_data))
			continue
		var/datum/money_account/requestor = order_data["requesting_acct"]
		var/buyer_faction = order_data["buyer_faction"] || FACTION_INDEPENDENT
		var/list/price_snapshot = order_data["price_snapshot"]
		result.Add(list(list(
			"id" = order_id,
			"requestor_name" = requestor ? requestor.owner_name : "Unknown",
			"buyer_faction" = buyer_faction,
			"reason" = order_data["reason"] || "No reason provided.",
			"cost" = round(order_data["cost"], 0.01),
			"fee" = round(order_data["fee"], 0.01),
			"total" = round(order_data["cost"] + order_data["fee"], 0.01),
			"selected" = current_order == order_id,
			"item_count" = SSsupply.CollectCountsFrom(order_data["contents"]),
			"contents" = SerializeShopListGroups(order_data["contents"], buyer_faction, price_snapshot)
		)))
		total_serialized++
	return result

/datum/computer_file/program/supply/proc/GetContractAcceptBlockReason(datum/trade_contract/contract)
	if(!istype(contract))
		return "Contract data is unavailable."
	if(!account)
		return "Link an account before accepting contracts."
	return contract.GetAcceptBlockReason(receiving, account, faction)

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
		if(CONTRACT_STATUS_AVAILABLE)
			block_reason = GetContractAcceptBlockReason(contract)
		if(CONTRACT_STATUS_ACTIVE)
			block_reason = GetContractDeliverBlockReason(contract)
		if(CONTRACT_STATUS_FAILED)
			block_reason = contract.failure_reason || "Contract failed."
	var/can_act = contract.status == CONTRACT_STATUS_AVAILABLE || contract.status == CONTRACT_STATUS_ACTIVE
	can_act = can_act && !block_reason
	return list(
		"id" = contract.id,
		"serial" = contract.contract_serial || "",
		"type_label" = contract.GetTypeLabel(),
		"source_name" = source_station ? source_station.name : "Unknown",
		"destination_name" = destination_station ? destination_station.name : "Unknown",
		"cargo" = contract.GetDisplayCargoText(),
		"reward" = round(contract.reward, 0.01),
		"deposit" = round(contract.deposit, 0.01),
		"penalty" = round(contract.penalty, 0.01),
		"distance" = round(contract.distance, 0.01),
		"base_value" = round(contract.base_value, 0.01),
		"accepted_by" = contract.accepted_by || "",
		"status" = contract.GetStatusLabel(),
		"status_tone" = contract.GetStatusTone(),
		"instruction_text" = contract.GetInstructionText(),
		"status_text" = block_reason || contract.GetStatusText(),
		"block_reason" = block_reason || "",
		"action_hint" = contract.GetActionHint() || "",
		"resolved_note" = contract.GetResolvedNote() || "",
		"can_act" = can_act,
		"action_label" = contract.status == CONTRACT_STATUS_ACTIVE ? contract.GetActiveActionLabel() : "Accept"
	)

/datum/computer_file/program/supply/proc/SerializeContracts(status)
	var/list/result = list()
	for(var/datum/trade_contract/contract as anything in SSsupply.trade_contracts)
		if(contract.status != status)
			continue
		if(status == CONTRACT_STATUS_AVAILABLE && !contract.ShouldDisplayAvailable())
			continue
		if(status == CONTRACT_STATUS_ACTIVE && !contract.CanStayActive())
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
		"cost" = round(order_data["cost"], 0.01),
		"fee" = round(order_data["fee"], 0.01),
		"total" = round(order_data["cost"] + order_data["fee"], 0.01),
		"contents" = SerializeShopListGroups(order_data["contents"], buyer_faction, price_snapshot)
	)

/datum/computer_file/program/supply/proc/SerializeLogEntries()
	var/list/result = list()
	var/list/log_collection = GetLogCollection()
	if(!islist(log_collection))
		return result
	for(var/i in length(log_collection) to 1 step -1)
		var/list/log_entry = log_collection[i]
		result.Add(list(list(
			"id" = log_entry["id"],
			"time" = log_entry["time"],
			"ordering_acct" = log_entry["ordering_acct"],
			"total_paid" = round(log_entry["total_paid"], 0.01)
		)))
	return result

/datum/computer_file/program/supply/proc/GetActiveContractCount()
	var/count = 0
	for(var/datum/trade_contract/contract as anything in SSsupply.trade_contracts)
		if(contract.status == CONTRACT_STATUS_ACTIVE && contract.CanStayActive())
			count++
	return count

/datum/computer_file/program/supply/proc/PopulateBaseTradeUiData(list/data, mob/user = null)
	var/receiving_id = GetBeaconDisplayId(receiving)
	var/sending_id = GetBeaconDisplayId(sending)
	data["src"] = ref(src)
	data["screen"] = trade_screen
	data["log_screen"] = log_screen
	data["currency"] = GLOB.using_map.local_currency_name
	data["currency_short"] = GLOB.using_map.local_currency_name_short
	data["faction"] = faction
	data["has_account"] = istype(account)
	data["account_owner_name"] = account ? account.owner_name : ""
	data["account_number"] = account ? account.account_number : 0
	data["account_money"] = account ? round(account.money, 0.01) : 0
	data["receiving"] = receiving_id || ""
	data["has_receiving"] = !!receiving_id
	data["sending"] = sending_id || ""
	data["has_sending"] = !!sending_id
	data["goods_quantity_target"] = goods_quantity_target || ""
	data["cart_form_mode"] = cart_form_mode || ""
	data["cart_count"] = SSsupply.CollectCountsFrom(shopping_list)
	var/cart_total = SSsupply.CollectPriceForList(shopping_list, faction)
	data["cart_total"] = round(cart_total, 0.01)
	data["cart_fee"] = round(cart_total * SSsupply.handling_fee, 0.01)
	var/cart_range_block = receiving ? SSsupply.GetShopListTradeRangeBlockReason(receiving, shopping_list) : null
	data["cart_trade_block_reason"] = cart_range_block || ""
	var/orders_locked = (world.time < order_cooldown_until)
	data["orders_locked"] = orders_locked
	data["can_purchase_cart"] = istype(account) && !!receiving_id && length(shopping_list) && !cart_range_block
	data["can_build_order"] = istype(account) && length(shopping_list) && !orders_locked
	data["order_count"] = length(SSsupply.order_queue)
	var/pending_total = 0
	for(var/order_id as anything in SSsupply.order_queue)
		var/list/order_entry = SSsupply.order_queue[order_id]
		if(islist(order_entry))
			pending_total += (order_entry["cost"] + order_entry["fee"])
	data["pending_orders_total"] = round(pending_total, 0.01)
	var/cooldown_sec = (sending && sending.export_cooldown > world.time) ? round((sending.export_cooldown - world.time) / 10) : 0
	data["export_cooldown_remaining"] = cooldown_sec
	data["export_cooldown_text"] = cooldown_sec ? "[cooldown_sec]s" : "Ready"
	var/user_greeting = ""
	if(istype(user))
		var/obj/item/card/id/I = user.GetIdCard()
		if(istype(I))
			user_greeting = "WELCOME, [uppertext(I.registered_name)], [uppertext(I.assignment)]"
			if(I.military_branch)
				user_greeting += " ([uppertext(I.military_branch)])"
		else
			user_greeting = "WELCOME, [uppertext(user.name)]"
	data["user_greeting"] = user_greeting
	data["available_receiving_beacons"] = SerializeLocalBeacons("receiving")
	data["available_sending_beacons"] = SerializeLocalBeacons("sending")
	data["save_order_id"] = save_order_id

/datum/computer_file/program/supply/proc/BuildSettingsScreenData(list/data)
	var/datum/money_account/master_account = GetMasterAccount()
	data["has_master_budget"] = istype(master_account)
	data["master_budget"] = master_account ? round(master_account.money, 0.01) : 0
	var/obj/item/card/id/inserted_id = GetInsertedIdCard()
	data["has_inserted_id"] = istype(inserted_id)
	data["can_link_id_account"] = istype(inserted_id) && inserted_id.associated_account_number
	data["inserted_id_account_number"] = inserted_id ? inserted_id.associated_account_number : 0

/datum/computer_file/program/supply/proc/BuildGoodsScreenData(list/data, mob/user = null)
	var/datum/trading_station/selected_station = EnsureSelectedStation()
	var/list/stations = SerializeVisibleStations()
	data["has_visible_stations"] = length(stations) ? TRUE : FALSE
	data["stations"] = stations
	data["has_selected_station"] = istype(selected_station)
	data["selected_category"] = chosen_category || ""
	if(istype(selected_station))
		data["selected_station"] = SerializeSelectedStation(selected_station)
		data["selected_station_intel"] = known_market_intel[selected_station.uid]
		var/block_reason = GetStationTradeBlockReason(selected_station)
		if(!block_reason)
			data["categories"] = SerializeCategories(selected_station)
			data["goods"] = SerializeGoods(selected_station, user)
		else
			data["categories"] = list()
			data["goods"] = list()
	else
		data["categories"] = list()
		data["goods"] = list()
	data["market_intel"] = SerializeKnownMarketIntel()

/datum/computer_file/program/supply/proc/BuildExportScreenData(list/data)
	var/datum/trading_station/selected_station = EnsureSelectedStation()
	var/list/export_items = SerializeExportItems()
	var/export_block_reason = null
	if(!istype(account))
		export_block_reason = "Link an account before exporting goods."
	else if(!GetBeaconDisplayId(sending))
		export_block_reason = "Select a sending beacon first."
	else if(sending && sending.export_cooldown > world.time)
		export_block_reason = "The sending beacon is on cooldown."
	else if(istype(selected_station))
		export_block_reason = SSsupply.GetTradeRangeBlockReason(sending, selected_station)
	else if(!length(export_items))
		export_block_reason = "No exportable objects are inside the sending beacon range."

	data["export_items"] = export_items
	var/export_total = 0
	for(var/list/export_item as anything in export_items)
		export_total += export_item["value"]
	data["export_total"] = round(export_total, 0.01)
	data["can_export"] = !export_block_reason
	data["export_block_reason"] = export_block_reason || ""
	data["export_target_station"] = selected_station ? selected_station.name : ""
	data["has_export_target_station"] = istype(selected_station)

/datum/computer_file/program/supply/proc/BuildCartScreenData(list/data)
	var/receiving_id = GetBeaconDisplayId(receiving)
	var/cart_trade_block = receiving ? SSsupply.GetShopListTradeRangeBlockReason(receiving, shopping_list) : null
	var/orders_locked = (world.time < order_cooldown_until)
	data["cart_groups"] = SerializeShopListGroups(shopping_list, faction)
	data["cart_trade_block_reason"] = cart_trade_block || ""
	data["can_purchase_cart"] = istype(account) && !!receiving_id && length(shopping_list) && !cart_trade_block
	data["can_build_order"] = istype(account) && length(shopping_list) && !orders_locked
	data["can_save_cart"] = !!length(shopping_list)
	data["saved_carts"] = SerializeSavedCarts()
	data["orders_locked"] = orders_locked

/datum/computer_file/program/supply/proc/BuildOrdersScreenData(list/data, mob/user)
	var/selected_order_data = SerializeSelectedOrder()
	data["can_approve_orders"] = HasCargoApprovalAccess(user)
	data["can_manage_orders"] = data["can_approve_orders"]
	data["orders"] = SerializeOrders()
	data["has_selected_order"] = islist(selected_order_data)
	if(islist(selected_order_data))
		data["selected_order"] = selected_order_data

/datum/computer_file/program/supply/proc/BuildContractsScreenData(list/data)
	SSsupply.EnsureVisibleContractOffers()
	var/list/available_contracts = SerializeContracts(CONTRACT_STATUS_AVAILABLE)
	var/list/active_contracts = SerializeContracts(CONTRACT_STATUS_ACTIVE)
	var/list/completed_contracts = SerializeContracts(CONTRACT_STATUS_COMPLETED)
	var/list/failed_contracts = SerializeContracts(CONTRACT_STATUS_FAILED)
	data["available_contracts"] = available_contracts
	data["available_contract_count"] = length(available_contracts)
	data["active_contracts"] = active_contracts
	data["active_contract_count"] = length(active_contracts)
	data["completed_contracts"] = completed_contracts
	data["completed_contract_count"] = length(completed_contracts)
	data["failed_contracts"] = failed_contracts
	data["failed_contract_count"] = length(failed_contracts)
	data["resolved_contract_count"] = length(completed_contracts) + length(failed_contracts)

/datum/computer_file/program/supply/proc/BuildSavedScreenData(list/data)
	data["saved_carts"] = SerializeSavedCarts()

/datum/computer_file/program/supply/proc/BuildLogsScreenData(list/data)
	data["has_printer"] = !!(computer?.get_component(PART_PRINTER))
	data["log_entries"] = SerializeLogEntries()

/datum/computer_file/program/supply/proc/BuildTradeUiData(mob/user)
	var/list/data = get_header_data() || list()
	ValidateSelectedTradeBeacons()
	PopulateBaseTradeUiData(data, user)
	switch(trade_screen)
		if(SETTINGS_SCREEN)
			BuildSettingsScreenData(data)
		if(GOODS_SCREEN)
			BuildGoodsScreenData(data, user)
		if(EXPORT_SCREEN)
			BuildExportScreenData(data)
		if(CART_SCREEN)
			BuildCartScreenData(data)
		if(ORDER_SCREEN)
			BuildOrdersScreenData(data, user)
		if(CONTRACT_SCREEN)
			BuildContractsScreenData(data)
		if(SAVED_SCREEN)
			BuildSavedScreenData(data)
		if(LOG_SCREEN)
			BuildLogsScreenData(data)
	if(trade_screen != CONTRACT_SCREEN)
		data["active_contract_count"] = GetActiveContractCount()
	return data

/datum/computer_file/program/supply/proc/HandleScreenTopic(list/href_list)
	if("PRG_trade_screen" in href_list)
		trade_screen = href_list["PRG_trade_screen"]
		if(trade_screen == LOG_SCREEN && !log_screen)
			log_screen = LOG_SHIPPING
		ResetUiForms()
		return TRUE
	if("PRG_log_screen" in href_list)
		log_screen = href_list["PRG_log_screen"]
		return TRUE
	return FALSE

/datum/computer_file/program/supply/proc/PromptLinkAccount(list/href_list)
	if(!can_run(usr, TRUE))
		return TRUE
	var/account_number = text2num(href_list["PRG_link_account_number"])
	var/account_pin = text2num(href_list["PRG_link_account_pin"])
	if(!isnum(account_number) || !isnum(account_pin))
		OpenCartForm("link_account")
		return TRUE
	if(!account_number || !account_pin)
		to_chat(usr, SPAN_WARNING("Account number and PIN are required."))
		return TRUE
	var/obj/item/stock_parts/computer/card_slot/card_slot = computer?.get_component(PART_CARD)
	var/card_check = istype(card_slot) && card_slot.stored_card && card_slot.stored_card.associated_account_number == account_number
	var/datum/money_account/linked_account = attempt_account_access(account_number, account_pin, card_check ? 2 : 1, TRUE)
	if(!linked_account)
		to_chat(usr, SPAN_WARNING("Unable to link account: access denied."))
	else
		account = linked_account
		account_linked_from_card = FALSE
	CloseCartForm()
	return TRUE

/datum/computer_file/program/supply/proc/LinkInsertedIdAccount(list/href_list)
	if(!can_run(usr, TRUE))
		return TRUE
	var/obj/item/card/id/id_card = GetInsertedIdCard()
	if(!istype(id_card))
		to_chat(usr, SPAN_WARNING("Insert an ID card first."))
		return TRUE
	if(!id_card.associated_account_number)
		to_chat(usr, SPAN_WARNING("This ID card is not linked to any bank account."))
		return TRUE
	var/account_pin = text2num(href_list["PRG_link_id_pin"])
	if(!isnum(account_pin) || !account_pin)
		OpenCartForm("link_id_account")
		return TRUE
	var/datum/money_account/linked_account = attempt_account_access(id_card.associated_account_number, account_pin, 2, TRUE)
	if(!linked_account)
		to_chat(usr, SPAN_WARNING("Unable to link the ID-linked account: access denied."))
	else
		account = linked_account
		account_linked_from_card = TRUE
	CloseCartForm()
	return TRUE

/datum/computer_file/program/supply/proc/HandleAccountTopic(list/href_list)
	if(("PRG_account" in href_list) || ("PRG_link_account_number" in href_list))
		return PromptLinkAccount(href_list)
	if(("PRG_account_id" in href_list) || ("PRG_link_id_pin" in href_list))
		return LinkInsertedIdAccount(href_list)
	if("PRG_account_unlink" in href_list)
		account = null
		account_linked_from_card = FALSE
		current_order = null
		return TRUE
	return FALSE

/datum/computer_file/program/supply/proc/HandleCatalogTopic(list/href_list)
	var/station_id = href_list["PRG_station"] || href_list["amp;PRG_station"]
	if(station_id)
		var/datum/trading_station/target_station = SSsupply.GetVisibleStationByUid(station_id)
		if(istype(target_station) && !GetStationTradeBlockReason(target_station, faction))
			station = target_station
			SetChosenCategory()
			CloseGoodsQuantityForm()
		return TRUE
	if("PRG_goods_category" in href_list)
		SetChosenCategory(href_list["PRG_goods_category"])
		CloseGoodsQuantityForm()
		return TRUE
	if("PRG_goods_quantity_target" in href_list)
		EnsureSelectedStation()
		OpenGoodsQuantityForm(href_list["PRG_goods_quantity_target"])
		return TRUE
	if("PRG_goods_quantity_cancel" in href_list)
		CloseGoodsQuantityForm()
		return TRUE
	return FALSE

/datum/computer_file/program/supply/proc/SelectReceivingBeacon(list/href_list)
	if(!("PRG_beacon_id" in href_list))
		OpenCartForm("select_receiving")
		return TRUE
	var/chosen_id = href_list["PRG_beacon_id"]
	var/list/beacons_by_id = GetLocalReceivingBeaconsById()
	if(chosen_id in beacons_by_id)
		receiving = beacons_by_id[chosen_id]
	else if(chosen_id == "none")
		receiving = null
	CloseCartForm()
	return TRUE

/datum/computer_file/program/supply/proc/SelectSendingBeacon(list/href_list)
	if(!("PRG_beacon_id" in href_list))
		OpenCartForm("select_sending")
		return TRUE
	var/chosen_id = href_list["PRG_beacon_id"]
	var/list/beacons_by_id = GetLocalSendingBeaconsById()
	if(chosen_id in beacons_by_id)
		sending = beacons_by_id[chosen_id]
	else if(chosen_id == "none")
		sending = null
	CloseCartForm()
	return TRUE

/datum/computer_file/program/supply/proc/HandleBeaconTopic(list/href_list)
	if(("PRG_receiving" in href_list) || (cart_form_mode == "select_receiving" && ("PRG_beacon_id" in href_list)))
		return SelectReceivingBeacon(href_list)
	if(("PRG_sending" in href_list) || (cart_form_mode == "select_sending" && ("PRG_beacon_id" in href_list)))
		return SelectSendingBeacon(href_list)
	return FALSE

/datum/computer_file/program/supply/proc/ResolveCartAddQuantity(list/href_list)
	if("PRG_cart_add_amount" in href_list)
		var/amount = text2num(href_list["PRG_cart_add_amount"])
		return (isnum(amount) && amount > 0) ? round(amount) : 0
	if("PRG_cart_add_form" in href_list)
		var/form_amount = text2num(href_list["PRG_cart_add_amount"])
		return (isnum(form_amount) && form_amount > 0) ? round(form_amount) : 0
	return 1

/datum/computer_file/program/supply/proc/HandleCartAdd(list/href_list)
	if(!account)
		to_chat(usr, SPAN_WARNING("Link an account before adding goods to the cart."))
		return TRUE
	EnsureSelectedStation()
	if(!istype(station) || !chosen_category)
		return TRUE
	var/block_reason = GetStationCatalogBlockReason(station)
	if(block_reason)
		to_chat(usr, SPAN_WARNING(block_reason))
		return TRUE
	var/good_ref = null
	if("PRG_cart_add_good" in href_list)
		good_ref = href_list["PRG_cart_add_good"]
	else if("PRG_cart_add_form" in href_list)
		good_ref = href_list["PRG_cart_add_form"]
	else if("PRG_cart_add" in href_list)
		good_ref = href_list["PRG_cart_add"]
	var/count_to_buy = ResolveCartAddQuantity(href_list)
	if(count_to_buy > 0 && TryAddToCart(good_ref, count_to_buy))
		CloseGoodsQuantityForm()
	return TRUE

/datum/computer_file/program/supply/LoadSavedCartDirect(raw_index)
	. = ..()
	if(.)
		trade_screen = CART_SCREEN
		ResetUiForms()

/datum/computer_file/program/supply/proc/HandleSavedCartTopic(list/href_list)
	if("PRG_cart_save" in href_list)
		OpenCartForm("save")
		return TRUE
	if("PRG_cart_save_form" in href_list)
		var/name = sanitizeName(href_list["PRG_cart_save_name"], MAX_NAME_LEN)
		SaveShopList(name)
		CloseCartForm()
		return TRUE
	if("PRG_cart_load" in href_list)
		trade_screen = SAVED_SCREEN
		ResetUiForms()
		return TRUE
	if("PRG_cart_load_direct" in href_list)
		return LoadSavedCartDirect(href_list["PRG_cart_load_direct"])
	if("PRG_cart_delete" in href_list)
		return DeleteSavedCartDirect(href_list["PRG_cart_delete"])
	return FALSE

/datum/computer_file/program/supply/proc/HandleCartTopic(list/href_list)
	if(("PRG_cart_add" in href_list) || ("PRG_cart_add_good" in href_list) || ("PRG_cart_add_form" in href_list))
		return HandleCartAdd(href_list)
	if("PRG_cart_remove_good" in href_list)
		if(istype(station) && chosen_category)
			var/good_id = ResolveGoodId(chosen_category, href_list["PRG_cart_remove_good"])
			if(good_id)
				RemoveFromShopList(good_id, 1, station, chosen_category)
		return TRUE
	if("PRG_cart_set_form" in href_list)
		if(!istype(station) || !chosen_category)
			return TRUE
		var/good_id = ResolveGoodId(chosen_category, href_list["PRG_cart_set_form"])
		if(!good_id)
			return TRUE
		var/set_amount = text2num(href_list["PRG_cart_set_amount"])
		if(isnum(set_amount) && set_amount >= 0)
			var/stock = station.GetGoodAmount(chosen_category, good_id)
			var/current_in_cart = 0
			var/station_key = GetStationKey(station)
			var/list/station_cart = islist(shopping_list[station_key]) ? shopping_list[station_key] : shopping_list[station]
			if(islist(station_cart))
				if(isnum(station_cart[good_id]))
					current_in_cart = station_cart[good_id]
				else if(islist(station_cart[chosen_category]))
					var/list/category_cart = station_cart[chosen_category]
					current_in_cart = category_cart[good_id] || 0
			var/clamped = min(stock, round(set_amount))
			if(clamped > current_in_cart)
				AddToShopList(good_id, clamped - current_in_cart, stock)
			else if(clamped < current_in_cart)
				RemoveFromShopList(good_id, current_in_cart - clamped, station, chosen_category)
			CloseGoodsQuantityForm()
		return TRUE
	if("PRG_cart_remove_direct" in href_list)
		return HandleCartRemove(href_list)
	if("PRG_cart_reset" in href_list)
		ResetShopList()
		ResetUiForms()
		return TRUE
	if("PRG_cart_form" in href_list)
		OpenCartForm(href_list["PRG_cart_form"])
		return TRUE
	if("PRG_cart_form_cancel" in href_list)
		CloseCartForm()
		return TRUE
	if(("PRG_cart_save" in href_list) || ("PRG_cart_save_form" in href_list) || ("PRG_cart_load" in href_list) || ("PRG_cart_load_direct" in href_list) || ("PRG_cart_delete" in href_list))
		return HandleSavedCartTopic(href_list)
	return FALSE

/datum/computer_file/program/supply/proc/PurchaseCart()
	if(!can_run(usr, TRUE))
		return TRUE
	if(!ValidateLinkedAccount())
		to_chat(usr, SPAN_WARNING("Link an account before purchasing goods."))
		return TRUE
	if(!receiving)
		to_chat(usr, SPAN_WARNING("Select a receiving beacon first."))
		return TRUE
	if(!length(shopping_list))
		return TRUE
	var/cart_range_block = SSsupply.GetShopListTradeRangeBlockReason(receiving, shopping_list)
	if(cart_range_block)
		to_chat(usr, SPAN_WARNING(cart_range_block))
		return TRUE
	if(!SSsupply.Buy(receiving, account, shopping_list, FALSE, null, faction))
		to_chat(usr, SPAN_WARNING("Purchase failed. Check account balance, stock, and receiving area."))
	else
		ResetShopList()
		ResetUiForms()
	return TRUE

/datum/computer_file/program/supply/proc/ExecuteExport()
	if(!can_run(usr, TRUE))
		return TRUE
	if(!ValidateLinkedAccount())
		to_chat(usr, SPAN_WARNING("Link an account before exporting goods."))
		return TRUE
	if(!sending)
		to_chat(usr, SPAN_WARNING("Select a sending beacon first."))
		return TRUE
	if(!length(SerializeExportItems()))
		to_chat(usr, SPAN_WARNING("No exportable objects were found near the sending beacon."))
		return TRUE
	var/datum/trading_station/target_station = EnsureSelectedStation()
	if(istype(target_station) && target_station.wealth <= 0)
		to_chat(usr, SPAN_WARNING("Export failed: Station trade budget is depleted."))
		return TRUE
	var/export_result = SSsupply.Export(sending, account, target_station, faction)
	if(!export_result)
		to_chat(usr, SPAN_WARNING("Export failed. The beacon may still be on cooldown or goods could not be sold."))
	else if(export_result == TRADE_EXPORT_PARTIAL)
		to_chat(usr, SPAN_NOTICE("Station trade budget exhausted; remaining items left on beacon."))
	return TRUE

/datum/computer_file/program/supply/proc/HandleTradeTopic(list/href_list)
	if("PRG_receive" in href_list)
		return PurchaseCart()
	if("PRG_export" in href_list)
		return ExecuteExport()
	return FALSE

/datum/computer_file/program/supply/proc/AcceptContract(contract_id)
	if(!can_run(usr, TRUE))
		return TRUE
	if(!ValidateLinkedAccount())
		to_chat(usr, SPAN_WARNING("Link an account before accepting contracts."))
		return TRUE
	if(!receiving)
		to_chat(usr, SPAN_WARNING("Select a receiving beacon first."))
		return TRUE
	var/datum/trade_contract/contract_to_accept = SSsupply.GetTradeContract(contract_id)
	var/accept_block = GetContractAcceptBlockReason(contract_to_accept)
	if(accept_block)
		to_chat(usr, SPAN_WARNING(accept_block))
		return TRUE
	if(!SSsupply.AcceptTradeContract(receiving, account, contract_id, faction))
		var/fail_msg = contract_to_accept ? contract_to_accept.GetAcceptFailureMessage() : "Contract acceptance failed. Check source stock and the receiving area."
		to_chat(usr, SPAN_WARNING(fail_msg))
	return TRUE

/datum/computer_file/program/supply/proc/DeliverContract(contract_id)
	if(!can_run(usr, TRUE))
		return TRUE
	if(!sending)
		to_chat(usr, SPAN_WARNING("Select a sending beacon first."))
		return TRUE
	var/datum/trade_contract/contract_to_deliver = SSsupply.GetTradeContract(contract_id)
	var/deliver_block = GetContractDeliverBlockReason(contract_to_deliver)
	if(deliver_block)
		to_chat(usr, SPAN_WARNING(deliver_block))
		return TRUE
	if(!SSsupply.DeliverTradeContract(sending, contract_id))
		var/fail_msg = contract_to_deliver ? contract_to_deliver.GetDeliverFailureMessage() : "Contract delivery failed. The crate may be missing or the beacon may be on cooldown."
		to_chat(usr, SPAN_WARNING(fail_msg))
	return TRUE

/datum/computer_file/program/supply/proc/HandleContractTopic(list/href_list)
	if("PRG_contract_accept" in href_list)
		return AcceptContract(href_list["PRG_contract_accept"])
	if("PRG_contract_deliver" in href_list)
		return DeliverContract(href_list["PRG_contract_deliver"])
	return FALSE

/datum/computer_file/program/supply/proc/BuildOrderFromForm(raw_reason)
	CloseCartForm()
	if(!can_run(usr, TRUE))
		return TRUE
	if(world.time < order_cooldown_until)
		to_chat(usr, SPAN_WARNING("Wait a few seconds before submitting another order."))
		return TRUE
	if(!ValidateLinkedAccount())
		to_chat(usr, SPAN_WARNING("Link an account before building an order."))
		return TRUE
	if(!length(shopping_list) || SSsupply.CollectCountsFrom(shopping_list) <= 0)
		to_chat(usr, SPAN_WARNING("Your cart is empty."))
		return TRUE
	var/reason = sanitize(raw_reason, MAX_MESSAGE_LEN)
	if(!length(trimtext(reason)))
		to_chat(usr, SPAN_WARNING("A justification reason is required to submit a supply order."))
		return TRUE
	current_order = SSsupply.BuildOrder(account, reason, CopyShopList(shopping_list), faction)
	if(current_order)
		ResetShopList()
		ResetUiForms()
		trade_screen = ORDER_SCREEN
		order_cooldown_until = world.time + 10 SECONDS
	return TRUE

/datum/computer_file/program/supply/proc/RemoveOrder(order_id)
	if(!HasCargoApprovalAccess(usr))
		to_chat(usr, SPAN_WARNING("Cargo approval access is required to remove orders."))
		return TRUE
	if(order_id in SSsupply.order_queue)
		var/list/order_data = SSsupply.order_queue[order_id]
		if(islist(order_data) && (order_data["processing"] || order_data["status"] == "processing"))
			to_chat(usr, SPAN_WARNING("Order [order_id] is currently being processed and cannot be removed."))
			return TRUE
		SSsupply.DismantleOrder(order_id)
		if(current_order == order_id)
			current_order = null
	return TRUE

/datum/computer_file/program/supply/CloseCartForm()
	save_order_id = null
	return ..()

/datum/computer_file/program/supply/ResetUiForms()
	save_order_id = null
	return ..()

/datum/computer_file/program/supply/proc/SaveOrderToCart(order_id, list/href_list)
	if(!(order_id in SSsupply.order_queue))
		return TRUE
	var/name = href_list["PRG_save_name"]
	if(!name)
		save_order_id = order_id
		OpenCartForm("save_order")
		return TRUE
	name = sanitizeName(name, MAX_NAME_LEN)
	var/list/order_data = SSsupply.order_queue[order_id]
	SaveShopList(name, order_data["contents"])
	save_order_id = null
	CloseCartForm()
	to_chat(usr, SPAN_NOTICE("Order saved to cart presets."))
	return TRUE

/datum/computer_file/program/supply/proc/ApproveOrder(order_id)
	if(!HasCargoApprovalAccess(usr))
		to_chat(usr, SPAN_WARNING("Cargo approval access is required to approve orders."))
		return TRUE
	if(!receiving)
		to_chat(usr, SPAN_WARNING("Select a receiving beacon first."))
		return TRUE
	if(!receiving.operable())
		to_chat(usr, SPAN_WARNING("The receiving beacon is inoperable or unpowered."))
		return TRUE
	if(order_id in SSsupply.order_queue)
		var/list/order_data = SSsupply.order_queue[order_id]
		if(islist(order_data) && (order_data["processing"] || order_data["status"] == "processing"))
			to_chat(usr, SPAN_WARNING("Order [order_id] is already being processed."))
			return TRUE
		var/order_range_block = SSsupply.GetShopListTradeRangeBlockReason(receiving, order_data["contents"])
		if(order_range_block)
			to_chat(usr, SPAN_WARNING(order_range_block))
			return TRUE
	if(!SSsupply.PurchaseOrder(receiving, order_id))
		to_chat(usr, SPAN_WARNING("Order approval failed. Check department and requestor balances."))
	else
		if(current_order == order_id)
			current_order = null
	return TRUE

/datum/computer_file/program/supply/proc/HandleOrderTopic(list/href_list)
	if("PRG_build_order" in href_list)
		OpenCartForm("order")
		return TRUE
	if("PRG_build_order_form" in href_list)
		return BuildOrderFromForm(href_list["PRG_order_reason"])
	if("PRG_view_order" in href_list)
		current_order = href_list["PRG_view_order"]
		return TRUE
	if("PRG_remove_order" in href_list)
		return RemoveOrder(href_list["PRG_remove_order"])
	if("PRG_save_order_form" in href_list)
		if(save_order_id)
			return SaveOrderToCart(save_order_id, href_list)
		return TRUE
	if("PRG_save_order" in href_list)
		return SaveOrderToCart(href_list["PRG_save_order"], href_list)
	if("PRG_approve_order" in href_list)
		return ApproveOrder(href_list["PRG_approve_order"])
	return FALSE

/datum/computer_file/program/supply/proc/PrintLogInvoice(raw_log_id, is_internal = FALSE)
	var/list/log_data = SSsupply.GetLogDataById(raw_log_id)
	if(!length(log_data))
		to_chat(usr, SPAN_WARNING("Invoice #[html_encode(copytext(strip_html_properly(trimtext("[raw_log_id]")), 1, 33))] was not found."))
		return TRUE
	var/clean_id = copytext(strip_html_properly(trimtext("[log_data["id"] || raw_log_id]")), 1, 33)
	var/safe_id = html_encode(clean_id)
	var/list/id_data = splittext(clean_id, "-")
	var/log_type = LOG_SHIPPING
	switch(length(id_data) >= 2 ? uppertext(id_data[2]) : null)
		if("E")
			log_type = LOG_EXPORT
		if("O")
			log_type = LOG_ORDER
		if("C")
			log_type = LOG_CONTRACT
	var/title = "[lowertext(log_type)] invoice - #[clean_id][is_internal ? " (internal)" : ""]"
	var/safe_recipient = html_encode("[log_data["ordering_acct"]]")
	var/safe_paid = html_encode("[log_data["total_paid"]]")
	var/text = "<h3>[log_type] Invoice - #[safe_id]</h3><hr><font size='2'>"
	if(is_internal)
		text += "FOR INTERNAL USE ONLY<br><br>"
	text += "Recipient: [safe_recipient]<br>Contents:<br><ul>[log_data["contents"]]</ul>Total Credits Paid: [safe_paid]<br></font>"
	computer.print_paper(text, strip_html_properly(title))
	return TRUE

/datum/computer_file/program/supply/proc/HandlePrintTopic(list/href_list)
	if(!("PRG_print" in href_list) && !("PRG_print_internal" in href_list))
		return FALSE
	if(!computer?.get_component(PART_PRINTER))
		to_chat(usr, SPAN_WARNING("No printer is installed in this computer."))
		return TRUE
	var/raw_log_id = ("PRG_print" in href_list) ? href_list["PRG_print"] : href_list["PRG_print_internal"]
	return PrintLogInvoice(raw_log_id, ("PRG_print_internal" in href_list))

/datum/computer_file/program/supply/Topic(href, href_list)
	if(..() || href_list["close"])
		return TRUE
	ValidateSelectedTradeBeacons()
	if(HandleScreenTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleAccountTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleCatalogTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleBeaconTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleCartTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleTradeTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleContractTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleOrderTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandlePrintTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	return FALSE

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
