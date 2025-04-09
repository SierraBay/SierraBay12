/datum/map_template/ruin/away_site/slavers
	name = "Slavers' Base"
	id = "awaysite_slavers"
	description = "Asteroid with slavers base inside."
	prefix = "mods/_maps/general_maps/maps/"
	spawn_cost = 1
	generate_mining_by_z = 1
	area_usage_test_exempted_root_areas = list(/area/slavers_base)
	apc_test_exempt_areas = list(
		/area/slavers_base/hangar = NO_SCRUBBER
	)
