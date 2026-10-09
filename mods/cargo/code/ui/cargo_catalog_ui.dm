/datum/computer_file/program/supply_base/proc/SerializeSavedCarts()
	var/list/result = list()
	if(!islist(saved_shopping_lists))
		return result
	for(var/i in 1 to length(saved_shopping_lists))
		var/cart_name = saved_shopping_lists[i]
		var/list/cart_data = saved_shopping_lists[cart_name]
		if(!islist(cart_data))
			continue
		var/list/totals = SSsupply.GetCartTotals(cart_data, faction)
		result.Add(list(list(
			"index" = i,
			"name" = cart_name,
			"count" = totals["count"],
			"total" = GetSavedCartTotal(cart_data, totals)
		)))
	return result

/datum/computer_file/program/supply_base/proc/GetGoodIconAsset(item_path)
	if(!ispath(item_path, /atom/movable))
		return ""
	var/cached = GLOB.cargo_item_icon_cache[item_path]
	if(!isnull(cached))
		return cached
	var/atom/movable/dummy = item_path
	var/item_icon = initial(dummy.icon)
	var/item_state = initial(dummy.icon_state)
	if(!item_icon)
		GLOB.cargo_item_icon_cache[item_path] = ""
		return ""
	var/list/valid_states
	if(isfile(item_icon) || isicon(item_icon))
		valid_states = icon_states(item_icon)
	var/icon/I
	if(item_state && islist(valid_states) && (item_state in valid_states))
		I = icon(item_icon, item_state, SOUTH, 1)
	else if(islist(valid_states) && length(valid_states))
		I = icon(item_icon, valid_states[1], SOUTH, 1)
	else
		I = icon(item_icon, item_state, SOUTH, 1)
	if(!isicon(I))
		GLOB.cargo_item_icon_cache[item_path] = ""
		return ""
	var/asset_name = "cargo_icon_[md5("[item_path]")].png"
	register_asset(asset_name, I)
	GLOB.cargo_item_icon_cache[item_path] = asset_name
	return asset_name

/datum/computer_file/program/supply_base/proc/GetCategoryIcon(category_name)
	switch(lowertext(category_name))
		if("supply") return "📦"
		if("operations") return "📋"
		if("mining") return "💎"
		if("robotics") return "🤖"
		if("engineering") return "🔧"
		if("atmospherics") return "🌐"
		if("hospitality") return "🍴"
		if("custodial") return "🧹"
		if("hydroponics") return "🌿"
		if("recreation") return "🎲"
		if("medical") return "🩺"
		if("cartridges") return "💾"
		if("science") return "🔬"
		if("security") return "🛡️"
		if("weaponry") return "🔫"
		else
			return "📁"

/datum/computer_file/program/supply_base/proc/SerializeVisibleStations()
	var/list/result = list()
	var/has_local_receiving_beacon = HasLocalReceivingBeacon()
	var/list/available_stations = GetAvailableTradingStations()
	for(var/datum/trading_station/target_station as anything in available_stations)
		var/datum/trade_faction/station_faction = SSsupply.GetFaction(target_station.faction)
		var/faction_color = TradeRelationsColor(station_faction ? station_faction.relationship[faction] : null) || "#ffffff"
		var/list/status_data = GetStationStatusData(target_station, faction, has_local_receiving_beacon)
		var/list/availability_status = target_station.GetAvailabilityStatusData()
		result.Add(list(list(
			"uid" = target_station.uid,
			"name" = target_station.name,
			"faction" = target_station.faction,
			"faction_color" = faction_color,
			"selected" = (target_station == station),
			"market_label" = target_station.GetLiveMarketStatusLabel(),
			"market_tone" = target_station.GetLiveMarketStatusTone(),
			"status_label" = status_data["label"],
			"status_tone" = status_data["tone"],
			"availability_label" = islist(availability_status) ? availability_status["label"] : "",
			"availability_tone" = islist(availability_status) ? availability_status["tone"] : ""
		)))
	return result

/datum/computer_file/program/supply_base/proc/SerializeCategories(datum/trading_station/target_station = null)
	var/list/result = list()
	if(!istype(target_station))
		target_station = station
	if(!istype(target_station))
		return result
	for(var/category_name in target_station.offers_by_category)
		result.Add(list(list(
			"name" = category_name,
			"icon" = GetCategoryIcon(category_name),
			"selected" = category_name == chosen_category
		)))
	return result

/datum/computer_file/program/supply_base/proc/SerializeGoods(datum/trading_station/target_station = null, mob/user = null)
	var/list/result = list()
	if(!istype(target_station))
		target_station = station
	if(!istype(target_station) || !chosen_category)
		return result
	var/list/category = target_station.offers_by_category[chosen_category]
	if(!islist(category) || GetStationTradeBlockReason(target_station))
		return result

	var/can_add_goods = CanAddGoodsToCart()
	var/station_key = target_station.uid
	var/list/station_cart = shopping_list[station_key]
	var/list/assets_to_send = list()
	for(var/good_id in category)
		var/list/entry = SerializeGoodEntry(target_station, good_id, station_cart, can_add_goods, assets_to_send)
		if(islist(entry))
			result.Add(list(entry))
	if(user && user.client && length(assets_to_send))
		send_asset_list(user.client, assets_to_send, FALSE)
	return result

/datum/computer_file/program/supply_base/proc/SerializeGoodEntry(datum/trading_station/target_station, good_id, list/station_cart, can_add_goods, list/assets_to_send)
	var/datum/trade_offer/offer = target_station.GetOffer(good_id)
	if(!offer || !ispath(offer.item_path, /atom/movable))
		return null
	var/path = offer.item_path
	var/stock = offer.stock
	var/basic_price = offer.base_price
	var/price = SSsupply.GetStationBuyPrice(good_id, target_station, faction, chosen_category)
	var/sell_price = SSsupply.GetStationSellPrice(good_id, target_station, faction, chosen_category)
	var/in_cart = GetGoodCartQuantity(station_cart, good_id)
	var/atom/movable/item_type = path
	var/icon_asset = GetGoodIconAsset(path)
	if(icon_asset)
		assets_to_send |= icon_asset
	return list(
		"id" = good_id,
		"name" = offer.name,
		"desc" = initial(item_type.desc) || "",
		"stock" = stock,
		"price" = round(price, 0.01),
		"sell_price" = round(sell_price, 0.01),
		"markup_text" = GetGoodMarkupText(basic_price, price),
		"can_add" = can_add_goods && stock > 0,
		"quantity_form_open" = ("[goods_quantity_target]" == "[good_id]"),
		"icon" = icon_asset,
		"in_cart_amount" = in_cart
	)

/datum/computer_file/program/supply_base/proc/GetGoodCartQuantity(list/station_cart, good_id)
	return islist(station_cart) ? (station_cart[good_id] || 0) : 0

/datum/computer_file/program/supply_base/proc/SerializeShopListGroups(list/shop_list, buyer_faction = null, list/price_snapshot = null)
	var/list/result = list()
	if(!is_valid_cargo_cart(shop_list) || (!isnull(price_snapshot) && !is_valid_cargo_quote(price_snapshot)))
		return result
	if(isnull(buyer_faction))
		buyer_faction = faction

	for(var/station_key in shop_list)
		var/datum/trading_station/target_station = SSsupply ? SSsupply.GetStationByUid(station_key) : null
		if(!istype(target_station))
			continue
		var/list/cart = shop_list[station_key]
		if(!islist(cart))
			continue

		var/list/categories = GroupCartEntriesByCategory(cart, target_station)
		var/list/category_entries = SerializeCategoryEntries(categories, target_station, buyer_faction, price_snapshot)
		if(length(category_entries))
			result.Add(list(list(
				"station_uid" = target_station.uid,
				"station_name" = target_station.name,
				"categories" = category_entries
			)))
	return result

/datum/computer_file/program/supply_base/proc/GroupCartEntriesByCategory(list/cart, datum/trading_station/target_station)
	var/list/grouped = list()
	for(var/good_id in cart)
		var/datum/trade_offer/offer = istext(good_id) ? target_station.GetOffer(good_id) : null
		if(!offer || !is_valid_cargo_quantity(cart[good_id]))
			continue
		var/category_name = offer.category
		var/list/goods = grouped[category_name]
		if(!islist(goods))
			goods = list()
			grouped[category_name] = goods
		goods[good_id] = cart[good_id]
	return grouped

/datum/computer_file/program/supply_base/proc/SerializeCategoryEntries(list/categories, datum/trading_station/target_station, buyer_faction, list/price_snapshot)
	var/list/category_entries = list()
	for(var/category_name in categories)
		var/list/goods = categories[category_name]
		if(!islist(goods) || !length(goods))
			continue
		var/list/item_entries = list()
		for(var/good_id in goods)
			var/amount = goods[good_id]
			if(!isnum(amount) || amount < 1)
				continue
			var/unit_price = islist(price_snapshot) ? SSsupply.GetSnapshotUnitPrice(price_snapshot, target_station, category_name, good_id) : SSsupply.GetStationBuyPrice(good_id, target_station, buyer_faction, category_name)
			if(!isnum(unit_price))
				continue
			item_entries.Add(list(list(
				"good_id" = good_id,
				"name" = target_station.GetGoodName(category_name, good_id),
				"amount" = amount,
				"unit_price" = round(unit_price, 0.01),
				"price" = round(unit_price * amount, 0.01),
				"category_name" = category_name,
				"station_uid" = target_station.uid
			)))
		if(length(item_entries))
			category_entries.Add(list(list(
				"name" = category_name,
				"items" = item_entries
			)))
	return category_entries

/datum/computer_file/program/supply_base/proc/FormatCountdown(deciseconds)
	if(!isnum(deciseconds))
		return "00:00"
	var/seconds = max(0, round(deciseconds / 10))
	return "[pad_left(num2text((seconds / 60) % 60), 2, "0")]:[pad_left(num2text(seconds % 60), 2, "0")]"

/datum/computer_file/program/supply_base/proc/SerializeCargoOrder(datum/cargo_order/order)
	ASSERT(istype(order))
	var/datum/money_account/requestor = order.requesting_acct
	var/list/contents = is_valid_cargo_quote(order.price_snapshot) ? SerializeShopListGroups(order.contents, order.buyer_faction, order.price_snapshot) : list()
	return list(
		"id" = order.id,
		"requestor_name" = requestor ? requestor.owner_name : "Unknown",
		"requestor_account_number" = requestor ? requestor.account_number : 0,
		"buyer_faction" = order.buyer_faction,
		"cost" = round(order.cost, 0.01), "fee" = round(order.fee, 0.01),
		"total" = round(order.cost + order.fee, 0.01),
		"reason" = order.reason || "Not provided",
		"status" = order.status == CARGO_ORDER_REFUND_PENDING ? "Refund pending" : order.status,
		"status_tone" = order.IsLocked() ? "bad" : "average",
		"can_cancel" = !order.IsLocked(),
		"selected" = current_order == order.id,
		"item_count" = SSsupply.CollectCountsFrom(order.contents),
		"contents" = contents
	)
