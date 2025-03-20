/obj/machinery/trade_beacon
	icon = 'mods/eris_cargo/objects/misc/trade_beacon.dmi'
	icon_state = "beacon"
	anchored = TRUE
	density = TRUE
	construct_state = /singleton/machine_construction/default/panel_closed


/// The effective range of the trade beacon. This is how far the beacon can reach into space to find items to export.
	var/beacon_range = 1


/obj/machinery/trade_beacon/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(isMultitool(W))
		beacon_range = beacon_range >= 2 ? 1 : 2
		anchored = !anchored
		user.visible_message(
			SPAN_NOTICE("\The [user] pulses some circuitry within [src]."),
			SPAN_NOTICE("You set [src]'s effective range to [beacon_range].")
			)
		playsound(src.loc, "sound/effects/pop.ogg", 50)
		return TRUE

	return ..()


/obj/machinery/trade_beacon/proc/Activate()
	flick("[icon_state]_active", src)

	var/turf/T = get_turf(src)
	if(!T)
		return

	var/datum/effect/spark_spread/sparks = new /datum/effect/spark_spread
	sparks.set_up(5, 1, T)
	sparks.start()

	playsound(T, "sparks", 50, 1)


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
	for(var/atom/movable/A in range(beacon_range, src))
		if(A.anchored || A == src || A.invisibility || (A.loc == src))
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
	for(var/turf/simulated/floor/F in orange(beacon_range, src))
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
