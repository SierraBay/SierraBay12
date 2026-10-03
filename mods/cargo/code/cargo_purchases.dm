/datum/cargo_purchase
	var/obj/machinery/trade_beacon/receiving/beacon
	var/datum/money_account/account
	var/datum/cargo_order/order
	var/list/items = list()
	var/list/spawned = list()
	var/list/packing_plan = list()
	var/obj/structure/closet/locker
	var/price = 0
	var/packable = 0
	var/buyer_faction
	var/buyer_name
	var/committed = FALSE

/datum/cargo_purchase/Destroy()
	if(!committed)
		Rollback()
	ClearItems()
	packing_plan.Cut()
	packing_plan = null
	spawned.Cut()
	spawned = null
	locker = null
	beacon = null
	account = null
	order = null
	buyer_faction = null
	return ..()

/datum/cargo_purchase/proc/ClearItems()
	for(var/list/item as anything in items)
		item.Cut()
	items.Cut()
	items = null

/datum/cargo_purchase/proc/IsPersonalOrder()
	return order && order.requesting_acct != account

/datum/cargo_purchase/proc/PlanPacking()
	packable = 0
	for(var/list/item_data as anything in items)
		if(!SSsupply.CanPackPurchase(item_data["item_path"]))
			continue
		var/obj/item/item_type = item_data["item_path"]
		item_data["packable"] = TRUE
		item_data["packing_size"] = initial(item_type.w_class) / 2
		packable += item_data["count"]
	packing_plan["use_locker"] = packable > 1
	packing_plan["personal"] = IsPersonalOrder()
	packing_plan["buyer_name"] = buyer_name

/datum/cargo_purchase/proc/Execute()
	if(committed || !IsReady())
		return FALSE
	if(!SpawnItems() || !IsReady() || !ChargeAccount())
		Rollback()
		return FALSE
	var/info = FulfillStock()
	var/atom/invoice_location = locker || get_turf(spawned[1])
	SSsupply.CreateLogEntry("Shipping", buyer_name, info, price, TRUE, invoice_location)
	RecordDemand()
	committed = TRUE
	return TRUE

/datum/cargo_purchase/proc/SpawnItems()
	if(packing_plan["use_locker"])
		locker = SSsupply.CreateOrderLocker(beacon, packing_plan["personal"], packing_plan["buyer_name"])
		if(!locker || QDELETED(locker))
			return FALSE
		spawned += locker
	var/remaining_capacity = locker ? locker.storage_capacity : 0
	for(var/list/item_data as anything in items)
		for(var/i in 1 to item_data["count"])
			var/atom/movable/item = SpawnItem(item_data, remaining_capacity)
			if(!item || QDELETED(item))
				return FALSE
			spawned += item
			if(locker && item.loc == locker)
				remaining_capacity -= locker.content_size(item)
	return TRUE

/datum/cargo_purchase/proc/SpawnItem(list/item_data, remaining_capacity)
	var/path = item_data["item_path"]
	if(locker && item_data["packable"] && item_data["packing_size"] <= remaining_capacity)
		return new path(locker)
	return beacon.DropItem(path)

/datum/cargo_purchase/proc/Rollback()
	for(var/i = length(spawned) to 1 step -1)
		var/atom/movable/item = spawned[i]
		if(!QDELETED(item))
			qdel(item)
	spawned.Cut()
	locker = null

/datum/cargo_purchase/proc/ChargeAccount()
	if(!price)
		return TRUE
	return account.money >= price && account.withdraw(price, "Trade Network Purchase", "Trade Network")

/datum/cargo_purchase/proc/FulfillStock()
	var/list/wealth_by_station = list()
	var/contents_info = ""
	for(var/list/item_data as anything in items)
		var/datum/trading_station/station = item_data["station"]
		var/datum/trade_offer/offer = item_data["offer"]
		var/count = item_data["count"]
		wealth_by_station[station] += item_data["unit_price"] * count
		offer.ConsumeStock(count)
		contents_info += "<li>[count]x [offer.name]</li>"
	for(var/datum/trading_station/station as anything in wealth_by_station)
		station.AddToWealth(wealth_by_station[station])
	return contents_info

/datum/cargo_purchase/proc/RecordDemand()
	for(var/list/item_data as anything in items)
		var/datum/trade_offer/offer = item_data["offer"]
		SSsupply.ApplyTradeTransaction(item_data["station"], offer.category, offer.id, item_data["count"], "buy", buyer_faction)

/datum/controller/subsystem/supply/proc/PreparePurchase(obj/machinery/trade_beacon/receiving/beacon, datum/money_account/account, list/cart, buyer_faction = null, list/price_snapshot = null, datum/cargo_order/order = null)
	if(!istype(beacon) || QDELETED(beacon) || !beacon.operable() || !istype(account) || QDELETED(account))
		return null
	if((order || !isnull(price_snapshot)) && !is_valid_cargo_quote(price_snapshot))
		return null
	var/list/items = ExtractCartItems(cart)
	if(!length(items))
		return null
	var/datum/cargo_purchase/purchase = new
	purchase.beacon = beacon
	purchase.account = account
	purchase.order = order
	purchase.buyer_faction = buyer_faction
	purchase.buyer_name = purchase.IsPersonalOrder() ? order.requesting_acct.owner_name : account.owner_name
	purchase.items = items
	if(!QuotePurchase(purchase, price_snapshot) || (order && purchase.price != order.cost))
		qdel(purchase)
		return null
	purchase.PlanPacking()
	return purchase

/datum/controller/subsystem/supply/proc/QuotePurchase(datum/cargo_purchase/purchase, list/price_snapshot)
	for(var/list/item_data as anything in purchase.items)
		if(!QuotePurchaseItem(purchase, item_data, price_snapshot))
			return FALSE
	return TRUE

/datum/controller/subsystem/supply/proc/QuotePurchaseItem(datum/cargo_purchase/purchase, list/item_data, list/price_snapshot)
	var/datum/trading_station/station = item_data["station"]
	var/datum/trade_offer/offer = item_data["offer"]
	if(GetTradeRangeBlockReason(purchase.beacon, station) || GetStationFactionBlockReason(station, purchase.buyer_faction))
		return FALSE
	if(!offer.CanFulfill(item_data["count"]) || !offer.item_path)
		return FALSE
	var/unit_price = QuotePurchaseUnitPrice(purchase, item_data, price_snapshot)
	if(!isnum(unit_price) || isnan(unit_price) || unit_price < 1 || unit_price >= INFINITY)
		return FALSE
	item_data["unit_price"] = unit_price
	item_data["item_path"] = offer.item_path
	purchase.price += unit_price * item_data["count"]
	return TRUE

/datum/controller/subsystem/supply/proc/QuotePurchaseUnitPrice(datum/cargo_purchase/purchase, list/item_data, list/price_snapshot)
	var/datum/trading_station/station = item_data["station"]
	var/datum/trade_offer/offer = item_data["offer"]
	if(isnull(price_snapshot))
		return GetImportCost(offer.id, station, purchase.buyer_faction, offer.category)
	var/unit_price = GetSnapshotUnitPrice(price_snapshot, station, offer.category, offer.id)
	if(isnull(unit_price))
		return null
	var/list/goods = price_snapshot[station.uid]
	var/list/packet = goods[offer.id]
	return packet["amount"] == item_data["count"] ? unit_price : null

/datum/controller/subsystem/supply/proc/Buy(obj/machinery/trade_beacon/receiving/beacon, datum/money_account/account, list/cart, buyer_faction = null, list/price_snapshot = null)
	var/datum/cargo_purchase/purchase = PreparePurchase(beacon, account, cart, buyer_faction, price_snapshot)
	if(!purchase)
		return FALSE
	var/success = purchase.Execute()
	qdel(purchase)
	return success

/datum/controller/subsystem/supply/proc/CreateOrderLocker(obj/machinery/trade_beacon/receiving/beacon, is_order, buyer_name)
	var/obj/structure/closet/crate/trade/locker = beacon.DropItem(/obj/structure/closet/crate/trade)
	if(locker && is_order)
		locker.locked = TRUE
		locker.registered_name = buyer_name
		locker.name = "[initial(locker.name)] ([locker.registered_name])"
		locker.update_icon()
	return locker

/datum/controller/subsystem/supply/proc/CanPackPurchase(path, remaining_capacity = null)
	if(!ispath(path, /obj/item))
		return FALSE
	var/obj/item/item_type = path
	var/obj/structure/closet/crate/crate_type = /obj/structure/closet/crate
	var/capacity = isnull(remaining_capacity) ? initial(crate_type.storage_capacity) : remaining_capacity
	return initial(item_type.w_class) < ITEM_SIZE_NO_CONTAINER && initial(item_type.w_class) / 2 <= capacity

/datum/cargo_purchase/proc/IsReady()
	if(!beacon || QDELETED(beacon) || !beacon.operable() || !account || QDELETED(account) || account.suspended || account.money < price)
		return FALSE
	if(order && (QDELETED(order) || order.status != CARGO_ORDER_PROCESSING))
		return FALSE
	for(var/list/item_data as anything in items)
		if(!IsItemReady(item_data))
			return FALSE
	return TRUE

/datum/cargo_purchase/proc/IsItemReady(list/item_data)
	var/datum/trading_station/station = item_data["station"]
	var/datum/trade_offer/offer = item_data["offer"]
	if(QDELETED(station) || QDELETED(offer) || !station || !offer)
		return FALSE
	if(station.GetOffer(item_data["good_id"]) != offer || offer.item_path != item_data["item_path"] || !offer.CanFulfill(item_data["count"]))
		return FALSE
	return !SSsupply.GetTradeRangeBlockReason(beacon, station) && !SSsupply.GetStationFactionBlockReason(station, buyer_faction)
