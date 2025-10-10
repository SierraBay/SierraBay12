//Hivemind is rogue AI that uses unknown nanotech to follow some strange objective
//In fact, it's just hostile structures, wireweeds spreading event with some mobs
//Requires hard teamwork at late stages, but easily can be handled at the beginning

//All code stored in modules/hivemind
//============================================

/proc/level_eight_announcement()
	GLOB.using_map.level_x_biohazard_announcement(8)

/datum/event/hivemind
	announceWhen	= 300


/datum/event/hivemind/announce()
	level_eight_announcement()



/datum/event/hivemind/start()
	var/turf/start_location
	for(var/i=1 to 100)
		var/turf/T = pick_subarea_turf(/area/maintenance, list(GLOBAL_PROC_REF(is_station_turf), GLOBAL_PROC_REF(not_turf_contains_dense_objects)))
		start_location = T
		if(!start_location && i == 100)
			log_and_message_admins("Hivemind failed to find a viable turf.")
			kill()
			return
		if(start_location)
			break

	log_and_message_admins("Hivemind spawned in \the [get_area(start_location)]", location = start_location)
	new /obj/machinery/hivemind_machine/node(start_location)
