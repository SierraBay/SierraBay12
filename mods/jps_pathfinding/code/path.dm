/**
 * This file contains the stuff you need for using JPS (Jump Point Search) pathing, an alternative to A* that skips
 * over large numbers of uninteresting tiles resulting in much quicker pathfinding solutions. Mind that diagonals
 * cost the same as cardinal moves currently, so paths may look a bit strange, but should still be optimal.
 */

/**
 * This is the proc you use whenever you want to have pathfinding more complex than "try stepping towards the thing".
 * If no path was found, returns an empty list, which is important for bots like medibots who expect an empty list rather than nothing.
 * It will yield until a path is returned, using magic
 *
 * Arguments:
 * * am_caller: The movable atom that's trying to find the path
 * * end: What we're trying to path to. It doesn't matter if this is a turf or some other atom, we're gonna just path to the turf it's on anyway
 * * max_distance: The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * * min_target_dist: Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
 * * id: An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
 * * simulated_only: Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * * exclude: If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * * skip_first: Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break movement for some creatures.
 * * diagonal_safety: ensures diagonal moves won't use invalid midstep turfs by splitting them into two orthogonal moves if necessary
 */
/proc/get_path_to(atom/movable/am_caller, atom/end, max_distance = 30, min_target_dist = 0, id = null, simulated_only = TRUE, exclude, skip_first = TRUE, diagonal_safety = TRUE, no_id = FALSE)
	var/list/result = list()
	var/datum/callback/on_finish = new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), result)
	if(!SSpathfinder.pathfind(am_caller, end, max_distance, min_target_dist, id, simulated_only, exclude, skip_first, diagonal_safety, on_finish, no_id))
		qdel(on_finish)
		return list()
	while(!length(result))
		stoplag()
	qdel(on_finish)
	if(QDELETED(am_caller) || QDELETED(end))
		return list()
	return result[1] || list()

/// Store the path inside a result list so even an empty path signals completion.
/proc/pathfinding_finished(list/result, list/path)
	LIST_RESIZE(result, 1)
	result[1] = path

/**
 * A helper macro to see if it's possible to step from the first turf into the second one, minding things like door access and directional windows.
 * Note that this can only be used inside the [datum/pathfind][pathfind datum] since it uses variables from said datum.
 * If you really want to optimize things, optimize this, cuz this gets called a lot.
 * We do early next.density check despite it being already checked in LinkBlockedWithAccess for short-circuit performance
 */
#define CAN_STEP(cur_turf, next) (next && !next.density && !(simulated_only && SSpathfinder.space_type_cache[next.type]) && !(next in avoid) && !cur_turf.LinkBlockedWithAccess(next, am_caller, id, no_id, avoid, simulated_only))
/// Another helper macro for JPS, for telling when a node has forced neighbors that need expanding
#define STEP_NOT_HERE_BUT_THERE(cur_turf, dirA, dirB) ((!CAN_STEP(cur_turf, get_step(cur_turf, dirA)) && CAN_STEP(cur_turf, get_step(cur_turf, dirB))))

/// The JPS Node datum represents a turf that we find interesting enough to add to the open list and possibly search for new tiles from
/datum/jps_node
	/// The turf associated with this node
	var/turf/tile
	/// The node we just came from
	var/datum/jps_node/previous_node
	/// The A* node weight (f_value = number_of_tiles + heuristic)
	var/f_value
	/// The A* node heuristic (a rough estimate of how far we are from the goal)
	var/heuristic
	/// How many steps it's taken to get here from the start (currently pulling double duty as steps taken & cost to get here, since all moves incl diagonals cost 1 rn)
	var/number_tiles
	/// How many steps it took to get here from the last node
	var/jumps
	/// Nodes store the endgoal so they can process their heuristic without a reference to the pathfind datum
	var/turf/node_goal

/datum/jps_node/New(turf/our_tile, datum/jps_node/incoming_previous_node, jumps_taken, turf/incoming_goal)
	tile = our_tile
	jumps = jumps_taken
	if(incoming_goal) // if we have the goal argument, this must be the first/starting node
		node_goal = incoming_goal
	else if(incoming_previous_node) // if we have the parent, this is from a direct lateral/diagonal scan, we can fill it all out now
		previous_node = incoming_previous_node
		number_tiles = previous_node.number_tiles + jumps
		node_goal = previous_node.node_goal
		heuristic = get_dist(tile, node_goal)
		f_value = number_tiles + heuristic
	// otherwise, no parent node means this is from a subscan lateral scan, so we just need the tile for now until we call [datum/jps/proc/update_parent] on it

/datum/jps_node/Destroy(force, ...)
	previous_node = null
	return ..()

/datum/jps_node/proc/update_parent(datum/jps_node/new_parent)
	previous_node = new_parent
	node_goal = previous_node.node_goal
	jumps = get_dist(tile, previous_node.tile)
	number_tiles = previous_node.number_tiles + jumps
	heuristic = get_dist(tile, node_goal)
	f_value = number_tiles + heuristic

/// TODO: Macro this to reduce proc overhead
/proc/HeapPathWeightCompare(datum/jps_node/a, datum/jps_node/b)
	return b.f_value - a.f_value

/// The datum used to handle the JPS pathfinding, completely self-contained
/datum/pathfind
	/// The thing that we're actually trying to path for
	var/atom/movable/am_caller
	/// The turf where we started at
	var/turf/start
	/// The turf we're trying to path to (note that this won't track a moving target)
	var/turf/end
	/// The open list/stack we pop nodes out from (TODO: make this a normal list and macro-ize the heap operations to reduce proc overhead)
	var/datum/heap/open
	///An assoc list that serves as the closed list & tracks what turfs came from where. Key is the turf, and the value is what turf it came from
	var/list/sources
	/// The list we compile at the end if successful to pass back
	var/list/path

	// general pathfinding vars/args
	/// An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
	var/obj/item/card/id/id
	/// How far away we have to get to the end target before we can call it quits
	var/min_target_dist = 0
	/// Maximum number of movement steps; zero leaves the search unlimited.
	var/max_distance = 30
	/// Space is big and empty, if this is TRUE then we ignore pathing through unsimulated tiles
	var/simulated_only
	/// A specific turf we're avoiding, like if a mulebot is being blocked by someone t-posing in a doorway we're trying to get through
	var/list/avoid
	/// If we should delete the first step in the path or not. Used often because it is just the starting tile
	var/skip_first = FALSE
	/// Ensures diagonal moves won't use invalid midstep turfs by splitting them into two orthogonal moves if necessary
	var/diagonal_safety = TRUE
	/// The callback to invoke when we're done working, passing in the completed var/list/path
	var/datum/callback/on_finish
	/// All nodes, including nodes already popped from the heap, belong to this request.
	var/list/nodes = list()
	var/no_id = FALSE

/datum/pathfind/New(atom/movable/am_caller, atom/goal, id, max_distance, min_target_dist, simulated_only, avoid, skip_first, diagonal_safety, datum/callback/on_finish, no_id = FALSE)
	src.am_caller = am_caller
	end = get_turf(goal)
	open = new /datum/heap(GLOBAL_PROC_REF(HeapPathWeightCompare))
	sources = new()
	src.id = id
	src.max_distance = max_distance
	src.min_target_dist = min_target_dist
	src.simulated_only = simulated_only
	if(islist(avoid))
		var/list/avoided_turfs = avoid
		src.avoid = avoided_turfs.Copy()
	else
		src.avoid = list(avoid)
	src.no_id = no_id
	src.skip_first = skip_first
	src.diagonal_safety = diagonal_safety
	src.on_finish = on_finish

/datum/pathfind/Destroy()
	SSpathfinder.active_pathing -= src
	SSpathfinder.currentrun -= src
	if(on_finish)
		invoke(on_finish, null)
		on_finish = null
	QDEL_NULL(open)
	QDEL_NULL_LIST(nodes)
	am_caller = null
	id = null
	start = null
	end = null
	sources = null
	path = null
	avoid = null
	return ..()

/**
 * "starts" off the pathfinding, by storing the values this datum will need to work later on
 *  returns FALSE if it fails to setup properly, TRUE otherwise
 */
/datum/pathfind/proc/start()
	start = get_turf(am_caller)
	if(!start || !end || QDELETED(am_caller))
		return FALSE
	if(start.z != end.z) // No pathfinding between z levels.
		return FALSE
	if(max_distance && (max_distance + min_target_dist < get_dist(start, end))) //if start turf is farther than max_distance from end turf, no need to do anything
		return FALSE

	if(get_dist(start, end) <= min_target_dist)
		path = list(start)
		return TRUE

	var/datum/jps_node/current_processed_node = new (start, null, 0, end)
	nodes += current_processed_node
	open.insert(current_processed_node)
	sources[start] = start // i'm sure this is fine
	return TRUE

/**
 * search_step() is the workhorse of pathfinding. It'll do the searching logic, and will slowly build up a path
 * returns TRUE if everything is stable, FALSE if the pathfinding logic has failed, and we need to abort
 */
/datum/pathfind/proc/search_step()
	if(QDELETED(am_caller))
		return FALSE

	while(!open.is_empty() && !path)
		var/datum/jps_node/current_processed_node = open.pop() //get the lower f_value turf in the open list
		if(max_distance && (current_processed_node.number_tiles > max_distance))//if too many steps, don't process that path
			continue

		var/turf/current_turf = current_processed_node.tile
		for(var/scan_direction in list(EAST, WEST, NORTH, SOUTH))
			lateral_scan_spec(current_turf, scan_direction, current_processed_node)

		for(var/scan_direction in list(NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST))
			diag_scan_spec(current_turf, scan_direction, current_processed_node)

		// Stable, we'll just be back later
		if(TICK_CHECK)
			return TRUE
	return TRUE

/**
 * early_exit() is called when something goes wrong in processing, and we need to halt the pathfinding NOW
 */
/datum/pathfind/proc/early_exit()
	invoke(on_finish, null)
	on_finish = null
	qdel(src)

/**
 * Cleanup pass for the pathfinder. This tidies up the path, and fufills the pathfind's obligations
 */
/datum/pathfind/proc/finished()
	//we're done! reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5 * length(path)))
			path.Swap(i, length(path) - i + 1)
	sources = null
	QDEL_NULL(open)

	if(diagonal_safety)
		path = diagonal_movement_safety()
	if(max_distance && length(path) - 1 > max_distance)
		path = null
	if(length(path) > 0 && skip_first)
		path.Cut(1,2)
	invoke(on_finish, path)
	on_finish = null
	qdel(src)

/// Called when we've hit the goal with the node that represents the last tile, then sets the path var to that path so it can be returned by [datum/pathfind/proc/search]
/datum/pathfind/proc/unwind_path(datum/jps_node/unwind_node)
	path = new()
	var/turf/iter_turf = unwind_node.tile
	path.Add(iter_turf)

	while(unwind_node.previous_node)
		var/dir_goal = get_dir(iter_turf, unwind_node.previous_node.tile)
		for(var/i = 1 to unwind_node.jumps)
			iter_turf = get_step(iter_turf,dir_goal)
			path.Add(iter_turf)
		unwind_node = unwind_node.previous_node

/datum/pathfind/proc/diagonal_movement_safety()
	if(length(path) < 2)
		return path
	var/list/modified_path = list()

	for(var/i in 1 to length(path) - 1)
		var/turf/current_turf = path[i]
		var/turf/next_turf = path[i+1]
		var/movement_dir = get_dir(current_turf, next_turf)
		if(!(movement_dir & (movement_dir - 1))) //cardinal movement, no need to verify
			modified_path += current_turf
			continue
		modified_path += current_turf
		var/turf/midstep = get_step(current_turf, movement_dir & (NORTH | SOUTH))
		if(CAN_STEP(current_turf, midstep) && CAN_STEP(midstep, next_turf))
			continue
		midstep = get_step(current_turf, movement_dir & (EAST | WEST))
		if(!CAN_STEP(current_turf, midstep) || !CAN_STEP(midstep, next_turf))
			return null
		modified_path += midstep
	modified_path += path[length(path)]

	return modified_path

/**
 * For performing lateral scans from a given starting turf.
 *
 * These scans are called from both the main search loop, as well as subscans for diagonal scans, and they treat finding interesting turfs slightly differently.
 * If we're doing a normal lateral scan, we already have a parent node supplied, so we just create the new node and immediately insert it into the heap, ezpz.
 * If we're part of a subscan, we still need for the diagonal scan to generate a parent node, so we return a node datum with just the turf and let the diag scan
 * proc handle transferring the values and inserting them into the heap.
 *
 * Arguments:
 * * original_turf: What turf did we start this scan at?
 * * heading: What direction are we going in? Obviously, should be cardinal
 * * parent_node: Only given for normal lateral scans, if we don't have one, we're a diagonal subscan.
*/
/datum/pathfind/proc/lateral_scan_spec(turf/original_turf, heading, datum/jps_node/parent_node, scan_distance = 0)
	var/steps_taken = 0

	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(path)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf, current_turf))
			return
		if(max_distance && ((parent_node ? parent_node.number_tiles : scan_distance) + steps_taken > max_distance))
			return

		if(current_turf == end || (min_target_dist && (get_dist(current_turf, end) <= min_target_dist)))
			var/datum/jps_node/final_node = new(current_turf, parent_node, steps_taken)
			nodes += final_node
			sources[current_turf] = original_turf
			if(parent_node) // if this is a direct lateral scan we can wrap up, if it's a subscan from a diag, we need to let the diag make their node first, then finish
				unwind_path(final_node)
			return final_node
		else if(sources[current_turf]) // already visited, essentially in the closed list
			return
		else
			sources[current_turf] = original_turf


		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?

		switch(heading)
			if(NORTH)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST))
					interesting = TRUE
			if(SOUTH)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST))
					interesting = TRUE
			if(EAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST))
					interesting = TRUE
			if(WEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST))
					interesting = TRUE

		if(interesting)
			var/datum/jps_node/newnode = new(current_turf, parent_node, steps_taken)
			nodes += newnode
			if(parent_node) // if we're a diagonal subscan, we'll handle adding ourselves to the heap in the diag
				open.insert(newnode)
			return newnode

/**
 * For performing diagonal scans from a given starting turf.
 *
 * Unlike lateral scans, these only are called from the main search loop, so we don't need to worry about returning anything,
 * though we do need to handle the return values of our lateral subscans of course.
 *
 * Arguments:
 * * original_turf: What turf did we start this scan at?
 * * heading: What direction are we going in? Obviously, should be diagonal
 * * parent_node: We should always have a parent node for diagonals
*/
/datum/pathfind/proc/diag_scan_spec(turf/original_turf, heading, datum/jps_node/parent_node)
	var/steps_taken = 0
	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(path)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf, current_turf))
			return
		if(max_distance && (parent_node.number_tiles + steps_taken > max_distance))
			return

		if(current_turf == end || (min_target_dist && (get_dist(current_turf, end) <= min_target_dist)))
			var/datum/jps_node/final_node = new(current_turf, parent_node, steps_taken)
			nodes += final_node
			sources[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(sources[current_turf]) // already visited, essentially in the closed list
			return
		else
			sources[current_turf] = original_turf


		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?
		var/datum/jps_node/possible_child_node // otherwise, did one of our lateral subscans turn up something?

		switch(heading)
			if(NORTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, WEST, scan_distance = parent_node.number_tiles + steps_taken) || lateral_scan_spec(current_turf, NORTH, scan_distance = parent_node.number_tiles + steps_taken))
			if(NORTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, EAST, scan_distance = parent_node.number_tiles + steps_taken) || lateral_scan_spec(current_turf, NORTH, scan_distance = parent_node.number_tiles + steps_taken))
			if(SOUTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, SOUTH, scan_distance = parent_node.number_tiles + steps_taken) || lateral_scan_spec(current_turf, WEST, scan_distance = parent_node.number_tiles + steps_taken))
			if(SOUTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, SOUTH, scan_distance = parent_node.number_tiles + steps_taken) || lateral_scan_spec(current_turf, EAST, scan_distance = parent_node.number_tiles + steps_taken))

		if(interesting || possible_child_node)
			var/datum/jps_node/newnode = new(current_turf, parent_node, steps_taken)
			nodes += newnode
			open.insert(newnode)
			if(possible_child_node)
				possible_child_node.update_parent(newnode)
				open.insert(possible_child_node)
				if(possible_child_node.tile == end || (min_target_dist && (get_dist(possible_child_node.tile, end) <= min_target_dist)))
					unwind_path(possible_child_node)
			return


#undef CAN_STEP
#undef STEP_NOT_HERE_BUT_THERE
