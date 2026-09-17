/obj/machinery/trade_beacon
	name = "trade beacon"
	desc = "An automated subspace transponder used by the supply network."
	icon = 'icons/obj/machines/beacon.dmi'
	icon_state = "beacon"
	anchored = TRUE
	density = TRUE
	use_power = POWER_USE_OFF
	idle_power_usage = 0
	active_power_usage = 0
	stat_immune = MACHINE_STAT_NOSCREEN | MACHINE_STAT_NOINPUT | MACHINE_STAT_NOPOWER
	construct_state = /singleton/machine_construction/default/panel_closed/cannot_print
	var/last_spark_sound = 0

/obj/machinery/trade_beacon/proc/Activate()
	flick("[icon_state]_active", src)
	var/turf/T = get_turf(src)
	if(!T)
		return
	sparks(5, 1, T)
	if(world.time > last_spark_sound)
		playsound(T, "sparks", 50, 1)
		last_spark_sound = world.time

/obj/machinery/trade_beacon/proc/GetId()
	var/turf/T = get_turf(src)
	var/area/area_ref = get_area(src)
	if(!area_ref || !T)
		return "Unplaced beacon"
	return "[area_ref.name] ([T.x], [T.y], [T.z])"

/obj/machinery/trade_beacon/sending
	name = "sending trade beacon"
	desc = "Scans and de-materializes unanchored cargo within 2 tiles for export."
	icon_state = "beacon"
	var/export_cooldown = 0
	var/export_cooldown_time = 120 SECONDS

/obj/machinery/trade_beacon/sending/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return .
	SSsupply?.beacons_sending += src

/obj/machinery/trade_beacon/sending/Destroy()
	SSsupply?.beacons_sending -= src
	return ..()

/obj/machinery/trade_beacon/sending/proc/GetObjects()
	. = list()
	if(inoperable() || !anchored || QDELETED(src))
		return .
	for(var/atom/movable/movable in range(2, src))
		if(QDELETED(movable) || movable.anchored || movable == src || movable.invisibility)
			continue
		if(!isturf(movable.loc))
			continue
		. += movable

/obj/machinery/trade_beacon/sending/proc/StartExport()
	if(inoperable() || !anchored || QDELETED(src))
		return FALSE
	if(export_cooldown > world.time)
		return FALSE
	Activate()
	export_cooldown = world.time + export_cooldown_time
	return TRUE

/obj/machinery/trade_beacon/receiving
	name = "receiving trade beacon"
	desc = "Materializes incoming deliveries onto valid surrounding floor tiles within 2 tiles."

/obj/machinery/trade_beacon/receiving/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return .
	SSsupply?.beacons_receiving += src

/obj/machinery/trade_beacon/receiving/Destroy()
	SSsupply?.beacons_receiving -= src
	return ..()

/obj/machinery/trade_beacon/receiving/proc/CanDropOnTurf(turf/target_turf)
	if(!isturf(target_turf) || target_turf.density || istype(target_turf, /turf/space))
		return FALSE
	for(var/atom/movable/occupant as anything in target_turf)
		if(occupant.density)
			return FALSE
	return TRUE

/obj/machinery/trade_beacon/receiving/proc/DropItem(drop_type)
	if(inoperable() || !anchored || QDELETED(src) || !drop_type)
		return null
	var/list/valid_turfs = list()
	for(var/turf/tile in range(2, src))
		if(!CanDropOnTurf(tile))
			continue
		valid_turfs += tile
	if(!length(valid_turfs))
		return null
	Activate()
	var/turf/pickfloor = pick(valid_turfs)
	sparks(5, 1, pickfloor)
	return new drop_type(pickfloor)
