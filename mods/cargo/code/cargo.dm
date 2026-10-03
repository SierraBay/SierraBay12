
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
	var/export_to_cargo_account = TRUE

	var/obj/machinery/trade_beacon/sending/sending
	var/obj/machinery/trade_beacon/receiving/receiving

	var/list/known_market_intel = list()
	var/save_order_id
	var/message

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

/datum/computer_file/program/supply/proc/CheckCardAccess(obj/item/card/id/I, access_to_check)
	if(!istype(I))
		return FALSE
	var/list/card_access = I.GetAccess()
	if(!card_access)
		return FALSE
	if(islist(access_to_check))
		for(var/acc in access_to_check)
			if(islist(acc))
				var/matched = TRUE
				for(var/subacc in acc)
					if(!(subacc in card_access))
						matched = FALSE
						break
				if(matched)
					return TRUE
			else if(acc in card_access)
				return TRUE
		return FALSE
	return (access_to_check in card_access)

/datum/computer_file/program/supply/can_run(mob/living/user, loud = FALSE, access_to_check)
	if(!requires_access_to_run)
		return TRUE
	if(!access_to_check && !(access_to_check = required_access))
		return TRUE
	if(isghost(user) && check_rights(R_ADMIN, 0, user))
		return TRUE
	if(!istype(user))
		return FALSE

	var/atom/host = computer?.get_physical_host()
	var/obj/item/card/id/inserted = GetInsertedIdCard()
	var/obj/item/card/id/user_id = user.GetIdCard()

	if(!inserted && !user_id)
		if(loud)
			to_chat(user, SPAN_NOTICE("\The [host || "computer"] flashes an \"RFID Error - Unable to scan ID\" warning."))
		return FALSE

	if((inserted && CheckCardAccess(inserted, access_to_check)) || (user_id && CheckCardAccess(user_id, access_to_check)))
		return TRUE

	if(loud)
		to_chat(user, SPAN_NOTICE("\The [host || "computer"] flashes an \"Access Denied\" warning."))
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
	var/obj/item/card/id/inserted = GetInsertedIdCard()
	if(istype(inserted) && CheckCardAccess(inserted, required_access))
		return TRUE
	if(istype(user))
		var/obj/item/card/id/user_id = user.GetIdCard()
		if(istype(user_id) && CheckCardAccess(user_id, required_access))
			return TRUE
	return FALSE

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


/datum/computer_file/program/supply/proc/IsLocalTradeBeacon(obj/machinery/trade_beacon/beacon)
	if(!istype(beacon) || QDELETED(beacon) || !beacon.loc)
		return FALSE
	if(!GLOB.using_map?.use_overmap)
		var/atom/host = GetTradeSource()
		if(!host && istype(computer, /atom))
			host = computer
		return host && (beacon.z == host.z)
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

/datum/computer_file/program/supply/proc/GetExportPlan(datum/trading_station/target_station)
	if(!IsSendingSelected() || !istype(target_station))
		return null
	return SSsupply.BuildExportPlan(sending.GetObjects(), target_station, faction, target_station.wealth)

/datum/computer_file/program/supply/proc/HasRejectedExportCandidates()
	if(!IsSendingSelected())
		return FALSE
	var/list/rejected = list()
	SSsupply.GetExportCandidates(sending, rejected)
	return length(rejected) > 0

/datum/computer_file/program/supply/proc/GetContractAcceptBlockReason(datum/trade_contract/contract)
	if(!istype(contract))
		return "Contract data is unavailable."
	if(!istype(account))
		return "Link an account before accepting contracts."
	if(account.suspended)
		return "Linked payment account is suspended."
	return contract.GetAcceptBlockReason(receiving, account, faction)

/datum/computer_file/program/supply/proc/GetContractDeliverBlockReason(datum/trade_contract/contract)
	if(!istype(contract))
		return "Contract data is unavailable."
	return contract.GetDeliverBlockReason(sending)

/datum/computer_file/program/supply/proc/GetActiveContractCount()
	var/count = 0
	for(var/datum/trade_contract/contract as anything in SSsupply.trade_contracts)
		if(contract.status == CONTRACT_STATUS_ACTIVE && contract.CanStayActive())
			count++
	return count

/datum/computer_file/program/supply/proc/HandleScreenTopic(list/href_list)
	if("PRG_trade_screen" in href_list)
		trade_screen = href_list["PRG_trade_screen"]
		if(trade_screen == LOG_SCREEN && !log_screen)
			log_screen = LOG_SHIPPING
		ResetUiForms()
		message = null
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
	message = null
	var/index = isnum(raw_index) ? raw_index : text2num(raw_index)
	var/list/loaded
	if(isnum(index))
		var/numeric_index = round(index)
		if(numeric_index >= 1 && numeric_index <= length(saved_shopping_lists))
			var/name = saved_shopping_lists[numeric_index]
			loaded = LoadShopList(name)
	var/count_before = (islist(loaded) && SSsupply) ? SSsupply.CollectCountsFrom(loaded) : 0
	. = ..()
	if(.)
		var/count_after = (islist(shopping_list) && SSsupply) ? SSsupply.CollectCountsFrom(shopping_list) : 0
		if(count_before && count_after != count_before)
			message = "Some items from the saved template were unavailable and have been excluded."
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
		return HandleCartSetAmount(href_list)
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

/datum/computer_file/program/supply/proc/HandleCartSetAmount(list/href_list)
	if(!istype(station) || !chosen_category)
		return TRUE
	var/good_id = ResolveGoodId(chosen_category, href_list["PRG_cart_set_form"])
	if(!good_id)
		return TRUE
	var/set_amount = text2num(href_list["PRG_cart_set_amount"])
	if(isnum(set_amount) && set_amount >= 0)
		var/stock = station.GetGoodAmount(chosen_category, good_id)
		var/station_key = GetStationKey(station)
		var/list/station_cart = islist(shopping_list[station_key]) ? shopping_list[station_key] : shopping_list[station]
		var/current_in_cart = 0
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
	if(!SSsupply.Buy(receiving, account, shopping_list, faction))
		to_chat(usr, SPAN_WARNING("Purchase failed. Check account balance, stock, and receiving area."))
	else
		ResetShopList()
		ResetUiForms()
	return TRUE

/datum/computer_file/program/supply/proc/ExecuteExport()
	if(!can_run(usr, TRUE))
		return TRUE
	var/datum/money_account/export_account = GetExportAccount()
	if(!istype(export_account) || export_account.suspended)
		to_chat(usr, SPAN_WARNING("Select an active account for export proceeds."))
		return TRUE
	if(!sending)
		to_chat(usr, SPAN_WARNING("Select a sending beacon first."))
		return TRUE
	var/datum/trading_station/target_station = EnsureSelectedStation()
	if(!istype(target_station))
		to_chat(usr, SPAN_WARNING("No trading station is available for export."))
		return TRUE
	if(target_station.wealth <= 0)
		to_chat(usr, SPAN_WARNING("Export failed: Station trade budget is depleted."))
		return TRUE
	var/list/plan = GetExportPlan(target_station)
	if(!length(SerializeExportItems(plan)) && !HasRejectedExportCandidates())
		to_chat(usr, SPAN_WARNING("No exportable objects were found near the sending beacon."))
		return TRUE
	var/invoice_block_reason = SSsupply.GetExportInvoiceBlockReason(plan)
	if(!invoice_block_reason)
		invoice_block_reason = SSsupply.GetExportCompletionBlockReason(plan)
	if(invoice_block_reason)
		to_chat(usr, SPAN_WARNING(invoice_block_reason))
		return TRUE
	var/export_result = SSsupply.Export(sending, export_account, target_station, faction)
	if(!export_result)
		to_chat(usr, SPAN_WARNING("Export failed. The beacon may still be on cooldown or goods could not be sold."))
	else if(export_result == TRADE_EXPORT_PARTIAL)
		to_chat(usr, SPAN_NOTICE("Some goods exceeded the station's remaining trade budget and were left on the beacon."))
	return TRUE

/datum/computer_file/program/supply/proc/HandleTradeTopic(list/href_list)
	if("PRG_export_account" in href_list)
		export_to_cargo_account = href_list["PRG_export_account"] != "linked"
		return TRUE
	if("PRG_receive" in href_list)
		return PurchaseCart()
	if("PRG_export" in href_list)
		return ExecuteExport()
	return FALSE

/datum/computer_file/program/supply/proc/GetExportAccount()
	if(export_to_cargo_account)
		return GetMasterAccount()
	if(ValidateLinkedAccount())
		return account
	return null

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
	current_order = SSsupply.BuildOrder(account, reason, shopping_list, faction)
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
		var/datum/cargo_order/order_data = SSsupply.order_queue[order_id]
		if(istype(order_data) && (order_data.IsLocked()))
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
	var/datum/cargo_order/order_data = SSsupply.order_queue[order_id]
	SaveShopList(name, order_data.contents)
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
		var/datum/cargo_order/order_data = SSsupply.order_queue[order_id]
		if(istype(order_data) && (order_data.IsLocked()))
			to_chat(usr, SPAN_WARNING("Order [order_id] is already being processed."))
			return TRUE
		var/order_range_block = SSsupply.GetShopListTradeRangeBlockReason(receiving, order_data.contents)
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
