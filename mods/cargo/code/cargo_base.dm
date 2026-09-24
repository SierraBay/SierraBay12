GLOBAL_LIST_EMPTY(cargo_item_icon_cache)

/proc/is_valid_cargo_quantity(amount)
	return isnum(amount) && !isnan(amount) && amount > 0 && amount <= 1000 && round(amount) == amount

/datum/computer_file/program/supply_base
	var/faction = FACTION_INDEPENDENT
	var/datum/money_account/account
	var/list/shopping_list = list()
	var/list/saved_shopping_lists = list()
	var/saved_cart_id = 0
	var/datum/trading_station/station
	var/chosen_category
	var/current_order
	var/order_cooldown_until = 0
	var/goods_quantity_target
	var/cart_form_mode
	var/trade_catalog_view_distance = 6

/datum/computer_file/program/supply_base/New()
	..()
	if(GLOB.using_map?.trade_faction)
		faction = GLOB.using_map.trade_faction

/datum/computer_file/program/supply_base/on_startup(mob/living/user, datum/extension/interactive/ntos/new_host)
	. = ..()
	if(. && GLOB.using_map?.trade_faction)
		faction = GLOB.using_map.trade_faction

/datum/computer_file/program/supply_base/Destroy()
	account = null
	station = null
	current_order = null
	if(shopping_list)
		ClearShopList(shopping_list)
		shopping_list = null
	if(saved_shopping_lists)
		for(var/name in saved_shopping_lists)
			ClearShopList(saved_shopping_lists[name])
		saved_shopping_lists.Cut()
		saved_shopping_lists = null
	return ..()

/datum/computer_file/program/supply_base/proc/GetStationKey(station_ref = station)
	if(istype(station_ref, /datum/trading_station))
		var/datum/trading_station/target_station = station_ref
		return target_station.uid || "[target_station.type]"
	if(istext(station_ref))
		return station_ref
	return null

/datum/computer_file/program/supply_base/proc/ClearShopList(list/target_list)
	if(!islist(target_list))
		return
	for(var/station_key in target_list)
		var/list/sub = target_list[station_key]
		if(islist(sub))
			for(var/entry in sub)
				var/list/inner = sub[entry]
				if(islist(inner))
					inner.Cut()
			sub.Cut()
	target_list.Cut()

/datum/computer_file/program/supply_base/proc/CopyShopList(list/source)
	var/list/copied = list()
	if(!islist(source))
		return copied
	for(var/station_key in source)
		var/list/sub = source[station_key]
		if(!islist(sub))
			continue
		var/list/sub_copy = list()
		for(var/key in sub)
			var/val = sub[key]
			if(islist(val))
				var/list/val_list = val
				sub_copy[key] = val_list.Copy()
			else
				sub_copy[key] = val
		var/target_key = istype(station_key, /datum/trading_station) ? GetStationKey(station_key) : station_key
		copied[target_key] = sub_copy
	return copied

/datum/computer_file/program/supply_base/proc/OpenShopList(station_ref = station, target_category = chosen_category)
	var/station_key = GetStationKey(station_ref)
	if(!station_key)
		return null
	if(!islist(shopping_list[station_key]))
		shopping_list[station_key] = list()
	return shopping_list[station_key]

/datum/computer_file/program/supply_base/proc/GetShopList(station_ref = station, target_category = chosen_category)
	var/station_key = GetStationKey(station_ref)
	if(!station_key || !islist(shopping_list))
		return null
	var/list/cart = shopping_list[station_key] || (istype(station_ref, /datum/trading_station) ? shopping_list[station_ref] : null)
	if(!islist(cart))
		return null
	if(target_category && islist(cart[target_category]))
		return cart[target_category]
	return cart

/datum/computer_file/program/supply_base/proc/SanitizeShopList()
	if(!islist(shopping_list))
		return
	for(var/station_key in shopping_list.Copy())
		var/datum/trading_station/target_station = SSsupply ? SSsupply.ResolveStation(station_key) : null
		if(!istype(target_station) || QDELETED(target_station))
			shopping_list -= station_key
			continue
		var/list/cart = shopping_list[station_key]
		if(!islist(cart))
			shopping_list -= station_key
			continue
		for(var/item_key in cart.Copy())
			var/val = cart[item_key]
			if(isnum(val))
				var/datum/trade_offer/offer = target_station.GetOffer(item_key)
				if(val < 1 || !offer || (offer.hidden && !target_station.hidden_inv_unlocked))
					cart -= item_key
			else if(islist(val))
				var/list/val_list = val
				var/category_name = item_key
				var/list/cat_offers = islist(target_station.offers_by_category) ? target_station.offers_by_category[category_name] : null
				var/list/cat_inv = islist(target_station.inventory) ? target_station.inventory[category_name] : null
				if(!islist(cat_offers) && !islist(cat_inv))
					cart -= item_key
					continue
				for(var/g_id in val_list.Copy())
					var/datum/trade_offer/offer = target_station.GetOffer(g_id)
					var/valid_item = FALSE
					if(offer)
						if(!offer.hidden || target_station.hidden_inv_unlocked)
							if(offer.category == category_name || (islist(cat_offers) && (offer.id in cat_offers)))
								valid_item = TRUE
					else if(islist(cat_inv) && (g_id in cat_inv))
						if(target_station.hidden_inv_unlocked || !islist(target_station.hidden_inventory) || !islist(target_station.hidden_inventory[category_name]) || !(g_id in target_station.hidden_inventory[category_name]))
							valid_item = TRUE
					if(val_list[g_id] < 1 || !valid_item)
						val_list -= g_id
				if(!length(val_list))
					cart -= item_key
		if(!length(cart))
			shopping_list -= station_key

/datum/computer_file/program/supply_base/proc/AddToShopList(good_id, amount, limit, station_ref = station)
	if(!good_id || !isnum(amount) || isnan(amount) || amount <= 0)
		return
	var/station_key = GetStationKey(station_ref)
	if(!station_key)
		return
	if(!islist(shopping_list[station_key]))
		shopping_list[station_key] = list()
	var/list/cart = shopping_list[station_key]
	var/target_amount = (cart[good_id] || 0) + round(amount)
	if(limit && target_amount > limit)
		target_amount = limit
	cart[good_id] = target_amount

/datum/computer_file/program/supply_base/proc/RemoveFromShopList(good_id, amount, station_ref = station, target_category = chosen_category)
	if(!good_id || !isnum(amount) || isnan(amount) || amount <= 0)
		return
	var/station_key = GetStationKey(station_ref)
	if(!station_key)
		return
	var/list/cart = shopping_list[station_key]
	if(islist(cart) && (good_id in cart))
		cart[good_id] -= round(amount)
		if(cart[good_id] < 1)
			cart -= good_id
		if(!length(cart))
			shopping_list -= station_key
	else if(istype(station_ref, /datum/trading_station) && islist(shopping_list[station_ref]))
		var/list/leg_cats = shopping_list[station_ref]
		if(target_category && islist(leg_cats[target_category]))
			var/list/leg_goods = leg_cats[target_category]
			if(good_id in leg_goods)
				leg_goods[good_id] -= round(amount)
				if(leg_goods[good_id] < 1)
					leg_goods -= good_id
	SanitizeShopList()

/datum/computer_file/program/supply_base/proc/SetInShopList(good_id, amount, limit, station_ref = station, target_category = chosen_category)
	if(!good_id || !isnum(amount) || isnan(amount))
		return
	if(amount <= 0 || (isnum(limit) && limit <= 0))
		RemoveFromShopList(good_id, 999999, station_ref, target_category)
		return
	var/station_key = GetStationKey(station_ref)
	if(!station_key)
		return
	if(!islist(shopping_list[station_key]))
		shopping_list[station_key] = list()
	var/list/cart = shopping_list[station_key]
	var/target_amount = round(amount)
	if(isnum(limit) && target_amount > limit)
		target_amount = limit
	target_amount = clamp(target_amount, 1, 1000)
	cart[good_id] = target_amount

/datum/computer_file/program/supply_base/proc/ResetShopList()
	if(shopping_list)
		ClearShopList(shopping_list)
	shopping_list = list()

/datum/computer_file/program/supply_base/proc/GetDefaultSavedCartName()
	return "Saved Cart #[++saved_cart_id]"

/datum/computer_file/program/supply_base/proc/SaveShopList(name, list/shop_list = null)
	var/list/source = islist(shop_list) ? shop_list : shopping_list
	var/list/copy = CopyShopList(source)
	if(!length(copy))
		return FALSE
	var/list_name = name ? name : GetDefaultSavedCartName()
	if(list_name in saved_shopping_lists)
		ClearShopList(saved_shopping_lists[list_name])
	saved_shopping_lists[list_name] = copy
	return TRUE

/datum/computer_file/program/supply_base/proc/LoadShopList(name)
	if(!islist(saved_shopping_lists) || !(name in saved_shopping_lists))
		return null
	return CopyShopList(saved_shopping_lists[name])

/datum/computer_file/program/supply_base/proc/DeleteShopList(name)
	if(islist(saved_shopping_lists) && (name in saved_shopping_lists))
		ClearShopList(saved_shopping_lists[name])
		saved_shopping_lists -= name

/datum/computer_file/program/supply_base/proc/GetSavedCartTotal(list/cart_data)
	return round(SSsupply.CollectPriceForList(cart_data, faction), 0.01)

/datum/computer_file/program/supply_base/proc/SerializeSavedCarts()
	var/list/result = list()
	if(!islist(saved_shopping_lists))
		return result
	for(var/i in 1 to length(saved_shopping_lists))
		var/cart_name = saved_shopping_lists[i]
		var/list/cart_data = saved_shopping_lists[cart_name]
		if(!islist(cart_data))
			continue
		result.Add(list(list(
			"index" = i,
			"name" = cart_name,
			"count" = SSsupply.CollectCountsFrom(cart_data),
			"total" = GetSavedCartTotal(cart_data)
		)))
	return result

/datum/computer_file/program/supply_base/proc/LoadSavedCartDirect(raw_index)
	var/index = isnum(raw_index) ? raw_index : text2num(raw_index)
	if(isnum(index))
		index = round(index)
		if(index >= 1 && index <= length(saved_shopping_lists))
			var/name = saved_shopping_lists[index]
			var/list/loaded = LoadShopList(name)
			if(islist(loaded))
				var/count_before = SSsupply ? SSsupply.CollectCountsFrom(loaded) : 0
				var/list/backup = shopping_list
				shopping_list = loaded
				SanitizeShopList()
				var/count_after = SSsupply ? SSsupply.CollectCountsFrom(shopping_list) : 0
				if(!length(shopping_list) || count_after != count_before)
					shopping_list = backup
					return FALSE
				if(backup != shopping_list)
					ClearShopList(backup)
				return TRUE
	return FALSE

/datum/computer_file/program/supply_base/proc/DeleteSavedCartDirect(raw_index)
	var/index = isnum(raw_index) ? raw_index : text2num(raw_index)
	if(isnum(index))
		index = round(index)
		if(index >= 1 && index <= length(saved_shopping_lists))
			var/name = saved_shopping_lists[index]
			DeleteShopList(name)
			return TRUE
	return FALSE

/datum/computer_file/program/supply_base/proc/GetAvailableTradingStations()
	var/list/result = list()
	for(var/datum/trading_station/target_station as anything in SSsupply.visible_trading_stations)
		if(GetStationTradeBlockReason(target_station, faction))
			continue
		result += target_station
	return result

/datum/computer_file/program/supply_base/proc/OnStationSelected(datum/trading_station/selected_station)
	return

/datum/computer_file/program/supply_base/proc/EnsureSelectedStation()
	var/list/available_stations = GetAvailableTradingStations()
	if(!length(available_stations))
		station = null
		chosen_category = null
		return null

	if(!istype(station) || !(station in available_stations))
		station = available_stations[1]

	if(!chosen_category || !(chosen_category in station.inventory))
		SetChosenCategory()

	OnStationSelected(station)
	return station

/datum/computer_file/program/supply_base/proc/SetChosenCategory(value = null)
	if(!istype(station))
		chosen_category = null
		return
	if(value && (value in station.inventory))
		chosen_category = value
		return
	var/index = isnum(value) ? value : (istext(value) ? text2num(value) : null)
	if(isnum(index))
		index = round(index)
		if(index >= 1 && index <= length(station.inventory))
			chosen_category = station.inventory[index]
			return
	if(length(station.inventory))
		chosen_category = station.inventory[1]
	else
		chosen_category = null

/datum/computer_file/program/supply_base/proc/ResolveGoodId(category_name = null, good_ref)
	if(!istype(station))
		return null
	if(!category_name)
		category_name = chosen_category
	var/list/category = station.inventory[category_name]
	if(!islist(category) || !good_ref)
		return null
	if(good_ref in category)
		return good_ref
	var/index = isnum(good_ref) ? good_ref : text2num(good_ref)
	if(isnum(index))
		index = round(index)
		if(index >= 1 && index <= length(category))
			return category[index]
	return null

/datum/computer_file/program/supply_base/proc/GetTradeSource()
	return computer ? computer.get_physical_host() : null

/datum/computer_file/program/supply_base/proc/GetTradeSourceSector()
	var/atom/trade_source = GetTradeSource()
	if(!trade_source)
		return null
	return SSsupply.GetOvermapSectorFor(trade_source)

/datum/computer_file/program/supply_base/proc/GetStationCatalogBlockReason(datum/trading_station/target_station, buyer_faction = faction)
	if(!istype(target_station))
		return "Station unavailable."

	var/datum/trade_faction/station_faction = SSsupply.GetFaction(target_station.faction)
	if(istype(station_faction) && (buyer_faction in station_faction.embargo))
		return "Economic embargo in effect. Trading denied."
	if(length(target_station.whitelist_factions) && !(buyer_faction in target_station.whitelist_factions))
		return "This station trades only with approved factions."
	if(length(target_station.blacklist_factions) && (buyer_faction in target_station.blacklist_factions))
		return "This station refuses trade with your faction."
	var/availability_block = target_station.GetAvailabilityBlockReason(GetTradeSource())
	if(availability_block)
		return availability_block
	return null

/datum/computer_file/program/supply_base/proc/GetStationTradeBlockReason(datum/trading_station/target_station, buyer_faction = faction)
	var/catalog_block = GetStationCatalogBlockReason(target_station, buyer_faction)
	if(catalog_block)
		return catalog_block

	if(!GLOB.using_map.use_overmap || !istype(target_station) || !target_station.overmap_location)
		return null

	var/atom/trade_source = GetTradeSource()
	if(!trade_source)
		return null

	var/obj/overmap/visitable/current_sector = GetTradeSourceSector()
	if(!istype(current_sector))
		return "Trade catalog is available only while your vessel is present on the overmap."
	if(current_sector.z != target_station.overmap_location.z)
		return "This trade beacon is outside your current overmap region."

	var/distance = get_dist(current_sector, target_station.overmap_location)
	if(distance >= trade_catalog_view_distance)
		return "Move closer than [trade_catalog_view_distance] overmap tiles to browse this trade beacon's catalog."
	return null

/datum/computer_file/program/supply_base/proc/RequiresReceivingBeaconForStatus()
	return FALSE

/datum/computer_file/program/supply_base/proc/HasLocalReceivingBeacon()
	return TRUE

/datum/computer_file/program/supply_base/proc/GetStationStatusData(datum/trading_station/target_station, buyer_faction = faction, has_local_receiving_beacon = null)
	if(!istype(target_station))
		return list("label" = "Unavailable", "tone" = "bad")

	var/datum/trade_faction/station_faction = SSsupply.GetFaction(target_station.faction)
	if(istype(station_faction) && (buyer_faction in station_faction.embargo))
		return list("label" = "Embargoed", "tone" = "bad")

	if(length(target_station.whitelist_factions) && !(buyer_faction in target_station.whitelist_factions))
		return list("label" = "Wrong faction", "tone" = "bad")

	if(length(target_station.blacklist_factions) && (buyer_faction in target_station.blacklist_factions))
		return list("label" = "Wrong faction", "tone" = "bad")

	var/list/availability_status = target_station.GetAvailabilityStatusData()
	if(islist(availability_status) && target_station.GetAvailabilityBlockReason(GetTradeSource()))
		return availability_status

	if(RequiresReceivingBeaconForStatus())
		if(isnull(has_local_receiving_beacon))
			has_local_receiving_beacon = HasLocalReceivingBeacon()
		if(!has_local_receiving_beacon)
			return list("label" = "No local beacon", "tone" = "average")

	if(GetStationTradeBlockReason(target_station, buyer_faction))
		return list("label" = "Out of range", "tone" = "bad")

	return list("label" = "In range", "tone" = "good")

/datum/computer_file/program/supply_base/proc/CanAddGoodsToCart()
	return istype(account)

/datum/computer_file/program/supply_base/proc/TryAddToCart(good_ref, amount)
	if(!istype(station) || !chosen_category || !isnum(amount) || amount <= 0)
		return FALSE
	if(GetStationTradeBlockReason(station))
		return FALSE
	var/good_id = ResolveGoodId(chosen_category, good_ref)
	if(!good_id)
		return FALSE
	var/path = station.GetGoodPath(chosen_category, good_id)
	if(!ispath(path, /atom/movable))
		return FALSE
	var/good_amount = station.GetGoodAmount(chosen_category, good_id)
	if(!good_amount)
		return FALSE
	AddToShopList(good_id, round(amount), good_amount)
	return TRUE

/datum/computer_file/program/supply_base/proc/GetGoodMarkupText(basic_price, price)
	if(!basic_price || price == basic_price)
		return ""
	var/markup_percent = round(((price / basic_price) * 100) - 100)
	if(!markup_percent)
		return ""
	if(markup_percent > 0)
		return " (+[markup_percent]%)"
	return " ([markup_percent]%)"

/datum/computer_file/program/supply_base/proc/GetInsertedIdCard()
	var/obj/item/stock_parts/computer/card_slot/card_slot = computer ? computer.get_component(PART_CARD) : null
	return istype(card_slot) ? card_slot.stored_card : null

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
	for(var/category_name in target_station.inventory)
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
	var/list/category = target_station.inventory[chosen_category]
	if(!islist(category))
		return result

	var/block_reason = GetStationTradeBlockReason(target_station)
	if(block_reason)
		return result
	var/can_add_goods = CanAddGoodsToCart()
	var/station_key = target_station.uid || "[target_station.type]"
	var/list/station_cart = islist(shopping_list[station_key]) ? shopping_list[station_key] : (islist(shopping_list[target_station]) ? shopping_list[target_station] : null)
	var/list/assets_to_send = list()
	for(var/good_id in category)
		var/datum/trade_offer/offer = target_station.GetOffer(good_id)
		var/path = offer ? offer.item_path : target_station.GetGoodPath(chosen_category, good_id)
		if(!ispath(path, /atom/movable))
			continue
		var/stock = offer ? offer.stock : target_station.GetGoodAmount(chosen_category, good_id)
		var/basic_price = offer ? offer.base_price : SSsupply.GetStationTradeBasePrice(good_id, target_station, faction, chosen_category)
		var/price = SSsupply.GetStationBuyPrice(good_id, target_station, faction, chosen_category)
		var/sell_price = SSsupply.GetStationSellPrice(good_id, target_station, faction, chosen_category)
		var/in_cart = 0
		if(islist(station_cart))
			if(isnum(station_cart[good_id]))
				in_cart = station_cart[good_id]
			else if(islist(station_cart[chosen_category]))
				in_cart = station_cart[chosen_category][good_id] || 0
		var/atom/movable/item_type = path
		var/desc_text = initial(item_type.desc) || ""
		var/icon_asset = GetGoodIconAsset(path)
		if(icon_asset)
			assets_to_send |= icon_asset
		result.Add(list(list(
			"id" = good_id,
			"name" = offer ? offer.name : target_station.GetGoodName(chosen_category, good_id),
			"desc" = desc_text,
			"stock" = stock,
			"price" = round(price, 0.01),
			"sell_price" = round(sell_price, 0.01),
			"markup_text" = GetGoodMarkupText(basic_price, price),
			"can_add" = can_add_goods && stock > 0,
			"quantity_form_open" = ("[goods_quantity_target]" == "[good_id]"),
			"icon" = icon_asset,
			"in_cart_amount" = in_cart
		)))
	if(user && user.client && length(assets_to_send))
		send_asset_list(user.client, assets_to_send, FALSE)
	return result

/datum/computer_file/program/supply_base/proc/SerializeShopListGroups(list/shop_list, buyer_faction = null, list/price_snapshot = null)
	var/list/result = list()
	if(!islist(shop_list))
		return result
	if(isnull(buyer_faction))
		buyer_faction = faction

	for(var/station_key in shop_list)
		var/datum/trading_station/target_station = SSsupply ? SSsupply.ResolveStation(station_key) : null
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
	for(var/key in cart)
		var/val = cart[key]
		if(islist(val))
			grouped[key] = val
		else if(isnum(val) && val > 0)
			var/datum/trade_offer/offer = target_station.GetOffer(key)
			var/cat_name = offer ? (offer.category || "General") : "General"
			if(!islist(grouped[cat_name]))
				grouped[cat_name] = list()
			var/list/cat_items = grouped[cat_name]
			cat_items[key] = val
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
			var/unit_price = SSsupply.GetStationBuyPrice(good_id, target_station, buyer_faction, category_name)
			if(islist(price_snapshot))
				var/snapshot_price = SSsupply.GetSnapshotUnitPrice(price_snapshot, target_station, category_name, good_id)
				if(isnum(snapshot_price))
					unit_price = snapshot_price
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

/datum/computer_file/program/supply_base/proc/ResetUiForms()
	goods_quantity_target = null
	cart_form_mode = null

/datum/computer_file/program/supply_base/proc/CloseGoodsQuantityForm()
	goods_quantity_target = null

/datum/computer_file/program/supply_base/proc/OpenGoodsQuantityForm(good_id)
	goods_quantity_target = good_id
	cart_form_mode = null

/datum/computer_file/program/supply_base/proc/CloseCartForm()
	cart_form_mode = null

/datum/computer_file/program/supply_base/proc/OpenCartForm(mode)
	switch(mode)
		if("save", "order", "link_account", "link_id_account", "select_receiving", "select_sending", "save_order")
			cart_form_mode = mode
			goods_quantity_target = null
		else
			return

/datum/computer_file/program/supply_base/proc/HandleCartRemove(list/href_list)
	var/datum/trading_station/target_station = SSsupply.GetStationByUid(href_list["PRG_cart_remove_direct"])
	var/target_category = href_list["PRG_cart_category_name"]
	var/target_good_id = href_list["PRG_cart_good_id"]
	var/remove_amount = 1
	if("PRG_cart_remove_all" in href_list)
		remove_amount = 1000000
	else if("PRG_cart_remove_amount" in href_list)
		var/parsed_amount = text2num(href_list["PRG_cart_remove_amount"])
		if(!is_valid_cargo_quantity(parsed_amount))
			return TRUE
		remove_amount = round(parsed_amount)
	if(remove_amount > 0 && istype(target_station) && target_category && target_good_id)
		station = target_station
		chosen_category = target_category
		RemoveFromShopList(target_good_id, remove_amount, target_station, target_category)
	return TRUE

