/obj/machinery/trade_beacon
	icon = 'icons/obj/machines/beacon.dmi'
	icon_state = "beacon"
	anchored = TRUE
	density = TRUE

/obj/machinery/trade_beacon/proc/Activate()
	flick("[icon_state]_active", src)
	var/datum/effect/spark_spread/sparks = new
	sparks.set_up(5, 1, get_turf(src))
	sparks.start()
	playsound(get_turf(src), "sparks", 50, 1)

/obj/machinery/trade_beacon/proc/GetId()
	var/area/area_ref = get_area(src)
	if(!area_ref || !loc)
		return "Unplaced beacon"
	return "[area_ref.name] ([x], [y], [z])"

/obj/machinery/trade_beacon/sending
	name = "sending trade beacon"
	icon_state = "beacon"
	var/export_cooldown = 0
	var/export_cooldown_time = 120 SECONDS

/obj/machinery/trade_beacon/sending/Initialize()
	. = ..()
	SSsupply.beacons_sending += src

/obj/machinery/trade_beacon/sending/Destroy()
	SSsupply.beacons_sending -= src
	return ..()

/obj/machinery/trade_beacon/sending/proc/GetObjects()
	. = list()
	for(var/atom/movable/movable in range(2, src))
		if(QDELETED(movable) || movable.anchored || movable == src || movable.loc == src || movable.invisibility)
			continue
		. += movable

/obj/machinery/trade_beacon/sending/proc/StartExport()
	if(export_cooldown > world.time)
		return FALSE
	Activate()
	export_cooldown = world.time + export_cooldown_time
	return TRUE

/obj/machinery/trade_beacon/receiving
	name = "receiving trade beacon"

/obj/machinery/trade_beacon/receiving/Initialize()
	. = ..()
	SSsupply.beacons_receiving += src

/obj/machinery/trade_beacon/receiving/Destroy()
	SSsupply.beacons_receiving -= src
	return ..()

/obj/machinery/trade_beacon/receiving/proc/CanDropOnTurf(turf/simulated/floor/target_turf)
	for(var/atom/movable/occupant as anything in target_turf)
		if(occupant.density)
			return FALSE
	return TRUE

/obj/machinery/trade_beacon/receiving/proc/DropItem(drop_type)
	var/list/valid_turfs = list()
	for(var/turf/simulated/floor/floor in range(2, src))
		if(!CanDropOnTurf(floor))
			continue
		valid_turfs += floor
	if(!LAZYLEN(valid_turfs))
		return null
	Activate()
	var/turf/simulated/floor/pickfloor = pick(valid_turfs)
	var/datum/effect/spark_spread/sparks = new
	sparks.set_up(5, 1, pickfloor)
	sparks.start()
	return new drop_type(pickfloor)
