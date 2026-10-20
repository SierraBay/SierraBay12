/datum/nano_module/program/trade/Topic(href, list/href_list)
	if(..())
		return TRUE
	if(!SStrade.enabled || !can_still_topic())
		return TRUE
	var/mob/user = usr
	message = ""
	navigate(href_list)
	if(href_list["page_input"])
		input_page(user)
		return TRUE
	if(read_only)
		return TRUE
	if(href_list["PRG_account_unlink"])
		unlink_account()
		return TRUE
	if(href_list["PRG_account"])
		link_account(user)
		return TRUE
	if(href_list["quantity"])
		input_cart_quantity(href_list["quantity"], user)
		return TRUE
	if(href_list["add"] || href_list["remove"] || href_list["clear"])
		change_cart(href_list)
		return TRUE
	if(href_list["save"] || href_list["load"] || href_list["delete_saved"])
		change_saved(href_list, user)
		return TRUE
	if(href_list["purchase"] || href_list["request"] || href_list["department"])
		checkout(href_list, user)
		return TRUE
	if(href_list["approve"] || href_list["cancel"] || href_list["print"] || href_list["save_order"] || href_list["edit_reason"] || href_list["reroute"])
		order_action(href_list, user)
		return TRUE
	if(href_list["PRG_sending"] || href_list["PRG_receiving"])
		select_beacon(!!href_list["PRG_sending"], user)
		return TRUE
	if(can_export(user))
		manage_exports(href_list, user)
	if(href_list["log_receipt"])
		print_log(text2num(href_list["log_receipt"]), user, !!href_list["internal"])
	return TRUE

/datum/nano_module/program/trade/proc/navigate(list/href_list)
	if(href_list["PRG_prg_screen"])
		prg_screen = !prg_screen
	var/station_id = href_list["PRG_station"] || href_list["station"]
	var/datum/trade_station/station = SStrade.stations[station_id]
	if(station && (!station.black_market || is_hacked()))
		selected_station = station_id
		chosen_category = ""
		pages["goods"] = 1
		pages["offers"] = 1
	if(href_list["category"])
		select_category(href_list["category"])
		pages["goods"] = 1
	if(href_list["cart_station"])
		cart_station = href_list["cart_station"] == "All" ? "" : href_list["cart_station"]
		cart_category = ""
		pages["cart"] = 1
	if(href_list["cart_category"])
		cart_category = href_list["cart_category"] == "All" ? "" : href_list["cart_category"]
		pages["cart"] = 1
	if(href_list["view_order"])
		selected_order_id = href_list["view_order"]
	if(href_list["view_log"])
		selected_log_id = text2num(href_list["view_log"])
	if(href_list["log_filter"] in list("All", "Request", "Purchase", "Delivery", "Export", "Bounty", "Refund", "Cancelled"))
		log_filter = href_list["log_filter"]
		pages["logs"] = 1
	if(href_list["PRG_page"])
		pages[screen] = clamp(round(text2num(href_list["PRG_page"])), 1, 10000)
	if(read_only)
		if(href_list["screen"] in list("goods", "offers"))
			screen = href_list["screen"]
		return
	if(href_list["screen"] in list("goods", "cart", "offers", "orders", "saved", "logs"))
		screen = href_list["screen"]

/datum/nano_module/program/trade/proc/manage_exports(list/href_list, mob/user)
	if(href_list["export"])
		message = SStrade.export(get_sender()) ? "Export completed." : "Export unavailable or no eligible goods."
	else if(href_list["fulfill"])
		fulfill(href_list["fulfill"])
	else if(href_list["PRG_offer_fulfill_all"])
		var/count = SStrade.fulfill_all_offers(get_sender(), is_hacked(), get_bounty_account(), is_slave())
		message = count ? "Fulfilled [count] bounties." : "No complete bounties available. Check the beacon, goods and supply account."

/datum/nano_module/program/trade/proc/change_cart(list/action)
	if(action["clear"])
		cart.Cut()
	var/id = action["add"] || action["remove"]
	set_cart_quantity(id, (cart[id] || 0) + (action["add"] ? 1 : -1))

/datum/nano_module/program/trade/proc/input_cart_quantity(id, mob/user)
	var/datum/trade_good/good = SStrade.goods[id]
	if(!good || !good.is_available(is_hacked()))
		return
	var/quantity = input(user, "Quantity of [good.name]", "Trade", cart[id] || 0) as null|num
	if(QDELETED(src) || isnull(quantity) || !can_still_topic())
		return
	set_cart_quantity(id, quantity)

/datum/nano_module/program/trade/proc/set_cart_quantity(id, quantity)
	if(!isnum(quantity) || quantity != round(quantity) || quantity < 0)
		return
	if(!quantity)
		cart -= id
		return
	var/datum/trade_good/good = SStrade.goods[id]
	if(!good || !good.station.discovered || !good.is_available(is_hacked()))
		return
	var/other_count = get_cart_total_count() - (cart[id] || 0)
	cart[id] = clamp(quantity, 0, min(good.stock, max(0, TRADE_ORDER_LIMIT - other_count)))
	if(!cart[id])
		cart -= id

/datum/nano_module/program/trade/proc/get_cart_total_count()
	var/count = 0
	for(var/id in cart)
		count += cart[id]
	return count

/datum/nano_module/program/trade/proc/change_saved(list/action, mob/user)
	if(action["save"] && length(saved_carts) < TRADE_SAVED_CART_LIMIT && length(cart))
		var/title = sanitize(input(user, "Saved cart name", "Trade") as null|text, 64)
		if(!title || QDELETED(src) || !can_still_topic())
			return
		next_saved_id++
		var/id = "S[next_saved_id]"
		saved_carts[id] = cart.Copy()
		saved_names[id] = title
	if(action["load"] && islist(saved_carts[action["load"]]))
		var/list/saved = saved_carts[action["load"]]
		cart = saved.Copy()
	if(action["delete_saved"])
		saved_carts -= action["delete_saved"]
		saved_names -= action["delete_saved"]
	program.frontier_trade_state["cart"] = cart
	program.frontier_trade_state["next_id"] = next_saved_id

/datum/nano_module/program/trade/proc/checkout(list/action, mob/user)
	if(!!action["purchase"] + !!action["request"] + !!action["department"] != 1)
		return
	var/request_key = action["request"] ? get_user_key(user) : null
	if(request_key && world.time < SStrade.request_ready_at[request_key])
		message = "Wait ten seconds between requisitions."
		return
	var/list/purchase_cart = cart.Copy()
	var/datum/money_account/account
	var/personal = !!action["purchase"]
	if(personal)
		account = authenticate(user)
	else if(action["department"] && is_manager(user))
		account = TRADE_SUPPLY_ACCOUNT
	if(QDELETED(src))
		return
	if(!action["request"] && !account)
		message = "Payment requires a valid inserted ID or cargo access."
		return
	var/reason = action["request"] ? sanitize(input(user, "Reason for department funding", "Trade requisition") as null|text, 256) : "Direct purchase"
	if(!reason || QDELETED(src) || !can_still_topic() || (action["department"] && !is_manager(user)))
		return
	var/obj/item/card/id/card = get_inserted_card()
	if(personal && !authorize_cart(purchase_cart, user, card))
		return
	var/datum/trade_order/order = SStrade.create_order(
		purchase_cart,
		personal ? card?.registered_name : user.real_name,
		reason,
		hacked = action["request"] ? FALSE : is_hacked(),
		user = user,
		personal = personal,
		card = card,
		request_key = request_key,
	)
	finish_checkout(order, account, personal, user, !!action["request"])

/datum/nano_module/program/trade/proc/authorize_cart(list/purchase_cart, mob/user, obj/item/card/id/card)
	for(var/id in purchase_cart)
		var/datum/trade_good/good = SStrade.goods[id]
		if(good && !good.is_available(is_hacked(), user, personal = TRUE, card = card))
			message = "Item [good.name] requires department authorization. Submit a department funding request instead."
			return FALSE
	return TRUE

/datum/nano_module/program/trade/proc/finish_checkout(datum/trade_order/order, datum/money_account/account, personal, mob/user, request_only)
	if(!order)
		message = "Cart unavailable: check discovery, permissions, stock and quantities."
		return
	order.requester_key = get_user_key(user)
	if(request_only || (bind_receiver(order) && SStrade.pay_order(order, account, personal, is_hacked(), user, get_inserted_card())))
		message = "Order [order.id]: [order.state]."
		for(var/id in order.lines)
			cart[id] = max(0, cart[id] - order.lines[id])
			if(!cart[id])
				cart -= id
		selected_order_id = order.id
		screen = "orders"
		return
	SStrade.orders -= order.id
	qdel(order)
	message = "Payment failed: check funds, account status, stock and receiving beacon."

/datum/nano_module/program/trade/proc/order_action(list/action, mob/user)
	var/id = action["approve"] || action["cancel"] || action["print"] || action["save_order"] || action["edit_reason"] || action["reroute"]
	var/datum/trade_order/order = SStrade.orders[id]
	if(!order || !can_view_order(order, user))
		return
	if(action["approve"] && is_manager(user))
		message = bind_receiver(order) && SStrade.pay_order(order, TRADE_SUPPLY_ACCOUNT, FALSE, FALSE) ? "Requisition approved." : "Approval failed. Check stock, funds and receiver."
	else if(action["cancel"])
		message = SStrade.cancel_order(order) ? "Order cancelled." : "Cannot cancel. Check refund accounts and order state."
	else if(action["print"])
		print_text(order.get_receipt(is_manager(user) && !!action["internal"]), user)
	else if(action["save_order"])
		save_order_cart(order, user)
	else if(action["edit_reason"])
		edit_order_reason(order, user)
	else if(action["reroute"] && order.state == TRADE_PAID)
		message = bind_receiver(order) ? "Delivery receiver updated." : "No clear receiving beacon selected."

/datum/nano_module/program/trade/proc/save_order_cart(datum/trade_order/order, mob/user)
	if(length(saved_carts) >= TRADE_SAVED_CART_LIMIT)
		return
	var/title = sanitize(input(user, "Saved cart name", "Trade", order.id) as null|text, 64)
	if(!title || QDELETED(src) || !can_still_topic() || !can_view_order(order, user))
		return
	var/id = "S[++next_saved_id]"
	saved_carts[id] = order.lines.Copy()
	saved_names[id] = title
	program.frontier_trade_state["next_id"] = next_saved_id

/datum/nano_module/program/trade/proc/edit_order_reason(datum/trade_order/order, mob/user)
	if(order.state != TRADE_REQUEST || (!is_manager(user) && order.requester_key != get_user_key(user)))
		return
	var/reason = sanitize(input(user, "Requisition reason", "Trade", order.reason) as null|text, 256)
	if(!reason || QDELETED(src) || QDELETED(order) || !can_still_topic() || order.state != TRADE_REQUEST)
		return
	if(is_manager(user) || order.requester_key == get_user_key(user))
		order.reason = reason

/datum/nano_module/program/trade/proc/fulfill(id)
	var/datum/trade_station/station = SStrade.stations[selected_station]
	var/datum/trade_offer/offer = station?.offers[id]
	message = SStrade.fulfill_offer(get_sender(), offer, is_hacked(), get_bounty_account(), is_slave()) ? "Bounty fulfilled." : "Bounty unavailable or matching goods missing."

/datum/nano_module/program/trade/proc/can_view_log(list/entry, mob/user)
	var/datum/money_account/account = get_linked_account()
	return is_manager(user) || (user && entry["requester_key"] == get_user_key(user)) || (account && entry["account_number"] == account.account_number)

/datum/nano_module/program/trade/proc/print_log(id, mob/user, internal = FALSE)
	for(var/list/entry as anything in SStrade.shipping_log)
		if(entry["id"] == id && can_view_log(entry, user))
			print_text(SStrade.get_log_receipt(entry, internal && is_manager(user)), user)
			return

/datum/nano_module/program/trade/proc/select_category(category)
	if(category == "All")
		chosen_category = ""
		return
	for(var/list/entry as anything in build_categories_data())
		if(entry["id"] == category)
			chosen_category = category
			return

/datum/nano_module/program/trade/proc/input_page(mob/user)
	var/current_screen = screen
	var/page = input(user, "Page number", "Trade", pages[screen] || 1) as null|num
	if(QDELETED(src) || isnull(page) || !can_still_topic() || screen != current_screen)
		return
	pages[screen] = clamp(round(page), 1, 10000)
