/datum/computer_file/program/supply_order/proc/PopulateBaseUiData(list/data, mob/user, list/totals = null)
	CheckAccountValidity(user)
	var/obj/item/card/id/available_id = GetAvailableIdCard(user)
	totals ||= GetCartTotals()

	data["src"] = ref(src)
	data["screen"] = current_tab
	data["user_greeting"] = (user && user.name) ? "WELCOME, [uppertext(user.name)]" : "WELCOME TO SUPPLY ORDER TERMINAL"
	data["currency"] = GLOB.using_map?.local_currency_name || "Credits"
	data["currency_short"] = GLOB.using_map?.local_currency_name_short || "cr"
	data["faction"] = faction
	data["has_account"] = istype(account)
	data["account_owner_name"] = account ? account.owner_name : ""
	data["account_number"] = account ? account.account_number : 0
	data["account_money"] = account ? round(account.money, 0.01) : 0
	data["has_available_id"] = istype(available_id)
	data["can_link_id_account"] = istype(available_id) && !!available_id.associated_account_number
	data["available_id_name"] = available_id ? (available_id.registered_name || available_id.name) : ""
	data["available_id_account_number"] = available_id ? available_id.associated_account_number : 0
	data["cart_count"] = totals["count"]
	data["cart_subtotal"] = totals["subtotal"]
	data["cart_fee"] = totals["fee"]
	data["cart_total"] = totals["total"]
	data["handling_fee_percent"] = "[round(SSsupply.handling_fee * 100)]%"
	data["order_count"] = length(SSsupply.order_queue)
	data["my_order_count"] = GetMyOrderCount(user)
	data["orders_locked"] = (world.time < order_cooldown_until)
	data["cart_form_mode"] = cart_form_mode
	data["saved_carts"] = SerializeSavedCarts()
	data["orders_filter"] = orders_filter

/datum/computer_file/program/supply_order/proc/BuildGoodsScreenData(list/data, mob/user = null)
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
			data["goods"] = SerializeGoods(selected_station, user)
		else
			data["categories"] = list()
			data["goods"] = list()
	else
		data["categories"] = list()
		data["goods"] = list()

/datum/computer_file/program/supply_order/proc/BuildCartScreenData(list/data, list/totals = null)
	totals ||= GetCartTotals()
	var/block = GetSubmitBlockReason(totals)
	data["cart_groups"] = SerializeShopListGroups(shopping_list, faction, totals["price_snapshot"])
	data["can_submit_order"] = !block
	data["submit_block_reason"] = block || ""
	data["order_reason"] = order_reason || ""

/datum/computer_file/program/supply_order/proc/SerializeOrders(mob/user)
	var/list/result = list()
	for(var/order_id in SSsupply.order_queue)
		if(length(result) >= 50)
			break
		var/datum/cargo_order/order = SSsupply.GetCargoOrder(order_id)
		if(!order)
			continue
		var/is_mine = CanUserCancelOrder(user, order.requesting_acct)
		if(orders_filter == "mine" && !is_mine)
			continue
		var/list/entry = SerializeCargoOrder(order)
		entry["is_mine"] = is_mine
		entry["can_cancel"] = is_mine && !order.IsLocked()
		result.Add(list(entry))
	return result

/datum/computer_file/program/supply_order/proc/BuildOrdersScreenData(list/data, mob/user)
	data["orders"] = SerializeOrders(user)

/datum/computer_file/program/supply_order/proc/BuildAccountScreenData(list/data, mob/user)
	var/obj/item/card/id/inserted_id = GetInsertedIdCard()
	var/obj/item/card/id/held_id = user ? user.GetIdCard() : null
	data["inserted_id"] = istype(inserted_id) ? "[inserted_id.registered_name || inserted_id.name] (#[inserted_id.associated_account_number])" : "None"
	data["carried_id"] = istype(held_id) ? "[held_id.registered_name || held_id.name] (#[held_id.associated_account_number])" : "None"
	data["account_verified"] = authenticated_via_card
