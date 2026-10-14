//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
A Star pathfinding algorithm
Returns a list of tiles forming a path from A to B, taking dense objects as well as walls, and the orientation of
windows along the route into account.
Use:
your_list = AStar(start location, end location, adjacent turf proc, distance proc)
For the adjacent turf proc i wrote:
/turf/proc/AdjacentTurfs
And for the distance one i wrote:
/turf/proc/Distance
So an example use might be:

src.path_list = AStar(src.loc, target.loc, TYPE_PROC_REF(/turf, AdjacentTurfs), TYPE_PROC_REF(/turf, Distance) )

Note: The path is returned starting at the END node, so i wrote reverselist to reverse it for ease of use.

src.path_list = reverselist(src.pathlist)

Then to start on the path, all you need to do it:
Step_to(src, src.path_list[1])
src.path_list -= src.path_list[1] or equivilent to remove that node from the list.

Optional extras to add on (in order):
MaxNodes: The maximum number of nodes the returned path can be (0 = infinite)
Maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
Mintargetdist: Minimum distance to the target before path returns, could be used to get
near a target, but not right to it - for an AI mob with a gun, for example.
Minnodedist: Minimum number of nodes to return in the path, could be used to give a path a minimum
length to avoid portals or something i guess?? Not that they're counted right now but w/e.
*/

// Modified to provide ID argument - supplied to 'adjacent' proc, defaults to null
// Used for checking if route exists through a door which can be opened

// Also added 'exclude' turf to avoid travelling over; defaults to null

/PathNode
	var/datum/position
	var/PathNode/previous_node
	var/best_estimated_cost
	var/estimated_cost
	var/known_cost
	var/cost
	var/nodes_traversed


/PathNode/New(_position, _previous_node, _known_cost, _cost, _nodes_traversed)
	position = _position
	previous_node = _previous_node
	known_cost = _known_cost
	cost = _cost
	estimated_cost = cost + known_cost
	best_estimated_cost = estimated_cost
	nodes_traversed = _nodes_traversed


/proc/PathWeightCompare(PathNode/a, PathNode/b)
	return a.estimated_cost - b.estimated_cost


// Synchronous compatibility entrypoint. Queued callers use SSpathfinding.request_path().
/proc/AStar(start, end, adjacent, dist, max_nodes, max_node_depth = 30, min_target_dist = 0, min_node_dist, id, exclude, check_tick = FALSE)
	var/datum/pathfinding_request/request = new(start, end, adjacent, dist, max_nodes, max_node_depth, min_target_dist, min_node_dist, id, exclude)
	while (!request.advance())
		if (check_tick)
			CHECK_TICK
	. = request.path
	qdel(request)

/datum/pathfinding_request
	var/turf/end
	var/adjacent
	var/dist
	var/max_nodes
	var/max_node_depth
	var/min_target_dist
	var/min_node_dist
	var/id
	var/exclude
	var/PriorityQueue/open
	var/list/path_node_by_position = list()
	var/list/path
	var/datum/callback/on_complete

/datum/pathfinding_request/New(start, target, adjacency_call, distance_call, node_limit, depth_limit, target_distance, node_distance, access_id, excluded)
	..()
	end = get_turf(target)
	adjacent = adjacency_call
	dist = distance_call
	max_nodes = node_limit
	max_node_depth = depth_limit
	min_target_dist = target_distance
	min_node_dist = node_distance
	id = access_id
	exclude = excluded
	if (islist(excluded))
		var/list/excluded_positions = excluded
		exclude = excluded_positions.Copy()
	initialize_search(start)

/datum/pathfinding_request/proc/initialize_search(start)
	open = new /PriorityQueue(GLOBAL_PROC_REF(PathWeightCompare))
	var/turf/origin = get_turf(start)
	if (origin && end && origin.z == end.z)
		var/PathNode/first = new(origin, null, 0, call(origin, dist)(end), 0)
		path_node_by_position[origin] = first
		open.Enqueue(first)

/datum/pathfinding_request/Destroy()
	SSpathfinding.pending -= src
	SSpathfinding.processing -= src
	QDEL_NULL(on_complete)
	open.L.Cut()
	QDEL_NULL(open)
	path_node_by_position = null
	path = null
	end = null
	id = null
	exclude = null
	return ..()

// Returns TRUE when finished; one call expands at most one node.
/datum/pathfinding_request/proc/advance()
	if (open.IsEmpty() || QDELETED(end))
		return TRUE
	var/PathNode/current = open.Dequeue()
	if (current.position == end || call(current.position, dist)(end) <= min_target_dist)
		build_path(current)
		return TRUE
	if (min_node_dist && max_node_depth && call(current.position, min_node_dist)(end) + current.nodes_traversed >= max_node_depth)
		return FALSE
	if (max_node_depth && current.nodes_traversed >= max_node_depth)
		return FALSE
	for (var/datum/neighbor in call(current.position, adjacent)(id))
		if (neighbor == exclude || (islist(exclude) && (neighbor in exclude)))
			continue
		add_neighbor(current, neighbor)
	return FALSE

/datum/pathfinding_request/proc/add_neighbor(PathNode/current, datum/neighbor)
	var/known_cost = current.known_cost + call(current.position, dist)(neighbor)
	var/estimated_cost = call(neighbor, dist)(end)
	var/PathNode/previous = path_node_by_position[neighbor]
	if (previous)
		if (known_cost + estimated_cost >= previous.best_estimated_cost)
			return
		open.Remove(previous)
	var/PathNode/next = new(neighbor, current, known_cost, estimated_cost, current.nodes_traversed + 1)
	path_node_by_position[neighbor] = next
	open.Enqueue(next)
	if (max_nodes && open.Length() > max_nodes)
		open.Remove(open.Get(open.Length()))

/datum/pathfinding_request/proc/build_path(PathNode/current)
	path = new/list(current.nodes_traversed + 1)
	var/index = length(path)
	while (current)
		path[index--] = current.position
		current = current.previous_node

/datum/pathfinding_request/proc/complete()
	set waitfor = FALSE
	if (on_complete)
		invoke(on_complete, path)
