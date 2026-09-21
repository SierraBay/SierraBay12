#define SUPPLY_ORDER_TAB_GOODS   "goods"
#define SUPPLY_ORDER_TAB_CART    "cart"
#define SUPPLY_ORDER_TAB_ORDERS  "orders"
#define SUPPLY_ORDER_TAB_ACCOUNT "account"

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
	var/order_reason = ""
	var/orders_filter = "all"

/datum/computer_file/program/supply_order/process_tick()
	..()
	if(length(shopping_list))
		ui_header = "supply_awaiting_delivery.gif"
	else
		ui_header = "supply_idle.gif"

/datum/computer_file/program/supply_order/Destroy()
	authenticated_via_card = FALSE
	return ..()

/datum/computer_file/program/supply_order/GetDefaultSavedCartName()
	return "Preset #[++saved_cart_id]"

/datum/computer_file/program/supply_order/GetSavedCartTotal(list/cart_data)
	var/subtotal = SSsupply.CollectPriceForList(cart_data, faction)
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

/datum/computer_file/program/supply_order/proc/CheckAccountValidity()
	if(!account)
		return
	if(QDELETED(account) || account.suspended)
		account = null
		authenticated_via_card = FALSE

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
	to_chat(user, SPAN_NOTICE("Account #[account.account_number] linked successfully."))
	CloseCartForm()
	return TRUE

/datum/computer_file/program/supply_order/proc/UnlinkAccount(mob/user)
	account = null
	authenticated_via_card = FALSE
	if(user)
		to_chat(user, SPAN_NOTICE("Account unlinked."))
	else if(usr)
		to_chat(usr, SPAN_NOTICE("Account unlinked."))
	return TRUE

/datum/computer_file/program/supply_order/proc/GetCartTotals()
	var/count = SSsupply.CollectCountsFrom(shopping_list)
	var/subtotal = round(SSsupply.CollectPriceForList(shopping_list, faction), 0.01)
	var/fee = round(subtotal * SSsupply.handling_fee, 0.01)
	var/total = subtotal + fee
	return list("count" = count, "subtotal" = subtotal, "fee" = fee, "total" = total)

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
		var/datum/trading_station/target_station = SSsupply.ResolveStation(station_key)
		if(!istype(target_station) || QDELETED(target_station))
			return "One of the stations in your cart is no longer available."
		var/station_block = GetStationTradeBlockReason(target_station)
		if(station_block)
			return "[target_station.name]: [station_block]"
	return null

/datum/computer_file/program/supply_order/proc/CanUserCancelOrder(mob/user, datum/money_account/req_acct)
	if(!istype(req_acct))
		return FALSE
	if(account && req_acct == account)
		return TRUE
	var/obj/item/card/id/id_card = user ? user.GetIdCard() : null
	if(istype(id_card) && id_card.associated_account_number == req_acct.account_number)
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/SubmitOrder(mob/user, raw_reason)
	CheckAccountValidity()
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
	var/order_slot = SSsupply.BuildOrder(account, reason, CopyShopList(shopping_list), faction)
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
	var/list/order_data = SSsupply.order_queue[order_id]
	if(!islist(order_data))
		return TRUE
	if(order_data["processing"] || order_data["status"] == "processing")
		to_chat(user, SPAN_WARNING("Order [order_id] is currently being processed and cannot be cancelled."))
		return TRUE
	var/datum/money_account/req_acct = order_data["requesting_acct"]
	if(!CanUserCancelOrder(user, req_acct))
		to_chat(user, SPAN_WARNING("You can only cancel orders submitted by your account."))
		return TRUE
	SSsupply.DismantleOrder(order_id)
	if(current_order == order_id)
		current_order = null
	to_chat(user, SPAN_NOTICE("Order [order_id] has been cancelled."))
	return TRUE

/datum/computer_file/program/supply_order/proc/GetMyOrderCount(user_acct_num)
	if(!user_acct_num)
		return 0
	var/count = 0
	for(var/order_id as anything in SSsupply.order_queue)
		var/list/order_data = SSsupply.order_queue[order_id]
		if(!islist(order_data))
			continue
		var/datum/money_account/req_acct = order_data["requesting_acct"]
		if(req_acct && req_acct.account_number == user_acct_num)
			count++
	return count

/datum/computer_file/program/supply_order/proc/PopulateBaseUiData(list/data, mob/user)
	CheckAccountValidity()
	var/obj/item/card/id/available_id = GetAvailableIdCard(user)
	var/list/totals = GetCartTotals()
	var/user_acct_num = account ? account.account_number : null
	if(!user_acct_num && istype(available_id))
		user_acct_num = available_id.associated_account_number

	data["src"] = ref(src)
	data["screen"] = current_tab
	data["user_greeting"] = (user && user.name) ? "WELCOME, [uppertext(user.name)]" : "WELCOME TO SUPPLY ORDER TERMINAL"
	data["currency"] = GLOB.using_map?.local_currency_name || "Credits"
	data["currency_short"] = GLOB.using_map?.local_currency_name_short || "cr"
	data["faction"] = faction
	data["has_account"] = istype(account)
	data["account_owner_name"] = account ? account.owner_name : ""
	data["account_number"] = account ? account.account_number : 0
	data["account_money"] = account ? round(account.money, 0.01) : 0
	data["has_available_id"] = istype(available_id)
	data["can_link_id_account"] = istype(available_id) && !!available_id.associated_account_number
	data["available_id_name"] = available_id ? (available_id.registered_name || available_id.name) : ""
	data["available_id_account_number"] = available_id ? available_id.associated_account_number : 0
	data["cart_count"] = totals["count"]
	data["cart_subtotal"] = totals["subtotal"]
	data["cart_fee"] = totals["fee"]
	data["cart_total"] = totals["total"]
	data["handling_fee_percent"] = "[round(SSsupply.handling_fee * 100)]%"
	data["order_count"] = length(SSsupply.order_queue)
	data["my_order_count"] = GetMyOrderCount(user_acct_num)
	data["orders_locked"] = (world.time < order_cooldown_until)
	data["cart_form_mode"] = cart_form_mode
	data["saved_carts"] = SerializeSavedCarts()
	data["orders_filter"] = orders_filter

/datum/computer_file/program/supply_order/proc/BuildGoodsScreenData(list/data, mob/user = null)
	var/datum/trading_station/selected_station = EnsureSelectedStation()
	var/list/stations = SerializeVisibleStations()
	data["has_visible_stations"] = length(stations) ? TRUE : FALSE
	data["stations"] = stations
	data["has_selected_station"] = istype(selected_station)
	data["selected_category"] = chosen_category || ""
	if(istype(selected_station))
		var/block_reason = GetStationTradeBlockReason(selected_station)
		data["selected_station"] = list(
			"name" = selected_station.name,
			"uid" = selected_station.uid,
			"block_reason" = block_reason || ""
		)
		if(!block_reason)
			data["categories"] = SerializeCategories(selected_station)
			data["goods"] = SerializeGoods(selected_station, user)
		else
			data["categories"] = list()
			data["goods"] = list()
	else
		data["categories"] = list()
		data["goods"] = list()

/datum/computer_file/program/supply_order/proc/BuildCartScreenData(list/data)
	var/list/totals = GetCartTotals()
	var/block = GetSubmitBlockReason(totals)
	data["cart_groups"] = SerializeShopListGroups(shopping_list, faction)
	data["can_submit_order"] = !block
	data["submit_block_reason"] = block || ""
	data["order_reason"] = order_reason || ""

/datum/computer_file/program/supply_order/proc/SerializeOrders(mob/user)
	var/list/result = list()
	var/user_acct_num = account ? account.account_number : null
	if(!user_acct_num && istype(user))
		var/obj/item/card/id/id_card = user.GetIdCard()
		if(istype(id_card))
			user_acct_num = id_card.associated_account_number
	var/total_serialized = 0
	for(var/order_id as anything in SSsupply.order_queue)
		if(total_serialized >= 50)
			break
		var/list/order_data = SSsupply.order_queue[order_id]
		if(!islist(order_data))
			continue
		var/datum/money_account/requestor = order_data["requesting_acct"]
		var/is_mine = requestor && user_acct_num && (requestor.account_number == user_acct_num)
		if(orders_filter == "mine" && !is_mine)
			continue
		var/is_processing = (order_data["processing"] || order_data["status"] == "processing")
		var/buyer_faction = order_data["buyer_faction"] || FACTION_INDEPENDENT
		var/list/price_snapshot = order_data["price_snapshot"]
		result.Add(list(list(
			"id" = order_id,
			"requestor_name" = requestor ? requestor.owner_name : "Unknown",
			"requestor_account_number" = requestor ? requestor.account_number : 0,
			"buyer_faction" = buyer_faction,
			"cost" = round(order_data["cost"], 0.01),
			"fee" = round(order_data["fee"], 0.01),
			"total" = round(order_data["cost"] + order_data["fee"], 0.01),
			"reason" = order_data["reason"] || "Not provided",
			"status" = order_data["status"] || "Pending",
			"status_tone" = is_processing ? "bad" : "average",
			"is_mine" = is_mine,
			"can_cancel" = is_mine && !is_processing,
			"selected" = (current_order == order_id),
			"contents" = SerializeShopListGroups(order_data["contents"], buyer_faction, price_snapshot)
		)))
		total_serialized++
	return result

/datum/computer_file/program/supply_order/proc/BuildOrdersScreenData(list/data, mob/user)
	data["orders"] = SerializeOrders(user)

/datum/computer_file/program/supply_order/proc/BuildAccountScreenData(list/data, mob/user)
	var/obj/item/card/id/inserted_id = GetInsertedIdCard()
	var/obj/item/card/id/held_id = user ? user.GetIdCard() : null
	data["inserted_id"] = istype(inserted_id) ? "[inserted_id.registered_name || inserted_id.name] (#[inserted_id.associated_account_number])" : "None"
	data["carried_id"] = istype(held_id) ? "[held_id.registered_name || held_id.name] (#[held_id.associated_account_number])" : "None"
	data["account_verified"] = authenticated_via_card

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
			if(good_id && isnum(amount) && !isnan(amount))
				SetInShopList(good_id, amount, station.GetGoodAmount(chosen_category, good_id))
		goods_quantity_target = null
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/HandleCartTopic(list/href_list)
	if("PRG_cart_add_good" in href_list)
		EnsureSelectedStation()
		var/block_reason = GetStationTradeBlockReason(station)
		if(block_reason)
			to_chat(usr, SPAN_WARNING(block_reason))
			return TRUE
		var/amount = text2num(href_list["PRG_cart_add_amount"]) || 1
		TryAddToCart(href_list["PRG_cart_add_good"], amount)
		return TRUE
	if("PRG_cart_remove_good" in href_list)
		EnsureSelectedStation()
		var/good_id = ResolveGoodId(chosen_category, href_list["PRG_cart_remove_good"])
		if(good_id)
			RemoveFromShopList(good_id, 1, station, chosen_category)
		return TRUE
	if("PRG_cart_form" in href_list)
		cart_form_mode = href_list["PRG_cart_form"]
		return TRUE
	if("PRG_cart_form_cancel" in href_list)
		cart_form_mode = null
		return TRUE
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
	if(HandleCartFormTopic(href_list))
		return TRUE
	if("PRG_cart_remove_direct" in href_list)
		return HandleCartRemove(href_list)
	if("PRG_cart_reset" in href_list)
		ResetShopList()
		cart_form_mode = null
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
	PopulateBaseUiData(data, user)

	switch(current_tab)
		if(SUPPLY_ORDER_TAB_GOODS)
			BuildGoodsScreenData(data, user)
		if(SUPPLY_ORDER_TAB_CART)
			BuildCartScreenData(data)
		if(SUPPLY_ORDER_TAB_ORDERS)
			BuildOrdersScreenData(data, user)
		if(SUPPLY_ORDER_TAB_ACCOUNT)
			BuildAccountScreenData(data, user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-cargo_order_client.tmpl", "Supply Order Client", 900, 700, state = GLOB.default_state)
		ui.set_initial_data(data)
		ui.open()

#undef SUPPLY_ORDER_TAB_GOODS
#undef SUPPLY_ORDER_TAB_CART
#undef SUPPLY_ORDER_TAB_ORDERS
#undef SUPPLY_ORDER_TAB_ACCOUNT
