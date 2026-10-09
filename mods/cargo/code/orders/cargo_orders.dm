/datum/cargo_order
	var/id
	var/datum/money_account/requesting_acct
	var/reason
	var/buyer_faction
	var/cost = 0
	var/fee = 0
	var/status = CARGO_ORDER_PENDING
	var/list/contents
	var/list/price_snapshot
	var/viewable_contents
	var/datum/money_account/escrow_account
	var/escrow_amount = 0
	var/pending_refund = 0

/datum/cargo_order/New(new_id, datum/money_account/account, new_reason, list/cart, new_faction)
	..()
	ASSERT(istext(new_id) && istype(account) && is_valid_cargo_cart(cart))
	id = new_id
	requesting_acct = account
	reason = new_reason
	buyer_faction = new_faction || FACTION_INDEPENDENT
	contents = copy_cargo_cart(cart)
	price_snapshot = SSsupply.BuildMarketSnapshot(contents, new_faction)
	Recalculate()

/datum/cargo_order/Destroy()
	if(SSsupply?.order_queue?[id] == src)
		SSsupply.order_queue -= id
	clear_cargo_cart(contents)
	contents = null
	clear_cargo_quote(price_snapshot)
	price_snapshot = null
	requesting_acct = null
	escrow_account = null
	buyer_faction = null
	return ..()

/datum/cargo_order/proc/IsLocked()
	return status != CARGO_ORDER_PENDING

/datum/cargo_order/proc/Recalculate()
	cost = SSsupply.GetSnapshotTotalCost(price_snapshot, contents, buyer_faction)
	var/datum/money_account/master_account = get_supply_department_account()
	fee = master_account && requesting_acct == master_account ? 0 : round(cost * SSsupply.handling_fee, 0.01)
	viewable_contents = SSsupply.BuildOrderViewableContents(contents)

/datum/cargo_order/proc/RemoveStation(station_uid)
	if(!(station_uid in contents) && !(station_uid in price_snapshot))
		return FALSE
	var/list/goods = contents[station_uid]
	goods?.Cut()
	contents -= station_uid
	clear_cargo_station_quote(price_snapshot[station_uid])
	price_snapshot -= station_uid
	Recalculate()
	return TRUE

/datum/controller/subsystem/supply/proc/GetCargoOrder(order_id)
	var/datum/cargo_order/order = order_queue[order_id]
	return istype(order) && !QDELETED(order) ? order : null

/datum/controller/subsystem/supply/proc/DismantleOrder(order_id)
	var/datum/cargo_order/order = GetCargoOrder(order_id)
	if(!order || order.IsLocked())
		return FALSE
	order.status = CARGO_ORDER_CANCELLED
	qdel(order)
	return TRUE

/datum/controller/subsystem/supply/proc/PurgeStationFromOrders(datum/trading_station/station)
	if(!istype(station) || !islist(order_queue) || !(station in all_trading_stations))
		return
	for(var/order_id in order_queue.Copy())
		var/datum/cargo_order/order = GetCargoOrder(order_id)
		if(order?.RemoveStation(station.uid) && !length(order.contents))
			DismantleOrder(order_id)

/datum/controller/subsystem/supply/proc/BuildOrderViewableContents(list/shopping_list)
	. = ""
	for(var/list/item_data as anything in ExtractCartItems(shopping_list))
		var/datum/trade_offer/offer = item_data["offer"]
		. += "<li>[item_data["count"]]x [offer.name]</li>"

/datum/controller/subsystem/supply/proc/BuildOrder(datum/money_account/requesting_account, reason, list/shopping_list, buyer_faction = null)
	if(!istype(requesting_account) || QDELETED(requesting_account) || CollectCountsFrom(shopping_list) <= 0)
		return null
	var/order_id = "order_[++order_queue_id]"
	var/datum/cargo_order/order = new(order_id, requesting_account, reason, shopping_list, buyer_faction)
	order_queue[order_id] = order
	return order_id

/datum/controller/subsystem/supply/proc/RefundEscrowOrder(datum/cargo_order/order)
	ASSERT(istype(order))
	if(!order.escrow_amount)
		order.status = CARGO_ORDER_PENDING
		if(!length(order.contents))
			DismantleOrder(order.id)
		return TRUE
	order.pending_refund = order.escrow_amount
	order.status = CARGO_ORDER_REFUND_PENDING
	if(order.TryRefund())
		return TRUE
	var/account_name = order.requesting_acct?.owner_name || "Unavailable account"
	CreateLogEntry("Order", account_name, "<li>Order [order.id]: refund pending ([order.pending_refund]).</li>", 0)
	return FALSE

/datum/controller/subsystem/supply/proc/CompleteOrder(order_id)
	var/datum/cargo_order/order = GetCargoOrder(order_id)
	if(!order || order.status != CARGO_ORDER_PROCESSING)
		return FALSE
	order.status = CARGO_ORDER_COMPLETED
	qdel(order)
	return TRUE

/datum/controller/subsystem/supply/proc/PurchaseOrder(obj/machinery/trade_beacon/receiving/beacon, order_id)
	if(QDELETED(beacon) || !istype(beacon) || !beacon.operable())
		return FALSE
	var/datum/cargo_order/order = GetCargoOrder(order_id)
	if(!order || order.IsLocked())
		return FALSE
	var/datum/money_account/master_account = get_supply_department_account()
	var/datum/money_account/requesting_account = order.requesting_acct
	if(!master_account || !requesting_account || QDELETED(master_account) || QDELETED(requesting_account) || master_account.suspended || requesting_account.suspended)
		return FALSE
	return ExecuteOrderPurchase(beacon, order, master_account, requesting_account)

/datum/controller/subsystem/supply/proc/ExecuteOrderPurchase(obj/machinery/trade_beacon/receiving/beacon, datum/cargo_order/order, datum/money_account/master_account, datum/money_account/requesting_account)
	var/total_cost = order.cost + order.fee
	if(requesting_account.money < (master_account == requesting_account ? order.cost : total_cost))
		return FALSE
	var/datum/cargo_purchase/purchase = PreparePurchase(beacon, master_account, order.contents, order.buyer_faction, order.price_snapshot, order)
	if(!purchase)
		return FALSE
	order.status = CARGO_ORDER_PROCESSING
	var/funded = FundOrderEscrow(order, master_account)
	var/success = funded && purchase.Execute()
	qdel(purchase)
	if(!success)
		RefundEscrowOrder(order)
		return FALSE
	return FinishOrderPurchase(order, total_cost)

/datum/controller/subsystem/supply/proc/FinishOrderPurchase(datum/cargo_order/order, total_cost)
	order.ClearEscrow()
	CreateLogEntry("Order", order.requesting_acct.owner_name, order.viewable_contents, total_cost)
	CompleteOrder(order.id)
	return TRUE

/datum/cargo_order/proc/ClearEscrow()
	escrow_account = null
	escrow_amount = 0
	pending_refund = 0

/datum/cargo_order/proc/TryRefund()
	if(status != CARGO_ORDER_REFUND_PENDING || pending_refund <= 0)
		return FALSE
	if(QDELETED(escrow_account) || QDELETED(requesting_acct) || !escrow_account || !requesting_acct)
		return FALSE
	if(!escrow_account.transfer(requesting_acct, pending_refund, "Trade Network Order Refund"))
		return FALSE
	SSsupply.CreateLogEntry("Order", requesting_acct.owner_name, "<li>Order [id]: escrow refunded.</li>", -pending_refund)
	ClearEscrow()
	status = CARGO_ORDER_PENDING
	if(!length(contents))
		SSsupply.DismantleOrder(id)
	return TRUE

/datum/controller/subsystem/supply/proc/ProcessPendingOrderRefunds()
	for(var/order_id in order_queue.Copy())
		var/datum/cargo_order/order = GetCargoOrder(order_id)
		if(order?.status == CARGO_ORDER_REFUND_PENDING)
			order.TryRefund()

/datum/controller/subsystem/supply/proc/FundOrderEscrow(datum/cargo_order/order, datum/money_account/master_account)
	if(master_account == order.requesting_acct)
		return TRUE
	var/amount = order.cost + order.fee
	if(!order.requesting_acct.transfer(master_account, amount, "Trade Network Order (Escrow)"))
		return FALSE
	order.escrow_account = master_account
	order.escrow_amount = amount
	return TRUE
