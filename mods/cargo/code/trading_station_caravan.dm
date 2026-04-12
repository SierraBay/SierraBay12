/datum/trading_station/caravan
	uid = "trade_caravan"
	faction = FACTION_INDEPENDENT
	spawn_always = FALSE
	spawn_probability = 35
	spawn_cost = 1
	trade_range = 2
	markup = 1.15
	base_income = 1100
	supports_contracts = FALSE
	can_host_caravans = FALSE
	is_mobile = TRUE
	icon_states = list("trading_station")
	random_factions = list(
		FACTION_INDEPENDENT,
		FACTION_FREETRADE,
		FACTION_INDIE_CONFED
	)
	name_pool = list(
		"FTV Wayfarer" = "A mobile trade caravan carrying mixed civilian cargo and opportunistic surplus.",
		"FTV Long Haul" = "An itinerant merchant convoy moving between beacon routes with a rotating inventory.",
		"FTV Open Palm" = "A roving independent trade caravan broadcasting merchant registry codes.",
		"FTV Far Market" = "A caravan specializing in off-route deals and transient dockside trade."
	)
	var/list/caravan_group_types = list(
		/datum/legacy_station_group/operations,
		/datum/legacy_station_group/engineering,
		/datum/legacy_station_group/materials,
		/datum/legacy_station_group/medicine,
		/datum/legacy_station_group/science,
		/datum/legacy_station_group/service,
		/datum/legacy_station_group/civilian
	)
	var/min_groups = 2
	var/max_groups = 3

/datum/trading_station/caravan/InitSrc(turf/station_loc = null, force_discovered = FALSE)
	uid = "trade_caravan_[random_id(type, 1000, 9999)]"
	if(!length(legacy_supply_roots))
		BuildCaravanSupplyRoots()
	return ..(station_loc, force_discovered)

/datum/trading_station/caravan/proc/BuildCaravanSupplyRoots()
	legacy_supply_roots = list()
	var/list/group_pool = caravan_group_types.Copy()
	var/groups_to_pick = rand(min_groups, max_groups)
	for(var/i = 1 to groups_to_pick)
		if(!length(group_pool))
			break
		var/group_type = pick(group_pool)
		group_pool -= group_type
		var/datum/legacy_station_group/group = new group_type
		for(var/root_type in group.root_categories)
			if(!(root_type in legacy_supply_roots))
				legacy_supply_roots += root_type

/datum/trading_station/caravan/proc/GetCaravanRouteCandidates()
	var/list/result = list()
	for(var/datum/trading_station/station as anything in SSsupply.all_trading_stations)
		if(station == src || !station.can_host_caravans || !istype(station.overmap_location))
			continue
		result += station
	return result

/datum/trading_station/caravan/GetOvermapObjectType()
	return /obj/overmap/trade_beacon/caravan

/datum/trading_station/caravan/GetOvermapScannerDesc()
	var/faction_name = faction || FACTION_INDEPENDENT
	return {"\[i\]Registration\[/i\]: [GetOvermapName()]
\[i\]Class\[/i\]: Mobile Trade Caravan
\[i\]Transponder\[/i\]: Transmitting (CIV), [faction_name]
\[b\]Notice\[/b\]: [GetOvermapDesc()]"}

/datum/trading_station/caravan/GetAvailabilityBlockReason(atom/source = null)
	var/obj/overmap/trade_beacon/caravan/caravan_object = overmap_object
	if(!istype(caravan_object))
		return "This caravan is currently unavailable."
	return null

/datum/trading_station/caravan/GetAvailabilityStatusData()
	var/obj/overmap/trade_beacon/caravan/caravan_object = overmap_object
	if(!istype(caravan_object))
		return list(
			"label" = "Unavailable",
			"tone" = "bad"
		)
	return caravan_object.GetTradeAvailabilityStatusData()

/datum/trading_station/caravan/GetAvailabilityWindowRemaining()
	var/obj/overmap/trade_beacon/caravan/caravan_object = overmap_object
	if(!istype(caravan_object))
		return null
	return caravan_object.GetTradeWindowRemaining()

/datum/trading_station/caravan/PlaceOvermap(spawn_x, spawn_y, spawn_z = GLOB.using_map.overmap_z)
	..()
	var/obj/overmap/trade_beacon/caravan/caravan_object = overmap_object
	if(istype(caravan_object))
		caravan_object.BindToStation(src)

/obj/overmap/trade_beacon/caravan
	name = "trade caravan"
	desc = "A mobile merchant caravan moving between beacon routes."
	icon_state = "trading_station"
	movable = TRUE
	randomize_start_pos = FALSE
	requires_contact = TRUE
	instant_contact = TRUE
	max_speed = 1 / (8 SECONDS)
	min_speed = 1 / (20 SECONDS)
	var/datum/trading_station/caravan/linked_station
	var/datum/trading_station/current_stop = null
	var/datum/trading_station/route_destination = null
	var/list/current_route = null
	var/route_index = 1
	var/next_action_at = 0
	var/nav_update_rate = 2 SECONDS
	var/next_nav_update = 0
	var/cruise_speed = 1 / (8 SECONDS)
	var/trade_window_min = 5 MINUTES
	var/trade_window_max = 10 MINUTES
	var/repath_cooldown = 10 SECONDS
	var/trade_window_end = 0
	var/caravan_state = "in_transit"

/obj/overmap/trade_beacon/caravan/Initialize()
	. = ..()

/obj/overmap/trade_beacon/caravan/Destroy()
	if(linked_station && linked_station.overmap_object == src)
		linked_station.overmap_object = null
		linked_station.overmap_location = null
	linked_station = null
	current_stop = null
	route_destination = null
	current_route = null
	return ..()

/obj/overmap/trade_beacon/caravan/Process()
	. = ..()
	if(!istype(linked_station) || QDELETED(linked_station))
		qdel(src)
		return
	if(!istype(loc, /turf))
		return
	linked_station.UpdateOvermapLocation(loc)

	if(world.time < next_action_at)
		StopMovement()
		return

	if(!TryAdoptStartStation())
		StopMovement()
		next_action_at = world.time + trade_window_min
		return
	if(caravan_state == "docked" && world.time < next_action_at)
		return

	UpdateRouteProgress()
	if(!istype(route_destination) || !length(current_route) || route_index > length(current_route))
		if(!SelectNextRoute())
			StopMovement()
			if(caravan_state == "docked")
				BeginTradeWindow(1 MINUTE)
			else
				next_action_at = world.time + trade_window_min
		return

	var/turf/destination = route_destination.overmap_location
	if(!istype(destination))
		ClearRoute()
		StopMovement()
		next_action_at = world.time + repath_cooldown
		return

	var/turf/next_step = current_route[route_index]
	if(!istype(next_step) || !CanTraverseTurf(next_step, destination))
		if(!BuildRouteTo(destination))
			StopMovement()
			next_action_at = world.time + repath_cooldown
		return

	if(loc == destination)
		StopMovement()
		current_stop = route_destination
		ClearRoute()
		BeginTradeWindow()
		return

	if(world.time >= next_nav_update)
		SetCruiseHeading(next_step)
		next_nav_update = world.time + nav_update_rate

/obj/overmap/trade_beacon/caravan/proc/BindToStation(datum/trading_station/caravan/station)
	linked_station = station
	if(istype(linked_station))
		linked_station.overmap_object = src
		linked_station.UpdateOvermapLocation(loc)

/obj/overmap/trade_beacon/caravan/proc/TryAdoptStartStation()
	if(istype(current_stop) && !QDELETED(current_stop) && istype(current_stop.overmap_location))
		return TRUE
	if(!istype(linked_station))
		return FALSE

	var/list/candidates = linked_station.GetCaravanRouteCandidates()
	if(!length(candidates))
		return FALSE

	current_stop = pick(candidates)
	if(istype(current_stop.overmap_location) && loc != current_stop.overmap_location)
		forceMove(current_stop.overmap_location)
	linked_station.UpdateOvermapLocation(loc)
	BeginTradeWindow()
	return TRUE

/obj/overmap/trade_beacon/caravan/proc/SelectNextRoute()
	ClearRoute()
	if(!istype(linked_station))
		return FALSE

	var/list/candidates = linked_station.GetCaravanRouteCandidates()
	var/candidate_count = length(candidates)
	if(!candidate_count)
		return FALSE

	var/start_index = rand(1, candidate_count)
	for(var/i in 0 to candidate_count - 1)
		var/list_index = ((start_index + i - 1) % candidate_count) + 1
		var/datum/trading_station/candidate = candidates[list_index]
		if(candidate == current_stop || !istype(candidate.overmap_location))
			continue
		if(!BuildRouteTo(candidate.overmap_location))
			continue
		route_destination = candidate
		BeginTransit()
		return TRUE
	return FALSE

/obj/overmap/trade_beacon/caravan/proc/ClearRoute()
	StopMovement()
	route_destination = null
	current_route = null
	route_index = 1

/obj/overmap/trade_beacon/caravan/proc/BuildRouteTo(turf/goal)
	current_route = null
	route_index = 1
	if(!istype(goal) || !istype(loc, /turf))
		return FALSE

	var/turf/start = loc
	if(start == goal)
		current_route = list(start)
		route_index = 2
		return TRUE

	var/list/open_nodes = list(start)
	var/list/came_from = list()
	var/list/g_score = list()
	var/list/f_score = list()
	g_score[RouteNodeKey(start)] = 0
	f_score[RouteNodeKey(start)] = EstimateRouteHeuristic(start, goal)
	var/iterations = 0

	while(length(open_nodes) && iterations++ < 2500)
		var/turf/current = PickBestOpenNode(open_nodes, f_score)
		if(!istype(current))
			break
		if(current == goal)
			current_route = ReconstructRoute(came_from, current)
			route_index = 2
			return length(current_route) >= 1

		open_nodes -= current
		var/current_key = RouteNodeKey(current)
		var/current_cost = g_score[current_key]
		for(var/turf/neighbor as anything in GetPathNeighbors(current, goal))
			var/neighbor_key = RouteNodeKey(neighbor)
			var/tentative_cost = current_cost + GetTraversalCost(neighbor, goal)
			if(!isnum(g_score[neighbor_key]) || tentative_cost < g_score[neighbor_key])
				came_from[neighbor_key] = current
				g_score[neighbor_key] = tentative_cost
				f_score[neighbor_key] = tentative_cost + EstimateRouteHeuristic(neighbor, goal)
				if(!(neighbor in open_nodes))
					open_nodes += neighbor

	return FALSE

/obj/overmap/trade_beacon/caravan/proc/PickBestOpenNode(list/open_nodes, list/f_score)
	var/turf/best_node = null
	var/best_score = INFINITY
	for(var/turf/node as anything in open_nodes)
		var/score = f_score[RouteNodeKey(node)]
		if(isnull(score))
			score = INFINITY
		if(score < best_score)
			best_score = score
			best_node = node
	return best_node

/obj/overmap/trade_beacon/caravan/proc/ReconstructRoute(list/came_from, turf/current)
	var/list/path = list(current)
	var/node_key = RouteNodeKey(current)
	while(came_from[node_key])
		current = came_from[node_key]
		path.Insert(1, current)
		node_key = RouteNodeKey(current)
	return path

/obj/overmap/trade_beacon/caravan/proc/GetPathNeighbors(turf/current, turf/goal)
	var/list/neighbors = list()
	for(var/direction in list(NORTH, SOUTH, EAST, WEST))
		var/turf/neighbor = get_step(current, direction)
		if(!istype(neighbor, /turf/unsimulated/map) || istype(neighbor, /turf/unsimulated/map/edge))
			continue
		if(!CanTraverseTurf(neighbor, goal))
			continue
		neighbors += neighbor
	return neighbors

/obj/overmap/trade_beacon/caravan/proc/CanTraverseTurf(turf/target_turf, turf/goal)
	if(!istype(target_turf, /turf/unsimulated/map) || istype(target_turf, /turf/unsimulated/map/edge))
		return FALSE
	if(target_turf == goal)
		return TRUE
	if(length(overmap_event_handler.hazard_by_turf[target_turf]))
		return FALSE
	if(locate(/obj/overmap/event) in target_turf)
		return FALSE
	if(locate(/obj/overmap/visitable/star) in target_turf)
		return FALSE
	return TRUE

/obj/overmap/trade_beacon/caravan/proc/GetTraversalCost(turf/target_turf, turf/goal)
	if(target_turf == goal)
		return 1

	var/cost = 1
	for(var/turf/nearby as anything in orange(1, target_turf))
		if(nearby == target_turf)
			continue
		var/list/hazards = overmap_event_handler.hazard_by_turf[nearby]
		if(length(hazards))
			cost += 6 * length(hazards)
		if(locate(/obj/overmap/event) in nearby)
			cost += 10

	var/high_safe_edge = GLOB.using_map.overmap_size - OVERMAP_EDGE
	if(target_turf.x <= OVERMAP_EDGE || target_turf.y <= OVERMAP_EDGE || target_turf.x >= high_safe_edge || target_turf.y >= high_safe_edge)
		cost += 2
	return cost

/obj/overmap/trade_beacon/caravan/proc/EstimateRouteHeuristic(turf/start, turf/goal)
	return abs(start.x - goal.x) + abs(start.y - goal.y)

/obj/overmap/trade_beacon/caravan/proc/RouteNodeKey(turf/node)
	return "[node.x],[node.y],[node.z]"

/obj/overmap/trade_beacon/caravan/proc/BeginTransit()
	caravan_state = "in_transit"
	trade_window_end = 0

/obj/overmap/trade_beacon/caravan/proc/BeginTradeWindow(duration = null)
	caravan_state = "docked"
	StopMovement()
	if(!isnum(duration))
		duration = rand(trade_window_min, trade_window_max)
	trade_window_end = world.time + duration
	next_action_at = trade_window_end

/obj/overmap/trade_beacon/caravan/proc/IsTradeWindowOpen()
	return caravan_state == "docked" && world.time < trade_window_end

/obj/overmap/trade_beacon/caravan/proc/GetTradeWindowRemaining()
	if(!IsTradeWindowOpen())
		return 0
	return max(0, trade_window_end - world.time)

/obj/overmap/trade_beacon/caravan/proc/GetTradeAvailabilityBlockReason()
	if(IsTradeWindowOpen())
		return null
	return "This caravan is in transit. Intercept it during its next 5-10 minute trade stop."

/obj/overmap/trade_beacon/caravan/proc/GetTradeAvailabilityStatusData()
	if(IsTradeWindowOpen())
		return list(
			"label" = "Docked",
			"tone" = "good"
		)
	return list(
		"label" = "In transit",
		"tone" = "average"
	)

/obj/overmap/trade_beacon/caravan/proc/UpdateRouteProgress()
	while(length(current_route) && route_index <= length(current_route))
		var/turf/next_step = current_route[route_index]
		if(loc != next_step)
			break
		route_index++

/obj/overmap/trade_beacon/caravan/proc/SetCruiseHeading(turf/next_step)
	if(!istype(next_step))
		StopMovement()
		return
	var/desired_x = SIGN(next_step.x - x) * cruise_speed
	var/desired_y = SIGN(next_step.y - y) * cruise_speed
	if(!desired_x && !desired_y)
		StopMovement()
		return
	adjust_speed(desired_x - speed[1], desired_y - speed[2])
	dir = get_dir(src, next_step)

/obj/overmap/trade_beacon/caravan/proc/StopMovement()
	if(speed[1] || speed[2])
		adjust_speed(-speed[1], -speed[2])
