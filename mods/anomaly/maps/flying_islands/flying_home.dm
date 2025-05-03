/datum/map_template/ruin/exoplanet/gravi_flying_home
	name = "flying_home"
	id = "planetsite_anomalies_flying_home"
	description = "anomalies lol"
	mappaths = list('mods/anomaly/maps/flying_islands/flying_home.dmm')
	spawn_cost = 1
	ruin_tags = RUIN_GRAVI_ANOMALIES
	apc_test_exempt_areas = list(
		/area/map_template/anomaly/flying_home = NO_SCRUBBER|NO_VENT|NO_APC
	)
	skip_main_unit_tests = TRUE


/area/map_template/anomaly/flying_home
	name = "\improper Flying home"
	icon_state = "A"
	has_gravity = 0
