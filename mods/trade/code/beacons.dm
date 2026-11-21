/obj/machinery/trade_beacon
	name = "trade beacon"
	desc = "A bluespace freight transceiver linked to local frontier relays."
	icon = 'mods/trade/icons/trade_beacon.dmi'
	icon_state = "beacon"
	anchored = TRUE
	density = TRUE
	use_power = POWER_USE_IDLE
	idle_power_usage = 500
	active_power_usage = 5000
	construct_state = /singleton/machine_construction/default/panel_closed
	var/base_icon_state = "beacon"
	var/entropy = 0
	var/entropy_updated = 0
	var/locked_until = 0
	var/instability_timer

/obj/machinery/trade_beacon/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/trade_beacon/on_update_icon()
	icon_state = panel_open ? "[base_icon_state]_panel" : base_icon_state

/obj/machinery/trade_beacon/proc/is_ready()
	clear_expired_instability()
	update_entropy()
	return SStrade.enabled && !QDELETED(src) && !panel_open && !MACHINE_IS_BROKEN(src) && powered() && world.time >= locked_until

/obj/machinery/trade_beacon/proc/clear_expired_instability()
	if(!locked_until || world.time < locked_until)
		return
	if(instability_timer)
		deltimer(instability_timer)
	reset_instability()

/obj/machinery/trade_beacon/proc/activate()
	update_entropy()
	entropy += 2
	flick("[base_icon_state]_active", src)
	use_power_oneoff(active_power_usage)
	var/datum/effect/spark_spread/sparks = new
	sparks.set_up(3, FALSE, src)
	sparks.start()
	if(entropy < TRADE_ENTROPY_LIMIT)
		return
	locked_until = world.time + TRADE_INSTABILITY_DURATION
	visible_message(SPAN_WARNING("[src] reports bluespace instability. Freight suspended for thirty seconds."))
	instability_timer = addtimer(new Callback(src, PROC_REF(reset_instability)), TRADE_INSTABILITY_DURATION, TIMER_STOPPABLE)

/obj/machinery/trade_beacon/proc/update_entropy()
	var/elapsed = floor(max(0, world.time - entropy_updated) / TRADE_ENTROPY_DECAY_INTERVAL)
	entropy = max(0, entropy - elapsed)
	entropy_updated = entropy ? entropy_updated + elapsed * TRADE_ENTROPY_DECAY_INTERVAL : world.time

/obj/machinery/trade_beacon/proc/get_id()
	var/area/location = get_area(src)
	return "[location?.name] ([x], [y], [z])"

/obj/machinery/trade_beacon/proc/reset_instability()
	instability_timer = null
	entropy = 0
	entropy_updated = world.time
	locked_until = 0

/obj/machinery/trade_beacon/Destroy()
	if(instability_timer)
		deltimer(instability_timer)
	return ..()

/obj/machinery/trade_beacon/sending
	name = "sending trade beacon"
	icon_state = "beacon_sending"
	base_icon_state = "beacon_sending"
	uncreated_component_parts = list(
		/obj/item/stock_parts/circuitboard/trade_beacon/sending,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/manipulator,
	)
	var/export_ready_at = 0
	var/export_timer

/obj/machinery/trade_beacon/sending/Initialize(mapload)
	. = ..()
	SStrade.beacons_sending |= src

/obj/machinery/trade_beacon/sending/Destroy()
	SStrade.beacons_sending -= src
	if(export_timer)
		deltimer(export_timer)
	return ..()

/obj/machinery/trade_beacon/sending/proc/get_objects()
	var/list/objects = list()
	var/turf/center = get_turf(src)
	if(!center)
		return objects
	var/list/floors = get_transfer_turfs()
	for(var/turf/floor as anything in floors)
		for(var/atom/movable/item as anything in floor.contents)
			if(!istype(item) || item == src)
				continue
			if(item.anchored && !istype(item, /obj/machinery/stasis_cage) && !istype(item, /obj/machinery/anomaly_container))
				continue
			objects |= item
	return objects

/// Clamp the freight area to map bounds for beacons installed near the edge.
/obj/machinery/trade_beacon/proc/get_transfer_turfs()
	return block(
		locate(max(1, x - TRADE_BEACON_RANGE), max(1, y - TRADE_BEACON_RANGE), z),
		locate(min(world.maxx, x + TRADE_BEACON_RANGE), min(world.maxy, y + TRADE_BEACON_RANGE), z),
	)

/obj/machinery/trade_beacon/sending/proc/start_export()
	if(export_timer)
		deltimer(export_timer)
	activate()
	export_ready_at = world.time + TRADE_EXPORT_COOLDOWN
	export_timer = addtimer(new Callback(src, PROC_REF(reset_export)), TRADE_EXPORT_COOLDOWN, TIMER_STOPPABLE)

/obj/machinery/trade_beacon/sending/proc/reset_export()
	export_timer = null
	export_ready_at = 0

/obj/machinery/trade_beacon/receiving
	name = "receiving trade beacon"
	uncreated_component_parts = list(
		/obj/item/stock_parts/circuitboard/trade_beacon/receiving,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/manipulator,
	)

/obj/machinery/trade_beacon/receiving/Initialize(mapload)
	. = ..()
	SStrade.beacons_receiving |= src

/obj/machinery/trade_beacon/receiving/Destroy()
	SStrade.beacons_receiving -= src
	return ..()

/obj/machinery/trade_beacon/receiving/proc/get_clear_turfs()
	var/list/clear_floors = list()
	var/list/floors = get_transfer_turfs()
	for(var/turf/simulated/floor/floor as anything in floors)
		if(is_landing_clear(floor))
			clear_floors += floor
	return clear_floors

/obj/machinery/trade_beacon/receiving/proc/get_landing_turf()
	var/list/floors = get_landing_turfs(1)
	return length(floors) ? floors[1] : null

/obj/machinery/trade_beacon/receiving/proc/get_landing_turfs(count)
	var/list/result = list()
	if(!is_ready() || count <= 0)
		return result
	var/list/clear_floors = get_clear_turfs()
	var/available = length(clear_floors)
	if(!available)
		return result
	for(var/index in 1 to count)
		result += clear_floors[((index - 1) % available) + 1]
	return result

/obj/machinery/trade_beacon/receiving/proc/is_landing_clear(turf/simulated/floor/floor)
	if(!istype(floor) || floor.density)
		return FALSE
	for(var/atom/movable/item as anything in floor.contents)
		if(item.density || ismob(item))
			return FALSE
	return TRUE

/obj/item/stock_parts/circuitboard/trade_beacon
	name = "circuit board (trade beacon)"
	board_type = "machine"
	origin_tech = list(TECH_BLUESPACE = 2, TECH_ENGINEERING = 2)
	req_components = list(/obj/item/stock_parts/capacitor = 1, /obj/item/stock_parts/manipulator = 1)

/obj/item/stock_parts/circuitboard/trade_beacon/sending
	name = "circuit board (sending trade beacon)"
	build_path = /obj/machinery/trade_beacon/sending

/obj/item/stock_parts/circuitboard/trade_beacon/receiving
	name = "circuit board (receiving trade beacon)"
	build_path = /obj/machinery/trade_beacon/receiving

/datum/design/circuit/trade_sending
	id = "trade_sending"
	build_path = /obj/item/stock_parts/circuitboard/trade_beacon/sending
	req_tech = list(TECH_BLUESPACE = 2, TECH_ENGINEERING = 2)

/datum/design/circuit/trade_receiving
	id = "trade_receiving"
	build_path = /obj/item/stock_parts/circuitboard/trade_beacon/receiving
	req_tech = list(TECH_BLUESPACE = 2, TECH_ENGINEERING = 2)

/obj/structure/closet/secure_closet/personal/trade
	name = "trade shipment"
	desc = "A reusable freight container. Personal shipments unlock with the buyer's ID and can be dismantled with a welder when unlocked."

/obj/structure/closet/secure_closet/personal/trade/WillContain()
	return list()

/obj/structure/closet/secure_closet/personal/trade/slice_into_parts(obj/item/weldingtool/WT, mob/user)
	if(locked)
		to_chat(user, SPAN_WARNING("Unlock \the [src] before dismantling it."))
		return
	dump_contents()
	user.visible_message(
		SPAN_NOTICE("\The [src] has been dismantled by [user] with \the [WT]."),
		SPAN_NOTICE("You dismantle \the [src] with \the [WT]."),
		"You hear welding.",
	)
	qdel(src)

/obj/structure/closet/secure_closet/personal/trade/verb/collapse_shipment_locker()
	set src in oview(1)
	set category = "Object"
	set name = "Collapse Empty Locker"

	if(!CanPhysicallyInteract(usr))
		return
	if(locked)
		to_chat(usr, SPAN_WARNING("Unlock \the [src] first."))
		return
	if(length(contents))
		to_chat(usr, SPAN_WARNING("Empty \the [src] before collapsing it."))
		return
	usr.visible_message(
		SPAN_NOTICE("[usr] folds and collapses \the [src] for disposal."),
		SPAN_NOTICE("You fold and collapse \the [src]."),
	)
	qdel(src)

/obj/item/paper/trade_invoice
	name = "trade invoice"
	info = "Frontier Trade Network"

/obj/item/device/price_scanner
	parent_type = /obj/item/device/scanner/price

/obj/overmap/trade_station
	name = "frontier trade relay"
	desc = "A frontier trade relay broadcasting commercial telemetry."
	icon_state = "radio"
	scannable = TRUE
	requires_contact = TRUE
	var/datum/trade_station/station

/obj/overmap/trade_station/Initialize(mapload, datum/trade_station/new_station)
	if(new_station)
		station = new_station
		name = new_station.name
		desc = new_station.desc
		color = new_station.overmap_color
		if(new_station.start_discovered)
			instant_contact = TRUE
	return ..()

/obj/overmap/trade_station/Destroy()
	if(station)
		station.overmap_object = null
	station = null
	return ..()
