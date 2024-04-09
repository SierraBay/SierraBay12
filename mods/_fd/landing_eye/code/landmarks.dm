/obj/shuttle_landmark/proc/shuttle_departed(datum/shuttle/shuttle)

// Used to trigger effects prior to the shuttle's actual landing
/obj/shuttle_landmark/proc/landmark_selected(datum/shuttle/shuttle)

/obj/shuttle_landmark/proc/landmark_deselected(datum/shuttle/shuttle)

//Used for custom landing locations. Self deletes after a shuttle leaves.
/obj/shuttle_landmark/temporary
	name = "Landing Point"
	landmark_tag = "landing"
	flags = SLANDMARK_FLAG_AUTOSET

/obj/shuttle_landmark/temporary/Initialize()
	landmark_tag += "-[random_id("landmarks",1,9999)]"
	. = ..()

/obj/shuttle_landmark/temporary/Destroy()
	LAZYREMOVE(SSshuttle.registered_shuttle_landmarks, landmark_tag)
	return ..()

/obj/shuttle_landmark/temporary/landmark_deselected(datum/shuttle/shuttle)
	if(shuttle.moving_status != SHUTTLE_INTRANSIT && shuttle.current_location != src)
		qdel(src)

/obj/shuttle_landmark/temporary/shuttle_departed(datum/shuttle/shuttle)
	qdel(src)
