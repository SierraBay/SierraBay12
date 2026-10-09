/datum/trading_station/proc/GetFacilitySuffix()
	var/list/facility_suffixes = list("Depot", "Outpost", "Relay", "Hub", "Platform", "Terminal", "Exchange", "Array", "Facility")
	return prob(65) ? " [pick(facility_suffixes)]" : ""

/datum/trading_station/proc/GetNamingPrefixData()
	if(faction == FACTION_INDIE_CONFED)
		return list("short" = pick("TTB", "CTB", "PTB"), "full" = "Terran Trade Beacon")
	if(faction == FACTION_NANOTRASEN)
		return list("short" = pick("NTB", "NSB"), "full" = "NanoTrasen Beacon")
	return list("short" = pick("FTB", "ISB", "OSB", "ASB"), "full" = "Free Trade Beacon")

/datum/trading_station/proc/GetThematicCores()
	return thematic_cores

/datum/trading_station/proc/GetRoleSummary()
	return role_summary

/datum/trading_station/proc/GetFaction()
	return SSsupply.GetFaction(faction)

/datum/trading_station/proc/AssignStationIdentity(turf/station_loc = null)
	if(name)
		CRASH("[type] trade station had name set before InitSrc() was called!")
	if(LAZYLEN(random_factions))
		faction = pick(random_factions)

	var/list/available_names = islist(name_pool) ? name_pool.Copy() : list()
	for(var/datum/trading_station/other_station as anything in SSsupply?.all_trading_stations)
		if(other_station.name)
			available_names.Remove(other_station.name)

	if(length(available_names))
		name = pick(available_names)
		desc = available_names[name]
	else
		log_debug("Trade station name pool exhausted for [type]; generating procedural identity.")
		AssignProceduralIdentity(station_loc)

	uid ||= "[type]_[random_id(type, 100, 999)]"

/datum/trading_station/proc/AssignProceduralIdentity(turf/station_loc = null)
	var/turf/target_turf = istype(station_loc) ? station_loc : overmap_location
	var/list/identity = GenerateProceduralStationIdentity(src, target_turf)
	name = identity["name"]
	desc = identity["desc"]
	if(!name)
		name = "[initial(name) || "Trade Station"] [random_id(type, 100, 999)]"
	if(!desc)
		desc = initial(desc) || "An automated merchant outpost."

/datum/trading_station/proc/SetupOvermapPlacement(turf/station_loc = null, force_discovered = FALSE)
	if(start_hidden)
		start_hidden = !force_discovered

	if(!GLOB.using_map.use_overmap)
		start_hidden = FALSE
		return

	var/turf/spawn_turf = ResolveOvermapSpawnLocation(station_loc)
	if(istype(spawn_turf))
		PlaceOvermap(spawn_turf.x, spawn_turf.y, spawn_turf.z)

/datum/trading_station/proc/RegisterStation()
	SSsupply.all_trading_stations |= src
	if(start_hidden)
		SSsupply.hidden_trading_stations |= src
	else
		SSsupply.visible_trading_stations |= src

/datum/trading_station/proc/ResolveOvermapSpawnLocation(turf/station_loc = null)
	if(!GLOB.using_map?.overmap_z)
		return null
	if(istype(station_loc))
		return station_loc
	if(use_smart_overmap_placement)
		var/turf/smart_turf = FindSmartOvermapSpawnLocation(GLOB.using_map.overmap_z)
		if(istype(smart_turf))
			return smart_turf
	return FindFallbackOvermapSpawnLocation(GLOB.using_map.overmap_z)

/datum/trading_station/proc/FindFallbackOvermapSpawnLocation(spawn_z)
	var/list/candidate_turfs = GetOvermapSpawnCandidateTurfs(spawn_z)
	if(!length(candidate_turfs))
		return null
	return pick(candidate_turfs)

/datum/trading_station/proc/FindSmartOvermapSpawnLocation(spawn_z)
	var/list/candidate_turfs = GetOvermapSpawnCandidateTurfs(spawn_z)
	if(!length(candidate_turfs))
		return null

	if(isnum(placement_attempt_sample) && placement_attempt_sample > 0 && length(candidate_turfs) > placement_attempt_sample)
		candidate_turfs = SampleOvermapSpawnCandidates(candidate_turfs, placement_attempt_sample)

	var/list/weighted_candidates = list()
	var/best_score = null
	for(var/turf/candidate as anything in candidate_turfs)
		var/score = ScoreOvermapSpawnLocation(candidate)
		if(!isnum(score) || score <= 0)
			continue
		weighted_candidates[candidate] = score
		if(isnull(best_score) || score > best_score)
			best_score = score

	if(length(weighted_candidates))
		return pickweight(weighted_candidates)
	return null

/datum/trading_station/proc/SampleOvermapSpawnCandidates(list/candidate_turfs, sample_size)
	if(!islist(candidate_turfs) || !length(candidate_turfs) || !isnum(sample_size) || sample_size <= 0)
		return candidate_turfs
	if(length(candidate_turfs) <= sample_size)
		return candidate_turfs.Copy()

	var/list/pool = candidate_turfs.Copy()
	var/list/sampled = list()
	for(var/i in 1 to sample_size)
		if(!length(pool))
			break
		var/picked = pick(pool)
		pool -= picked
		sampled += picked
	return sampled

/datum/trading_station/proc/GetOvermapSpawnCandidateTurfs(spawn_z)
	if(!spawn_z)
		return list()

	var/map_low = OVERMAP_EDGE
	var/map_high = GLOB.using_map.overmap_size - OVERMAP_EDGE
	var/min_x = map_low
	var/max_x = map_high
	var/min_y = map_low
	var/max_y = map_high
	if(islist(forced_overmap_zone) && length(forced_overmap_zone) >= 2)
		var/list/x_bounds = forced_overmap_zone[1]
		var/list/y_bounds = forced_overmap_zone[2]
		if(islist(x_bounds) && length(x_bounds) >= 2 && islist(y_bounds) && length(y_bounds) >= 2)
			min_x = max(map_low, x_bounds[1])
			max_x = min(map_high, x_bounds[2])
			min_y = max(map_low, y_bounds[1])
			max_y = min(map_high, y_bounds[2])

	if(min_x > max_x || min_y > max_y)
		return list()

	var/list/result = list()
	for(var/turf/candidate as anything in block(locate(min_x, min_y, spawn_z), locate(max_x, max_y, spawn_z)))
		if(!CanUseOvermapSpawnLocation(candidate))
			continue
		result += candidate
	return result

/datum/trading_station/proc/CanUseOvermapSpawnLocation(turf/candidate)
	ASSERT(istype(candidate, /turf))
	if(!istype(candidate, /turf/unsimulated/map) || istype(candidate, /turf/unsimulated/map/edge))
		return FALSE
	if(locate(/obj/overmap/visitable) in candidate)
		return FALSE
	if(locate(/obj/overmap/trade_beacon) in candidate)
		return FALSE
	if(length(overmap_event_handler.hazard_by_turf[candidate]))
		return FALSE
	if(hazard_buffer > 0)
		for(var/turf/nearby as anything in RANGE_TURFS(candidate, hazard_buffer))
			if(nearby == candidate)
				continue
			if(length(overmap_event_handler.hazard_by_turf[nearby]))
				return FALSE
	return TRUE

/datum/trading_station/proc/ScoreOvermapSpawnLocation(turf/candidate)
	ASSERT(istype(candidate, /turf))
	if(!CanUseOvermapSpawnLocation(candidate))
		return 0

	var/score = 100
	var/nearest_station_distance = GetNearestTradeStationDistance(candidate)
	if(isnum(nearest_station_distance))
		if(nearest_station_distance < min_overmap_station_spacing)
			return 0
		score += min(nearest_station_distance, 12) * 10

	var/base_distance = GetBaseDistance(candidate)
	if(isnum(base_distance))
		if(base_distance < min_distance_from_base)
			return 0
		if(isnum(max_distance_from_base) && max_distance_from_base > 0 && base_distance > max_distance_from_base)
			score -= min((base_distance - max_distance_from_base) * 6, 60)
		if(isnum(preferred_distance_from_base) && preferred_distance_from_base > 0)
			score += max(0, 60 - (abs(base_distance - preferred_distance_from_base) * 8))

	score += GetOpenSpaceScore(candidate)
	return max(0, round(score))

/datum/trading_station/proc/GetNearestTradeStationDistance(turf/candidate)
	ASSERT(istype(candidate, /turf))
	var/nearest = null
	for(var/datum/trading_station/other_station as anything in SSsupply.all_trading_stations)
		if(other_station == src || !istype(other_station.overmap_location))
			continue
		var/distance = get_dist(candidate, other_station.overmap_location)
		if(isnull(nearest) || distance < nearest)
			nearest = distance
	return nearest

/datum/trading_station/proc/GetBaseDistance(turf/candidate)
	ASSERT(istype(candidate, /turf))
	var/obj/overmap/visitable/base_sector = GetPrimaryBaseSector()
	if(!istype(base_sector) || base_sector.z != candidate.z)
		return null
	return get_dist(candidate, base_sector)

/datum/trading_station/proc/GetPrimaryBaseSector()
	for(var/key in map_sectors)
		var/obj/overmap/visitable/sector = map_sectors[key]
		if(istype(sector) && HAS_FLAGS(sector.sector_flags, OVERMAP_SECTOR_BASE))
			return sector
	return null

/datum/trading_station/proc/GetOpenSpaceScore(turf/candidate)
	ASSERT(istype(candidate, /turf))
	var/score = 0
	for(var/turf/nearby as anything in RANGE_TURFS(candidate, 2))
		if(nearby == candidate)
			continue
		if(!istype(nearby, /turf/unsimulated/map) || istype(nearby, /turf/unsimulated/map/edge))
			continue
		if(locate(/obj/overmap/visitable) in nearby)
			score -= 12
			continue
		if(locate(/obj/overmap/trade_beacon) in nearby)
			score -= 10
			continue
		if(length(overmap_event_handler.hazard_by_turf[nearby]))
			score -= 16
			continue
		score += 2
	return score

/datum/trading_station/proc/PlaceOvermap(spawn_x, spawn_y, spawn_z = GLOB.using_map.overmap_z)
	if(!spawn_z)
		return

	var/turf/new_location = locate(spawn_x, spawn_y, spawn_z)
	UpdateOvermapLocation(new_location)
	if(!overmap_location)
		return

	var/overmap_type = GetOvermapObjectType()
	overmap_object = new overmap_type(overmap_location)
	overmap_object.name = GetOvermapName()
	overmap_object.desc = GetOvermapDesc()
	overmap_object.scanner_desc = GetOvermapScannerDesc()
	overmap_object.opacity = overmap_opacity
	overmap_object.dir = pick(rand(1, 2), 4, 8)
	if(icon)
		overmap_object.icon = icon
	overmap_object.icon_state = pick(icon_states)

	if(start_hidden)
		overmap_object.color = "#444444"

/datum/trading_station/proc/UpdateOvermapLocation(turf/new_location)
	if(overmap_location == new_location)
		return
	if(overmap_location && start_hidden)
		GLOB.entered_event.unregister(overmap_location, src, .proc/Discovered)
	overmap_location = new_location
	if(overmap_location && start_hidden)
		GLOB.entered_event.register(overmap_location, src, .proc/Discovered)

/datum/trading_station/proc/GetOvermapObjectType()
	return /obj/overmap/trade_beacon

/datum/trading_station/proc/GetOvermapName()
	return name || "Trade Beacon"

/datum/trading_station/proc/GetOvermapDesc()
	if(desc)
		return desc
	return "A long-range commercial beacon offering remote trade services."

/datum/trading_station/proc/GetOvermapScannerDesc()
	var/faction_name = faction || FACTION_INDEPENDENT
	return {"\[i\]Registration\[/i\]: [GetOvermapName()]
\[i\]Class\[/i\]: Commercial Trade Beacon
\[i\]Transponder\[/i\]: Transmitting (CIV), [faction_name]
\[b\]Notice\[/b\]: [GetOvermapDesc()]"}

/datum/trading_station/proc/GetAvailabilityBlockReason(atom/source = null)
	return null

/datum/trading_station/proc/GetAvailabilityStatusData()
	return null

/datum/trading_station/proc/GetAvailabilityWindowRemaining()
	return null

/datum/trading_station/proc/Discovered(_, atom/movable/O)
	if(istype(O, /obj/overmap/visitable/ship))
		// Mobile ship or shuttle discovered the station
	else if(istype(O, /obj/overmap/visitable/sector))
		var/obj/overmap/visitable/sector/S = O
		if(!HAS_FLAGS(S.sector_flags, OVERMAP_SECTOR_BASE))
			return
	else
		return

	start_hidden = FALSE
	SSsupply.hidden_trading_stations -= src
	if(!(src in SSsupply.visible_trading_stations))
		SSsupply.visible_trading_stations += src
	if(overmap_object)
		overmap_object.color = null
	if(overmap_location)
		GLOB.entered_event.unregister(overmap_location, src, .proc/Discovered)
