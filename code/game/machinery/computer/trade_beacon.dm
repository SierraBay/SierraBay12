/obj/machinery/trade_beacon
	icon = 'icons/obj/machines/trade_beacon.dmi'
	icon_state = "beacon"
	anchored = TRUE
	density = TRUE

/obj/machinery/trade_beacon/proc/Activate()
	flick("[icon_state]_active", src)
	var/datum/effect/spark_spread/sparks = new /datum/effect/spark_spread
	sparks.set_up(5, 1, get_turf(src))
	sparks.start()
	playsound(get_turf(src), "sparks", 50, 1)

/obj/machinery/trade_beacon/proc/GetId()
	var/area/A = get_area(src)
	return "[A.name] ([x], [y], [z])"

/* Sending */
/obj/machinery/trade_beacon/sending
	name = "sending trade beacon"
	icon_state = "beacon_sending"
	var/export_cooldown
	var/export_cooldown_time = 120 SECONDS

/obj/machinery/trade_beacon/sending/Initialize()
	. = ..()
	SSsupply.beacons_sending += src

/obj/machinery/trade_beacon/sending/Destroy()
	SSsupply.beacons_sending -= src
	return ..()

/obj/machinery/trade_beacon/sending/proc/GetObjects()
	var/list/objects = list()
	for(var/atom/movable/A in range(2, src))
		if(A.anchored)
			continue
		if(A == src)
			continue
		if(A.loc == src)
			continue
		if(A.invisibility)
			continue
		objects += A
	return objects

/obj/machinery/trade_beacon/sending/proc/StartExport()
	if(export_cooldown > world.time)
		return FALSE
	Activate()
	export_cooldown = world.time + export_cooldown_time
	return TRUE

/* Receiving */
/obj/machinery/trade_beacon/receiving
	name = "receiving trade beacon"

/obj/machinery/trade_beacon/receiving/Initialize()
	. = ..()
	SSsupply.beacons_receiving += src

/obj/machinery/trade_beacon/receiving/Destroy()
	SSsupply.beacons_receiving -= src
	return ..()

/obj/machinery/trade_beacon/receiving/proc/DropItem(drop_type)
	var/list/valid_turfs = list()
	for(var/turf/simulated/floor/F in range(2, src))
		if(F.contains_dense_objects(TRUE))
			continue
		valid_turfs += F
	if(!LAZYLEN(valid_turfs))
		return FALSE
	Activate()
	var/turf/simulated/floor/pickfloor = pick(valid_turfs)
	var/datum/effect/spark_spread/s = new /datum/effect/spark_spread
	s.set_up(5, 1, pickfloor)
	s.start()
	return new drop_type(pickfloor)
