/proc/is_valid_cargo_cart(list/cart)
	if(!islist(cart))
		return FALSE
	for(var/station_uid in cart)
		var/list/goods = cart[station_uid]
		if(!istext(station_uid) || !length(station_uid) || !islist(goods))
			return FALSE
		for(var/good_id in goods)
			if(!istext(good_id) || !length(good_id) || !is_valid_cargo_quantity(goods[good_id]))
				return FALSE
	return TRUE

/proc/copy_cargo_cart(list/cart)
	var/list/result = list()
	if(!is_valid_cargo_cart(cart))
		return result
	for(var/station_uid in cart)
		var/list/goods = cart[station_uid]
		result[station_uid] = goods.Copy()
	return result

/proc/clear_cargo_cart(list/cart)
	if(!islist(cart))
		return
	for(var/station_uid in cart)
		var/list/goods = cart[station_uid]
		if(islist(goods))
			goods.Cut()
	cart.Cut()

/proc/set_cargo_cart_quantity(list/cart, station_uid, good_id, amount)
	if(!islist(cart) || !istext(station_uid) || !length(station_uid) || !istext(good_id) || !length(good_id))
		return FALSE
	if(amount != 0 && !is_valid_cargo_quantity(amount))
		return FALSE
	var/list/goods = cart[station_uid]
	if(!islist(goods))
		if(!amount)
			return TRUE
		goods = list()
		cart[station_uid] = goods
	if(amount)
		goods[good_id] = amount
	else
		goods -= good_id
	if(!length(goods))
		cart -= station_uid
	return TRUE

/datum/controller/subsystem/supply/proc/ExtractCartItems(list/shop_list)
	var/list/items = list()
	if(!is_valid_cargo_cart(shop_list))
		return items
	for(var/station_uid in shop_list)
		var/datum/trading_station/station = GetStationByUid(station_uid)
		if(!istype(station) || QDELETED(station))
			return list()
		var/list/goods = shop_list[station_uid]
		for(var/good_id in goods)
			var/datum/trade_offer/offer = station.GetOffer(good_id)
			if(!istype(offer) || QDELETED(offer))
				return list()
			items.Add(list(list("station" = station, "good_id" = good_id, "cat" = offer.category, "count" = goods[good_id], "offer" = offer)))
	return items

/datum/controller/subsystem/supply/proc/CollectCountsFrom(list/shop_list)
	. = 0
	for(var/list/item as anything in ExtractCartItems(shop_list))
		. += item["count"]

/datum/controller/subsystem/supply/proc/CollectPriceForList(list/shop_list, buyer_faction = null)
	. = 0
	for(var/list/item as anything in ExtractCartItems(shop_list))
		. += GetImportCost(item["good_id"], item["station"], buyer_faction, item["cat"]) * item["count"]

/datum/controller/subsystem/supply/proc/ClearShopList(list/target_list)
	clear_cargo_cart(target_list)

/proc/is_valid_cargo_quote(list/snapshot)
	if(!islist(snapshot))
		return FALSE
	for(var/station_uid in snapshot)
		var/list/goods = snapshot[station_uid]
		if(!istext(station_uid) || !length(station_uid) || !islist(goods))
			return FALSE
		for(var/good_id in goods)
			var/list/packet = goods[good_id]
			if(!istext(good_id) || !length(good_id) || !is_valid_cargo_quote_packet(packet))
				return FALSE
	return TRUE

/proc/is_valid_cargo_quote_packet(list/packet)
	if(!islist(packet) || length(packet) != 3 || !is_valid_cargo_quantity(packet["amount"]))
		return FALSE
	var/unit_price = packet["unit_price"]
	var/timestamp = packet["timestamp"]
	return isnum(unit_price) && !isnan(unit_price) && unit_price >= 1 && unit_price < INFINITY && isnum(timestamp) && !isnan(timestamp) && timestamp >= 0 && timestamp < INFINITY

/proc/clear_cargo_station_quote(list/goods)
	if(!islist(goods))
		return
	for(var/good_id in goods)
		var/list/packet = goods[good_id]
		if(islist(packet))
			packet.Cut()
	goods.Cut()

/proc/clear_cargo_quote(list/snapshot)
	if(!islist(snapshot))
		return
	for(var/station_uid in snapshot)
		clear_cargo_station_quote(snapshot[station_uid])
	snapshot.Cut()

/datum/controller/subsystem/supply/proc/ClearMarketSnapshot(list/snapshot)
	clear_cargo_quote(snapshot)

/datum/controller/subsystem/supply/proc/GetCartTotals(list/cart, buyer_faction = null)
	var/count = 0
	var/price = 0
	var/list/price_snapshot = list()
	for(var/list/item as anything in ExtractCartItems(cart))
		count += item["count"]
		var/unit_price = GetImportCost(item["good_id"], item["station"], buyer_faction, item["cat"])
		SnapshotCartItem(price_snapshot, item, buyer_faction, unit_price)
		price += unit_price * item["count"]
	var/subtotal = round(price, 0.01)
	var/fee = round(subtotal * handling_fee, 0.01)
	return list("count" = count, "raw_subtotal" = price, "subtotal" = subtotal, "fee" = fee, "total" = subtotal + fee, "price_snapshot" = price_snapshot)
