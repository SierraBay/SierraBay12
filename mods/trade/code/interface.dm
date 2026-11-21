/datum/tgui_module/trade/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui/frontier_trade(user, src, "FrontierTrade", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/tgui/frontier_trade
	var/catalog_version = 0
	var/catalog_hacked = FALSE

/datum/tgui/frontier_trade/get_payload(custom_data, with_data, with_static_data)
	var/datum/tgui_module/trade/module = src_object
	var/current_version = SStrade.catalog_version
	var/hacked = module.is_hacked()
	if(with_data && (catalog_version != current_version || catalog_hacked != hacked))
		with_static_data = TRUE
	. = ..(custom_data, with_data, with_static_data)
	if(with_static_data)
		catalog_version = current_version
		catalog_hacked = hacked

/datum/tgui_module/trade/tgui_static_data(mob/user)
	var/hacked = is_hacked()
	var/list/catalog_rows = list()
	var/list/categories = list()
	for(var/uid in SStrade.stations)
		var/datum/trade_station/station = SStrade.stations[uid]
		if(!station.discovered || (station.black_market && !hacked))
			continue
		for(var/id in station.goods)
			var/datum/trade_good/good = station.goods[id]
			if(good.hidden && !station.hidden_inv_unlocked)
				continue
			if(good.category)
				categories |= good.category
			catalog_rows += list(list(
				"id" = id,
				"station_id" = station.uid,
				"station_name" = station.name,
				"name" = good.name,
				"desc" = good.desc,
				"category" = good.category,
				"stack_size" = good.stack_size,
				"floor_delivery" = good.needs_floor(),
				"delivery_mode" = good.delivery_mode,
				"container_label" = good.container_label,
				"is_bundle" = good.is_bundle,
				"randomized_count" = good.randomized_count,
				"contents_preview" = good.contents_preview,
				"req_access" = good.req_access_flat,
				"access_labels" = good.access_labels,
				"security_level" = good.security_level_code,
				"security_label" = good.security_label,
				"hidden" = good.hidden,
			))
	return list(
		"catalog_version" = SStrade.catalog_version,
		"currency" = GLOB.using_map.local_currency_name,
		"order_limit" = TRADE_ORDER_LIMIT,
		"handling_fee_rate" = TRADE_HANDLING_FEE,
		"entropy_limit" = TRADE_ENTROPY_LIMIT,
		"export_time_max" = TRADE_EXPORT_COOLDOWN,
		"read_only" = read_only,
		"program_type" = program_type,
		"categories" = categories,
		"catalog" = catalog_rows,
	)

/datum/tgui_module/trade/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = list()
	var/datum/money_account/supply = TRADE_SUPPLY_ACCOUNT
	var/manager = is_manager(user)
	data["read_only"] = read_only
	data["program_type"] = program_type
	data["manager"] = manager
	data["can_export"] = can_export(user)
	data["hacked"] = is_hacked()
	data["has_printer"] = has_printer()
	data["currency"] = GLOB.using_map.local_currency_name
	data["budget"] = (!manager && program_type == "ordering") ? 0 : (supply?.money || 0)
	data["message"] = message
	data["message_type"] = message_type
	data["order_limit"] = TRADE_ORDER_LIMIT
	data["request_wait"] = ceil(max(0, SStrade.request_ready_at[get_user_key(user)] - world.time) / (1 SECOND))
	data["ntos"] = build_ntos_data()
	build_stations_payload(data, user)
	if(read_only)
		data["account"] = list("owner" = null, "balance" = 0, "card_inserted" = FALSE, "card_owner" = null, "card_requires_pin" = FALSE, "card_linked" = FALSE, "card_access" = list())
		data["beacons"] = build_readonly_beacon_data()
		data["cart"] = list()
		data["cart_total"] = 0
		data["cart_fee"] = 0
		data["cart_count"] = 0
		data["cart_floor_needed"] = 0
		data["cart_overstock_ids"] = list()
		data["saved"] = list()
		data["orders"] = list()
		data["pending_orders_count"] = 0
		data["logs"] = list()
		data["logs_page"] = 1
		data["logs_page_size"] = logs_page_size
		data["logs_total"] = 0
		return data
	data["account"] = build_account_data()
	data["beacons"] = build_beacon_data(user)
	build_cart_payload(data, user)
	data["saved"] = build_saved_data()
	build_orders_payload(data, user)
	build_logs_payload(data, user)
	return data

/datum/tgui_module/trade/proc/build_ntos_data()
	var/datum/extension/interactive/ntos/os = program?.computer
	var/list/header = os ? os.get_header_data(program) : list()
	return list(
		"station_time" = header["PC_stationtime"] || stationtime2text(),
		"show_battery" = !!header["PC_showbatteryicon"],
		"battery_percent" = header["PC_batterypercent"] || "N/C",
		"ntnet_status" = os ? os.get_ntnet_status() : 0,
		"show_shutdown" = !!header["PC_showshutdown"],
		"active_program" = header["PC_activeprogram"] || program?.filename,
	)

/datum/tgui_module/trade/proc/build_account_data()
	var/datum/money_account/linked = get_linked_account()
	var/obj/item/card/id/inserted = get_inserted_card()
	var/datum/money_account/card_account = get_card_account()
	var/list/card_access = inserted ? inserted.GetAccess() : list()
	return list(
		"owner" = linked?.owner_name,
		"balance" = linked?.money || 0,
		"card_inserted" = !!inserted,
		"card_owner" = card_account?.owner_name,
		"card_requires_pin" = card_account ? (card_account.security_level > 0) : FALSE,
		"card_linked" = !!linked && inserted == linked_card,
		"card_access" = islist(card_access) ? card_access : list(),
	)

/datum/tgui_module/trade/proc/build_readonly_beacon_data()
	return list(
		"sender_id" = "",
		"receiver_id" = "",
		"sender_label" = "Unavailable",
		"receiver_label" = "Unavailable",
		"sender_present" = FALSE,
		"sender_ready" = FALSE,
		"export_ready" = FALSE,
		"export_time_max" = TRADE_EXPORT_COOLDOWN,
		"export_time_elapsed" = 0,
		"export_seconds" = 0,
		"sender_entropy" = 0,
		"entropy_limit" = TRADE_ENTROPY_LIMIT,
		"receiver_ready" = FALSE,
		"receiver_present" = FALSE,
		"receiver_free_tiles" = 0,
		"receiver_entropy" = 0,
		"receiver_locked_seconds" = 0,
		"estimated_delivery_seconds" = 0,
		"local_room_name" = null,
		"export_preview" = list("eligible_items" = 0, "estimated_payout" = 0, "blocked_roots" = 0, "payout_target" = "Supply Budget"),
		"senders" = list(),
		"receivers" = list(),
	)

/datum/tgui_module/trade/proc/build_beacon_data(mob/user)
	var/obj/machinery/trade_beacon/sending/sender = get_sender(require_ready = FALSE)
	var/obj/machinery/trade_beacon/receiving/receiver_rdy = get_receiver(null, require_ready = TRUE)
	var/obj/machinery/trade_beacon/receiving/receiver_any = receiver_rdy || get_receiver(null, require_ready = FALSE)
	var/free_tiles = receiver_any ? length(receiver_any.get_clear_turfs()) : 0
	var/rec_locked_s = 0
	if(receiver_any)
		receiver_any.clear_expired_instability()
		receiver_any.update_entropy()
		if(receiver_any.locked_until > world.time)
			rec_locked_s = ceil((receiver_any.locked_until - world.time) / (1 SECOND))
	var/est_delivery = receiver_rdy ? 2 : (rec_locked_s > 0 ? rec_locked_s + 2 : 0)
	var/area/local_room = is_slave() ? get_area(tgui_host(user)) : null
	var/list/preview = SStrade.preview_beacon_export(sender, is_slave())
	return list(
		"sender_id" = sender_id || "",
		"receiver_id" = receiver_id || "",
		"sender_label" = sender_id ? (sender ? sender.get_id() : "Unavailable") : (is_slave() && !sender ? "No local beacon in this room" : "Automatic"),
		"receiver_label" = get_receiver_label(),
		"sender_present" = !!sender,
		"sender_ready" = !!sender?.is_ready(),
		"export_ready" = !!(sender && sender.is_ready() && world.time >= sender.export_ready_at),
		"export_time_max" = TRADE_EXPORT_COOLDOWN,
		"export_time_elapsed" = sender ? clamp(world.time - sender.export_ready_at + TRADE_EXPORT_COOLDOWN, 0, TRADE_EXPORT_COOLDOWN) : 0,
		"export_seconds" = sender ? ceil(max(0, sender.export_ready_at - world.time) / (1 SECOND)) : 0,
		"sender_entropy" = sender ? round(sender.entropy, 0.1) : 0,
		"entropy_limit" = TRADE_ENTROPY_LIMIT,
		"receiver_ready" = !!receiver_rdy,
		"receiver_present" = !!receiver_any,
		"receiver_free_tiles" = free_tiles,
		"receiver_entropy" = receiver_any ? round(receiver_any.entropy, 0.1) : 0,
		"receiver_locked_seconds" = rec_locked_s,
		"estimated_delivery_seconds" = est_delivery,
		"local_room_name" = local_room?.name,
		"export_preview" = preview,
		"senders" = list_available_beacons(TRUE),
		"receivers" = list_available_beacons(FALSE),
	)

/datum/tgui_module/trade/proc/build_stations_payload(list/data, mob/user)
	var/list/station_rows = list()
	var/list/lines = list()
	var/list/stocks = list()
	var/list/prices = list()
	var/list/sec_locked = list()
	var/hacked = is_hacked()
	var/obj/machinery/trade_beacon/sending/sender = !read_only ? get_sender(require_ready = FALSE) : null
	var/export_rdy = !!(sender && sender.is_ready() && world.time >= sender.export_ready_at && can_export(user))
	var/list/bounty_candidates = sender ? SStrade.get_bounty_candidates(sender) : list()
	for(var/uid in SStrade.stations)
		var/datum/trade_station/station = SStrade.stations[uid]
		if(station.black_market && !hacked)
			continue
		if(station.discovered)
			for(var/id in station.goods)
				var/datum/trade_good/good = station.goods[id]
				if(good.hidden && !station.hidden_inv_unlocked)
					continue
				stocks[id] = good.stock
				prices[id] = good.get_price()
				if(!good.sec_available(hacked))
					sec_locked[id] = TRUE
		station_rows += list(serialize_station(station, hacked, bounty_candidates, export_rdy))
		append_tree_lines(lines, station, hacked)
	data["stations"] = station_rows
	data["tree_lines"] = lines
	data["stocks"] = stocks
	data["prices"] = prices
	data["sec_locked"] = sec_locked

/datum/tgui_module/trade/proc/serialize_station(datum/trade_station/station, hacked, list/bounty_candidates, export_rdy)
	var/list/recommends = list()
	for(var/target_uid in station.stations_recommended)
		var/datum/trade_station/target = SStrade.stations[target_uid]
		if(target && (!target.black_market || hacked))
			recommends += target.name
	var/favor_needed = station.hidden_inv_unlocked ? station.recommendation_threshold : station.hidden_inv_threshold
	var/list/offers_rows = list()
	var/visible_goods_count = 0
	if(station.discovered)
		for(var/id in station.goods)
			var/datum/trade_good/good = station.goods[id]
			if(!good.hidden || station.hidden_inv_unlocked)
				visible_goods_count++
		offers_rows = build_station_offers(station, bounty_candidates, export_rdy)
	return list(
		"id" = station.uid,
		"name" = station.name,
		"label" = station.tree_label,
		"desc" = station.desc,
		"icon" = station.icon_state,
		"color" = station.overmap_color,
		"x" = station.tree_x,
		"y" = station.tree_y,
		"discovered" = station.discovered,
		"black_market" = station.black_market,
		"markup" = station.markup,
		"specialties" = station.specialties,
		"goods_count" = visible_goods_count,
		"favor" = round(station.favor),
		"favor_needed" = favor_needed,
		"hidden_unlocked" = station.hidden_inv_unlocked,
		"recommendation_unlocked" = station.recommendation_unlocked,
		"recommendations_received" = length(station.recommendations_received),
		"recommendations_needed" = station.start_discovered ? 0 : station.recommendations_needed,
		"recommends" = recommends,
		"restock_seconds" = max(0, ceil((station.next_update - world.time) / (1 SECOND))),
		"offers" = offers_rows,
	)

/datum/tgui_module/trade/proc/build_station_offers(datum/trade_station/station, list/bounty_candidates, export_rdy)
	var/list/rows = list()
	for(var/id in station.offers)
		var/datum/trade_offer/offer = station.offers[id]
		var/total_reward = offer.unit_price * offer.amount
		var/matched = SStrade.count_offer_matches(offer, bounty_candidates)
		rows += list(list(
			"id" = id,
			"station_id" = station.uid,
			"station_name" = station.name,
			"name" = offer.name,
			"amount" = offer.amount,
			"unit_price" = offer.unit_price,
			"price" = total_reward,
			"favor_gain" = total_reward,
			"completed" = offer.completed,
			"requirements" = offer.get_requirements(),
			"matched_count" = matched,
			"can_fulfill" = !offer.completed && matched >= offer.amount && export_rdy,
			"reagent_volume" = offer.reagent_type ? offer.reagent_volume : 0,
			"stack_size" = offer.native_stack_size,
			"live_required" = offer.live_required,
		))
	return rows

/datum/tgui_module/trade/proc/append_tree_lines(list/lines, datum/trade_station/station, hacked)
	for(var/uid in station.stations_recommended)
		var/datum/trade_station/target = SStrade.stations[uid]
		if(!target || (target.black_market && !hacked))
			continue
		lines += list(list(
			"x1" = station.tree_x,
			"y1" = station.tree_y,
			"x2" = target.tree_x,
			"y2" = target.tree_y,
			"unlocked" = station.recommendation_unlocked,
		))

/datum/tgui_module/trade/proc/build_cart_payload(list/data, mob/user)
	var/list/rows = list()
	var/list/overstock_ids = list()
	var/total = 0
	var/count = 0
	var/has_loose = FALSE
	var/floor_items = 0
	var/hacked = is_hacked()
	var/obj/item/card/id/card = get_inserted_card()
	for(var/id in cart)
		var/datum/trade_good/good = SStrade.goods[id]
		if(!good)
			continue
		var/qty = cart[id]
		var/unit_price = good.get_price()
		total += unit_price * qty
		count += qty
		if(qty > good.stock)
			overstock_ids += id
		if(good.needs_floor())
			floor_items += qty
		else
			has_loose = TRUE
		rows += list(list(
			"id" = id,
			"name" = good.name,
			"quantity" = qty,
			"stock" = good.stock,
			"station_id" = good.station.uid,
			"station" = good.station.name,
			"category" = good.category,
			"unit_price" = unit_price,
			"price" = unit_price * qty,
			"stack_size" = good.stack_size,
			"floor_delivery" = good.needs_floor(),
			"delivery_mode" = good.delivery_mode,
			"container_label" = good.container_label,
			"restricted" = !good.is_available(hacked, user, personal = TRUE, card = card),
			"access_labels" = good.access_labels,
		))
	data["cart"] = rows
	data["cart_total"] = total
	data["cart_fee"] = ceil(total * TRADE_HANDLING_FEE)
	data["cart_count"] = count
	data["cart_floor_needed"] = count > 0 ? max(1, (has_loose ? 1 : 0) + floor_items) : 0
	data["cart_overstock_ids"] = overstock_ids

/datum/tgui_module/trade/proc/build_saved_data()
	var/list/rows = list()
	for(var/id in saved_carts)
		var/list/items = saved_carts[id]
		var/units = 0
		var/est_cost = 0
		var/list/preview_items = list()
		for(var/good_id in items)
			var/qty = items[good_id]
			units += qty
			var/datum/trade_good/good = SStrade.goods[good_id]
			var/uprice = good ? good.get_price() : 0
			est_cost += uprice * qty
			preview_items += list(list(
				"id" = good_id,
				"name" = good ? good.name : good_id,
				"quantity" = qty,
				"stock" = good ? good.stock : 0,
				"unit_price" = uprice,
			))
		rows += list(list(
			"id" = id,
			"name" = saved_names[id],
			"item_count" = length(items),
			"total_units" = units,
			"estimated_cost" = est_cost,
			"items" = preview_items,
		))
	return rows

/datum/tgui_module/trade/proc/build_orders_payload(list/data, mob/user)
	var/list/active_rows = list()
	var/list/done_rows = list()
	var/pending_count = 0
	var/manager = is_manager(user)
	var/user_key = get_user_key(user)
	for(var/id in SStrade.orders)
		var/datum/trade_order/order = SStrade.orders[id]
		if(order.state == TRADE_REQUEST)
			pending_count++
		if(!can_view_order(order, user))
			continue
		var/list/row = list(
			"id" = id,
			"buyer" = order.buyer,
			"reason" = order.reason,
			"state" = order.state,
			"total" = order.total,
			"fee" = order.fee,
			"pending" = order.state == TRADE_REQUEST,
			"cancellable" = (order.state in list(TRADE_REQUEST, TRADE_PAID)),
			"paid" = order.state == TRADE_PAID,
			"can_edit_reason" = (order.state == TRADE_REQUEST && (manager || order.requester_key == user_key)),
			"delivery_status" = get_order_delivery_status(order),
			"needed_tiles" = order.get_floor_count(),
			"items" = copy_trade_rows(order.get_rows(), encode = FALSE),
		)
		if(order.state in list(TRADE_REQUEST, TRADE_PAID))
			active_rows.Insert(1, list(row))
		else
			done_rows.Insert(1, list(row))
	if(length(done_rows) > 25)
		done_rows.Cut(26)
	active_rows += done_rows
	data["orders"] = active_rows
	data["pending_orders_count"] = pending_count

/datum/tgui_module/trade/proc/build_logs_payload(list/data, mob/user)
	var/list/visible = list()
	for(var/list/entry as anything in SStrade.shipping_log)
		if(can_view_log(entry, user))
			visible += list(entry)
	var/total = length(visible)
	var/page_size = max(5, min(50, logs_page_size || TRADE_LOG_PAGE_SIZE))
	var/max_page = max(1, ceil(total / page_size))
	var/cur_page = clamp(logs_page || 1, 1, max_page)
	logs_page = cur_page
	var/list/rows = list()
	var/start_idx = (cur_page - 1) * page_size + 1
	var/end_idx = min(total, cur_page * page_size)
	if(start_idx <= end_idx)
		for(var/idx in start_idx to end_idx)
			var/list/entry = visible[idx]
			var/list/row = entry.Copy()
			row["contents"] = copy_trade_rows(entry["contents"], encode = FALSE)
			rows += list(row)
	data["logs"] = rows
	data["logs_page"] = cur_page
	data["logs_page_size"] = page_size
	data["logs_total"] = total
