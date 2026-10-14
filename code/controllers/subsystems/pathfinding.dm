// Adapted from NebulaSS13/Nebula#4302.
SUBSYSTEM_DEF(pathfinding)
	name = "Pathfinding"
	priority = SS_PRIORITY_PATHFINDING
	wait = 1
	flags = SS_NO_INIT

	var/list/pending = list()
	var/list/processing = list()

/datum/controller/subsystem/pathfinding/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..("Queued: [length(pending)] Processing: [length(processing)]")

// Each request retains its search state, so a single large search can yield to the MC.
/datum/controller/subsystem/pathfinding/fire(resumed, no_mc_tick)
	if (!resumed)
		processing = pending.Copy()
	while (length(processing))
		var/datum/pathfinding_request/request = processing[1]
		if (QDELETED(request))
			processing.Cut(1, 2)
			continue
		if (request.advance())
			pending -= request
			processing -= request
			request.complete()
			qdel(request)
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/pathfinding/proc/request_path(start, end, datum/callback/on_complete, adjacent = TYPE_PROC_REF(/turf, CardinalTurfsWithAccess), dist = TYPE_PROC_REF(/turf, Distance), max_nodes, max_node_depth = 250, min_target_dist = 0, min_node_dist, id, exclude)
	var/datum/pathfinding_request/request = new(start, end, adjacent, dist, max_nodes, max_node_depth, min_target_dist, min_node_dist, id, exclude)
	request.on_complete = on_complete
	pending += request
	return request

/datum/controller/subsystem/pathfinding/proc/find_path_immediate(start, end, max_nodes, max_node_depth = 30, min_target_dist = 0, min_node_dist, id, exclude, check_tick = FALSE)
	return AStar(start, end, TYPE_PROC_REF(/turf, CardinalTurfsWithAccess), TYPE_PROC_REF(/turf, Distance), max_nodes, max_node_depth, min_target_dist, min_node_dist, id, exclude, check_tick)

/datum/controller/subsystem/pathfinding/proc/enqueue_mover(atom/movable/mover, atom/target, datum/pathfinding_metadata/metadata)
	if (QDELETED(mover) || mover.waiting_for_path || !get_turf(target))
		qdel(metadata)
		return FALSE
	metadata ||= new
	mover.waiting_for_path = request_path(get_turf(mover), get_turf(target), new /datum/callback(mover, TYPE_PROC_REF(/atom/movable, receive_path)), max_nodes = metadata.max_nodes, max_node_depth = metadata.max_node_depth, min_target_dist = metadata.min_target_dist, min_node_dist = metadata.min_node_dist, id = metadata.id || mover.GetIdCard(), exclude = metadata.obstacle)
	qdel(metadata)
	return TRUE

/datum/controller/subsystem/pathfinding/proc/dequeue_mover(atom/movable/mover)
	QDEL_NULL(mover.waiting_for_path)

/atom/movable
	var/datum/pathfinding_request/waiting_for_path

/atom/movable/proc/receive_path(list/path)
	waiting_for_path = null
	if (length(path))
		path_found(path)
	else
		path_not_found()

/atom/movable/proc/path_found(list/path)
	return

/atom/movable/proc/path_not_found()
	return

/datum/pathfinding_metadata
	var/max_nodes
	var/max_node_depth = 250
	var/atom/id
	var/min_target_dist = 0
	var/min_node_dist
	var/obstacle

/datum/pathfinding_metadata/New(_max_nodes, _max_node_depth, _id, _min_target_dist, _min_node_dist, _obstacle)
	..()
	max_nodes = _max_nodes
	id = _id
	obstacle = _obstacle
	if (!isnull(_max_node_depth))
		max_node_depth = _max_node_depth
	if (!isnull(_min_target_dist))
		min_target_dist = _min_target_dist
	min_node_dist = _min_node_dist

/datum/pathfinding_metadata/Destroy()
	id = null
	obstacle = null
	return ..()
