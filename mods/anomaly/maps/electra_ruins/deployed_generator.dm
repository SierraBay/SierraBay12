/datum/map_template/ruin/exoplanet/electra_generator
	name = "deployed_generator"
	id = "planetsite_anomalies_generator"
	description = "anomalies lol."
	mappaths = list('mods/anomaly/maps/electra_ruins/deployed_generator.dmm')
	spawn_cost = 1
	ruin_tags = RUIN_ELECTRA_ANOMALIES
	apc_test_exempt_areas = list(
		/area/map_template/deployed_generator = NO_SCRUBBER|NO_VENT|NO_APC
	)


/area/map_template/deployed_generator
	name = "\improper Deployed science generator"
	icon_state = "A"
