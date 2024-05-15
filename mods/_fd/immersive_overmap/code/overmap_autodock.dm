/datum/shuttle/autodock/overmap/New(_name, obj/shuttle_landmark/start_waypoint)
	. = ..()
	range = max(0, range - 1)
