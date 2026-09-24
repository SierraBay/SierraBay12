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
	icon_states = list("unknown", "trade")
	random_factions = list(
		FACTION_INDEPENDENT,
		FACTION_FREETRADE,
		FACTION_INDIE_CONFED
	)
	name_pool = list(
		"FTV Wayfarer" = "A mobile trade caravan carrying mixed civilian cargo and opportunistic surplus.",
		"FTV Long Haul" = "An itinerant merchant convoy moving between beacon routes with a rotating inventory.",
		"FTV Open Palm" = "A roving independent trade caravan broadcasting merchant registry codes.",
		"FTV Far Market" = "A caravan specializing in off-route deals and transient dockside trade.",
		"FTV Stray Wind" = "A light independent merchant cutter trading regional surplus across peripheral jump points.",
		"FTV Nomad's Coin" = "A veteran trader convoy bartering manufactured goods for raw salvage.",
		"FTV Drift Hopper" = "A swift bulk runner connecting independent outposts outside core shipping lanes.",
		"FTV Silver Horizon" = "A luxury and consumer provisions merchant vessel cruising between planetary outposts."
	)
	var/list/caravan_station_types = list(
		/datum/trading_station/operations,
		/datum/trading_station/engineering,
		/datum/trading_station/materials,
		/datum/trading_station/medicine,
		/datum/trading_station/science,
		/datum/trading_station/service,
		/datum/trading_station/civilian,
		/datum/trading_station/eva,
		/datum/trading_station/atmospherics
	)
	var/min_groups = 2
	var/max_groups = 3
	var/has_departed = FALSE
	thematic_cores = list("Wayfarer", "Long Haul", "Open Palm", "Far Market", "Stray Wind", "Nomad's Coin", "Drift Hopper", "Silver Horizon", "Peregrine", "Wandering Star")
	role_summary = "mobile deep-space commercial cargo transit"

/datum/trading_station/caravan/GetNamingPrefixData()
	return list("short" = pick("FTV", "MSV", "CSV"), "full" = "Free Trade Vessel")

/datum/trading_station/caravan/GetFacilitySuffix()
	return prob(30) ? " [pick("Runner", "Hauler", "Convoy", "Express")]" : ""

/datum/trading_station/caravan/InitSrc(turf/station_loc = null, force_discovered = FALSE)
	uid = "trade_caravan_[random_id(type, 1000, 9999)]"
	return ..(station_loc, force_discovered)

/datum/trading_station/caravan/AssembleInventory()
	ResetOfferRegistries()
	BuildCaravanInventory()
	inventory = offers_by_category
	SyncAmountsOfGoods()

/datum/trading_station/caravan/proc/BuildCaravanInventory()
	var/list/available_stations = caravan_station_types.Copy()
	var/stations_to_sample = clamp(rand(min_groups, max_groups), 1, length(available_stations))
	for(var/i in 1 to stations_to_sample)
		if(!length(available_stations))
			break
		var/chosen_station_type = pick(available_stations)
		available_stations -= chosen_station_type
		SampleStationOffers(chosen_station_type)

/datum/trading_station/caravan/proc/SampleStationOffers(chosen_station_type)
	var/datum/trading_station/source_station = FindOrSpawnSourceStation(chosen_station_type)
	if(!istype(source_station))
		return
	var/needs_qdel = !(source_station in SSsupply?.all_trading_stations)
	SampleVisibleOffersFrom(source_station)
	if(length(source_station.hidden_offers) && prob(50))
		SampleHiddenOffersFrom(source_station)
	if(needs_qdel)
		qdel(source_station)

/datum/trading_station/caravan/proc/FindOrSpawnSourceStation(chosen_station_type)
	if(SSsupply && islist(SSsupply.all_trading_stations))
		for(var/datum/trading_station/existing in SSsupply.all_trading_stations)
			if(existing.type == chosen_station_type && length(existing.offers))
				return existing
	var/datum/trading_station/source_station = new chosen_station_type(FALSE)
	if(istype(source_station))
		source_station.AssembleInventory()
		return source_station
	return null

/datum/trading_station/caravan/proc/SampleVisibleOffersFrom(datum/trading_station/source_station)
	for(var/category_name in source_station.offers_by_category)
		var/list/source_offers = source_station.offers_by_category[category_name]
		if(!islist(source_offers) || !length(source_offers))
			continue
		var/list/candidate_keys = source_offers.Copy()
		var/items_to_pick = min(length(candidate_keys), rand(2, 5))
		for(var/j in 1 to items_to_pick)
			var/picked_key = pick(candidate_keys)
			candidate_keys -= picked_key
			var/datum/trade_offer/source_offer = source_offers[picked_key]
			if(istype(source_offer))
				var/datum/trade_offer/cloned = source_offer.Duplicate(GenerateGoodOfferId(), src)
				AddOffer(cloned)

/datum/trading_station/caravan/proc/SampleHiddenOffersFrom(datum/trading_station/source_station)
	var/list/hidden_keys = source_station.hidden_offers.Copy()
	if(!length(hidden_keys))
		return
	var/picked_hidden_key = pick(hidden_keys)
	var/datum/trade_offer/hidden_offer = source_station.hidden_offers[picked_hidden_key]
	if(istype(hidden_offer))
		var/datum/trade_offer/cloned = hidden_offer.Duplicate(GenerateGoodOfferId(), src)
		cloned.hidden = TRUE
		AddOffer(cloned)

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
	if(has_departed)
		return "This caravan has departed."
	if(!GLOB.using_map.use_overmap || !overmap_location)
		return null
	var/obj/overmap/trade_beacon/caravan/caravan_object = overmap_object
	if(!istype(caravan_object) || QDELETED(caravan_object))
		return "This caravan is currently unavailable."
	return caravan_object.GetTradeAvailabilityBlockReason()


/datum/trading_station/caravan/GetAvailabilityStatusData()
	if(has_departed)
		return list(
			"label" = "Departed",
			"tone" = "bad"
		)
	if(!GLOB.using_map.use_overmap || !overmap_location)
		return list(
			"label" = "Docked",
			"tone" = "good"
		)
	var/obj/overmap/trade_beacon/caravan/caravan_object = overmap_object
	if(!istype(caravan_object) || QDELETED(caravan_object))
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
	icon_state = "unknown"
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
	var/datum/caravan_route_search/route_search = null
	var/route_index = 1
	var/route_search_nodes_per_process = 150
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
		linked_station.has_departed = TRUE
		linked_station.overmap_object = null
		linked_station.overmap_location = null
	linked_station = null
	current_stop = null
	route_destination = null
	current_route = null
	QDEL_NULL(route_search)
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

	if(world.time < next_action_at)
		StopMovement()
		return

	if(caravan_state == "docked" || !istype(route_destination))
		if(!SelectNextRoute())
			StopMovement()
			BeginTradeWindow(1 MINUTE)
			return
		return

	var/turf/destination = istype(route_destination) ? route_destination.overmap_location : null
	if(!istype(destination))
		ClearRoute()
		StopMovement()
		next_action_at = world.time + repath_cooldown
		return

	if(loc == destination)
		StopMovement()
		current_stop = route_destination
		ClearRoute()
		BeginTradeWindow()
		return

	if(!length(current_route))
		var/list/completed_route = ContinueRouteSearch(destination)
		if(isnull(completed_route))
			StopMovement()
			return
		if(!islist(completed_route))
			ClearRoute()
			StopMovement()
			next_action_at = world.time + repath_cooldown
			return
		current_route = completed_route
		route_index = 2

	UpdateRouteProgress()

	if(route_index > length(current_route))
		current_route = null
		route_index = 1
		if(!BeginRouteSearch(destination))
			ClearRoute()
			StopMovement()
			next_action_at = world.time + repath_cooldown
		return

	var/turf/next_step = current_route[route_index]
	if(!istype(next_step) || !CanTraverseTurf(next_step, destination))
		current_route = null
		route_index = 1
		if(!BeginRouteSearch(destination))
			ClearRoute()
			StopMovement()
			next_action_at = world.time + repath_cooldown
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
		if(!BeginRouteSearch(candidate.overmap_location))
			continue
		route_destination = candidate
		BeginTransit()
		return TRUE
	return FALSE

/obj/overmap/trade_beacon/caravan/proc/ClearRoute()
	StopMovement()
	route_destination = null
	current_route = null
	QDEL_NULL(route_search)
	route_index = 1

/datum/caravan_route_node
	var/turf/node
	var/f_score = 0
	var/g_score = 0

/proc/cmp_caravan_route_node(datum/caravan_route_node/a, datum/caravan_route_node/b)
	return a.f_score - b.f_score

/datum/caravan_route_search
	var/turf/goal
	var/PriorityQueue/open_queue
	var/list/open_nodes = list()
	var/list/closed_nodes = list()
	var/list/came_from = list()
	var/list/g_score = list()
	var/iterations = 0
	var/max_iterations = 1500

/datum/caravan_route_search/Destroy()
	QDEL_NULL(open_queue)
	open_nodes.Cut()
	closed_nodes.Cut()
	came_from.Cut()
	g_score.Cut()
	goal = null
	return ..()

/datum/caravan_route_search/proc/InitializeSearch(turf/start, turf/new_goal, obj/overmap/trade_beacon/caravan/caravan)
	if(!istype(start) || !istype(new_goal) || !istype(caravan))
		return FALSE
	goal = new_goal
	open_queue = new /PriorityQueue(GLOBAL_PROC_REF(cmp_caravan_route_node))
	var/datum/caravan_route_node/start_node = new
	start_node.node = start
	start_node.g_score = 0
	start_node.f_score = caravan.EstimateRouteHeuristic(start, goal)
	open_nodes[start] = start_node
	g_score[start] = 0
	open_queue.Enqueue(start_node)
	return TRUE

/datum/caravan_route_search/proc/Advance(obj/overmap/trade_beacon/caravan/caravan, node_budget)
	if(!istype(caravan) || !istype(goal) || !istype(open_queue) || node_budget < 1)
		return FALSE
	var/processed_nodes = 0
	while(!open_queue.IsEmpty() && processed_nodes++ < node_budget && iterations++ < max_iterations)
		var/datum/caravan_route_node/current_node = open_queue.Dequeue()
		var/turf/current = current_node?.node
		if(!istype(current) || closed_nodes[current])
			continue
		open_nodes[current] = null
		closed_nodes[current] = TRUE
		if(current == goal)
			return ReconstructRoute(current)
		ExpandNeighbors(current, caravan)
	if(open_queue.IsEmpty() || iterations >= max_iterations)
		return FALSE
	return null

/datum/caravan_route_search/proc/ExpandNeighbors(turf/current, obj/overmap/trade_beacon/caravan/caravan)
	var/current_cost = g_score[current]
	for(var/turf/neighbor as anything in caravan.GetPathNeighbors(current, goal))
		if(closed_nodes[neighbor])
			continue
		var/tentative_cost = current_cost + caravan.GetTraversalCost(neighbor, goal)
		var/datum/caravan_route_node/next_node = open_nodes[neighbor]
		if(istype(next_node) && tentative_cost >= next_node.g_score)
			continue
		if(!istype(next_node))
			next_node = new
			next_node.node = neighbor
		else
			open_queue.Remove(next_node)
		next_node.g_score = tentative_cost
		next_node.f_score = tentative_cost + caravan.EstimateRouteHeuristic(neighbor, goal)
		open_nodes[neighbor] = next_node
		came_from[neighbor] = current
		g_score[neighbor] = tentative_cost
		open_queue.Enqueue(next_node)

/datum/caravan_route_search/proc/ReconstructRoute(turf/current)
	var/list/path = list(current)
	while(came_from[current])
		current = came_from[current]
		path += current
	return reverseRange(path)

/obj/overmap/trade_beacon/caravan/proc/BeginRouteSearch(turf/goal)
	QDEL_NULL(route_search)
	if(!istype(goal) || !istype(loc, /turf))
		return FALSE
	route_search = new
	if(route_search.InitializeSearch(loc, goal, src))
		return TRUE
	QDEL_NULL(route_search)
	return FALSE

/obj/overmap/trade_beacon/caravan/proc/ContinueRouteSearch(turf/goal)
	if(!istype(route_search) || route_search.goal != goal)
		if(!BeginRouteSearch(goal))
			return FALSE
	var/list/result = route_search.Advance(src, route_search_nodes_per_process)
	if(islist(result))
		QDEL_NULL(route_search)
		return result
	if(isnull(result))
		return null
	QDEL_NULL(route_search)
	return FALSE

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
	for(var/turf/nearby as anything in RANGE_TURFS(target_turf, 1))
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
	next_action_at = world.time

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
