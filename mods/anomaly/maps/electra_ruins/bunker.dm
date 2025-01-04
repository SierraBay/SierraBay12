/datum/map_template/ruin/exoplanet/electra_bunker
	name = "science bunker"
	id = "planetsite_anomalies_bunker"
	description = "anomalies lol."
	mappaths = list('mods/anomaly/maps/electra_ruins/bunker.dmm')
	spawn_cost = 1
	ruin_tags = RUIN_ELECTRA_ANOMALIES
	apc_test_exempt_areas = list(
		/area/map_template/bunker = NO_SCRUBBER|NO_VENT|NO_APC
	)

/area/map_template/bunker
	name = "\improper Science bunker"
	icon_state = "A"
