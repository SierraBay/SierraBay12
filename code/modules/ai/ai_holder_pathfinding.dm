// This handles obtaining a (usually A*) path towards something, such as a target, destination, or leader.
// This interacts heavily with code inside ai_holder_movement.dm

/datum/ai_holder
	// Pathfinding.
	var/use_astar = FALSE				// Do we use the more expensive A* implementation or stick with BYOND's default step_to()?
	var/list/path = list()				// A list of tiles that A* gave us as a solution to reach the target.
	var/list/obstacles = list()			// Things A* will try to avoid.
	var/astar_adjacent_proc = TYPE_PROC_REF(/turf, CardinalTurfsWithAccess) // Proc to use when A* pathfinding.  Default makes them bound to cardinals.
	var/failed_steps = 0				// If move_once() fails to move the mob onto the correct tile, this increases. When it reaches 3, the path is recalc'd since they're probably stuck.
	var/datum/pathfinding_request/pending_path
	var/path_failed = FALSE

// This clears the stored A* path.
/datum/ai_holder/proc/forget_path()
	ai_log("forget_path() : Entering.", AI_LOG_DEBUG)
	QDEL_NULL(pending_path)
	path_failed = FALSE
	if (path_display)
		for (var/turf/T in path)
			T.CutOverlays(path_overlay)
	path.Cut()
	ai_log("forget_path() : Exiting.", AI_LOG_DEBUG)

/datum/ai_holder/proc/give_up_movement()
	ai_log("give_up_movement() : Entering.", AI_LOG_DEBUG)
	forget_path()
	destination = null
	ai_log("give_up_movement() : Exiting.", AI_LOG_DEBUG)

/datum/ai_holder/proc/calculate_path(atom/A, get_to = 1)
	ai_log("calculate_path([A],[get_to]) : Entering.", AI_LOG_DEBUG)
	if (!A)
		ai_log("calculate_path() : Called without an atom. Exiting.",AI_LOG_WARNING)
		return

	if (!use_astar) // If we don't use A* then this is pointless.
		ai_log("calculate_path() : Not using A*, Exiting.", AI_LOG_DEBUG)
		return

	get_path(get_turf(A), get_to)

	ai_log("calculate_path() : Exiting.", AI_LOG_DEBUG)

///A* now, try to a path to a target
/datum/ai_holder/proc/get_path(turf/target, get_to = 1, max_distance = world.view*6)
	ai_log("get_path() : Entering.",AI_LOG_DEBUG)
	if (pending_path && pending_path.end == target && pending_path.min_target_dist == get_to)
		return
	forget_path()
	if (QDELETED(holder) || !target)
		return
	pending_path = SSpathfinding.request_path(get_turf(holder), target, new /datum/callback(src, TYPE_PROC_REF(/datum/ai_holder, path_found)), adjacent = astar_adjacent_proc, min_target_dist = get_to, max_node_depth = max_distance, id = holder.IGetID(), exclude = obstacles)

/datum/ai_holder/proc/path_found(list/new_path)
	pending_path = null
	path_failed = !length(new_path)
	if (path_failed || QDELETED(holder))
		return
	path = new_path
	if (path_display)
		for (var/turf/T in path)
			T.AddOverlays(path_overlay)
