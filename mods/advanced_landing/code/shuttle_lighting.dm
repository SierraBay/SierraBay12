/datum/shuttle/shuttle_moved(obj/shuttle_landmark/destination, list/turf_translation)
	. = ..()
	var/list/turfs = list()
	for(var/turf/source in turf_translation)
		turfs += source
		if(turf_translation[source])
			turfs += turf_translation[source]
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(resync_ambient_corners), turfs), 2 SECONDS)

/proc/resync_ambient_corners(list/turfs)
	for(var/turf/T as anything in turfs)
		for(var/datum/lighting_corner/C in T.corners)
			var/r = 0
			var/g = 0
			var/b = 0
			for(var/turf/M in list(C.t1, C.t2, C.t3, C.t4))
				r += M.ambient_light_old_r
				g += M.ambient_light_old_g
				b += M.ambient_light_old_b
			if(r != C.ambient_r || g != C.ambient_g || b != C.ambient_b)
				C.update_ambient_lumcount(r - C.ambient_r, g - C.ambient_g, b - C.ambient_b)
		CHECK_TICK
