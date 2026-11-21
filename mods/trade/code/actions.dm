/datum/tgui_module/trade/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE
	if(!SStrade.enabled)
		return TRUE
	var/mob/user = usr
	var/atom/host_atom = tgui_host(user)
	if(istype(host_atom))
		host_atom.CouldUseTopic(user)
	if(handle_ntos_act(action, params, user))
		return TRUE
	if(read_only)
		return TRUE
	if(handle_account_and_beacon_act(action, params, user))
		return TRUE
	if(handle_cart_and_saved_act(action, params, user))
		return TRUE
	if(handle_order_act(action, params, user))
		return TRUE
	if(handle_export_and_log_act(action, params, user))
		return TRUE
	return FALSE

/datum/tgui_module/trade/proc/handle_ntos_act(action, list/params, mob/user)
	var/datum/extension/interactive/ntos/os = program?.computer
	switch(action)
		if("pc_minimize")
			os?.minimize_program(program, user)
			return TRUE
		if("pc_exit")
			os?.kill_program(program)
			return TRUE
		if("pc_shutdown")
			if(os)
				os.on = FALSE
				os.system_shutdown()
			return TRUE
		if("clear_message")
			set_message("", "info")
			return TRUE
		if("set_tab")
			if(istext(params?["tab"]))
				active_tab = params["tab"]
			return TRUE
	return FALSE

/datum/tgui_module/trade/proc/handle_account_and_beacon_act(action, list/params, mob/user)
	switch(action)
		if("link_account")
			if(link_account(params["pin"]))
				set_message("Account linked for transactions.", "good")
			else
				set_message("Unable to authenticate inserted ID card. Check card and PIN.", "bad")
			return TRUE
		if("unlink_account")
			unlink_account()
			set_message("Account unlinked.", "info")
			return TRUE
		if("select_sender")
			set_selected_beacon(TRUE, params["id"])
			return TRUE
		if("select_receiver")
			set_selected_beacon(FALSE, params["id"])
			return TRUE
	return FALSE

/datum/tgui_module/trade/proc/handle_cart_and_saved_act(action, list/params, mob/user)
	switch(action)
		if("add_cart")
			var/id = params["id"]
			var/delta = max(1, round(text2num("[params["amount"]]") || 1))
			set_cart_quantity(id, (cart[id] || 0) + delta)
			return TRUE
		if("remove_cart")
			var/id = params["id"]
			var/delta = max(1, round(text2num("[params["amount"]]") || 1))
			set_cart_quantity(id, max(0, (cart[id] || 0) - delta))
			return TRUE
		if("delete_cart_item")
			set_cart_quantity(params["id"], 0)
			return TRUE
		if("set_cart_qty", "set_cart")
			set_cart_quantity(params["id"], text2num("[params["quantity"]]"))
			return TRUE
		if("fix_cart_stock")
			fix_cart_stock()
			return TRUE
		if("remove_restricted_cart")
			remove_restricted_from_cart(user)
			return TRUE
		if("clear_cart")
			cart.Cut()
			set_message("Cart cleared.", "info")
			return TRUE
		if("save_cart")
			save_current_cart(params["name"])
			return TRUE
		if("load_saved")
			load_saved_cart(params["id"], !!params["merge"])
			return TRUE
		if("delete_saved")
			delete_saved_cart(params["id"])
			return TRUE
		if("purchase", "request", "department")
			checkout(action, params, user)
			return TRUE
	return FALSE

/datum/tgui_module/trade/proc/handle_order_act(action, list/params, mob/user)
	var/datum/trade_order/order = SStrade.orders[params["id"]]
	switch(action)
		if("approve_order")
			approve_order(order, user)
			return TRUE
		if("cancel_order")
			if(order && can_view_order(order, user))
				var/ok = SStrade.cancel_order(order)
				set_message(ok ? "Order [order.id] cancelled." : "Cannot cancel order [order.id]. Verify refund account status and order state.", ok ? "good" : "bad")
			return TRUE
		if("print_order")
			if(order && can_view_order(order, user))
				print_text(order.get_receipt(is_manager(user) && !!params["internal"]), user)
			return TRUE
		if("save_order")
			if(order && can_view_order(order, user))
				save_order_cart(order, params["name"])
			return TRUE
		if("edit_reason")
			if(order && can_view_order(order, user))
				edit_order_reason(order, user, params["reason"])
			return TRUE
		if("reroute_order")
			if(order && can_view_order(order, user) && order.state == TRADE_PAID)
				var/ok = bind_receiver(order)
				set_message(ok ? "Delivery receiver updated for order [order.id]." : "No powered receiving beacon available.", ok ? "good" : "bad")
			return TRUE
	return FALSE

/datum/tgui_module/trade/proc/handle_export_and_log_act(action, list/params, mob/user)
	switch(action)
		if("export")
			if(!can_export(user))
				set_message("Export requires cargo manager access or a linked ID card on a local terminal.", "bad")
				return TRUE
			var/obj/machinery/trade_beacon/sending/sender = get_sender(require_ready = FALSE)
			if(!sender)
				set_message(is_slave() ? "No sending trade beacon found in this room." : "No sending trade beacon available.", "bad")
				return TRUE
			if(!sender.is_ready())
				set_message("Sending beacon [sender.get_id()] is offline, open, or cooling down from bluespace instability.", "bad")
				return TRUE
			if(world.time < sender.export_ready_at)
				var/wait_s = ceil((sender.export_ready_at - world.time) / (1 SECOND))
				set_message("Sending beacon is recharging ([wait_s]s remaining).", "bad")
				return TRUE
			var/exported = SStrade.export(sender)
			set_message(exported ? "Exported [exported] item(s) from [sender.get_id()]." : "No exportable items found on [sender.get_id()] (check for protected items or non-exportable goods).", exported ? "good" : "bad")
			return TRUE
		if("fulfill")
			if(!can_export(user))
				set_message("Link an ID card to claim local bounty rewards.", "bad")
				return TRUE
			fulfill(params["station_id"], params["offer_id"])
			return TRUE
		if("fulfill_all")
			if(!can_export(user))
				set_message("Link an ID card to claim local bounty rewards.", "bad")
				return TRUE
			var/obj/machinery/trade_beacon/sending/sender = get_sender(require_ready = FALSE)
			if(!sender || !sender.is_ready() || world.time < sender.export_ready_at)
				set_message("Sending beacon is not ready for bounty transfer.", "bad")
				return TRUE
			var/count = SStrade.fulfill_all_offers(sender, is_hacked(), get_bounty_account(), is_slave())
			set_message(count ? "Fulfilled [count] bounty contract(s)." : "No complete bounty contracts matched items on [sender.get_id()].", count ? "good" : "bad")
			return TRUE
		if("load_logs")
			var/req_page = round(text2num("[params["page"]]") || 1)
			var/req_size = round(text2num("[params["page_size"]]") || logs_page_size)
			logs_page = max(1, req_page)
			logs_page_size = clamp(req_size, 5, 50)
			return TRUE
		if("print_log")
			print_log(text2num("[params["id"]]"), user, !!params["internal"])
			return TRUE
	return FALSE

/datum/tgui_module/trade/proc/set_cart_quantity(id, quantity)
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

/datum/tgui_module/trade/proc/fix_cart_stock()
	var/adjusted = 0
	for(var/id in cart.Copy())
		var/datum/trade_good/good = SStrade.goods[id]
		if(!good || good.stock <= 0)
			cart -= id
			adjusted++
		else if(cart[id] > good.stock)
			cart[id] = good.stock
			adjusted++
	set_message(adjusted ? "Adjusted [adjusted] cart line(s) to current available stock." : "All cart items are within available stock.", "info")

/datum/tgui_module/trade/proc/remove_restricted_from_cart(mob/user)
	var/removed = 0
	var/hacked = is_hacked()
	var/obj/item/card/id/card = get_inserted_card()
	for(var/id in cart.Copy())
		var/datum/trade_good/good = SStrade.goods[id]
		if(!good || !good.is_available(hacked, user, personal = TRUE, card = card))
			cart -= id
			removed++
	set_message(removed ? "Removed [removed] department-restricted item(s) from cart." : "No restricted items in cart.", "info")

/datum/tgui_module/trade/proc/get_cart_total_count()
	var/count = 0
	for(var/id in cart)
		count += cart[id]
	return count

/datum/tgui_module/trade/proc/save_current_cart(raw_name)
	if(!length(cart))
		set_message("Cart is empty.", "bad")
		return
	if(length(saved_carts) >= TRADE_SAVED_CART_LIMIT)
		set_message("Saved cart limit reached.", "bad")
		return
	var/title = sanitize(raw_name, 64, encode = FALSE)
	if(!title)
		set_message("Enter a valid cart name (max 64 characters).", "bad")
		return
	next_saved_id++
	var/id = "S[next_saved_id]"
	saved_carts[id] = cart.Copy()
	saved_names[id] = title
	if(program?.frontier_trade_state)
		program.frontier_trade_state["next_id"] = next_saved_id
	set_message("Saved cart '[title]'.", "good")

/datum/tgui_module/trade/proc/load_saved_cart(id, merge = FALSE)
	if(!islist(saved_carts[id]))
		return
	var/list/saved = saved_carts[id]
	if(!merge)
		cart.Cut()
	var/short_count = 0
	for(var/good_id in saved)
		var/datum/trade_good/good = SStrade.goods[good_id]
		var/desired = (merge ? (cart[good_id] || 0) : 0) + saved[good_id]
		if(!good || good.stock < desired)
			short_count++
		set_cart_quantity(good_id, desired)
	var/title = saved_names[id] || id
	if(short_count)
		set_message("[merge ? "Merged" : "Loaded"] '[title]' ([short_count] item(s) limited by current stock).", "info")
	else
		set_message("[merge ? "Merged" : "Loaded"] saved cart '[title]'.", "good")

/datum/tgui_module/trade/proc/delete_saved_cart(id)
	if(!(id in saved_carts))
		return
	saved_carts -= id
	saved_names -= id
	set_message("Deleted saved cart.", "info")

/datum/tgui_module/trade/proc/diagnose_cart_error(list/purchase_cart, hacked, mob/user, personal, obj/item/card/id/card)
	if(!length(purchase_cart))
		return "Cart is empty."
	var/total_units = 0
	for(var/id in purchase_cart)
		var/datum/trade_good/good = SStrade.goods[id]
		var/qty = purchase_cart[id]
		if(!good)
			return "Unknown catalog item '[id]'."
		if(!good.station.discovered || (good.station.black_market && !hacked))
			return "Relay '[good.station.name]' is not currently reachable."
		if(!good.sec_available(hacked))
			return "Item '[good.name]' requires [good.security_label || "elevated security alert"]."
		if(!good.is_available(hacked, user, personal, card))
			var/req_txt = length(good.access_labels) ? " ([jointext(good.access_labels, ", ")])" : ""
			return "Item '[good.name]' requires department authorization[req_txt]. Submit a department requisition instead."
		if(qty > good.stock)
			return "Out of stock: '[good.name]' has [good.stock] left in stock (cart has [qty])."
		total_units += qty
	if(total_units > TRADE_ORDER_LIMIT)
		return "Cart total ([total_units] units) exceeds the [TRADE_ORDER_LIMIT]-unit order limit."
	return null

/datum/tgui_module/trade/proc/checkout(kind, list/params, mob/user)
	var/request_key = kind == "request" ? get_user_key(user) : null
	if(request_key && world.time < SStrade.request_ready_at[request_key])
		var/wait_s = ceil((SStrade.request_ready_at[request_key] - world.time) / (1 SECOND))
		set_message("Wait [wait_s]s between department requisitions.", "bad")
		return
	var/personal = kind == "purchase"
	var/datum/money_account/account = resolve_checkout_account(kind, params["pin"], user)
	if(kind != "request" && !account)
		set_message(personal ? "Personal purchase requires a valid inserted ID card (and PIN if required)." : "Department checkout requires Cargo authorization.", "bad")
		return
	var/reason = kind == "request" ? sanitize(params["reason"], 256, encode = FALSE) : "Direct purchase"
	if(!reason)
		set_message("Enter a requisition reason.", "bad")
		return
	var/list/purchase_cart = cart.Copy()
	var/obj/item/card/id/card = get_inserted_card()
	var/hacked = (kind == "request" ? FALSE : is_hacked())
	var/cart_err = diagnose_cart_error(purchase_cart, hacked, user, personal, card)
	if(cart_err)
		set_message(cart_err, "bad")
		return
	var/datum/trade_order/order = SStrade.create_order(
		purchase_cart,
		personal ? card?.registered_name : user.real_name,
		reason,
		hacked = hacked,
		user = user,
		personal = personal,
		card = card,
		request_key = request_key,
	)
	finish_checkout(order, account, personal, user, kind == "request")

/datum/tgui_module/trade/proc/resolve_checkout_account(kind, raw_pin, mob/user)
	if(kind == "department")
		return is_manager(user) ? TRADE_SUPPLY_ACCOUNT : null
	if(kind != "purchase")
		return null
	var/datum/money_account/linked = get_linked_account()
	if(linked && linked == get_card_account() && linked_card == get_inserted_card())
		return linked
	return authenticate(raw_pin)

/datum/tgui_module/trade/proc/authorize_cart(list/purchase_cart, mob/user, obj/item/card/id/card)
	for(var/id in purchase_cart)
		var/datum/trade_good/good = SStrade.goods[id]
		if(good && !good.is_available(is_hacked(), user, personal = TRUE, card = card))
			set_message("Item [good.name] requires department authorization. Submit a department funding request instead.", "bad")
			return FALSE
	return TRUE

/datum/tgui_module/trade/proc/finish_checkout(datum/trade_order/order, datum/money_account/account, personal, mob/user, request_only)
	if(!order)
		set_message("Order validation failed: check stock, access permissions, and relay discovery.", "bad")
		return
	order.requester_key = get_user_key(user)
	if(!request_only)
		var/fee = personal ? ceil(order.total * TRADE_HANDLING_FEE) : 0
		var/needed_funds = order.total + fee
		if(!account || account.suspended)
			SStrade.orders -= order.id
			qdel(order)
			set_message("Payment failed: target money account is unavailable or suspended.", "bad")
			return
		if(account.money < needed_funds)
			var/cur = GLOB.using_map.local_currency_name
			var/short_by = needed_funds - account.money
			SStrade.orders -= order.id
			qdel(order)
			set_message("Insufficient funds in '[account.owner_name]': need [needed_funds] [cur], have [account.money] [cur] (short by [short_by] [cur]).", "bad")
			return
		if(!bind_receiver(order))
			SStrade.orders -= order.id
			qdel(order)
			set_message(is_slave() ? "No powered receiving trade beacon found in this room." : "No powered receiving trade beacon available.", "bad")
			return
	if(request_only || SStrade.pay_order(order, account, personal, is_hacked(), user, get_inserted_card()))
		if(!request_only)
			SStrade.deliver(order)
		set_message("Order [order.id]: [order.state].", "good")
		for(var/id in order.lines)
			cart[id] = max(0, cart[id] - order.lines[id])
			if(!cart[id])
				cart -= id
		return
	SStrade.orders -= order.id
	qdel(order)
	set_message("Payment failed: verify account status, stock availability, and receiving beacon.", "bad")

/datum/tgui_module/trade/proc/approve_order(datum/trade_order/order, mob/user)
	if(!order || !is_manager(user))
		return
	var/datum/money_account/supply = TRADE_SUPPLY_ACCOUNT
	if(!supply || supply.suspended)
		set_message("Approval failed: Supply department account is unavailable or suspended.", "bad")
		return
	if(supply.money < order.total)
		var/cur = GLOB.using_map.local_currency_name
		set_message("Insufficient Supply budget for [order.id]: need [order.total] [cur], available [supply.money] [cur].", "bad")
		return
	var/cart_err = diagnose_cart_error(order.lines, FALSE, user, FALSE, null)
	if(cart_err)
		set_message("Cannot approve [order.id]: [cart_err]", "bad")
		return
	var/prev_receiver = order.receiver_id
	var/area/prev_area = order.delivery_area
	if(bind_receiver(order) && SStrade.pay_order(order, supply, FALSE, FALSE))
		SStrade.deliver(order)
		set_message("Requisition [order.id] approved ([order.state]).", "good")
		return
	order.receiver_id = prev_receiver
	order.delivery_area = prev_area
	set_message("Approval failed for [order.id]: check receiving beacon and stock.", "bad")

/datum/tgui_module/trade/proc/save_order_cart(datum/trade_order/order, raw_name)
	if(length(saved_carts) >= TRADE_SAVED_CART_LIMIT)
		set_message("Saved cart limit reached.", "bad")
		return
	var/title = sanitize(raw_name || order.id, 64, encode = FALSE)
	if(!title)
		set_message("Enter a valid cart name.", "bad")
		return
	var/id = "S[++next_saved_id]"
	saved_carts[id] = order.lines.Copy()
	saved_names[id] = title
	if(program?.frontier_trade_state)
		program.frontier_trade_state["next_id"] = next_saved_id
	set_message("Saved order [order.id] as '[title]'.", "good")

/datum/tgui_module/trade/proc/edit_order_reason(datum/trade_order/order, mob/user, raw_reason)
	if(order.state != TRADE_REQUEST || (!is_manager(user) && order.requester_key != get_user_key(user)))
		return
	var/reason = sanitize(raw_reason, 256, encode = FALSE)
	if(!reason)
		set_message("Enter a valid requisition reason.", "bad")
		return
	order.reason = reason
	set_message("Updated reason for order [order.id].", "good")

/datum/tgui_module/trade/proc/fulfill(station_id, offer_id)
	var/datum/trade_station/station = SStrade.stations[station_id]
	var/datum/trade_offer/offer = station?.offers[offer_id]
	var/obj/machinery/trade_beacon/sending/sender = get_sender(require_ready = FALSE)
	if(!sender || !sender.is_ready() || world.time < sender.export_ready_at)
		set_message("Sending beacon is not ready for bounty transfer.", "bad")
		return
	var/ok = SStrade.fulfill_offer(sender, offer, is_hacked(), get_bounty_account(), is_slave())
	set_message(ok ? "Fulfilled bounty '[offer?.name]'." : "Bounty requirements not met on [sender.get_id()] ([offer?.get_requirements() || "check required items"]).", ok ? "good" : "bad")

/datum/tgui_module/trade/proc/can_view_log(list/entry, mob/user)
	var/datum/money_account/account = get_linked_account()
	return is_manager(user) || (user && entry["requester_key"] == get_user_key(user)) || (account && entry["account_number"] == account.account_number)

/datum/tgui_module/trade/proc/print_log(id, mob/user, internal = FALSE)
	for(var/list/entry as anything in SStrade.shipping_log)
		if(entry["id"] == id && can_view_log(entry, user))
			print_text(SStrade.get_log_receipt(entry, internal && is_manager(user)), user)
			return
