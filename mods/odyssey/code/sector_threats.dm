/obj/overmap/event/var/odyssey_replaceable = FALSE


/proc/odyssey_sector_threat_profile(list/sector)
	var/danger = sector["danger"] || ODYSSEY_DANGER_SAFE
	switch (danger)
		if (ODYSSEY_DANGER_HOSTILE)
			// Near Sierra's vanilla overmap_event_areas (34), still cloud-shaped.
			return list("clouds" = 32, "event_delay" = -8 MINUTES, "leviathan_chance" = 55)
		if (ODYSSEY_DANGER_DANGEROUS)
			return list("clouds" = 24, "event_delay" = -4 MINUTES, "leviathan_chance" = 22)
		if (ODYSSEY_DANGER_CIVILIAN)
			return list("clouds" = 16, "event_delay" = 4 MINUTES, "leviathan_chance" = 5)
	return list("clouds" = 8, "event_delay" = 10 MINUTES, "leviathan_chance" = 0)


/proc/odyssey_sector_hazard_pool(danger)
	switch (danger)
		if (ODYSSEY_DANGER_HOSTILE)
			return list(
				/obj/overmap/event/meteor,
				/obj/overmap/event/electric,
				/obj/overmap/event/ion,
				/obj/overmap/event/carp,
				/obj/overmap/event/gravity
			)
		if (ODYSSEY_DANGER_DANGEROUS)
			return list(
				/obj/overmap/event/meteor,
				/obj/overmap/event/electric,
				/obj/overmap/event/ion,
				/obj/overmap/event/dust,
				/obj/overmap/event/gravity
			)
		if (ODYSSEY_DANGER_CIVILIAN)
			return list(
				/obj/overmap/event/dust,
				/obj/overmap/event/ion,
				/obj/overmap/event/carp
			)
	return list(/obj/overmap/event/dust, /obj/overmap/event/ion)


/// Cloud shape mirrors vanilla /datum/overmap_event defaults for the hazard type.
/proc/odyssey_hazard_cloud_shape(hazard_type)
	switch (hazard_type)
		if (/obj/overmap/event/meteor)
			return list("count" = 15, "radius" = 4, "continuous" = FALSE)
		if (/obj/overmap/event/electric)
			return list("count" = 11, "radius" = 3, "continuous" = TRUE)
		if (/obj/overmap/event/dust)
			return list("count" = 16, "radius" = 4, "continuous" = TRUE)
		if (/obj/overmap/event/ion)
			return list("count" = 8, "radius" = 3, "continuous" = TRUE)
		if (/obj/overmap/event/carp)
			return list("count" = 8, "radius" = 3, "continuous" = FALSE)
		if (/obj/overmap/event/gravity)
			return list("count" = 12, "radius" = 4, "continuous" = TRUE)
	return list("count" = 8, "radius" = 3, "continuous" = TRUE)


/proc/odyssey_pick_from_list(list/choices, seed, salt)
	if (!length(choices))
		return null
	return choices[odyssey_seed_roll(seed, salt, 1, length(choices))]


/// Deterministic analogue of overmap_event_handler.acquire_event_turfs.
/proc/odyssey_acquire_cloud_turfs(turf/origin, count, radius, continuous, list/candidate_turfs, seed, salt)
	if (!origin || !length(candidate_turfs) || count < 1)
		return list()
	var/list/available = candidate_turfs.Copy()
	if (!(origin in available))
		return list()
	count = min(count, length(available))
	var/list/selected = list(origin)
	var/list/frontier = list(origin)
	available -= origin
	var/step = 0
	while (length(frontier) && length(selected) < count)
		step += 1
		var/turf/from_turf = odyssey_pick_from_list(frontier, seed, "[salt]:front:[step]")
		if (!from_turf)
			break
		var/list/neighbours
		if (continuous)
			neighbours = from_turf.CardinalTurfs(FALSE)
		else
			neighbours = trange(radius, from_turf)
		var/list/fitting = list()
		for (var/turf/T in neighbours)
			if (T in available)
				fitting += T
		if (!length(fitting))
			frontier -= from_turf
			continue
		var/turf/picked = odyssey_pick_from_list(fitting, seed, "[salt]:pick:[step]")
		available -= picked
		selected += picked
		if (get_dist(origin, picked) < radius)
			frontier += picked
	return selected


/proc/odyssey_apply_sector_threats()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !GLOB.using_map.use_overmap)
		return FALSE
	var/list/sector = odyssey_get_sector(state.current_sector_id, state)
	if (!islist(sector))
		return FALSE
	var/list/profile = odyssey_sector_threat_profile(sector)
	var/z = GLOB.using_map.overmap_z
	var/size = GLOB.using_map.overmap_size
	if (!z || size < 6)
		return FALSE

	// Replace the generic random clouds with this sector's reproducible profile.
	for (var/obj/overmap/event/E in world)
		var/turf/event_turf = get_turf(E)
		if (E.odyssey_replaceable && event_turf && event_turf.z == z)
			qdel(E)

	var/list/candidate_turfs = block(locate(OVERMAP_EDGE, OVERMAP_EDGE, z), locate(size - OVERMAP_EDGE, size - OVERMAP_EDGE, z))
	candidate_turfs = where(candidate_turfs, GLOBAL_PROC_REF(can_not_locate), /obj/overmap/visitable)

	var/list/pool = odyssey_sector_hazard_pool(sector["danger"])
	var/wanted_clouds = profile["clouds"]
	var/clouds_spawned = 0
	var/tiles_spawned = 0
	var/seed = sector["seed"]

	for (var/i = 1 to wanted_clouds)
		if (!length(candidate_turfs))
			break
		var/turf/origin = odyssey_pick_from_list(candidate_turfs, seed, "cloud-origin:[i]")
		if (!origin)
			break
		var/hazard_type = odyssey_pick_from_list(pool, seed, "cloud-type:[i]")
		var/list/shape = odyssey_hazard_cloud_shape(hazard_type)
		var/list/event_turfs = odyssey_acquire_cloud_turfs(origin, shape["count"], shape["radius"], shape["continuous"], candidate_turfs, seed, "cloud-shape:[i]")
		if (!length(event_turfs))
			candidate_turfs -= origin
			continue
		candidate_turfs -= event_turfs
		for (var/turf/event_turf in event_turfs)
			var/obj/overmap/event/hazard = new hazard_type(event_turf, seed)
			hazard.odyssey_replaceable = TRUE
			tiles_spawned++
		clouds_spawned++

	var/event_delay = profile["event_delay"]
	if (SSevent && event_delay)
		SSevent.delay_events(EVENT_LEVEL_MODERATE, event_delay)
		SSevent.delay_events(EVENT_LEVEL_MAJOR, event_delay)

	var/leviathan_roll = odyssey_seed_roll(seed, "leviathan", 1, 100)
	if (leviathan_roll <= profile["leviathan_chance"])
		odyssey_spawn_sector_leviathan(sector)

	log_game("ODYSSEY: sector threats id=[state.current_sector_id] danger=[sector["danger"]] clouds=[clouds_spawned]/[wanted_clouds] tiles=[tiles_spawned] leviathan_roll=[leviathan_roll]")
	return TRUE


/proc/odyssey_spawn_sector_leviathan(list/sector)
	var/list/types = list(
		/obj/overmap/event/leviathan/medusa,
		/obj/overmap/event/leviathan/dragon,
		/obj/overmap/event/leviathan/swarm
	)
	var/obj/overmap/visitable/ship/sierra/S
	for (var/obj/overmap/visitable/ship/candidate in SSshuttle.ships)
		if (!S || candidate.vessel_mass > S.vessel_mass)
			S = candidate
	if (!S)
		return FALSE
	var/z = GLOB.using_map.overmap_z
	var/size = GLOB.using_map.overmap_size
	for (var/i = 1 to 40)
		var/x = odyssey_seed_roll(sector["seed"], "lev-x:[i]", 2, size - 2)
		var/y = odyssey_seed_roll(sector["seed"], "lev-y:[i]", 2, size - 2)
		var/turf/T = locate(x, y, z)
		if (!T || get_dist(T, S) < 5 || locate(/obj/overmap/visitable) in T)
			continue
		var/index = odyssey_seed_roll(sector["seed"], "lev-type", 1, length(types))
		var/leviathan_type = types[index]
		var/obj/overmap/event/leviathan = new leviathan_type(T)
		leviathan.odyssey_replaceable = TRUE
		return TRUE
	return FALSE
