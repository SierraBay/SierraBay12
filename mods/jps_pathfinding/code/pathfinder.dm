/// Queues and manages JPS pathfinding steps.
SUBSYSTEM_DEF(pathfinder)
	name = "Pathfinder"
	init_order = SS_INIT_PATHFINDER
	priority = SS_PRIORITY_PATHFINDER
	wait = 0.5
	runlevels = RUNLEVELS_PREGAME | RUNLEVELS_GAME
	var/list/datum/pathfind/active_pathing = list()
	var/list/datum/pathfind/currentrun = list()
	var/static/list/space_type_cache = typecacheof(/turf/space)

/datum/controller/subsystem/pathfinder/UpdateStat(time)
	if(PreventUpdateStat(time))
		return ..()
	..("P:[length(active_pathing)]")

/datum/controller/subsystem/pathfinder/fire(resumed)
	if(!resumed)
		currentrun = active_pathing.Copy()
	while(length(currentrun))
		var/datum/pathfind/path = currentrun[length(currentrun)]
		if(QDELETED(path))
			LIST_DEC(currentrun)
			continue
		if(!path.search_step())
			path.early_exit()
		else if(path.path || path.open.is_empty())
			path.finished()
		if(MC_TICK_CHECK)
			return

/// Returns TRUE once queued; failed requests also release their nodes and callback references.
/datum/controller/subsystem/pathfinder/proc/pathfind(atom/movable/am_caller, atom/end, max_distance = 30, min_target_dist = 0, id = null, simulated_only = TRUE, exclude, skip_first = TRUE, diagonal_safety = TRUE, datum/callback/on_finish, no_id = FALSE)
	var/datum/pathfind/path = new(am_caller, end, id, max_distance, min_target_dist, simulated_only, exclude, skip_first, diagonal_safety, on_finish, no_id)
	if(path.start())
		active_pathing += path
		return TRUE
	qdel(path)
	return FALSE
