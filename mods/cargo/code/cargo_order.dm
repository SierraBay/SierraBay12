#define SUPPLY_ORDER_TAB_GOODS  "goods"
#define SUPPLY_ORDER_TAB_CART   "cart"
#define SUPPLY_ORDER_TAB_ORDERS "orders"

var/global/list/cargo_item_icon_cache = list()

/proc/is_valid_cargo_quantity(amount)
	return isnum(amount) && !isnan(amount) && amount > 0 && amount <= 1000 && round(amount) == amount

/datum/computer_file/program/supply_order
	filename = "supply_order"
	filedesc = "Supply Ordering"
	nanomodule_path = null
	ui_header = null
	program_icon_state = "supply"
	program_key_state = "rd_key"
	program_menu_icon = "cart"
	extended_desc = "Client application for browsing station trade catalogs and submitting supply order requests."
	size = 12
	available_on_ntnet = TRUE
	requires_ntnet = FALSE
	category = PROG_SUPPLY
	usage_flags = PROGRAM_ALL
	required_access = null
	requires_access_to_run = FALSE
	requires_access_to_download = FALSE

	var/faction = FACTION_INDEPENDENT
	var/current_tab = SUPPLY_ORDER_TAB_GOODS
	var/datum/money_account/account
	var/authenticated_via_card = FALSE
	var/list/shopping_list = list()
	var/datum/trading_station/station
	var/chosen_category
	var/current_order
	var/order_cooldown_until = 0
	var/goods_quantity_target
	var/order_reason = ""
	var/trade_catalog_view_distance = 6

/datum/computer_file/program/supply_order/New()
	..()
	if(GLOB.using_map?.trade_faction)
		faction = GLOB.using_map.trade_faction

/datum/computer_file/program/supply_order/on_startup(mob/living/user, datum/extension/interactive/ntos/new_host)
	. = ..()
	if(. && GLOB.using_map?.trade_faction)
		faction = GLOB.using_map.trade_faction

/datum/computer_file/program/supply_order/process_tick()
	..()
	if(length(shopping_list))
		ui_header = "supply_awaiting_delivery.gif"
	else
		ui_header = "supply_idle.gif"

/datum/computer_file/program/supply_order/Destroy()
	account = null
	authenticated_via_card = FALSE
	station = null
	current_order = null
	if(shopping_list)
		ClearShopList(shopping_list)
		shopping_list = null
	return ..()

/datum/computer_file/program/supply_order/proc/ClearShopList(list/target_list)
	if(!islist(target_list))
		return
	for(var/datum/trading_station/target_station as anything in target_list)
		var/list/categories = target_list[target_station]
		if(islist(categories))
			for(var/category_name in categories)
				var/list/goods = categories[category_name]
				if(islist(goods))
					goods.Cut()
			categories.Cut()
	target_list.Cut()

/datum/computer_file/program/supply_order/proc/CopyShopList(list/source)
	var/list/copied = list()
	if(!islist(source))
		return copied
	for(var/datum/trading_station/target_station as anything in source)
		var/list/categories = source[target_station]
		if(!islist(categories))
			continue
		var/list/category_copy = list()
		for(var/category_name in categories)
			var/list/goods = categories[category_name]
			if(islist(goods))
				category_copy[category_name] = goods.Copy()
		if(length(category_copy))
			copied[target_station] = category_copy
	return copied

/datum/computer_file/program/supply_order/proc/OpenShopList(datum/trading_station/target_station = station, target_category = chosen_category)
	if(!istype(target_station) || !target_category)
		return null
	if(!islist(shopping_list[target_station]))
		shopping_list[target_station] = list()
	var/list/categories = shopping_list[target_station]
	if(!islist(categories[target_category]))
		categories[target_category] = list()
	return categories[target_category]

/datum/computer_file/program/supply_order/proc/GetShopList(datum/trading_station/target_station = station, target_category = chosen_category)
	if(!istype(target_station) || !target_category || !islist(shopping_list))
		return null
	var/list/categories = shopping_list[target_station]
	if(!islist(categories))
		return null
	return categories[target_category]

/datum/computer_file/program/supply_order/proc/SanitizeShopList()
	for(var/datum/trading_station/target_station as anything in shopping_list.Copy())
		if(!istype(target_station) || QDELETED(target_station))
			shopping_list -= target_station
			continue
		var/list/categories = shopping_list[target_station]
		if(!islist(categories))
			shopping_list -= target_station
			continue
		for(var/category_name in categories.Copy())
			var/list/goods = categories[category_name]
			if(!islist(goods) || !length(goods))
				categories -= category_name
		if(!length(categories))
			shopping_list -= target_station

/datum/computer_file/program/supply_order/proc/AddToShopList(good_id, amount, limit)
	if(!good_id || !is_valid_cargo_quantity(amount))
		return
	var/list/inventory_list = OpenShopList()
	if(!islist(inventory_list))
		return
	var/target_amount = (inventory_list[good_id] || 0) + amount
	if(limit && target_amount > limit)
		target_amount = limit
	inventory_list[good_id] = target_amount

/datum/computer_file/program/supply_order/proc/RemoveFromShopList(good_id, amount, datum/trading_station/target_station = station, target_category = chosen_category)
	if(!good_id || !is_valid_cargo_quantity(amount))
		return
	var/list/inventory_list = GetShopList(target_station, target_category)
	if(!islist(inventory_list) || !(good_id in inventory_list))
		return
	inventory_list[good_id] -= amount
	if(inventory_list[good_id] < 1)
		inventory_list -= good_id
	SanitizeShopList()

/datum/computer_file/program/supply_order/proc/SetInShopList(good_id, amount, limit, datum/trading_station/target_station = station, target_category = chosen_category)
	if(!good_id || !isnum(amount) || isnan(amount))
		return
	if(amount <= 0)
		var/list/inventory_list = GetShopList(target_station, target_category)
		if(islist(inventory_list))
			inventory_list -= good_id
			SanitizeShopList()
		return
	if(!is_valid_cargo_quantity(amount))
		return
	var/target_amount = amount
	var/list/inventory_list = OpenShopList(target_station, target_category)
	if(!islist(inventory_list))
		return
	if(limit && target_amount > limit)
		target_amount = limit
	inventory_list[good_id] = target_amount

/datum/computer_file/program/supply_order/proc/ResetShopList()
	if(shopping_list)
		ClearShopList(shopping_list)
	shopping_list = list()

/datum/computer_file/program/supply_order/proc/EnsureSelectedStation()
	if(!length(SSsupply.visible_trading_stations))
		station = null
		chosen_category = null
		return null
	if(!istype(station) || !(station in SSsupply.visible_trading_stations))
		station = SSsupply.visible_trading_stations[1]
	if(!chosen_category || !(chosen_category in station.inventory))
		SetChosenCategory()
	return station

/datum/computer_file/program/supply_order/proc/SetChosenCategory(value = null)
	if(!istype(station))
		chosen_category = null
		return
	if(value && (value in station.inventory))
		chosen_category = value
		return
	if(length(station.inventory))
		chosen_category = station.inventory[1]
	else
		chosen_category = null

/datum/computer_file/program/supply_order/proc/ResolveGoodId(category_name = null, good_ref)
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

/datum/computer_file/program/supply_order/proc/GetTradeSource()
	return computer ? computer.get_physical_host() : null

/datum/computer_file/program/supply_order/proc/GetTradeSourceSector()
	var/atom/trade_source = GetTradeSource()
	if(!trade_source)
		return null
	return SSsupply.GetOvermapSectorFor(trade_source)

/datum/computer_file/program/supply_order/proc/GetStationCatalogBlockReason(datum/trading_station/target_station, buyer_faction = faction)
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

/datum/computer_file/program/supply_order/proc/GetStationTradeBlockReason(datum/trading_station/target_station, buyer_faction = faction)
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

/datum/computer_file/program/supply_order/proc/GetStationStatusData(datum/trading_station/target_station, buyer_faction = faction)
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
	if(GetStationTradeBlockReason(target_station, buyer_faction))
		return list("label" = "Out of range", "tone" = "bad")
	return list("label" = "In range", "tone" = "good")

/datum/computer_file/program/supply_order/proc/TryAddToCart(good_ref, amount)
	if(!istype(station) || !chosen_category || !is_valid_cargo_quantity(amount))
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
	AddToShopList(good_id, amount, good_amount)
	return TRUE

/datum/computer_file/program/supply_order/proc/GetGoodMarkupText(basic_price, price)
	if(!basic_price || price == basic_price)
		return ""
	var/markup_percent = round(((price / basic_price) * 100) - 100)
	if(!markup_percent)
		return ""
	if(markup_percent > 0)
		return " (+[markup_percent]%)"
	return " ([markup_percent]%)"

/datum/computer_file/program/supply_order/proc/GetInsertedIdCard()
	var/obj/item/stock_parts/computer/card_slot/card_slot = computer ? computer.get_component(PART_CARD) : null
	return istype(card_slot) ? card_slot.stored_card : null

/datum/computer_file/program/supply_order/proc/CheckAccountValidity()
	if(!account)
		return
	if(QDELETED(account) || account.suspended)
		account = null
		authenticated_via_card = FALSE
		return
	if(authenticated_via_card)
		var/obj/item/card/id/id_card = GetInsertedIdCard()
		if(!istype(id_card) || id_card.associated_account_number != account.account_number)
			account = null
			authenticated_via_card = FALSE
			return
	else if(account.account_type != ACCOUNT_TYPE_PERSONAL)
		var/obj/item/card/id/id_card = GetInsertedIdCard()
		if(!istype(id_card) || id_card.associated_account_number != account.account_number)
			account = null
			authenticated_via_card = FALSE
			return

/datum/computer_file/program/supply_order/proc/PromptLinkAccount(mob/user)
	var/obj/item/card/id/id_card = GetInsertedIdCard()
	var/default_number = id_card ? id_card.associated_account_number : null
	var/account_number = input(user, "Enter account number.", "Account Link", default_number) as num|null
	if(!account_number)
		return TRUE
	var/account_pin = input(user, "Enter PIN.", "Account Link") as num|null
	if(!account_pin)
		return TRUE
	var/card_check = istype(id_card) && id_card.associated_account_number == account_number
	var/datum/money_account/linked_account = attempt_account_access(account_number, account_pin, card_check ? 2 : 1)
	if(!linked_account)
		to_chat(user, SPAN_WARNING("Unable to link account: access denied."))
		return TRUE
	if(linked_account.suspended)
		to_chat(user, SPAN_WARNING("Unable to link account: account is suspended."))
		return TRUE
	if(!card_check && linked_account.account_type != ACCOUNT_TYPE_PERSONAL)
		to_chat(user, SPAN_WARNING("Public ordering terminals only allow linking personal accounts without physical ID card verification."))
		return TRUE
	if(linked_account.security_level == 0 && !card_check)
		to_chat(user, SPAN_WARNING("Accounts with level 0 security require a matching physical ID card to be inserted."))
		return TRUE
	account = linked_account
	authenticated_via_card = card_check ? TRUE : FALSE
	to_chat(user, SPAN_NOTICE("Account #[account.account_number] linked successfully."))
	return TRUE

/datum/computer_file/program/supply_order/proc/LinkInsertedIdAccount(mob/user)
	var/obj/item/card/id/id_card = GetInsertedIdCard()
	if(!istype(id_card))
		to_chat(user, SPAN_WARNING("Insert an ID card first."))
		return TRUE
	if(!id_card.associated_account_number)
		to_chat(user, SPAN_WARNING("This ID card is not linked to any bank account."))
		return TRUE
	var/account_pin = input(user, "Enter the PIN for account #[id_card.associated_account_number].", "ID Account Link") as num|null
	if(!account_pin)
		return TRUE
	var/datum/money_account/linked_account = attempt_account_access(id_card.associated_account_number, account_pin, 2)
	if(!linked_account)
		to_chat(user, SPAN_WARNING("Unable to link the ID-linked account: access denied."))
		return TRUE
	if(linked_account.suspended)
		to_chat(user, SPAN_WARNING("Unable to link account: account is suspended."))
		return TRUE
	account = linked_account
	authenticated_via_card = TRUE
	to_chat(user, SPAN_NOTICE("Account #[account.account_number] linked successfully."))
	return TRUE

/datum/computer_file/program/supply_order/proc/UnlinkAccount()
	account = null
	authenticated_via_card = FALSE
	to_chat(usr, SPAN_NOTICE("Account unlinked."))
	return TRUE

/datum/computer_file/program/supply_order/proc/GetCartTotals()
	var/count = SSsupply.CollectCountsFrom(shopping_list)
	var/subtotal = round(SSsupply.CollectPriceForList(shopping_list, faction), 0.01)
	var/fee = round(subtotal * SSsupply.handling_fee, 0.01)
	var/total = subtotal + fee
	return list("count" = count, "subtotal" = subtotal, "fee" = fee, "total" = total)

/datum/computer_file/program/supply_order/proc/GetSubmitBlockReason(list/totals)
	if(!istype(account) || account.suspended)
		return "Link an active personal bank account before submitting an order."
	if(!totals["count"] || totals["count"] <= 0)
		return "Your cart is empty. Add items from the catalog."
	if(world.time < order_cooldown_until)
		return "Please wait for the ordering cooldown to expire."
	if(account.money < totals["total"])
		return "Insufficient account balance to cover items and handling fee."
	for(var/datum/trading_station/target_station as anything in shopping_list)
		if(QDELETED(target_station))
			return "One of the stations in your cart is no longer available."
		var/station_block = GetStationTradeBlockReason(target_station)
		if(station_block)
			return "[target_station.name]: [station_block]"
	return null

/datum/computer_file/program/supply_order/proc/CanUserCancelOrder(mob/user, datum/money_account/req_acct)
	if(!istype(req_acct))
		return FALSE
	if(account && req_acct == account)
		return TRUE
	var/obj/item/card/id/id_card = user ? user.GetIdCard() : null
	if(istype(id_card) && id_card.associated_account_number == req_acct.account_number)
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/SubmitOrder(mob/user, raw_reason)
	CheckAccountValidity()
	var/list/totals = GetCartTotals()
	var/block = GetSubmitBlockReason(totals)
	if(block)
		to_chat(user, SPAN_WARNING(block))
		return TRUE
	if(SSsupply.CollectCountsFrom(shopping_list) <= 0)
		to_chat(user, SPAN_WARNING("Your cart is empty."))
		return TRUE
	var/reason = sanitize(raw_reason, MAX_MESSAGE_LEN)
	if(!length(trimtext(reason)))
		to_chat(user, SPAN_WARNING("A justification reason is required to submit a supply order."))
		return TRUE
	var/order_slot = SSsupply.BuildOrder(account, reason, CopyShopList(shopping_list), faction)
	if(!order_slot)
		to_chat(user, SPAN_WARNING("Failed to submit order to cargo queue."))
		return TRUE
	current_order = order_slot
	ResetShopList()
	order_reason = ""
	current_tab = SUPPLY_ORDER_TAB_ORDERS
	order_cooldown_until = world.time + 10 SECONDS
	to_chat(user, SPAN_NOTICE("Order [order_slot] submitted successfully to cargo."))
	return TRUE

/datum/computer_file/program/supply_order/proc/CancelOrder(mob/user, order_id)
	if(!order_id || !(order_id in SSsupply.order_queue))
		to_chat(user, SPAN_WARNING("Order was not found or has already been fulfilled."))
		return TRUE
	var/list/order_data = SSsupply.order_queue[order_id]
	if(!islist(order_data))
		return TRUE
	if(order_data["processing"] || order_data["status"] == "processing")
		to_chat(user, SPAN_WARNING("Order [order_id] is currently being processed and cannot be cancelled."))
		return TRUE
	var/datum/money_account/req_acct = order_data["requesting_acct"]
	if(!CanUserCancelOrder(user, req_acct))
		to_chat(user, SPAN_WARNING("You can only cancel orders submitted by your account."))
		return TRUE
	SSsupply.DismantleOrder(order_id)
	if(current_order == order_id)
		current_order = null
	to_chat(user, SPAN_NOTICE("Order [order_id] has been cancelled."))
	return TRUE

/datum/computer_file/program/supply_order/proc/GetMyOrderCount(user_acct_num)
	if(!user_acct_num)
		return 0
	var/count = 0
	for(var/order_id as anything in SSsupply.order_queue)
		var/list/order_data = SSsupply.order_queue[order_id]
		if(!islist(order_data))
			continue
		var/datum/money_account/req_acct = order_data["requesting_acct"]
		if(req_acct && req_acct.account_number == user_acct_num)
			count++
	return count

/datum/computer_file/program/supply_order/proc/PopulateBaseUiData(list/data, mob/user)
	CheckAccountValidity()
	var/obj/item/card/id/inserted_id = GetInsertedIdCard()
	var/list/totals = GetCartTotals()
	var/user_acct_num = account ? account.account_number : null
	if(!user_acct_num && istype(inserted_id))
		user_acct_num = inserted_id.associated_account_number
	if(!user_acct_num && istype(user))
		var/obj/item/card/id/held_card = user.GetIdCard()
		if(istype(held_card))
			user_acct_num = held_card.associated_account_number

	data["src"] = ref(src)
	data["screen"] = current_tab
	data["currency"] = GLOB.using_map?.local_currency_name || "Credits"
	data["currency_short"] = GLOB.using_map?.local_currency_name_short || "cr"
	data["faction"] = faction
	data["has_account"] = istype(account)
	data["account_owner_name"] = account ? account.owner_name : ""
	data["account_number"] = account ? account.account_number : 0
	data["account_money"] = account ? round(account.money, 0.01) : 0
	data["has_inserted_id"] = istype(inserted_id)
	data["can_link_id_account"] = istype(inserted_id) && !!inserted_id.associated_account_number
	data["inserted_id_account_number"] = inserted_id ? inserted_id.associated_account_number : 0
	data["cart_count"] = totals["count"]
	data["cart_subtotal"] = totals["subtotal"]
	data["cart_fee"] = totals["fee"]
	data["cart_total"] = totals["total"]
	data["handling_fee_percent"] = "[round(SSsupply.handling_fee * 100)]%"
	data["order_count"] = length(SSsupply.order_queue)
	data["my_order_count"] = (current_tab == SUPPLY_ORDER_TAB_ORDERS) ? GetMyOrderCount(user_acct_num) : 0
	data["orders_locked"] = (world.time < order_cooldown_until)

/datum/computer_file/program/supply_order/proc/SerializeVisibleStations()
	var/list/result = list()
	for(var/datum/trading_station/target_station as anything in SSsupply.visible_trading_stations)
		var/datum/trade_faction/station_faction = SSsupply.GetFaction(target_station.faction)
		var/faction_color = TradeRelationsColor(station_faction ? station_faction.relationship[faction] : null) || "#ffffff"
		var/list/status_data = GetStationStatusData(target_station, faction)
		result.Add(list(list(
			"uid" = target_station.uid,
			"name" = target_station.name,
			"faction" = target_station.faction,
			"faction_color" = faction_color,
			"selected" = (target_station == station),
			"status_label" = status_data["label"],
			"status_tone" = status_data["tone"]
		)))
	return result

/datum/computer_file/program/supply_order/proc/SerializeCategories(datum/trading_station/target_station)
	var/list/result = list()
	if(!istype(target_station))
		return result
	for(var/category_name in target_station.inventory)
		result.Add(list(list(
			"name" = category_name,
			"selected" = (category_name == chosen_category)
		)))
	return result

/datum/computer_file/program/supply_order/proc/GetGoodIconBase64(item_path)
	if(!ispath(item_path, /atom/movable))
		return ""
	var/cached = cargo_item_icon_cache[item_path]
	if(!isnull(cached))
		return cached
	if(!GLOB.iconCache)
		return ""
	var/atom/movable/dummy = item_path
	var/item_icon = initial(dummy.icon)
	var/item_state = initial(dummy.icon_state)
	if(!item_icon)
		cargo_item_icon_cache[item_path] = ""
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
		cargo_item_icon_cache[item_path] = ""
		return ""
	var/b64 = icon2base64(I, "cargo_[md5("[item_path]")]")
	var/icon_url = b64 ? "data:image/png;base64,[b64]" : ""
	cargo_item_icon_cache[item_path] = icon_url
	return icon_url

/datum/computer_file/program/supply_order/proc/SerializeGoods(datum/trading_station/target_station)
	var/list/result = list()
	if(!istype(target_station) || !chosen_category)
		return result
	var/block_reason = GetStationTradeBlockReason(target_station)
	if(block_reason)
		return result
	var/list/category = target_station.inventory[chosen_category]
	if(!islist(category))
		return result
	var/list/category_cart = islist(shopping_list[target_station]) ? shopping_list[target_station][chosen_category] : null
	for(var/good_id in category)
		var/path = target_station.GetGoodPath(chosen_category, good_id)
		if(!ispath(path, /atom/movable))
			continue
		var/stock = target_station.GetGoodAmount(chosen_category, good_id)
		var/basic_price = SSsupply.GetStationTradeBasePrice(good_id, target_station, faction, chosen_category)
		var/price = SSsupply.GetStationBuyPrice(good_id, target_station, faction, chosen_category)
		var/in_cart = islist(category_cart) ? (category_cart[good_id] || 0) : 0
		result.Add(list(list(
			"id" = good_id,
			"name" = target_station.GetGoodName(chosen_category, good_id),
			"stock" = stock,
			"price" = round(price, 0.01),
			"markup_text" = GetGoodMarkupText(basic_price, price),
			"can_add" = stock > 0,
			"quantity_form_open" = ("[goods_quantity_target]" == "[good_id]"),
			"icon" = GetGoodIconBase64(path),
			"in_cart_amount" = in_cart
		)))
	return result

/datum/computer_file/program/supply_order/proc/BuildGoodsScreenData(list/data)
	var/datum/trading_station/selected_station = EnsureSelectedStation()
	var/list/stations = SerializeVisibleStations()
	data["has_visible_stations"] = length(stations) ? TRUE : FALSE
	data["stations"] = stations
	data["has_selected_station"] = istype(selected_station)
	data["selected_category"] = chosen_category || ""
	if(istype(selected_station))
		var/block_reason = GetStationTradeBlockReason(selected_station)
		data["selected_station"] = list(
			"name" = selected_station.name,
			"uid" = selected_station.uid,
			"block_reason" = block_reason || ""
		)
		if(!block_reason)
			data["categories"] = SerializeCategories(selected_station)
			data["goods"] = SerializeGoods(selected_station)
		else
			data["categories"] = list()
			data["goods"] = list()
	else
		data["categories"] = list()
		data["goods"] = list()

/datum/computer_file/program/supply_order/proc/SerializeShopListGroups(list/shop_list, buyer_faction = null, list/price_snapshot = null)
	var/list/result = list()
	if(!islist(shop_list))
		return result
	if(isnull(buyer_faction))
		buyer_faction = faction
	for(var/datum/trading_station/target_station as anything in shop_list)
		var/list/categories = shop_list[target_station]
		if(!istype(target_station) || !islist(categories))
			continue
		var/list/category_entries = SerializeShopListCategories(target_station, categories, buyer_faction, price_snapshot)
		if(length(category_entries))
			result.Add(list(list(
				"station_uid" = target_station.uid,
				"station_name" = target_station.name,
				"categories" = category_entries
			)))
	return result

/datum/computer_file/program/supply_order/proc/SerializeShopListCategories(datum/trading_station/target_station, list/categories, buyer_faction, list/price_snapshot)
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
				var/snap = SSsupply.GetSnapshotUnitPrice(price_snapshot, target_station, category_name, good_id)
				if(isnum(snap))
					unit_price = snap
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
			category_entries.Add(list(list("name" = category_name, "items" = item_entries)))
	return category_entries

/datum/computer_file/program/supply_order/proc/BuildCartScreenData(list/data)
	var/list/totals = GetCartTotals()
	var/block = GetSubmitBlockReason(totals)
	data["cart_groups"] = SerializeShopListGroups(shopping_list, faction)
	data["can_submit_order"] = !block
	data["submit_block_reason"] = block || ""
	data["order_reason"] = order_reason || ""

/datum/computer_file/program/supply_order/proc/SerializeOrders(mob/user)
	var/list/result = list()
	var/user_acct_num = account ? account.account_number : null
	if(!user_acct_num && istype(user))
		var/obj/item/card/id/id_card = user.GetIdCard()
		if(istype(id_card))
			user_acct_num = id_card.associated_account_number
	var/total_serialized = 0
	for(var/order_id as anything in SSsupply.order_queue)
		if(total_serialized >= 50)
			break
		var/list/order_data = SSsupply.order_queue[order_id]
		if(!islist(order_data))
			continue
		var/datum/money_account/requestor = order_data["requesting_acct"]
		var/is_mine = requestor && user_acct_num && (requestor.account_number == user_acct_num)
		var/is_processing = (order_data["processing"] || order_data["status"] == "processing")
		result.Add(list(list(
			"id" = order_id,
			"requestor_name" = requestor ? requestor.owner_name : "Unknown",
			"requestor_account_number" = requestor ? requestor.account_number : 0,
			"total" = round(order_data["cost"] + order_data["fee"], 0.01),
			"status" = order_data["status"] || "Pending",
			"status_tone" = is_processing ? "bad" : "average",
			"is_mine" = is_mine,
			"can_cancel" = is_mine && !is_processing,
			"selected" = (current_order == order_id)
		)))
		total_serialized++
	return result

/datum/computer_file/program/supply_order/proc/SerializeSelectedOrder(mob/user)
	if(current_order && !(current_order in SSsupply.order_queue))
		current_order = null
	if(!current_order)
		return null
	var/list/order_data = SSsupply.order_queue[current_order]
	if(!islist(order_data))
		return null
	var/datum/money_account/requestor = order_data["requesting_acct"]
	var/buyer_faction = order_data["buyer_faction"] || FACTION_INDEPENDENT
	var/list/price_snapshot = order_data["price_snapshot"]
	var/is_mine = CanUserCancelOrder(user, requestor)
	var/is_processing = (order_data["processing"] || order_data["status"] == "processing")
	return list(
		"id" = current_order,
		"requestor_name" = requestor ? requestor.owner_name : "Unknown",
		"requestor_account_number" = requestor ? requestor.account_number : 0,
		"status" = order_data["status"] || "Pending",
		"status_tone" = is_processing ? "bad" : "average",
		"is_mine" = is_mine,
		"can_cancel" = is_mine && !is_processing,
		"cost" = round(order_data["cost"], 0.01),
		"fee" = round(order_data["fee"], 0.01),
		"total" = round(order_data["cost"] + order_data["fee"], 0.01),
		"reason" = order_data["reason"] || "Not provided",
		"contents" = SerializeShopListGroups(order_data["contents"], buyer_faction, price_snapshot)
	)

/datum/computer_file/program/supply_order/proc/BuildOrdersScreenData(list/data, mob/user)
	var/selected_order_data = SerializeSelectedOrder(user)
	data["orders"] = SerializeOrders(user)
	data["has_selected_order"] = islist(selected_order_data)
	if(islist(selected_order_data))
		data["selected_order"] = selected_order_data

/datum/computer_file/program/supply_order/proc/HandleTabTopic(list/href_list)
	if(!("PRG_trade_screen" in href_list))
		return FALSE
	var/new_tab = href_list["PRG_trade_screen"]
	if(new_tab in list(SUPPLY_ORDER_TAB_GOODS, SUPPLY_ORDER_TAB_CART, SUPPLY_ORDER_TAB_ORDERS))
		current_tab = new_tab
		goods_quantity_target = null
	return TRUE

/datum/computer_file/program/supply_order/proc/HandleAccountTopic(mob/user, list/href_list)
	if("PRG_account" in href_list)
		return PromptLinkAccount(user)
	if("PRG_account_id" in href_list)
		return LinkInsertedIdAccount(user)
	if("PRG_account_unlink" in href_list)
		return UnlinkAccount()
	return FALSE

/datum/computer_file/program/supply_order/proc/HandleCatalogTopic(list/href_list)
	var/station_id = href_list["PRG_station"] || href_list["amp;PRG_station"]
	if(station_id)
		station = SSsupply.GetVisibleStationByUid(station_id)
		SetChosenCategory()
		goods_quantity_target = null
		return TRUE
	if("PRG_goods_category" in href_list)
		EnsureSelectedStation()
		if(!GetStationTradeBlockReason(station))
			SetChosenCategory(href_list["PRG_goods_category"])
		goods_quantity_target = null
		return TRUE
	if("PRG_goods_quantity_target" in href_list)
		EnsureSelectedStation()
		goods_quantity_target = href_list["PRG_goods_quantity_target"]
		return TRUE
	if("PRG_goods_quantity_cancel" in href_list)
		goods_quantity_target = null
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/HandleCartFormTopic(list/href_list)
	if("PRG_cart_add_form" in href_list)
		EnsureSelectedStation()
		var/block_reason = GetStationTradeBlockReason(station)
		if(block_reason)
			to_chat(usr, SPAN_WARNING(block_reason))
		else
			var/amount = text2num(href_list["PRG_cart_add_amount"])
			if(is_valid_cargo_quantity(amount))
				TryAddToCart(href_list["PRG_cart_add_form"], amount)
		goods_quantity_target = null
		return TRUE
	if("PRG_cart_set_form" in href_list)
		EnsureSelectedStation()
		var/block_reason = GetStationTradeBlockReason(station)
		if(block_reason)
			to_chat(usr, SPAN_WARNING(block_reason))
		else
			var/good_id = ResolveGoodId(chosen_category, href_list["PRG_cart_set_form"])
			var/amount = text2num(href_list["PRG_cart_set_amount"])
			if(good_id && isnum(amount) && !isnan(amount))
				SetInShopList(good_id, amount, station.GetGoodAmount(chosen_category, good_id))
		goods_quantity_target = null
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/HandleCartTopic(list/href_list)
	if("PRG_cart_add_good" in href_list)
		EnsureSelectedStation()
		var/block_reason = GetStationTradeBlockReason(station)
		if(block_reason)
			to_chat(usr, SPAN_WARNING(block_reason))
			return TRUE
		TryAddToCart(href_list["PRG_cart_add_good"], 1)
		return TRUE
	if("PRG_cart_remove_good" in href_list)
		EnsureSelectedStation()
		var/good_id = ResolveGoodId(chosen_category, href_list["PRG_cart_remove_good"])
		if(good_id)
			RemoveFromShopList(good_id, 1, station, chosen_category)
		return TRUE
	if(HandleCartFormTopic(href_list))
		return TRUE
	if("PRG_cart_remove_direct" in href_list)
		return HandleCartRemove(href_list)
	if("PRG_cart_reset" in href_list)
		ResetShopList()
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/proc/HandleCartRemove(list/href_list)
	var/datum/trading_station/target_station = SSsupply.GetStationByUid(href_list["PRG_cart_remove_direct"])
	var/target_category = href_list["PRG_cart_category_name"]
	var/target_good_id = href_list["PRG_cart_good_id"]
	var/remove_amount = 1
	if("PRG_cart_remove_amount" in href_list)
		var/parsed_amount = text2num(href_list["PRG_cart_remove_amount"])
		if(is_valid_cargo_quantity(parsed_amount))
			remove_amount = parsed_amount
	if(remove_amount > 0 && istype(target_station) && target_category && target_good_id)
		RemoveFromShopList(target_good_id, remove_amount, target_station, target_category)
	return TRUE

/datum/computer_file/program/supply_order/proc/HandleOrderTopic(mob/user, list/href_list)
	if("PRG_build_order_form" in href_list)
		return SubmitOrder(user, href_list["PRG_order_reason"])
	if("PRG_view_order" in href_list)
		current_order = href_list["PRG_view_order"]
		return TRUE
	if("PRG_cancel_order" in href_list)
		return CancelOrder(user, href_list["PRG_cancel_order"])
	return FALSE

/datum/computer_file/program/supply_order/Topic(href, href_list)
	if(..() || href_list["close"])
		return TRUE
	if(HandleTabTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleAccountTopic(usr, href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleCatalogTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleCartTopic(href_list))
		SSnano.update_uis(src)
		return TRUE
	if(HandleOrderTopic(usr, href_list))
		SSnano.update_uis(src)
		return TRUE
	return FALSE

/datum/computer_file/program/supply_order/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	. = ..()
	if(!.)
		return

	var/list/data = get_header_data() || list()
	PopulateBaseUiData(data, user)

	switch(current_tab)
		if(SUPPLY_ORDER_TAB_GOODS)
			BuildGoodsScreenData(data)
		if(SUPPLY_ORDER_TAB_CART)
			BuildCartScreenData(data)
		if(SUPPLY_ORDER_TAB_ORDERS)
			BuildOrdersScreenData(data, user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-cargo_order_client.tmpl", "Supply Order Client", 900, 700, state = GLOB.default_state)
		ui.set_initial_data(data)
		ui.open()

#undef SUPPLY_ORDER_TAB_GOODS
#undef SUPPLY_ORDER_TAB_CART
#undef SUPPLY_ORDER_TAB_ORDERS
