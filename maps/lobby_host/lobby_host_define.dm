/datum/map/lobby_host
	name = "Lobby Host"
	full_name = "Ship Selection Lobby"
	path = "lobby_host"
	flags = MAP_HAS_BRANCH | MAP_HAS_RANK

	station_levels = list(1)
	contact_levels = list(1)
	player_levels = list(1)
	admin_levels = list()

	allowed_jobs = list()
	allowed_spawns = list("Cryogenic Storage", "Arrivals Shuttle")
	default_spawn = "Cryogenic Storage"

	station_name = "Unassigned Vessel"
	station_short = "Vessel"
	dock_name = "Deep Space"
	boss_name = "Central Command"
	boss_short = "Centcomm"
	company_name = "Independent"
	company_short = "IND"
	system_name = "Uncharted System"

	use_overmap = TRUE
	overmap_size = 35
	overmap_event_areas = 20
	using_sun = TRUE
	num_exoplanets = 1
	planet_size = list(129, 129)
	away_site_budget = 5.5
	min_offmap_players = 0

	evac_controller_type = /datum/evacuation_controller/starship/fast
	default_law_type = /datum/ai_laws/nanotrasen

	ship_vote_enabled = TRUE
	default_main_ship_id = "awaysite_liberia"

	lobby_tracks = list(/singleton/audio/track/absconditus)

	welcome_sound = null

	/// Random aways wait until the voted main ship exists on the overmap.
	var/deferred_aways_loaded = FALSE

/datum/map/lobby_host/setup_map()
	..()
	system_name = generate_system_name()

/// Prepare overmap/events at init; load derelicts only after the main vessel is placed.
/datum/map/lobby_host/build_away_sites()
	if (!overmap_z)
		build_overmap()
	ensure_overmap_events()
	if (!ship_loaded)
		report_progress("Lobby host: deferring away sites until main vessel loads.")
		return
	if (deferred_aways_loaded)
		return
	deferred_aways_loaded = TRUE

	var/list/skipped = list()
	for (var/site_name in SSmapping.away_sites_templates)
		var/datum/map_template/ruin/away_site/site = SSmapping.away_sites_templates[site_name]
		if (site.votable_as_main_ship)
			skipped[site_name] = site
	for (var/site_name in skipped)
		SSmapping.away_sites_templates -= site_name

	..()

	for (var/site_name in skipped)
		SSmapping.away_sites_templates[site_name] = skipped[site_name]

	// Missions ran at misc_late with no aways; rebuild now that sites exist.
	derelict_missions_list.Cut()
	derelict_mission_configs.Cut()
	generate_derelict_missions()
	build_derelict_z_mapping()

/datum/map/lobby_host/proc/ensure_overmap_events()
	if (!use_overmap || !overmap_z || !overmap_event_areas)
		return
	for (var/obj/overmap/event/E)
		return // SSevent already placed hazards (overmap existed in time)
	overmap_event_handler.create_events(overmap_z, overmap_size, overmap_event_areas)
	report_progress("Lobby host: spawned [overmap_event_areas] overmap event clusters.")

/datum/map/lobby_host/get_map_info()
	if (ship_loaded && selected_main_ship)
		return "Main vessel: [selected_main_ship.name]. Set Occupation preferences for ship crew roles (marked \[current vessel]) and ready up for roundstart spawn."
	return "Waiting for crew to select a vessel. After the ship loads, set Occupation preferences for its crew roles and ready up."

/datum/map/lobby_host/proc/load_voted_ship(ship_id)
	if (ship_loaded)
		return TRUE
	if (!ship_id)
		ship_id = default_main_ship_id

	var/datum/map_template/ruin/away_site/site
	for (var/site_name in SSmapping.away_sites_templates)
		var/datum/map_template/ruin/away_site/candidate = SSmapping.away_sites_templates[site_name]
		if (candidate.id == ship_id)
			site = candidate
			break

	if (!site)
		log_error("Lobby host: could not find away site template id '[ship_id]'.")
		return FALSE

	report_progress("Loading main vessel: [site.name]...")
	var/z_before = world.maxz
	if (!site.load_new_z())
		log_error("Lobby host: failed to load '[site.name]'.")
		return FALSE

	var/z_start = z_before + 1
	var/z_end = world.maxz
	station_levels = list()
	contact_levels = list()
	for (var/z_level = z_start to z_end)
		station_levels |= z_level
		contact_levels |= z_level
		player_levels |= z_level
	map_levels = station_levels.Copy()

	station_name = site.name
	station_short = site.name
	selected_main_ship = site
	ship_loaded = TRUE
	loaded_away_site_ids += site.id
	bind_active_main_submap()
	report_progress("Main vessel loaded: [site.name] (Z [z_start]-[z_end]).")
	build_away_sites()
	return TRUE

/// Find the joinable submap created by the voted ship and expose it for roundstart/prefs.
/datum/map/lobby_host/proc/bind_active_main_submap()
	active_main_submap = null
	active_main_ship_descriptor = null
	for (var/datum/submap/submap as anything in SSmapping.submaps)
		if (!submap?.archetype || !(submap.associated_z in station_levels))
			continue
		active_main_submap = submap
		active_main_ship_descriptor = submap.archetype.descriptor
		if (SSjobs.job_lists_by_map_name[active_main_ship_descriptor])
			SSjobs.job_lists_by_map_name[active_main_ship_descriptor]["default_to_hidden"] = FALSE
		for (var/title in submap.jobs)
			var/datum/job/submap/ship_job = submap.jobs[title]
			if (ship_job)
				ship_job.create_record = TRUE
		for (var/client/C as anything in GLOB.clients)
			if (C?.prefs)
				C.prefs.hiding_maps[active_main_ship_descriptor] = FALSE
		report_progress("Main vessel crew roster: [active_main_ship_descriptor].")
		return
	log_error("Lobby host: main vessel loaded but no joinable submap was found on station levels.")
