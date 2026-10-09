/// Sierra shuttles that must be on the ship at save or they are left behind.
#define ODYSSEY_TRACKED_SHUTTLE_NAMES list("Guppy", "Charon", "Petrov", "Phaethon")


/proc/odyssey_shuttle_is_tracked(datum/shuttle/S)
	if (!istype(S))
		return FALSE
	if (istype(S, /datum/shuttle/autodock/ferry/escape_pod))
		return TRUE
	return S.name in ODYSSEY_TRACKED_SHUTTLE_NAMES


/proc/odyssey_shuttle_is_on_sierra(datum/shuttle/S)
	if (!istype(S))
		return FALSE
	var/datum/shuttle/autodock/ferry/escape_pod/pod = S
	if (istype(pod) && pod.location)
		return FALSE
	var/obj/shuttle_landmark/landmark = S.current_location
	if (istype(landmark))
		var/turf/landmark_turf = get_turf(landmark)
		if (istype(landmark_turf) && (landmark_turf.z in GLOB.using_map.station_levels))
			return TRUE
	for (var/area/shuttle_area in S.shuttle_area)
		for (var/turf/area_turf in shuttle_area)
			if (area_turf.z in GLOB.using_map.station_levels)
				return TRUE
			break
	return FALSE


/proc/odyssey_shuttle_abandon_destination(datum/shuttle/S)
	if (!istype(S))
		return null
	if (istype(S, /datum/shuttle/autodock/ferry))
		var/datum/shuttle/autodock/ferry/ferry = S
		if (istype(ferry.waypoint_offsite) && S.current_location != ferry.waypoint_offsite)
			return ferry.waypoint_offsite
	if (istype(S, /datum/shuttle/autodock))
		var/datum/shuttle/autodock/dock = S
		if (istype(dock.landmark_transition) && S.current_location != dock.landmark_transition)
			return dock.landmark_transition
	return null


/proc/odyssey_collect_abandoned_shuttles()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	state.abandoned_shuttles = list()
	if (!SSshuttle)
		return
	for (var/shuttle_name in SSshuttle.shuttles)
		var/datum/shuttle/S = SSshuttle.shuttles[shuttle_name]
		if (!odyssey_shuttle_is_tracked(S))
			continue
		if (odyssey_shuttle_is_on_sierra(S))
			continue
		state.abandoned_shuttles += S.name
		log_game("ODYSSEY: shuttle left behind name=[S.name] loc=[S.current_location]")


/proc/odyssey_hide_abandoned_overmap(datum/shuttle/S)
	if (!istype(S))
		return
	for (var/obj/overmap/visitable/ship/landable/landable in world)
		if (landable.shuttle == S.name)
			qdel(landable)


/proc/odyssey_apply_abandoned_shuttles()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!islist(state.abandoned_shuttles) || !length(state.abandoned_shuttles) || !SSshuttle)
		return
	var/moved = 0
	for (var/shuttle_name in state.abandoned_shuttles)
		var/datum/shuttle/S = SSshuttle.shuttles[shuttle_name]
		if (!istype(S) || !odyssey_shuttle_is_on_sierra(S))
			continue
		var/obj/shuttle_landmark/destination = odyssey_shuttle_abandon_destination(S)
		if (!istype(destination))
			log_error("ODYSSEY: cannot abandon shuttle [shuttle_name]: no offsite/transit landmark")
			continue
		var/old_knockdown = S.knockdown
		S.knockdown = FALSE
		var/ok = S.attempt_move(destination)
		S.knockdown = old_knockdown
		if (!ok)
			log_error("ODYSSEY: abandon move failed for [shuttle_name] to [destination]")
			continue
		odyssey_hide_abandoned_overmap(S)
		moved++
	log_debug("ODYSSEY: apply_abandoned_shuttles moved=[moved]/[length(state.abandoned_shuttles)]")


#undef ODYSSEY_TRACKED_SHUTTLE_NAMES
