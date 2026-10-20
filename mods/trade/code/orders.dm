/datum/trade_order
	var/id
	var/state = TRADE_REQUEST
	var/buyer
	var/requester_key
	var/reason
	var/datum/money_account/account
	var/list/lines = list()
	var/list/unit_prices = list()
	var/total = 0
	var/fee = 0
	var/personal = FALSE
	var/list/snapshots = list()
	var/receiver_id
	var/area/delivery_area
	var/invoice_id

/datum/trade_order/Destroy()
	account = null
	delivery_area = null
	QDEL_NULL_ASSOC_LIST(snapshots)
	lines.Cut()
	unit_prices.Cut()
	return ..()

/datum/trade_order/proc/get_floor_count()
	var/count = 1
	for(var/id in lines)
		var/datum/trade_order_line/line = snapshots[id]
		if(line?.needs_floor())
			count += lines[id]
	return count

/datum/controller/subsystem/trade/proc/create_order(list/cart, buyer, reason, hacked = FALSE, mob/user = null, personal = FALSE, obj/item/card/id/card = null, request_key = null)
	if(request_key && world.time < request_ready_at[request_key])
		return
	var/datum/trade_order/order = new
	order.buyer = buyer
	order.reason = reason
	if(!quote_order(order, cart, hacked, user, personal, card))
		qdel(order)
		return
	next_order_id++
	order.id = "T[next_order_id]"
	orders[order.id] = order
	if(request_key)
		request_ready_at[request_key] = world.time + TRADE_REQUEST_COOLDOWN
		order.requester_key = request_key
		log_transaction("Request", order.id, order.total, buyer, order.get_rows(), requester_key = request_key)
	return order

/datum/controller/subsystem/trade/proc/quote_order(datum/trade_order/order, list/cart, hacked, mob/user = null, personal = FALSE, obj/item/card/id/card = null)
	if(!length(cart) || length(cart) > TRADE_ORDER_LIMIT)
		return FALSE
	var/count = 0
	for(var/id in cart)
		var/datum/trade_good/good = goods[id]
		var/quantity = cart[id]
		if(!good || !isnum(quantity) || quantity != round(quantity) || quantity < 1 || quantity > good.stock)
			return FALSE
		if(!good.station.discovered || !good.is_available(hacked, user, personal, card))
			return FALSE
		var/datum/trade_order_line/line = new
		line.capture(good, quantity)
		order.snapshots[id] = line
		count += quantity
		order.lines[id] = quantity
		order.unit_prices[id] = good.get_price()
		order.total += good.get_price() * quantity
	return count <= TRADE_ORDER_LIMIT && order.total > 0

/datum/controller/subsystem/trade/proc/pay_order(datum/trade_order/order, datum/money_account/account, personal, hacked = FALSE, mob/user = null, obj/item/card/id/card = null)
	if(transaction_busy || !order || order.state != TRADE_REQUEST || !account || account.suspended || !get_receiver(order))
		return FALSE
	if(personal && (!user || !card || get_account(card.associated_account_number) != account))
		return FALSE
	if(!validate_lines(order, hacked, user, personal, card))
		return FALSE
	var/datum/money_account/supply = TRADE_SUPPLY_ACCOUNT
	var/fee = personal ? ceil(order.total * TRADE_HANDLING_FEE) : 0
	if((fee && (!supply || supply.suspended || supply == account)) || account.money < order.total + fee)
		return FALSE
	transaction_busy = TRUE
	var/success = commit_payment(order, account, supply, fee)
	transaction_busy = FALSE
	if(success)
		order.personal = personal
	return success

/datum/controller/subsystem/trade/proc/validate_lines(datum/trade_order/order, hacked, mob/user = null, personal = FALSE, obj/item/card/id/card = null)
	for(var/id in order.lines)
		var/datum/trade_good/good = goods[id]
		if(!good || !good.station.discovered || !good.is_available(hacked, user, personal, card) || good.stock < order.lines[id])
			return FALSE
		var/datum/trade_order_line/line = order.snapshots[id]
		if(!line || line.item_type != good.item_type || line.stack_size != good.stack_size || line.quantity != order.lines[id])
			return FALSE
		if(good.get_price() != order.unit_prices[id])
			return FALSE
	return TRUE

/datum/controller/subsystem/trade/proc/commit_payment(datum/trade_order/order, datum/money_account/account, datum/money_account/supply, fee)
	if(!account.withdraw(order.total + fee, "Trade order [order.id]", "Frontier Trade Network"))
		return FALSE
	if(fee && !supply.deposit(fee, "Handling fee [order.id]", "Frontier Trade Network"))
		account.deposit(order.total + fee, "Failed order refund [order.id]", "Frontier Trade Network")
		return FALSE
	order.account = account
	order.fee = fee
	order.state = TRADE_PAID
	for(var/id in order.lines)
		var/datum/trade_good/good = goods[id]
		good.stock -= order.lines[id]
		good.reserved_stock += order.lines[id]
	order.invoice_id = log_transaction("Purchase", order.id, order.total + fee, account.owner_name, order.get_rows(), account.account_number, fee, order.requester_key)
	return TRUE

/datum/controller/subsystem/trade/proc/cancel_order(datum/trade_order/order)
	if(transaction_busy || !order || !(order.state in list(TRADE_REQUEST, TRADE_PAID)))
		return FALSE
	if(order.state == TRADE_REQUEST)
		order.state = TRADE_CANCELLED
		log_transaction("Cancelled", order.id, 0, order.buyer, order.get_rows(), requester_key = order.requester_key)
		return TRUE
	var/datum/money_account/supply = TRADE_SUPPLY_ACCOUNT
	if(!order.account || order.account.suspended || (order.fee && (!supply || supply.suspended || supply.money < order.fee)))
		return FALSE
	transaction_busy = TRUE
	var/success = refund_order(order, supply)
	transaction_busy = FALSE
	return success

/datum/controller/subsystem/trade/proc/refund_order(datum/trade_order/order, datum/money_account/supply)
	if(order.fee && !supply.withdraw(order.fee, "Handling refund [order.id]", "Frontier Trade Network"))
		return FALSE
	if(!order.account.deposit(order.total + order.fee, "Order refund [order.id]", "Frontier Trade Network"))
		if(order.fee)
			supply.deposit(order.fee, "Failed refund rollback", "Frontier Trade Network")
		return FALSE
	for(var/id in order.lines)
		var/datum/trade_good/good = goods[id]
		if(good)
			good.stock += order.lines[id]
			good.reserved_stock -= order.lines[id]
	order.state = TRADE_CANCELLED
	log_transaction("Refund", order.id, order.total + order.fee, order.account.owner_name, order.get_rows(), order.account.account_number, order.fee, order.requester_key)
	return TRUE

/datum/controller/subsystem/trade/proc/deliver(datum/trade_order/order)
	if(transaction_busy || order.state != TRADE_PAID)
		return FALSE
	var/obj/machinery/trade_beacon/receiving/beacon = get_receiver(order)
	var/list/floors = beacon?.get_landing_turfs(order.get_floor_count())
	if(!length(floors))
		return FALSE
	transaction_busy = TRUE
	try
		create_shipment(order, beacon, floors)
	catch(var/exception/error)
		transaction_busy = FALSE
		throw error
	transaction_busy = FALSE
	return TRUE

/datum/controller/subsystem/trade/proc/create_shipment(datum/trade_order/order, obj/machinery/trade_beacon/receiving/beacon, list/floors)
	var/obj/structure/closet/secure_closet/personal/trade/crate = new(floors[1])
	var/list/spawned = list()
	try
		crate.registered_name = order.personal ? order.buyer : null
		crate.locked = order.personal
		crate.SetName("Trade shipment [order.id]")
		populate_order(order, crate, spawned)
		unpack_shipment(spawned, floors)
		beacon.activate()
	catch(var/exception/error)
		QDEL_NULL_LIST(spawned)
		qdel(crate)
		throw error
	complete_delivery(order)

/datum/controller/subsystem/trade/proc/unpack_shipment(list/spawned, list/floors)
	var/index = 2
	for(var/atom/movable/item as anything in spawned)
		if(!istype(item, /obj/item))
			item.forceMove(floors[index++])

/datum/controller/subsystem/trade/proc/complete_delivery(datum/trade_order/order)
	order.state = TRADE_DELIVERED
	for(var/id in order.lines)
		var/datum/trade_good/good = goods[id]
		if(good)
			good.reserved_stock -= order.lines[id]
		var/datum/trade_order_line/line = order.snapshots[id]
		var/datum/trade_station/station = stations[line.station_id]
		station?.add_to_wealth(line.unit_price * line.quantity)
	log_transaction("Delivery", order.id, order.total + order.fee, order.buyer, order.get_rows(), order.account?.account_number, order.fee, order.requester_key)

/datum/controller/subsystem/trade/proc/populate_order(datum/trade_order/order, obj/structure/closet/crate, list/spawned)
	for(var/id in order.snapshots)
		var/datum/trade_order_line/line = order.snapshots[id]
		for(var/count in 1 to line.quantity)
			var/atom/movable/item = line.spawn_item(crate)
			ASSERT(istype(item) && !QDELETED(item))
			spawned += item
	var/obj/item/paper/trade_invoice/invoice = new(crate)
	invoice.info = order.get_receipt()
