
/datum/computer_file/program/supply_order
	parent_type = /datum/computer_file/program/supply_base
	filename = "supply_order"
	filedesc = "Supply Ordering"
	nanomodule_path = null
	ui_header = null
	program_icon_state = "supply"
	program_key_state = "rd_key"
	program_menu_icon = "cart"
	extended_desc = "Client application for browsing station trade catalogs and submitting supply order requests."
	size = 12
	available_on_ntnet = TRUE
	requires_ntnet = FALSE
	category = PROG_SUPPLY
	usage_flags = PROGRAM_ALL
	required_access = null
	requires_access_to_run = FALSE
	requires_access_to_download = FALSE

	var/current_tab = SUPPLY_ORDER_TAB_GOODS
	var/authenticated_via_card = FALSE
	var/weakref/authenticated_user
	var/weakref/authenticated_card
	var/order_reason = ""
	var/orders_filter = "all"

/datum/computer_file/program/supply_order/process_tick()
	..()
	if(length(shopping_list))
		ui_header = "supply_awaiting_delivery.gif"
	else
		ui_header = "supply_idle.gif"

/datum/computer_file/program/supply_order/Destroy()
	ClearAccountSession()
	return ..()

/datum/computer_file/program/supply_order/on_shutdown(forced = 0)
	ClearAccountSession()
	return ..()

/datum/computer_file/program/supply_order/GetDefaultSavedCartName()
	return "Preset #[++saved_cart_id]"

/datum/computer_file/program/supply_order/GetSavedCartTotal(list/cart_data, list/totals = null)
	totals ||= SSsupply.GetCartTotals(cart_data, faction)
	var/subtotal = totals["raw_subtotal"]
	return round(subtotal + round(subtotal * SSsupply.handling_fee, 0.01), 0.01)

/datum/computer_file/program/supply_order/CanAddGoodsToCart()
	return TRUE

/datum/computer_file/program/supply_order/proc/GetAvailableIdCard(mob/user)
	var/obj/item/card/id/id_card = GetInsertedIdCard()
	if(istype(id_card))
		return id_card
	if(istype(user))
		id_card = user.GetIdCard()
		if(istype(id_card))
			return id_card
	return null

/datum/computer_file/program/supply_order/proc/ClearAccountSession()
	account = null
	authenticated_via_card = FALSE
	authenticated_user = null
	authenticated_card = null

/datum/computer_file/program/supply_order/proc/CheckAccountValidity(mob/user)
	if(!account)
		return
	if(QDELETED(account) || account.suspended || (authenticated_user && authenticated_user.resolve() != user))
		ClearAccountSession()
		return
	if(authenticated_via_card)
		var/obj/item/card/id/id_card = authenticated_card?.resolve()
		if(!istype(id_card) || QDELETED(id_card) || GetAvailableIdCard(user) != id_card || id_card.associated_account_number != account.account_number)
			ClearAccountSession()

/datum/computer_file/program/supply_order/proc/PromptLinkAccount(mob/user, list/href_list)
	var/account_number = text2num(href_list["PRG_link_account_number"])
	var/account_pin = text2num(href_list["PRG_link_account_pin"])
	if(!isnum(account_number) || !isnum(account_pin))
		OpenCartForm("link_account")
		return TRUE
	if(!account_number || !account_pin)
		to_chat(user, SPAN_WARNING("Account number and PIN are required."))
		return TRUE
	var/obj/item/card/id/id_card = GetAvailableIdCard(user)
	var/card_check = istype(id_card) && id_card.associated_account_number == account_number
	var/datum/money_account/linked_account = attempt_account_access(account_number, account_pin, card_check ? 2 : 1)
	if(!linked_account)
		to_chat(user, SPAN_WARNING("Unable to link account: access denied."))
		CloseCartForm()
		return TRUE
	if(linked_account.suspended)
		to_chat(user, SPAN_WARNING("Unable to link account: account is suspended."))
		CloseCartForm()
		return TRUE
	if(!card_check && linked_account.account_type != ACCOUNT_TYPE_PERSONAL)
		to_chat(user, SPAN_WARNING("Public ordering terminals only allow linking personal accounts without physical ID card verification."))
		CloseCartForm()
		return TRUE
	if(linked_account.security_level == 0 && !card_check)
		to_chat(user, SPAN_WARNING("Accounts with level 0 security require a matching physical ID card to be verified."))
		CloseCartForm()
		return TRUE
	account = linked_account
	authenticated_via_card = card_check ? TRUE : FALSE
	authenticated_user = weakref(user)
	authenticated_card = card_check ? weakref(id_card) : null
	to_chat(user, SPAN_NOTICE("Account #[account.account_number] linked successfully."))
	CloseCartForm()
	return TRUE

/datum/computer_file/program/supply_order/proc/LinkInsertedIdAccount(mob/user, list/href_list)
	var/obj/item/card/id/id_card = GetAvailableIdCard(user)
	if(!istype(id_card))
		to_chat(user, SPAN_WARNING("Insert or equip an ID card first."))
		return TRUE
	if(!id_card.associated_account_number)
		to_chat(user, SPAN_WARNING("This ID card is not linked to any bank account."))
		return TRUE
	var/datum/money_account/target_account = get_account(id_card.associated_account_number)
	if(!target_account)
		to_chat(user, SPAN_WARNING("Unable to locate bank account #[id_card.associated_account_number]."))
		return TRUE
	if(target_account.suspended)
		to_chat(user, SPAN_WARNING("Unable to link account: account is suspended."))
		return TRUE
	var/account_pin = 0
	if(target_account.security_level > 0)
		account_pin = text2num(href_list["PRG_link_id_pin"])
		if(!isnum(account_pin) || !account_pin)
			OpenCartForm("link_id_account")
			return TRUE
	var/datum/money_account/linked_account = attempt_account_access(id_card.associated_account_number, account_pin, 2)
	if(!linked_account)
		to_chat(user, SPAN_WARNING("Unable to link account: access denied."))
		CloseCartForm()
		return TRUE
	account = linked_account
	authenticated_via_card = TRUE
	authenticated_user = weakref(user)
	authenticated_card = weakref(id_card)
	to_chat(user, SPAN_NOTICE("Account #[account.account_number] linked successfully."))
	CloseCartForm()
	return TRUE

/datum/computer_file/program/supply_order/proc/UnlinkAccount(mob/user)
	ClearAccountSession()
	if(user)
		to_chat(user, SPAN_NOTICE("Account unlinked."))
	else if(usr)
		to_chat(usr, SPAN_NOTICE("Account unlinked."))
	return TRUE

/datum/computer_file/program/supply_order/proc/GetSubmitBlockReason(list/totals)
	if(!istype(account) || account.suspended)
		return "Link an active personal bank account before submitting an order."
	if(!totals["count"] || totals["count"] <= 0)
		return "Your cart is empty. Add items from the catalog."
	if(world.time < order_cooldown_until)
		return "Please wait for the ordering cooldown to expire."
	if(account.money < totals["total"])
		return "Insufficient account balance to cover items and handling fee."
	for(var/station_key in shopping_list)
		var/datum/trading_station/target_station = SSsupply.GetStationByUid(station_key)
		if(!istype(target_station) || QDELETED(target_station))
			return "One of the stations in your cart is no longer available."
		var/station_block = GetStationTradeBlockReason(target_station)
		if(station_block)
			return "[target_station.name]: [station_block]"
	return null

/datum/computer_file/program/supply_order/proc/CanUserCancelOrder(mob/user, datum/money_account/req_acct)
	CheckAccountValidity(user)
	if(!istype(req_acct))
		return FALSE
	if(account && (req_acct == account || (account.account_number && req_acct.account_number == account.account_number)))
		return TRUE
	var/obj/item/card/id/inserted_id = GetInsertedIdCard()
	if(istype(inserted_id) && inserted_id.associated_account_number && inserted_id.associated_account_number == req_acct.account_number)
		return TRUE
	if(istype(user))
		var/obj/item/card/id/held_id = user.GetIdCard()
		if(istype(held_id) && held_id.associated_account_number && held_id.associated_account_number == req_acct.account_number)
			return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/SubmitOrder(mob/user, raw_reason)
	CheckAccountValidity(user)
	var/list/totals = GetCartTotals()
	var/block = GetSubmitBlockReason(totals)
	if(block)
		to_chat(user, SPAN_WARNING(block))
		return TRUE
	if(SSsupply.CollectCountsFrom(shopping_list) <= 0)
		to_chat(user, SPAN_WARNING("Your cart is empty."))
		return TRUE
	var/reason = sanitize(raw_reason, MAX_MESSAGE_LEN)
	if(!length(trimtext(reason)))
		to_chat(user, SPAN_WARNING("A justification reason is required to submit a supply order."))
		return TRUE
	var/order_slot = SSsupply.BuildOrder(account, reason, shopping_list, faction)
	if(!order_slot)
		to_chat(user, SPAN_WARNING("Failed to submit order to cargo queue."))
		return TRUE
	current_order = order_slot
	ResetShopList()
	order_reason = ""
	cart_form_mode = null
	current_tab = SUPPLY_ORDER_TAB_ORDERS
	order_cooldown_until = world.time + 10 SECONDS
	to_chat(user, SPAN_NOTICE("Order [order_slot] submitted successfully to cargo."))
	return TRUE

/datum/computer_file/program/supply_order/proc/CancelOrder(mob/user, order_id)
	if(!order_id || !(order_id in SSsupply.order_queue))
		to_chat(user, SPAN_WARNING("Order was not found or has already been fulfilled."))
		return TRUE
	var/datum/cargo_order/order_data = SSsupply.order_queue[order_id]
	if(!istype(order_data))
		return TRUE
	if(order_data.IsLocked())
		to_chat(user, SPAN_WARNING("Order [order_id] is currently being processed and cannot be cancelled."))
		return TRUE
	var/datum/money_account/req_acct = order_data.requesting_acct
	if(!CanUserCancelOrder(user, req_acct))
		to_chat(user, SPAN_WARNING("You can only cancel orders submitted by your account."))
		return TRUE
	SSsupply.DismantleOrder(order_id)
	if(current_order == order_id)
		current_order = null
	to_chat(user, SPAN_NOTICE("Order [order_id] has been cancelled."))
	return TRUE

/datum/computer_file/program/supply_order/proc/GetMyOrderCount(user_or_acct = null)
	var/count = 0
	var/filter_acct_num = isnum(user_or_acct) ? user_or_acct : null
	var/mob/user = istype(user_or_acct, /mob) ? user_or_acct : null
	for(var/order_id as anything in SSsupply.order_queue)
		var/datum/cargo_order/order_data = SSsupply.order_queue[order_id]
		if(!istype(order_data))
			continue
		var/datum/money_account/req_acct = order_data.requesting_acct
		if(!istype(req_acct))
			continue
		if(filter_acct_num)
			if(req_acct.account_number == filter_acct_num)
				count++
		else if(CanUserCancelOrder(user, req_acct))
			count++
	return count

/datum/computer_file/program/supply_order/proc/HandleTabTopic(list/href_list)
	if(!("PRG_trade_screen" in href_list))
		return FALSE
	var/new_tab = href_list["PRG_trade_screen"]
	if(new_tab in list(SUPPLY_ORDER_TAB_GOODS, SUPPLY_ORDER_TAB_CART, SUPPLY_ORDER_TAB_ORDERS, SUPPLY_ORDER_TAB_ACCOUNT))
		current_tab = new_tab
		goods_quantity_target = null
		cart_form_mode = null
	return TRUE

/datum/computer_file/program/supply_order/proc/HandleAccountTopic(mob/user, list/href_list)
	if(("PRG_account" in href_list) || ("PRG_link_account_number" in href_list))
		return PromptLinkAccount(user, href_list)
	if(("PRG_account_id" in href_list) || ("PRG_link_id_pin" in href_list))
		return LinkInsertedIdAccount(user, href_list)
	if("PRG_account_unlink" in href_list)
		return UnlinkAccount(user)
	return FALSE

/datum/computer_file/program/supply_order/proc/HandleCatalogTopic(list/href_list)
	var/station_id = href_list["PRG_station"] || href_list["amp;PRG_station"]
	if(station_id)
		var/datum/trading_station/target_station = SSsupply.GetVisibleStationByUid(station_id)
		if(istype(target_station) && !GetStationTradeBlockReason(target_station, faction))
			station = target_station
			SetChosenCategory()
			goods_quantity_target = null
		return TRUE
	if("PRG_goods_category" in href_list)
		EnsureSelectedStation()
		if(!GetStationTradeBlockReason(station))
			SetChosenCategory(href_list["PRG_goods_category"])
		goods_quantity_target = null
		return TRUE
	if("PRG_goods_quantity_target" in href_list)
		EnsureSelectedStation()
		goods_quantity_target = href_list["PRG_goods_quantity_target"]
		return TRUE
	if("PRG_goods_quantity_cancel" in href_list)
		goods_quantity_target = null
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/HandleCartFormTopic(list/href_list)
	if("PRG_cart_add_form" in href_list)
		EnsureSelectedStation()
		var/block_reason = GetStationTradeBlockReason(station)
		if(block_reason)
			to_chat(usr, SPAN_WARNING(block_reason))
		else
			var/amount = text2num(href_list["PRG_cart_add_amount"])
			if(is_valid_cargo_quantity(amount))
				TryAddToCart(href_list["PRG_cart_add_form"], amount)
		goods_quantity_target = null
		return TRUE
	if("PRG_cart_set_form" in href_list)
		EnsureSelectedStation()
		var/block_reason = GetStationTradeBlockReason(station)
		if(block_reason)
			to_chat(usr, SPAN_WARNING(block_reason))
		else
			var/good_id = ResolveGoodId(chosen_category, href_list["PRG_cart_set_form"])
			var/amount = text2num(href_list["PRG_cart_set_amount"])
			if(good_id && is_valid_cargo_quantity(amount))
				SetInShopList(good_id, amount, station.GetGoodAmount(chosen_category, good_id))
			else if(good_id && isnum(amount) && amount <= 0)
				RemoveFromShopList(good_id, 999999)
		goods_quantity_target = null
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/HandleCartTopic(list/href_list)
	if("PRG_cart_add_good" in href_list)
		return HandleCartAddGood(href_list)
	if("PRG_cart_remove_good" in href_list)
		return HandleCartRemoveGood(href_list)
	if("PRG_cart_form" in href_list)
		cart_form_mode = href_list["PRG_cart_form"]
		return TRUE
	if("PRG_cart_form_cancel" in href_list)
		cart_form_mode = null
		return TRUE
	if(("PRG_cart_save_form" in href_list) || ("PRG_cart_load_direct" in href_list) || ("PRG_cart_delete" in href_list))
		return HandleCartPresetTopic(href_list)
	if(HandleCartFormTopic(href_list))
		return TRUE
	if("PRG_cart_remove_direct" in href_list)
		return HandleCartRemove(href_list)
	if("PRG_cart_reset" in href_list)
		ResetShopList()
		cart_form_mode = null
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/HandleCartAddGood(list/href_list)
	EnsureSelectedStation()
	var/block_reason = GetStationTradeBlockReason(station)
	if(block_reason)
		to_chat(usr, SPAN_WARNING(block_reason))
		return TRUE
	var/amount = text2num(href_list["PRG_cart_add_amount"]) || 1
	TryAddToCart(href_list["PRG_cart_add_good"], amount)
	return TRUE

/datum/computer_file/program/supply_order/proc/HandleCartRemoveGood(list/href_list)
	EnsureSelectedStation()
	var/good_id = ResolveGoodId(chosen_category, href_list["PRG_cart_remove_good"])
	if(good_id)
		RemoveFromShopList(good_id, 1, station, chosen_category)
	return TRUE

/datum/computer_file/program/supply_order/proc/HandleCartPresetTopic(list/href_list)
	if("PRG_cart_save_form" in href_list)
		var/preset_name = sanitize(href_list["PRG_cart_save_name"], 32)
		if(SaveShopList(preset_name))
			to_chat(usr, SPAN_NOTICE("Cart preset saved successfully."))
		cart_form_mode = null
		return TRUE
	if("PRG_cart_load_direct" in href_list)
		var/preset_name = href_list["PRG_cart_load_direct"]
		var/list/loaded = LoadShopList(preset_name)
		if(loaded)
			if(shopping_list)
				ClearShopList(shopping_list)
			shopping_list = loaded
			to_chat(usr, SPAN_NOTICE("Cart preset loaded."))
		return TRUE
	if("PRG_cart_delete" in href_list)
		DeleteShopList(href_list["PRG_cart_delete"])
		to_chat(usr, SPAN_NOTICE("Cart preset removed."))
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/HandleOrderTopic(mob/user, list/href_list)
	if("PRG_build_order_form" in href_list)
		return SubmitOrder(user, href_list["PRG_order_reason"])
	if("PRG_view_order" in href_list)
		current_order = href_list["PRG_view_order"]
		return TRUE
	if("PRG_cancel_order" in href_list)
		return CancelOrder(user, href_list["PRG_cancel_order"])
	if("PRG_orders_filter" in href_list)
		orders_filter = href_list["PRG_orders_filter"]
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/Topic(href, href_list)
	if(..() || href_list["close"])
		return TRUE
	CheckAccountValidity(usr)
	if(HandleTabTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleAccountTopic(usr, href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleCatalogTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleCartTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleOrderTopic(usr, href_list))
		SSnano.update_uis(src)
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	. = ..()
	if(!.)
		return

	var/list/data = get_header_data() || list()
	var/list/totals = GetCartTotals()
	PopulateBaseUiData(data, user, totals)

	switch(current_tab)
		if(SUPPLY_ORDER_TAB_GOODS)
			BuildGoodsScreenData(data, user)
		if(SUPPLY_ORDER_TAB_CART)
			BuildCartScreenData(data, totals)
		if(SUPPLY_ORDER_TAB_ORDERS)
			BuildOrdersScreenData(data, user)
		if(SUPPLY_ORDER_TAB_ACCOUNT)
			BuildAccountScreenData(data, user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-cargo_order_client.tmpl", "Supply Order Client", 900, 700, state = GLOB.default_state)
		ui.set_initial_data(data)
		ui.open()
