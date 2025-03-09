/datum/map_template/ruin/away_site/mining_signal
	name = "Mining - Dwarf Planet"
	id = "awaysite_mining_signal"
	description = "A mineral-rich, formerly-volcanic site on a dwarf planet."
	prefix = "mods/_maps/general_maps/maps/"
	spawn_cost = 1
	generate_mining_by_z = 1
	base_turf_for_zs = /turf/simulated/floor/asteroid
	area_usage_test_exempted_root_areas = list(/area/mine, /area/outpost)
	apc_test_exempt_areas = list(
		/area/mine/explored = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/mine/unexplored = NO_SCRUBBER|NO_VENT|NO_APC
	)
	area_coherency_test_exempt_areas =  list(/area/mine/explored, /area/mine/unexplored)
