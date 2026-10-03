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
		"can_trade" = !block_reason,
		"trade_window_remaining" = isnum(trade_window_remaining) ? FormatCountdown(trade_window_remaining) : ""
	)

/datum/computer_file/program/supply/proc/SerializeExportItems(list/plan)
	var/list/result = list()
	if(!islist(plan))
		return result
	var/datum/trading_station/target_station = station
	var/list/grouped = list()
	var/list/entries = plan["entries"]
	for(var/list/entry as anything in entries)
		if(!entry["sell"])
			continue
		var/atom/movable/item = entry["item"]
		var/atom/movable/root = entry["scope"] || entry["root"]
		var/list/root_data = grouped[root]
		if(!islist(root_data))
			var/display_name = root.name
			if(istype(root, /obj/structure/closet))
				var/obj/item/paper/manifest/rnd_invoice/slip = SSsupply.FindRnDInvoice(root)
				if(slip)
					display_name = "[root.name] (R&D #[slip.target_account_number])"
			root_data = list("name" = display_name, "amount" = 1, "unit_value" = 0, "value" = 0, "target_station" = target_station ? target_station.name : "Trade Network", "sub_items" = list())
			grouped[root] = root_data
			result.Add(list(root_data))
		root_data["value"] += entry["price"]
		root_data["unit_value"] = root_data["value"]
		if(item == root && !length(root.contents))
			continue
		var/amount = max(0.000001, entry["amount"])
		var/list/sub_items = root_data["sub_items"]
		sub_items.Add(list(list("name" = item == root ? "[item.name] (packaging)" : item.name, "amount" = amount, "unit_value" = round(entry["price"] / amount, 0.01), "value" = entry["price"])))
	return result

/datum/computer_file/program/supply/proc/SerializeOrders()
	var/list/result = list()
	for(var/order_id in SSsupply.order_queue)
		if(length(result) >= 50)
			break
		var/datum/cargo_order/order = SSsupply.GetCargoOrder(order_id)
		if(!order)
			continue
		var/list/entry = SerializeCargoOrder(order)
		entry["reason"] = order.reason || "No reason provided."
		result.Add(list(entry))
	return result

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
	var/datum/cargo_order/order = SSsupply.GetCargoOrder(current_order)
	if(!order)
		current_order = null
		return null
	return SerializeCargoOrder(order)

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

/datum/computer_file/program/supply/proc/PopulateBaseTradeUiData(list/data, mob/user = null, list/totals = null)
	data["src"] = ref(src)
	data["screen"] = trade_screen
	data["log_screen"] = log_screen
	data["message"] = message || ""
	data["currency"] = GLOB.using_map.local_currency_name
	data["currency_short"] = GLOB.using_map.local_currency_name_short
	data["faction"] = faction
	data["goods_quantity_target"] = goods_quantity_target || ""
	data["cart_form_mode"] = cart_form_mode || ""
	data["save_order_id"] = save_order_id
	data["user_greeting"] = GetUserGreeting(user)
	PopulateAccountUiData(data)
	PopulateBeaconUiData(data)
	PopulateCartSummaryUiData(data, totals)

/datum/computer_file/program/supply/proc/PopulateAccountUiData(list/data)
	data["has_account"] = istype(account)
	data["account_owner_name"] = account ? account.owner_name : ""
	data["account_number"] = account ? account.account_number : 0
	data["account_money"] = account ? round(account.money, 0.01) : 0

/datum/computer_file/program/supply/proc/PopulateBeaconUiData(list/data)
	var/receiving_id = GetBeaconDisplayId(receiving)
	var/sending_id = GetBeaconDisplayId(sending)
	data["receiving"] = receiving_id || ""
	data["has_receiving"] = !!receiving_id
	data["sending"] = sending_id || ""
	data["has_sending"] = !!sending_id
	var/cooldown_sec = (sending && sending.export_cooldown > world.time) ? round((sending.export_cooldown - world.time) / 10) : 0
	data["export_cooldown_remaining"] = cooldown_sec
	data["export_cooldown_text"] = cooldown_sec ? "[cooldown_sec]s" : "Ready"
	data["available_receiving_beacons"] = SerializeLocalBeacons("receiving")
	data["available_sending_beacons"] = SerializeLocalBeacons("sending")

/datum/computer_file/program/supply/proc/PopulateCartSummaryUiData(list/data, list/totals = null)
	totals ||= GetCartTotals()
	data["cart_count"] = totals["count"]
	data["cart_total"] = totals["subtotal"]
	data["cart_fee"] = totals["fee"]
	var/cart_range_block = receiving ? SSsupply.GetShopListTradeRangeBlockReason(receiving, shopping_list) : null
	data["cart_trade_block_reason"] = cart_range_block || ""
	var/orders_locked = (world.time < order_cooldown_until)
	data["orders_locked"] = orders_locked
	data["can_purchase_cart"] = istype(account) && !!data["has_receiving"] && length(shopping_list) && !cart_range_block
	data["can_build_order"] = istype(account) && length(shopping_list) && !orders_locked
	data["order_count"] = length(SSsupply.order_queue)
	var/pending_total = 0
	for(var/order_id as anything in SSsupply.order_queue)
		var/datum/cargo_order/order_entry = SSsupply.order_queue[order_id]
		if(istype(order_entry))
			pending_total += (order_entry.cost + order_entry.fee)
	data["pending_orders_total"] = round(pending_total, 0.01)

/datum/computer_file/program/supply/proc/GetUserGreeting(mob/user)
	var/obj/item/card/id/I = GetInsertedIdCard()
	if(!istype(I) && istype(user))
		I = user.GetIdCard()
	if(istype(I))
		var/branch = I.military_branch ? " ([uppertext(I.military_branch)])" : ""
		return "WELCOME, [uppertext(I.registered_name)], [uppertext(I.assignment)][branch]"
	if(istype(user))
		return "WELCOME, [uppertext(user.name)]"
	return ""

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
	var/list/stations = SerializeVisibleStations()
	data["has_visible_stations"] = length(stations) ? TRUE : FALSE
	data["stations"] = stations
	data["has_selected_station"] = istype(selected_station)
	if(istype(selected_station))
		data["selected_station"] = SerializeSelectedStation(selected_station)
	var/datum/money_account/export_account = GetExportAccount()
	data["export_to_cargo_account"] = export_to_cargo_account
	data["export_account_owner"] = export_account ? export_account.owner_name : "Unavailable"
	var/list/plan = GetExportPlan(selected_station)
	var/list/export_items = SerializeExportItems(plan)
	var/export_block_reason = null
	if(!istype(export_account) || export_account.suspended)
		export_block_reason = "Select an active account for export proceeds."
	else if(!GetBeaconDisplayId(sending))
		export_block_reason = "Select a sending beacon first."
	else if(!istype(selected_station))
		export_block_reason = "No trading station is available for export."
	else if(selected_station.wealth <= 0)
		export_block_reason = "Station trade budget is depleted."
	else if(sending && sending.export_cooldown > world.time)
		export_block_reason = "The sending beacon is on cooldown."
	else
		export_block_reason = SSsupply.GetTradeRangeBlockReason(sending, selected_station)
	if(!export_block_reason && !length(export_items) && !HasRejectedExportCandidates())
		export_block_reason = "No exportable objects are inside the sending beacon range."
	if(!export_block_reason)
		export_block_reason = SSsupply.GetExportInvoiceBlockReason(plan)
	if(!export_block_reason && islist(plan))
		export_block_reason = SSsupply.GetExportCompletionBlockReason(plan)

	data["export_items"] = export_items
	var/export_total = 0
	for(var/list/export_item as anything in export_items)
		export_total += export_item["value"]
	data["export_total"] = round(export_total, 0.01)
	data["can_export"] = !export_block_reason
	data["export_block_reason"] = export_block_reason || ""
	data["export_target_station"] = selected_station ? selected_station.name : ""
	data["has_export_target_station"] = istype(selected_station)

/datum/computer_file/program/supply/proc/BuildCartScreenData(list/data, list/totals = null)
	totals ||= GetCartTotals()
	data["cart_groups"] = SerializeShopListGroups(shopping_list, faction, totals["price_snapshot"])
	data["can_save_cart"] = !!length(shopping_list)
	data["saved_carts"] = SerializeSavedCarts()

/datum/computer_file/program/supply/proc/BuildOrdersScreenData(list/data, mob/user)
	var/selected_order_data = SerializeSelectedOrder()
	data["can_approve_orders"] = HasCargoApprovalAccess(user)
	data["can_manage_orders"] = data["can_approve_orders"]
	data["orders"] = SerializeOrders()
	data["has_selected_order"] = islist(selected_order_data)
	if(islist(selected_order_data))
		data["selected_order"] = selected_order_data

/datum/computer_file/program/supply/proc/BuildContractsScreenData(list/data)
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
	var/list/totals = GetCartTotals()
	PopulateBaseTradeUiData(data, user, totals)
	switch(trade_screen)
		if(SETTINGS_SCREEN)
			BuildSettingsScreenData(data)
		if(GOODS_SCREEN)
			BuildGoodsScreenData(data, user)
		if(EXPORT_SCREEN)
			BuildExportScreenData(data)
		if(CART_SCREEN)
			BuildCartScreenData(data, totals)
		if(ORDER_SCREEN)
			BuildOrdersScreenData(data, user)
		if(CONTRACT_SCREEN)
			BuildContractsScreenData(data)
		if(SAVED_SCREEN)
			BuildSavedScreenData(data)
		if(LOG_SCREEN)
			BuildLogsScreenData(data)
	if(trade_screen != CONTRACT_SCREEN)
		var/available_contract_count = 0
		for(var/datum/trade_contract/contract as anything in SSsupply.trade_contracts)
			if(contract.status == CONTRACT_STATUS_AVAILABLE && contract.ShouldDisplayAvailable())
				available_contract_count++
		data["available_contract_count"] = available_contract_count
		data["active_contract_count"] = GetActiveContractCount()
	return data
