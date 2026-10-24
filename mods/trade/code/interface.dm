/datum/nano_module/program/trade/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data(program)
	build_data(data, user)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(ui)
		return
	ui = new(user, src, ui_key, "mods-trade.tmpl", name, 1000, 760, state = state)
	ui.add_template("_goods", "mods-trade_goods.tmpl")
	ui.add_template("_cart", "mods-trade_cart.tmpl")
	ui.add_template("_offers", "mods-trade_offers.tmpl")
	ui.add_template("_orders", "mods-trade_orders.tmpl")
	ui.add_template("_saved", "mods-trade_saved.tmpl")
	ui.add_template("_logs", "mods-trade_log.tmpl")
	ui.set_initial_data(data)
	ui.set_auto_update(TRUE)
	ui.open()

/datum/nano_module/program/trade/proc/build_data(list/data, mob/user)
	data["screen"] = screen
	data["prg_screen"] = prg_screen
	data["read_only"] = read_only
	data["message"] = html_encode(message)
	data["currency"] = GLOB.using_map.local_currency_name
	data["manager"] = is_manager(user)
	data["can_export"] = can_export(user)
	data["can_logs"] = !read_only && (user || !!get_linked_account())
	data["program_type"] = program_type
	data["hacked"] = is_hacked()
	data["stations"] = build_station_data()
	data["categories"] = build_categories_data()
	data["category"] = chosen_category
	data["goods"] = build_goods_data(user)
	data["cart"] = build_cart_data(user)
	build_cart_filters(data)
	data["request_wait"] = ceil(max(0, SStrade.request_ready_at[get_user_key(user)] - world.time) / (1 SECOND))
	data["total"] = get_cart_total()
	data["fee"] = ceil(data["total"] * TRADE_HANDLING_FEE)
	data["saved"] = build_saved_data()
	data["orders"] = build_orders_data(user)
	data["offers"] = build_offers_data()
	data["logs"] = build_logs_data(user)
	data["log_filter"] = log_filter
	build_detail_data(data, user)
	var/datum/money_account/supply = TRADE_SUPPLY_ACCOUNT
	data["budget"] = supply?.money || 0
	build_beacon_data(data)
	build_tree_data(data)
	build_dossier_data(data)
	build_account_data(data)
	paginate(data)
	data["receiver_ready"] = !!get_receiver()
	data["card_inserted"] = !!get_inserted_card()

/datum/nano_module/program/trade/proc/build_station_data()
	var/list/rows = list()
	for(var/uid in SStrade.stations)
		var/datum/trade_station/station = SStrade.stations[uid]
		if(!station.discovered || (station.black_market && !is_hacked()))
			continue
		rows += list(list(
			"id" = uid,
			"name" = html_encode(station.name),
			"favor" = station.favor,
			"hidden" = station.hidden_inv_unlocked,
			"restock" = max(0, round((station.next_update - world.time) / (1 SECOND))),
		))
	return rows

/datum/nano_module/program/trade/proc/build_goods_data(mob/user)
	var/list/rows = list()
	var/datum/trade_station/station = SStrade.stations[selected_station]
	if(!station?.discovered || (station.black_market && !is_hacked()))
		return rows
	for(var/id in station.goods)
		var/datum/trade_good/good = station.goods[id]
		if(!good.is_available(is_hacked()) || (chosen_category && chosen_category != good.category))
			continue
		rows += list(list(
			"id" = id,
			"name" = html_encode(good.name),
			"category" = html_encode(good.category),
			"stock" = good.stock,
			"cart_count" = cart[id] || 0,
			"price" = good.get_price(),
			"stack_size" = good.stack_size,
			"floor_delivery" = good.needs_floor(),
			"restricted" = !good.is_available(is_hacked(), user, personal = TRUE, card = get_inserted_card()),
		))
	return rows

/datum/nano_module/program/trade/proc/build_cart_data(mob/user)
	var/list/rows = list()
	for(var/id in cart)
		var/datum/trade_good/good = SStrade.goods[id]
		if(!good || (cart_station && cart_station != good.station.uid) || (cart_category && cart_category != good.category))
			continue
		rows += list(list(
			"id" = id,
			"name" = html_encode(good.name),
			"quantity" = cart[id],
			"station" = html_encode(good.station.name),
			"category" = html_encode(good.category),
			"unit_price" = good.get_price(),
			"price" = good.get_price() * cart[id],
			"stack_size" = good.stack_size,
			"restricted" = !good.is_available(is_hacked(), user, personal = TRUE, card = get_inserted_card()),
		))
	return rows

/datum/nano_module/program/trade/proc/get_cart_total()
	var/total = 0
	for(var/id in cart)
		var/datum/trade_good/good = SStrade.goods[id]
		if(good)
			total += good.get_price() * cart[id]
	return total

/datum/nano_module/program/trade/proc/build_saved_data()
	var/list/rows = list()
	for(var/id in saved_carts)
		rows += list(list("id" = id, "name" = html_encode(saved_names[id])))
	return rows

/datum/nano_module/program/trade/proc/build_orders_data(mob/user)
	var/list/rows = list()
	for(var/id in SStrade.orders)
		var/datum/trade_order/order = SStrade.orders[id]
		if(!can_view_order(order, user))
			continue
		rows += list(list(
			"id" = id,
			"buyer" = html_encode(order.buyer),
			"reason" = html_encode(order.reason),
			"state" = order.state,
			"total" = order.total + order.fee,
			"pending" = order.state == TRADE_REQUEST,
			"cancellable" = (order.state in list(TRADE_REQUEST, TRADE_PAID)),
			"paid" = order.state == TRADE_PAID,
		))
	return rows

/datum/nano_module/program/trade/proc/build_offers_data()
	var/list/rows = list()
	var/datum/trade_station/station = SStrade.stations[selected_station]
	if(!station?.discovered || (station.black_market && !is_hacked()))
		return rows
	for(var/id in station.offers)
		var/datum/trade_offer/offer = station.offers[id]
		rows += list(list(
			"id" = id,
			"name" = html_encode(offer.name),
			"amount" = offer.amount,
			"price" = offer.unit_price * offer.amount,
			"completed" = offer.completed,
			"requirements" = html_encode(offer.get_requirements()),
		))
	return rows

/datum/nano_module/program/trade/proc/build_beacon_data(list/data)
	var/obj/machinery/trade_beacon/sending/beacon = get_sender(require_ready = FALSE)
	data["sender_ready"] = !!beacon?.is_ready()
	data["export_ready"] = beacon && beacon.is_ready() && world.time >= beacon.export_ready_at
	data["export_time_max"] = TRADE_EXPORT_COOLDOWN
	data["export_time_elapsed"] = beacon ? clamp(world.time - beacon.export_ready_at + TRADE_EXPORT_COOLDOWN, 0, TRADE_EXPORT_COOLDOWN) : 0
	data["export_seconds"] = beacon ? ceil(max(0, beacon.export_ready_at - world.time) / (1 SECOND)) : 0
	data["sender_present"] = !!beacon
	data["sender_entropy"] = beacon ? round(beacon.entropy, 0.1) : 0
	data["sender_label"] = html_encode(sender_id ? (beacon ? beacon.get_id() : "Unavailable") : "Automatic")
	data["receiver_label"] = html_encode(get_receiver_label())

/datum/nano_module/program/trade/proc/build_account_data(list/data)
	var/datum/money_account/account = get_linked_account()
	data["account"] = account ? html_encode(account.owner_name) : null
	data["balance"] = account?.money || 0

/datum/nano_module/program/trade/proc/build_tree_data(list/data)
	var/list/nodes = list()
	var/list/lines = list()
	for(var/uid in SStrade.stations)
		var/datum/trade_station/station = SStrade.stations[uid]
		if(station.black_market && !is_hacked())
			continue
		nodes += list(list("id" = uid, "name" = html_encode(station.name), "label" = html_encode(station.tree_label), "x" = station.tree_x, "y" = station.tree_y, "is_discovered" = station.discovered, "icon" = station.icon_state))
		append_tree_lines(lines, station)
	data["trade_tree"] = nodes
	data["tree_lines"] = lines
	data["station_id"] = selected_station

/datum/nano_module/program/trade/proc/append_tree_lines(list/lines, datum/trade_station/station)
	for(var/uid in station.stations_recommended)
		var/datum/trade_station/target = SStrade.stations[uid]
		if(!target || (target.black_market && !is_hacked()))
			continue
		lines += list(list(
			"line_x" = min(station.tree_x, target.tree_x),
			"line_y" = min(station.tree_y, target.tree_y),
			"width" = abs(station.tree_x - target.tree_x),
			"height" = abs(station.tree_y - target.tree_y),
			"istop" = target.tree_y > station.tree_y,
			"isright" = target.tree_x < station.tree_x,
			"unlocked" = station.recommendation_unlocked,
		))

/datum/nano_module/program/trade/proc/build_dossier_data(list/data)
	var/datum/trade_station/station = SStrade.stations[selected_station]
	if(!station || (station.black_market && !is_hacked()))
		return
	data["station_name"] = html_encode(station.name)
	data["station_desc"] = html_encode(station.desc)
	data["station_discovered"] = station.discovered
	data["station_favor"] = round(station.favor)
	data["station_favor_needed"] = station.hidden_inv_unlocked ? station.recommendation_threshold : station.hidden_inv_threshold
	data["station_hidden"] = station.hidden_inv_unlocked
	data["station_recommended"] = station.recommendation_unlocked
	data["station_recommendations_needed"] = station.start_discovered ? 0 : station.recommendations_needed
	data["station_recommendations_received"] = length(station.recommendations_received)
	data["station_recommendations"] = get_recommendation_names(station)
	data["offer_time"] = "[ceil(max(0, station.next_update - world.time) / (1 SECOND))]s"

/datum/nano_module/program/trade/proc/get_recommendation_names(datum/trade_station/station)
	var/list/names = list()
	for(var/uid in station.stations_recommended)
		var/datum/trade_station/target = SStrade.stations[uid]
		if(target && (!target.black_market || is_hacked()))
			names += html_encode(target.name)
	return jointext(names, "; ")

/datum/nano_module/program/trade/proc/paginate(list/data)
	var/list/rows = data[screen]
	if(!islist(rows))
		return
	var/page_count = max(1, ceil(length(rows) / TRADE_PAGE_SIZE))
	var/page = clamp(pages[screen] || 1, 1, page_count)
	pages[screen] = page
	data["page"] = page
	data["page_count"] = page_count
	data["row_count"] = length(rows)
	var/start = (page - 1) * TRADE_PAGE_SIZE + 1
	data[screen] = rows.Copy(start, min(length(rows) + 1, start + TRADE_PAGE_SIZE))

/datum/nano_module/program/trade/proc/build_categories_data()
	var/list/categories = list()
	var/datum/trade_station/station = SStrade.stations[selected_station]
	if(!station?.discovered || (station.black_market && !is_hacked()))
		return categories
	for(var/id in station.goods)
		var/datum/trade_good/good = station.goods[id]
		if(good.is_available(is_hacked()))
			categories |= good.category
	var/list/rows = list()
	for(var/category in categories)
		rows += list(list("id" = category, "name" = html_encode(category)))
	return rows

/datum/nano_module/program/trade/proc/build_logs_data(mob/user)
	var/list/rows = list()
	for(var/list/entry as anything in SStrade.shipping_log)
		if(can_view_log(entry, user) && (log_filter == "All" || log_filter == entry["kind"]))
			rows += list(entry)
	return rows

/datum/nano_module/program/trade/proc/build_detail_data(list/data, mob/user)
	data["order_detail"] = null
	data["log_detail"] = null
	var/datum/trade_order/order = SStrade.orders[selected_order_id]
	if(order && can_view_order(order, user))
		data["order_detail"] = list("id" = order.id, "buyer" = html_encode(order.buyer), "reason" = html_encode(order.reason), "state" = order.state, "items" = copy_trade_rows(order.get_rows(), TRUE), "total" = order.total, "fee" = order.fee, "paid" = order.state == TRADE_PAID, "pending" = order.state == TRADE_REQUEST)
	for(var/list/entry as anything in SStrade.shipping_log)
		if(entry["id"] != selected_log_id || !can_view_log(entry, user))
			continue
		var/list/detail = entry.Copy()
		detail["contents"] = copy_trade_rows(entry["contents"], TRUE)
		data["log_detail"] = detail
		break

/datum/nano_module/program/trade/proc/build_cart_filters(list/data)
	var/list/vendors = list()
	var/list/categories = list()
	for(var/id in cart)
		var/datum/trade_good/good = SStrade.goods[id]
		if(!good)
			continue
		vendors[good.station.uid] = good.station.name
		if(!cart_station || cart_station == good.station.uid)
			categories |= good.category
	var/list/rows = list()
	for(var/uid in vendors)
		rows += list(list("id" = uid, "name" = html_encode(vendors[uid])))
	data["cart_stations"] = rows
	rows = list()
	for(var/category in categories)
		rows += list(list("id" = category, "name" = html_encode(category)))
	data["cart_categories"] = rows
	data["cart_station"] = cart_station
	data["cart_category"] = cart_category
