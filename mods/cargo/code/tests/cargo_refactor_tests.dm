/datum/money_account/cargo_test_payment
	var/reject_withdrawal = FALSE
	var/reject_refund = FALSE
	var/withdrawal_attempts = 0
	var/refund_attempts = 0
	var/obj/machinery/trade_beacon/receiving/cargo_test_delivery/test_beacon

/datum/money_account/cargo_test_payment/Destroy()
	test_beacon = null
	return ..()

/datum/money_account/cargo_test_payment/withdraw(amount, purpose, machine_id)
	withdrawal_attempts++
	test_beacon?.RememberFreightContents()
	return reject_withdrawal ? FALSE : ..()

/datum/money_account/cargo_test_payment/transfer(to_account, amount, purpose)
	if(purpose == "Trade Network Order Refund")
		refund_attempts++
		if(reject_refund)
			return FALSE
	return ..()

/obj/machinery/trade_beacon/receiving/cargo_test_delivery
	var/list/deliveries = list()
	var/reject_after = 0

/obj/machinery/trade_beacon/receiving/cargo_test_delivery/DropItem(drop_type)
	if(reject_after && length(deliveries) >= reject_after)
		RememberFreightContents()
		return null
	. = ..()
	if(.)
		deliveries += .

/obj/machinery/trade_beacon/receiving/cargo_test_delivery/Destroy()
	for(var/atom/movable/item as anything in deliveries)
		if(!QDELETED(item))
			DeleteTestFreight(item)
	deliveries.Cut()
	deliveries = null
	return ..()

/obj/machinery/trade_beacon/receiving/cargo_test_delivery/proc/RememberFreightContents()
	for(var/atom/movable/item as anything in deliveries.Copy())
		if(!QDELETED(item))
			deliveries |= item.GetAllContents()

/obj/machinery/trade_beacon/receiving/cargo_test_delivery/proc/DeleteTestFreight(atom/movable/item)
	for(var/atom/movable/content as anything in item.contents.Copy())
		DeleteTestFreight(content)
	qdel(item)

// Isolates orders and logs; restores the original accounts and station registry.
/datum/cargo_test_context
	var/list/supply_state = list()
	var/datum/money_account/old_supply_account
	var/datum/money_account/cargo_test_payment/cargo_account
	var/datum/money_account/customer_account
	var/datum/trading_station/unit_test_duplicate_pricing/station
	var/obj/machinery/trade_beacon/receiving/cargo_test_delivery/beacon
	var/list/cart
	var/good_id

/datum/cargo_test_context/New(turf/location)
	..()
	SaveSupplyState()
	old_supply_account = department_accounts["Supply"]
	cargo_account = new
	customer_account = new
	customer_account.owner_name = "Cargo refactor customer"
	customer_account.money = 1000
	department_accounts["Supply"] = cargo_account
	BuildCatalogAndBeacon(location)

/datum/cargo_test_context/proc/BuildCatalogAndBeacon(turf/location)
	station = new
	station.uid = "cargo_refactor_[ref(src)]"
	SSsupply.all_trading_stations += station
	station.AssembleInventory()
	good_id = station.offers_by_category["Alpha"][1]
	station.SetGoodAmount("Alpha", good_id, 5)
	cart = list()
	set_cargo_cart_quantity(cart, station.uid, good_id, 1)
	beacon = new(location)
	cargo_account.test_beacon = beacon

/datum/cargo_test_context/proc/SaveSupplyState()
	for(var/key in list("all_trading_stations", "order_queue", "order_queue_id", "order_log", "order_number", "shipping_log", "shipping_invoice_number"))
		supply_state[key] = SSsupply.vars[key]
		if(islist(supply_state[key]))
			var/list/original = supply_state[key]
			SSsupply.vars[key] = original.Copy()
	SSsupply.order_queue = list()
	SSsupply.order_log = list()
	SSsupply.shipping_log = list()

/datum/cargo_test_context/Destroy()
	for(var/order_id in SSsupply.order_queue.Copy())
		qdel(SSsupply.order_queue[order_id])
	QDEL_NULL(station)
	QDEL_NULL(beacon)
	QDEL_NULL(cargo_account)
	QDEL_NULL(customer_account)
	clear_cargo_cart(cart)
	cart = null
	department_accounts["Supply"] = old_supply_account
	old_supply_account = null
	for(var/key in supply_state)
		SSsupply.vars[key] = supply_state[key]
	supply_state.Cut()
	supply_state = null
	return ..()

/datum/cargo_test_context/proc/BuildTestOrder()
	var/order_id = SSsupply.BuildOrder(customer_account, "Cargo refactor test", cart, FACTION_INDEPENDENT)
	return SSsupply.GetCargoOrder(order_id)

/datum/unit_test/cargo_reject_legacy_cart_test
	name = "CARGO: Legacy carts and numeric quotes fail without side effects"

/datum/unit_test/cargo_reject_legacy_cart_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	var/fail_reason = CheckInvalidCarts(context) || CheckInvalidQuotes(context)
	if(!fail_reason && (context.customer_account.money != 1000 || context.station.GetGoodAmount("Alpha", context.good_id) != 5 || length(context.beacon.deliveries)))
		fail_reason = "Rejected input changed money, stock, or delivered freight."
	qdel(context)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("Old formats are rejected before delivery and payment.")
	return 1

/datum/unit_test/cargo_reject_legacy_cart_test/proc/CheckInvalidCarts(datum/cargo_test_context/context)
	var/list/reference_cart = list()
	reference_cart[context.station] = context.cart[context.station.uid]
	var/list/nested_cart = list()
	nested_cart[context.station.uid] = list("Alpha" = context.cart[context.station.uid])
	if(SSsupply.Buy(context.beacon, context.customer_account, reference_cart) || SSsupply.Buy(context.beacon, context.customer_account, nested_cart))
		return "Buy accepted a legacy cart."
	if(SSsupply.BuildOrder(context.customer_account, "Invalid", nested_cart))
		return "BuildOrder accepted a legacy cart."
	var/list/invalid_cart = copy_cargo_cart(context.cart)
	for(var/quantity in list(0, -1, 1.5, 1001, "1"))
		invalid_cart[context.station.uid][context.good_id] = quantity
		if(SSsupply.Buy(context.beacon, context.customer_account, invalid_cart))
			return "Buy accepted invalid quantity [quantity]."
	return null

/datum/unit_test/cargo_reject_legacy_cart_test/proc/CheckInvalidQuotes(datum/cargo_test_context/context)
	var/list/snapshot = SSsupply.BuildMarketSnapshot(context.cart)
	var/fail_reason = CheckLegacyQuotes(context, snapshot)
	if(fail_reason)
		return fail_reason
	var/list/goods = snapshot[context.station.uid]
	goods[context.good_id] = 10
	if(SSsupply.Buy(context.beacon, context.customer_account, context.cart, null, snapshot))
		return "Buy accepted a numeric snapshot."
	goods.Cut()
	if(SSsupply.Buy(context.beacon, context.customer_account, context.cart, null, snapshot))
		return "Buy substituted a market price for a missing snapshot price."
	return CheckMissingOrderQuote(context)

/datum/unit_test/cargo_reject_legacy_cart_test/proc/CheckLegacyQuotes(datum/cargo_test_context/context, list/snapshot)
	var/list/reference_quote = list()
	reference_quote[context.station] = snapshot[context.station.uid]
	var/list/category_quote = list()
	category_quote[context.station.uid] = list("Alpha" = snapshot[context.station.uid])
	if(SSsupply.Buy(context.beacon, context.customer_account, context.cart, null, reference_quote) || SSsupply.Buy(context.beacon, context.customer_account, context.cart, null, category_quote))
		return "Buy accepted a station-reference or category-based quote."
	return null

/datum/unit_test/cargo_reject_legacy_cart_test/proc/CheckMissingOrderQuote(datum/cargo_test_context/context)
	var/datum/cargo_order/order = context.BuildTestOrder()
	SSsupply.ClearMarketSnapshot(order.price_snapshot)
	order.price_snapshot = null
	if(SSsupply.PurchaseOrder(context.beacon, order.id))
		return "Order without a quote used a live price."
	return null

/datum/unit_test/cargo_order_copy_and_station_removal_test
	name = "CARGO: Orders and presets own independent carts and fixed quotes"

/datum/unit_test/cargo_order_copy_and_station_removal_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	var/fail_reason = CheckCartCopies(context) || CheckStationRemoval(context)
	qdel(context)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("Independent carts retain their fixed prices after station removal.")
	return 1

/datum/unit_test/cargo_order_copy_and_station_removal_test/proc/CheckCartCopies(datum/cargo_test_context/context)
	var/datum/computer_file/program/supply/program = new
	program.shopping_list = copy_cargo_cart(context.cart)
	program.SaveShopList("Independent")
	var/list/loaded = program.LoadShopList("Independent")
	set_cargo_cart_quantity(loaded, context.station.uid, context.good_id, 3)
	var/list/saved = program.saved_shopping_lists["Independent"]
	var/valid = saved[context.station.uid][context.good_id] == 1 && program.shopping_list[context.station.uid][context.good_id] == 1
	qdel(program)
	clear_cargo_cart(loaded)
	if(!valid)
		return "Loading a preset shared its cart with the session or saved copy."
	return CheckOrderCopies(context)

/datum/unit_test/cargo_order_copy_and_station_removal_test/proc/CheckOrderCopies(datum/cargo_test_context/context)
	var/datum/cargo_order/order = context.BuildTestOrder()
	var/datum/cargo_order/second = context.BuildTestOrder()
	var/list/packet = order.price_snapshot[context.station.uid][context.good_id]
	packet["unit_price"]++
	var/list/second_packet = second.price_snapshot[context.station.uid][context.good_id]
	set_cargo_cart_quantity(context.cart, context.station.uid, context.good_id, 4)
	return second_packet["unit_price"] != packet["unit_price"] && order.contents[context.station.uid][context.good_id] == 1 ? null : "Orders shared their cart or quote with another owner."

/datum/unit_test/cargo_order_copy_and_station_removal_test/proc/CheckStationRemoval(datum/cargo_test_context/context)
	var/datum/trading_station/unit_test_duplicate_pricing/second_station = new
	second_station.uid = "cargo_second_[ref(src)]"
	SSsupply.all_trading_stations += second_station
	second_station.AssembleInventory()
	var/second_id = second_station.offers_by_category["Beta"][1]
	set_cargo_cart_quantity(context.cart, second_station.uid, second_id, 1)
	var/datum/cargo_order/order = context.BuildTestOrder()
	var/order_id = order.id
	var/remaining_cost = SSsupply.GetSnapshotUnitPrice(order.price_snapshot, second_station, "Beta", second_id)
	var/datum/trade_offer/offer = second_station.GetOffer(second_id)
	offer.base_price *= 10
	QDEL_NULL(context.station)
	var/valid = order.cost == remaining_cost && length(order.contents) == 1 && length(order.price_snapshot) == 1
	qdel(second_station)
	return valid && !SSsupply.GetCargoOrder(order_id) ? null : "Station removal did not recalculate from fixed prices or cancel the empty order."

/datum/unit_test/cargo_purchase_rollback_test
	name = "CARGO: Delivery and withdrawal failures roll back freight and economy"

/datum/unit_test/cargo_purchase_rollback_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	PrepareWithdrawalFailure(context)
	var/fail_reason = CheckRollback(context)
	PrepareDeliveryFailure(context)
	if(!fail_reason)
		fail_reason = CheckRollback(context)
	qdel(context)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("Failed delivery and withdrawal leave no cargo or economic changes.")
	return 1

/datum/unit_test/cargo_purchase_rollback_test/proc/PrepareWithdrawalFailure(datum/cargo_test_context/context)
	context.cargo_account.money = 1000
	context.cargo_account.reject_withdrawal = TRUE
	context.station.live_market_enabled = TRUE
	context.station.EnsureLiveMarketCommodity("Alpha", context.good_id, 10, 5)

/datum/unit_test/cargo_purchase_rollback_test/proc/PrepareDeliveryFailure(datum/cargo_test_context/context)
	context.beacon.deliveries.Cut()
	context.beacon.reject_after = 1
	var/datum/trade_offer/bulk = new("test_bulk", /obj/structure/closet/crate, "Bulk", null, "Alpha", 20, 1, 1, null, context.station)
	context.station.AddOffer(bulk)
	set_cargo_cart_quantity(context.cart, context.station.uid, bulk.id, 1)
	context.cargo_account.reject_withdrawal = FALSE

/datum/unit_test/cargo_purchase_rollback_test/proc/CheckRollback(datum/cargo_test_context/context)
	var/wealth = context.station.wealth
	var/demand = context.station.GetLiveMarketDemandScore("Alpha", context.good_id)
	var/list/cart = copy_cargo_cart(context.cart)
	set_cargo_cart_quantity(cart, context.station.uid, context.good_id, 2)
	if(SSsupply.Buy(context.beacon, context.cargo_account, cart))
		return "Buy succeeded after delivery or withdrawal was rejected."
	for(var/atom/movable/item as anything in context.beacon.deliveries)
		if(!QDELETED(item))
			return "Rejected purchase retained created freight or packaging."
	if(context.cargo_account.money != 1000 || context.station.wealth != wealth || context.station.GetGoodAmount("Alpha", context.good_id) != 5)
		return "Rejected purchase changed money, wealth, or stock."
	if(context.station.GetLiveMarketDemandScore("Alpha", context.good_id) != demand || length(SSsupply.shipping_log))
		return "Rejected purchase changed demand or shipping logs."
	return null

/datum/unit_test/cargo_order_refund_retry_test
	name = "CARGO: Pending escrow refunds retain their source and succeed exactly once"

/datum/unit_test/cargo_order_refund_retry_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	context.cargo_account.reject_withdrawal = TRUE
	context.cargo_account.reject_refund = TRUE
	var/datum/cargo_order/order = context.BuildTestOrder()
	var/fail_reason = CheckPendingRefund(context, order)
	if(!fail_reason)
		fail_reason = CheckRetry(context, order)
	qdel(context)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("Escrow remains locked on its original account until one successful refund.")
	return 1

/datum/unit_test/cargo_order_refund_retry_test/proc/CheckPendingRefund(datum/cargo_test_context/context, datum/cargo_order/order)
	var/total = order.cost + order.fee
	if(SSsupply.PurchaseOrder(context.beacon, order.id))
		return "Order succeeded despite rejected withdrawal."
	if(order.status != CARGO_ORDER_REFUND_PENDING || order.pending_refund != total || order.escrow_account != context.cargo_account)
		return "Failed refund lost its debt or original escrow account."
	if(SSsupply.DismantleOrder(order.id) || SSsupply.PurchaseOrder(context.beacon, order.id))
		return "Refund-pending order allowed cancellation or approval."
	if(context.customer_account.money != 1000 - total || context.cargo_account.money != total)
		return "Failed refund changed the escrow balances."
	return null

/datum/unit_test/cargo_order_refund_retry_test/proc/CheckRetry(datum/cargo_test_context/context, datum/cargo_order/order)
	department_accounts["Supply"] = context.customer_account
	context.cargo_account.suspended = TRUE
	SSsupply.ProcessPendingOrderRefunds()
	if(order.status != CARGO_ORDER_REFUND_PENDING || order.escrow_account != context.cargo_account)
		return "Retry replaced the suspended escrow account."
	context.cargo_account.suspended = FALSE
	context.cargo_account.reject_refund = FALSE
	SSsupply.ProcessPendingOrderRefunds()
	var/attempts = context.cargo_account.refund_attempts
	SSsupply.ProcessPendingOrderRefunds()
	if(order.status != CARGO_ORDER_PENDING || order.pending_refund || order.escrow_account)
		return "Successful refund did not restore the pending order."
	if(context.customer_account.money != 1000 || context.cargo_account.money || context.cargo_account.refund_attempts != attempts)
		return "Escrow was refunded more than once or to the wrong balance."
	return null

/datum/unit_test/cargo_order_refund_empty_cart_test
	name = "CARGO: Station removal retains escrow debt until refund"

/datum/unit_test/cargo_order_refund_empty_cart_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	context.cargo_account.reject_withdrawal = TRUE
	context.cargo_account.reject_refund = TRUE
	var/datum/cargo_order/order = context.BuildTestOrder()
	var/order_id = order.id
	var/debt = order.cost + order.fee
	SSsupply.PurchaseOrder(context.beacon, order_id)
	QDEL_NULL(context.station)
	var/valid = SSsupply.GetCargoOrder(order_id) == order && order.pending_refund == debt && !length(order.contents)
	context.cargo_account.reject_refund = FALSE
	SSsupply.ProcessPendingOrderRefunds()
	valid = valid && !SSsupply.GetCargoOrder(order_id) && context.customer_account.money == 1000 && !context.cargo_account.money
	qdel(context)
	if(valid)
		pass("Empty orders retain their debt and are removed after repayment.")
	else
		fail("Station removal discarded escrow debt or retained a repaid empty order.")
	return 1

/datum/unit_test/cargo_order_deleted_escrow_test
	name = "CARGO: Deleted escrow accounts remain pending without replacement"

/datum/unit_test/cargo_order_deleted_escrow_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	context.cargo_account.reject_withdrawal = TRUE
	context.cargo_account.reject_refund = TRUE
	var/datum/cargo_order/order = context.BuildTestOrder()
	SSsupply.PurchaseOrder(context.beacon, order.id)
	var/debt = order.pending_refund
	var/datum/money_account/original = context.cargo_account
	QDEL_NULL(context.cargo_account)
	department_accounts["Supply"] = context.customer_account
	SSsupply.ProcessPendingOrderRefunds()
	var/valid = order.status == CARGO_ORDER_REFUND_PENDING && order.escrow_account == original && order.pending_refund == debt
	valid = valid && !SSsupply.DismantleOrder(order.id) && context.customer_account.money == 1000 - debt
	qdel(context)
	if(valid)
		pass("Deleted escrow retains its original debt and account reference.")
	else
		fail("Deleted escrow was replaced or its unpaid order was removed.")
	return 1

/datum/unit_test/cargo_order_processing_lock_test
	name = "CARGO: Processing orders block cancellation and repeated approval"

/datum/unit_test/cargo_order_processing_lock_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	var/datum/cargo_order/order = context.BuildTestOrder()
	order.status = CARGO_ORDER_PROCESSING
	var/valid = !SSsupply.DismantleOrder(order.id) && !SSsupply.PurchaseOrder(context.beacon, order.id)
	valid = valid && SSsupply.GetCargoOrder(order.id) == order && !length(context.beacon.deliveries) && context.customer_account.money == 1000
	qdel(context)
	if(valid)
		pass("Processing state blocks duplicate approval and cancellation.")
	else
		fail("Processing order was changed by a repeated approval or cancellation.")
	return 1

/datum/unit_test/cargo_refund_ui_status_test
	name = "CARGO: Both order interfaces expose pending refunds and disable actions"

/datum/unit_test/cargo_refund_ui_status_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	var/datum/cargo_order/order = context.BuildTestOrder()
	order.status = CARGO_ORDER_REFUND_PENDING
	var/datum/computer_file/program/supply/cargo_program = new
	var/datum/computer_file/program/supply_order/customer_program = new
	customer_program.orders_filter = "all"
	var/list/cargo_entries = cargo_program.SerializeOrders()
	var/list/customer_entries = customer_program.SerializeOrders(null)
	var/valid = CheckRefundEntry(cargo_entries) && CheckRefundEntry(customer_entries)
	qdel(cargo_program)
	qdel(customer_program)
	qdel(context)
	if(valid)
		pass("Both interfaces preserve the refund status and lock actions.")
	else
		fail("An order interface omitted the refund status or enabled actions.")
	return 1

/datum/unit_test/cargo_refund_ui_status_test/proc/CheckRefundEntry(list/entries)
	if(length(entries) != 1)
		return FALSE
	var/list/entry = entries[1]
	return entry["status"] == "Refund pending" && entry["status_tone"] == "bad" && !entry["can_cancel"] && length(entry["contents"]) == 1

/datum/unit_test/cargo_purchase_preparation_test
	name = "CARGO: Preparing personal purchases caches packing without side effects"

/datum/unit_test/cargo_purchase_preparation_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	set_cargo_cart_quantity(context.cart, context.station.uid, context.good_id, 2)
	var/datum/cargo_order/order = context.BuildTestOrder()
	var/datum/cargo_purchase/purchase = SSsupply.PreparePurchase(context.beacon, context.cargo_account, order.contents, order.buyer_faction, order.price_snapshot, order)
	var/valid = purchase && purchase.price == order.cost && purchase.packable == 2
	if(valid)
		var/list/item = purchase.items[1]
		valid = item["packable"] && item["packing_size"] > 0 && purchase.packing_plan["use_locker"] && purchase.packing_plan["personal"]
	valid = valid && context.customer_account.money == 1000 && !context.cargo_account.money && !length(context.beacon.deliveries)
	valid = valid && context.station.GetGoodAmount("Alpha", context.good_id) == 5 && order.status == CARGO_ORDER_PENDING
	qdel(purchase)
	qdel(context)
	if(valid)
		pass("Preparation caches personal packing and leaves stock, money and freight unchanged.")
	else
		fail("Preparation omitted packing data or changed economic state.")
	return 1

/datum/unit_test/cargo_template_station_lifecycle_test
	name = "CARGO: Unregistered catalog templates cannot remove registered station orders"

/datum/unit_test/cargo_template_station_lifecycle_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	var/datum/cargo_order/order = context.BuildTestOrder()
	var/datum/trading_station/unit_test_duplicate_pricing/template = new
	template.uid = context.station.uid
	template.AssembleInventory()
	qdel(template)
	var/valid = SSsupply.GetCargoOrder(order.id) == order && SSsupply.CollectCountsFrom(order.contents) == 1
	valid = valid && order.cost == 10 && order.status == CARGO_ORDER_PENDING
	qdel(context)
	if(valid)
		pass("Deleting catalog templates leaves the registered station and its orders intact.")
	else
		fail("An unregistered template purged another station's orders.")
	return 1

/datum/unit_test/cargo_shared_cart_prices_test
	name = "CARGO: Cart screens reuse totals prices and preserve preset commissions"

/datum/unit_test/cargo_shared_cart_prices_test/start_test()
	var/datum/cargo_test_context/context = new(get_safe_turf())
	var/datum/computer_file/program/supply/cargo_program = new
	var/datum/computer_file/program/supply_order/customer_program = new
	cargo_program.faction = customer_program.faction = FACTION_INDEPENDENT
	cargo_program.shopping_list = copy_cargo_cart(context.cart)
	customer_program.shopping_list = copy_cargo_cart(context.cart)
	var/list/totals = SSsupply.GetCartTotals(context.cart, FACTION_INDEPENDENT)
	var/valid = CheckPresetTotals(cargo_program, customer_program, totals)
	var/datum/trade_offer/offer = context.station.GetOffer(context.good_id)
	offer.base_price *= 10
	valid = valid && CheckCartScreen(cargo_program, totals) && CheckCartScreen(customer_program, totals)
	qdel(cargo_program)
	qdel(customer_program)
	qdel(context)
	if(valid)
		pass("Cart screens reuse quoted totals; personal presets include the original commission.")
	else
		fail("A screen repriced its cart or changed its preset commission.")
	return 1

/datum/unit_test/cargo_shared_cart_prices_test/proc/CheckPresetTotals(datum/computer_file/program/supply/cargo_program, datum/computer_file/program/supply_order/customer_program, list/totals)
	cargo_program.SaveShopList("Cached")
	customer_program.SaveShopList("Cached")
	var/list/cargo_presets = cargo_program.SerializeSavedCarts()
	var/list/customer_presets = customer_program.SerializeSavedCarts()
	return cargo_presets[1]["total"] == totals["subtotal"] && customer_presets[1]["total"] == totals["total"]

/datum/unit_test/cargo_shared_cart_prices_test/proc/CheckCartScreen(datum/computer_file/program/supply_base/program, list/totals)
	var/list/data = list()
	if(istype(program, /datum/computer_file/program/supply))
		var/datum/computer_file/program/supply/cargo_program = program
		cargo_program.BuildCartScreenData(data, totals)
	else
		var/datum/computer_file/program/supply_order/customer_program = program
		customer_program.BuildCartScreenData(data, totals)
	var/list/groups = data["cart_groups"]
	if(length(groups) != 1)
		return FALSE
	var/list/categories = groups[1]["categories"]
	var/list/items = categories[1]["items"]
	return length(items) == 1 && items[1]["price"] == totals["subtotal"]
