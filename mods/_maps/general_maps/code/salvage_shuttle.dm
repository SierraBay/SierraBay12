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
