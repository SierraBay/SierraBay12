/datum/map_template/ruin/away_site/salvage_ship
	name =  "Salvage Shuttle"
	id = "awaysite_crab"
	description = "Salvage Shuttle"
	prefix = "mods/_maps/general_maps/maps/"
	suffixes = list("salvage_shuttle/salvage_shuttle.dmm")
	spawn_cost = 0.5
	player_cost = 2
	accessibility_weight = 10
	spawn_weight = 0.67
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/salvage_shuttle)

	area_usage_test_exempted_root_areas = list(
		/area/salvage_shuttle,
		/area/derelict_cargo_ship
	)

	apc_test_exempt_areas = list(
		/area/salvage_shuttle/net = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/derelict_cargo_ship/maintenance = NO_SCRUBBER|NO_VENT,
		/area/derelict_cargo_ship/cockpit = NO_VENT
	)


/datum/job/submap/independent_salvager
	// title = "Independent Salvager"
	// total_positions = 2
	// outfit_type = /singleton/hierarchy/outfit/job/independent_salvager
	// supervisors = "your fellow crew"
	// info = "You're an independent salvager on board the ISV Crab. \
	// Fly through the sector, salvaging what materials and valuables you can find. \
	// You're a travelling merchant at heart. Make friends and trade your spoils to turn a profit!"
	// whitelisted_species = list(
	// 	SPECIES_HUMAN,
	// 	SPECIES_IPC,
	// 	SPECIES_SPACER,
	// 	SPECIES_GRAVWORLDER,
	// 	SPECIES_VATGROWN,
	// 	SPECIES_TRITONIAN,
	// 	SPECIES_MULE
	// )
	min_skill = list(
		SKILL_HAULING = SKILL_TRAINED,
		SKILL_PILOT = SKILL_BASIC,
		SKILL_EVA = SKILL_EXPERIENCED,
		SKILL_CONSTRUCTION = SKILL_TRAINED,
		SKILL_ELECTRICAL = SKILL_BASIC,
		SKILL_ATMOS = SKILL_BASIC,
		SKILL_MEDICAL = SKILL_BASIC,
		SKILL_ENGINES = SKILL_BASIC,
	)

	skill_points = 21
