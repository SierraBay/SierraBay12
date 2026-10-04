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
		return target_station.uid
	return istext(station_ref) ? station_ref : null

/datum/computer_file/program/supply_base/proc/ClearShopList(list/target_list)
	clear_cargo_cart(target_list)

/datum/computer_file/program/supply_base/proc/CopyShopList(list/source)
	return copy_cargo_cart(source)

/datum/computer_file/program/supply_base/proc/OpenShopList(station_ref = station, target_category = chosen_category)
	var/station_key = GetStationKey(station_ref)
	if(!station_key)
		return null
	if(!islist(shopping_list[station_key]))
		shopping_list[station_key] = list()
	return shopping_list[station_key]

/datum/computer_file/program/supply_base/proc/GetShopList(station_ref = station, target_category = chosen_category)
	var/station_key = GetStationKey(station_ref)
	return station_key && islist(shopping_list) ? shopping_list[station_key] : null

/datum/computer_file/program/supply_base/proc/SanitizeShopList()
	if(!islist(shopping_list))
		return
	for(var/station_uid in shopping_list.Copy())
		var/datum/trading_station/target_station = istext(station_uid) ? SSsupply.GetStationByUid(station_uid) : null
		var/list/goods = shopping_list[station_uid]
		if(!istype(target_station) || QDELETED(target_station) || !islist(goods))
			shopping_list -= station_uid
			continue
		for(var/good_id in goods.Copy())
			if(!istext(good_id) || !is_valid_cargo_quantity(goods[good_id]) || !target_station.GetOffer(good_id))
				goods -= good_id
		if(!length(goods))
			shopping_list -= station_uid

/datum/computer_file/program/supply_base/proc/AddToShopList(good_id, amount, limit, station_ref = station)
	if(!is_valid_cargo_quantity(amount) || (isnum(limit) && limit <= 0))
		return
	var/station_key = GetStationKey(station_ref)
	var/list/goods = GetShopList(station_ref)
	var/target_amount = min(1000, (goods?[good_id] || 0) + amount)
	if(isnum(limit))
		target_amount = min(target_amount, limit)
	set_cargo_cart_quantity(shopping_list, station_key, good_id, target_amount)

/datum/computer_file/program/supply_base/proc/RemoveFromShopList(good_id, amount, station_ref = station, target_category = chosen_category)
	if(!isnum(amount) || isnan(amount) || amount <= 0)
		return
	var/list/goods = GetShopList(station_ref)
	set_cargo_cart_quantity(shopping_list, GetStationKey(station_ref), good_id, max(0, (goods?[good_id] || 0) - round(amount)))
	SanitizeShopList()

/datum/computer_file/program/supply_base/proc/SetInShopList(good_id, amount, limit, station_ref = station, target_category = chosen_category)
	if(!isnum(amount) || isnan(amount))
		return
	if(amount <= 0 || (isnum(limit) && limit <= 0))
		RemoveFromShopList(good_id, 999999, station_ref, target_category)
		return
	if(!is_valid_cargo_quantity(amount))
		return
	var/target_amount = isnum(limit) ? min(amount, limit) : amount
	set_cargo_cart_quantity(shopping_list, GetStationKey(station_ref), good_id, target_amount)

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

/datum/computer_file/program/supply_base/proc/GetSavedCartTotal(list/cart_data, list/totals = null)
	totals ||= SSsupply.GetCartTotals(cart_data, faction)
	return totals["subtotal"]

/datum/computer_file/program/supply_base/proc/LoadSavedCartDirect(raw_index)
	var/index = isnum(raw_index) ? raw_index : text2num(raw_index)
	if(isnum(index))
		index = round(index)
		if(index >= 1 && index <= length(saved_shopping_lists))
			var/name = saved_shopping_lists[index]
			var/list/loaded = LoadShopList(name)
			if(islist(loaded))
				var/list/backup = shopping_list
				shopping_list = loaded
				SanitizeShopList()
				if(!length(shopping_list))
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

	if(!chosen_category || !(chosen_category in station.offers_by_category))
		SetChosenCategory()

	OnStationSelected(station)
	return station

/datum/computer_file/program/supply_base/proc/SetChosenCategory(value = null)
	if(!istype(station))
		chosen_category = null
		return
	if(value && (value in station.offers_by_category))
		chosen_category = value
		return
	var/index = isnum(value) ? value : (istext(value) ? text2num(value) : null)
	if(isnum(index))
		index = round(index)
		if(index >= 1 && index <= length(station.offers_by_category))
			chosen_category = station.offers_by_category[index]
			return
	if(length(station.offers_by_category))
		chosen_category = station.offers_by_category[1]
	else
		chosen_category = null

/datum/computer_file/program/supply_base/proc/ResolveGoodId(category_name = null, good_ref)
	if(!istype(station))
		return null
	if(!category_name)
		category_name = chosen_category
	var/list/category = station.offers_by_category[category_name]
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

/datum/computer_file/program/supply_base/proc/GetCartTotals()
	return SSsupply.GetCartTotals(shopping_list, faction)
