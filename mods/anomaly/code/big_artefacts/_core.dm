/obj/structure/big_artefact
	name = "Something"
	desc = "A large something."
	icon = 'mods/anomaly/icons/big_artefacts.dmi'
	density = TRUE
	waterproof = FALSE
	var/min_anomalies_ammout = 100
	var/max_anomalies_ammout = 200
	var/min_artefacts_ammount = 1
	var/max_artefacts_ammount = 2
	var/range_spawn = 30
	var/list/possible_anomalies = list()

/obj/structure/big_artefact/Initialize()
	. = ..()
	born_anomalies()

///Функция, которая заспавнит вокруг большого артефакта аномалии
/obj/structure/big_artefact/proc/born_anomalies()
	set background = 1
	var/started_in = world.time
	var/list/turfs_for_spawn = list()
	//У нас нет турфа?
	if(!src.loc)
		return
		//Собираем все турфы в определённом радиусе
	for(var/turf/turfs in RANGE_TURFS(src.loc, range_spawn))
		if(!TurfBlocked(turfs) || TurfBlockedByAnomaly(turfs))
			LAZYADD(turfs_for_spawn, turfs)
	generate_anomalies_in_turfs(possible_anomalies, turfs_for_spawn, min_anomalies_ammout, max_anomalies_ammout, min_artefacts_ammount, max_artefacts_ammount, null, null, "big artefact generation", started_in)

/obj/structure/big_artefact/shuttle_land_on()
	delete_artefact()

/obj/structure/big_artefact/proc/delete_artefact()
	LAZYREMOVE(SSanom.big_anomaly_artefacts, src)
	qdel(src)

/obj/structure/big_artefact/MouseDrop(obj/machinery/anomaly_container/over_object, mob/user)
	if(istype(over_object) && CanMouseDrop(over_object, usr))
		if (over_object.health_dead())
			visible_message(SPAN_WARNING("\The [over_object]'s containment is broken shut."))
			return
		if (!over_object.allowed(usr))
			visible_message(SPAN_WARNING("\The [over_object] blinks red, refusing to open."))
			return
		user.visible_message(
			SPAN_NOTICE("\The [usr] begins placing \the [src] into \the [over_object]."),
			SPAN_NOTICE("You begin placing \the [src] into \the [over_object].")
		)
		if(!do_after(usr, 4 SECONDS, over_object, DO_PUBLIC_UNIQUE))
			return
		user.visible_message(SPAN_NOTICE("The bolts on \the [over_object] drop with an hydraulic hiss, sealing its contents."))
		playsound(loc, 'sound/mecha/hydraulic.ogg', 40)
		Bumped(usr)
		over_object.contain(src)
	return

/obj/structure/big_artefact/forceMove()
	..()
	if(is_processing)
		if(get_turf(src) != loc)
			STOP_PROCESSING(SSanom, src)
	else
		if(get_turf(src) == loc)
			START_PROCESSING(SSanom, src)
