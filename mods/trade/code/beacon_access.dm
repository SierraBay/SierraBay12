/datum/nano_module/program/trade/proc/is_slave()
	return !read_only && program_type == "slave"

/datum/nano_module/program/trade/proc/can_use_beacon(obj/machinery/trade_beacon/beacon)
	if(QDELETED(beacon) || read_only)
		return FALSE
	if(program_type != "slave")
		return TRUE
	var/area/room = get_area(nano_host())
	return room && get_area(beacon) == room

/datum/nano_module/program/trade/proc/get_sender(require_ready = TRUE)
	var/obj/machinery/trade_beacon/sending/fallback
	for(var/obj/machinery/trade_beacon/sending/beacon as anything in SStrade.beacons_sending)
		if(!can_use_beacon(beacon) || (sender_id && sender_id != "\ref[beacon]"))
			continue
		if(beacon.is_ready() && world.time >= beacon.export_ready_at)
			return beacon
		if(!fallback || (beacon.is_ready() && !fallback.is_ready()) || (beacon.is_ready() == fallback.is_ready() && beacon.export_ready_at < fallback.export_ready_at))
			fallback = beacon
	return require_ready ? null : fallback

/datum/nano_module/program/trade/proc/get_receiver(datum/trade_order/order = null)
	for(var/obj/machinery/trade_beacon/receiving/beacon as anything in SStrade.beacons_receiving)
		if(!can_use_beacon(beacon) || (receiver_id && receiver_id != "\ref[beacon]"))
			continue
		if(length(beacon.get_landing_turfs(order ? order.get_floor_count() : 1)))
			return beacon

/datum/nano_module/program/trade/proc/select_beacon(sending, mob/user)
	var/list/choices = list("Automatic" = "")
	var/list/beacons = sending ? SStrade.beacons_sending : SStrade.beacons_receiving
	for(var/obj/machinery/trade_beacon/beacon as anything in beacons)
		if(can_use_beacon(beacon))
			choices[beacon.get_id()] = "\ref[beacon]"
	var/selection = input(user, "Select freight beacon", "Trade") as null|anything in choices
	if(QDELETED(src) || !selection || !can_still_topic())
		return
	if(sending)
		sender_id = choices[selection]
	else
		receiver_id = choices[selection]
	program.frontier_trade_state[sending ? "sender" : "receiver"] = choices[selection]

/datum/nano_module/program/trade/proc/can_export(mob/user)
	return is_manager(user) || (is_slave() && !!get_linked_account())

/datum/nano_module/program/trade/proc/get_bounty_account()
	return is_slave() ? get_linked_account() : TRADE_SUPPLY_ACCOUNT

/datum/nano_module/program/trade/proc/bind_receiver(datum/trade_order/order)
	var/obj/machinery/trade_beacon/receiving/beacon = get_receiver(order)
	if(!beacon)
		return FALSE
	order.receiver_id = "\ref[beacon]"
	order.delivery_area = is_slave() ? get_area(nano_host()) : null
	return TRUE

/datum/nano_module/program/trade/proc/get_receiver_label()
	if(!receiver_id)
		return "Automatic"
	for(var/obj/machinery/trade_beacon/receiving/beacon as anything in SStrade.beacons_receiving)
		if(can_use_beacon(beacon) && receiver_id == "\ref[beacon]")
			return beacon.get_id()
	return "Unavailable"
