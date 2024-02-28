/datum/shuttle/autodock/overmap/set_destination(obj/shuttle_landmark/A)
	if(A != current_location)
		if(next_location)
			next_location.landmark_deselected(src)
		next_location = A
		next_location.landmark_selected(src)
