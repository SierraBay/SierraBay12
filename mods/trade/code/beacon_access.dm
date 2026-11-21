/datum/tgui_module/trade/proc/is_slave()
	return !read_only && program_type == "slave"

/datum/tgui_module/trade/proc/can_use_beacon(obj/machinery/trade_beacon/beacon)
	if(QDELETED(beacon) || read_only)
		return FALSE
	if(program_type != "slave")
		return TRUE
	var/area/room = get_area(tgui_host())
	return room && get_area(beacon) == room

/datum/tgui_module/trade/proc/get_sender(require_ready = TRUE)
	var/obj/machinery/trade_beacon/sending/fallback
	for(var/obj/machinery/trade_beacon/sending/beacon as anything in SStrade.beacons_sending)
		if(!can_use_beacon(beacon) || (sender_id && sender_id != "\ref[beacon]"))
			continue
		if(beacon.is_ready() && world.time >= beacon.export_ready_at)
			return beacon
		if(!fallback || (beacon.is_ready() && !fallback.is_ready()) || (beacon.is_ready() == fallback.is_ready() && beacon.export_ready_at < fallback.export_ready_at))
			fallback = beacon
	return require_ready ? null : fallback

/datum/tgui_module/trade/proc/get_receiver(datum/trade_order/order = null, require_ready = TRUE)
	var/needed = order ? max(1, order.get_floor_count()) : 1
	var/obj/machinery/trade_beacon/receiving/fallback
	for(var/obj/machinery/trade_beacon/receiving/beacon as anything in SStrade.beacons_receiving)
		if(!can_use_beacon(beacon) || (receiver_id && receiver_id != "\ref[beacon]"))
			continue
		if(length(beacon.get_landing_turfs(needed)))
			return beacon
		if(!require_ready && !fallback && !beacon.panel_open && !MACHINE_IS_BROKEN(beacon) && beacon.powered())
			fallback = beacon
	return require_ready ? null : fallback

/datum/tgui_module/trade/proc/set_selected_beacon(sending, target_id)
	target_id = istext(target_id) ? target_id : ""
	if(target_id)
		var/list/beacons = sending ? SStrade.beacons_sending : SStrade.beacons_receiving
		var/found = FALSE
		for(var/obj/machinery/trade_beacon/beacon as anything in beacons)
			if(can_use_beacon(beacon) && target_id == "\ref[beacon]")
				found = TRUE
				break
		if(!found)
			set_message("Selected freight beacon is unavailable.", "bad")
			return FALSE
	if(sending)
		sender_id = target_id
	else
		receiver_id = target_id
	if(program?.frontier_trade_state)
		program.frontier_trade_state[sending ? "sender" : "receiver"] = target_id
	set_message(target_id ? "Selected freight beacon updated." : "Freight beacon set to automatic.", "info")
	return TRUE

/datum/tgui_module/trade/proc/can_export(mob/user)
	return is_manager(user) || (is_slave() && !!get_linked_account())

/datum/tgui_module/trade/proc/get_bounty_account()
	return is_slave() ? get_linked_account() : TRADE_SUPPLY_ACCOUNT

/datum/tgui_module/trade/proc/bind_receiver(datum/trade_order/order)
	var/obj/machinery/trade_beacon/receiving/beacon = get_receiver(order, require_ready = TRUE) || get_receiver(order, require_ready = FALSE)
	if(!beacon)
		return FALSE
	order.receiver_id = "\ref[beacon]"
	order.delivery_area = is_slave() ? get_area(tgui_host()) : null
	return TRUE

/datum/tgui_module/trade/proc/get_receiver_label()
	if(!receiver_id)
		var/obj/machinery/trade_beacon/receiving/auto_rec = get_receiver(null, require_ready = FALSE)
		if(is_slave() && !auto_rec)
			return "No local beacon in this room"
		return auto_rec ? "Automatic ([auto_rec.get_id()])" : "Automatic"
	for(var/obj/machinery/trade_beacon/receiving/beacon as anything in SStrade.beacons_receiving)
		if(can_use_beacon(beacon) && receiver_id == "\ref[beacon]")
			return beacon.get_id()
	return "Unavailable"

/datum/tgui_module/trade/proc/list_available_beacons(sending)
	var/list/beacons = sending ? SStrade.beacons_sending : SStrade.beacons_receiving
	var/list/usable = list()
	var/any_ready = FALSE
	for(var/obj/machinery/trade_beacon/beacon as anything in beacons)
		if(!can_use_beacon(beacon))
			continue
		var/rdy = beacon.is_ready()
		any_ready ||= rdy
		usable += list(list(
			"id" = "\ref[beacon]",
			"label" = beacon.get_id(),
			"ready" = rdy,
		))
	var/auto_label = (is_slave() && !length(usable)) ? "No local beacon in this room" : "Automatic"
	var/list/rows = list(list("id" = "", "label" = auto_label, "ready" = any_ready))
	rows += usable
	return rows

/datum/tgui_module/trade/proc/get_order_delivery_status(datum/trade_order/order)
	if(!order)
		return ""
	if(order.state == TRADE_REQUEST)
		return "Awaiting Quartermaster approval"
	if(order.state == TRADE_DELIVERED)
		return "Delivered"
	if(order.state == TRADE_CANCELLED)
		return "Cancelled"
	var/needed = order.get_floor_count()
	var/obj/machinery/trade_beacon/receiving/beacon = SStrade.get_receiver(order, require_ready = TRUE)
	if(beacon)
		return "Ready for delivery (~2s)"
	var/obj/machinery/trade_beacon/receiving/fallback = SStrade.get_receiver(order, require_ready = FALSE)
	if(!fallback)
		return "Blocked: No powered receiving beacon available"
	fallback.clear_expired_instability()
	if(fallback.locked_until > world.time)
		var/rem = ceil((fallback.locked_until - world.time) / (1 SECOND))
		return "Waiting: Receiver cooling down ([rem]s)"
	var/free_tiles = length(fallback.get_clear_turfs())
	if(!free_tiles)
		return "Blocked: Receiving pad is full (0 clear floor tiles; needs [needed])"
	return "Queued for next delivery cycle"
