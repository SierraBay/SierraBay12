/turf/Entered(atom/movable/AM)
	. = ..()
	if(!istype(AM))
		return

	if(isliving(AM))
		var/list/watchers = turf_watched_by_mobs[src]
		if(watchers)
			for(var/obj/machinery/porta_turret/PT in watchers)
				PT.wake_up()
	
	if(istype(AM, /obj/meteor))
		var/list/watchers = turf_watched_by_meteors[src]
		if(watchers)
			for(var/obj/machinery/pointdefense/PD in watchers)
				PD.wake_up()
