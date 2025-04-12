/area
	var/can_have_awakening_event = TRUE

/datum/event/exo_awakening/find_suitable_planet()
	var/list/sites = list() //a list of sites that have players present

	for (var/area/A in exoplanet_areas)
		if(!A.can_have_awakening_event)
			continue
		var/list/players = list()
		for (var/mob/M in GLOB.player_list)
			if (M.stat != DEAD && (get_z(M) in GetConnectedZlevels(A.z)))
				players += M
				chosen_area = A
				chosen_planet = map_sectors["[A.z]"]
				affecting_z = GetConnectedZlevels(A.z)

		if (length(players) >= required_players_count)
			sites += A
			players_on_site[A] = players

	if (!length(sites))
		log_debug("Exoplanet Awakening failed to run, not enough players on any planet. Aborting.")
		failed = TRUE
		kill()
		return

	chosen_area = pick(sites)
	chosen_planet = map_sectors["[chosen_area.z]"]
	affecting_z = GetConnectedZlevels(chosen_area.z)

	if (!chosen_area)
		log_debug("Exoplanet Awakening failed to start, could not find a planetary area.")
		failed = TRUE
		kill()
