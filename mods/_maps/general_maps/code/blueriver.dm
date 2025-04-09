/datum/map_template/ruin/away_site/blueriver
	name = "Bluespace River"
	id = "awaysite_blue"
	spawn_cost = 2
	description = "An arctic planet and an alien underground surface"
	prefix = "mods/_maps/general_maps/maps/"
	generate_mining_by_z = 2
	area_usage_test_exempted_root_areas = list(/area/bluespaceriver)
	apc_test_exempt_areas = list(
		/area/bluespaceriver/underground = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/bluespaceriver/ground = NO_SCRUBBER|NO_VENT|NO_APC
	)
