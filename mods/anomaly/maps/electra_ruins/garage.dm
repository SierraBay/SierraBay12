/datum/map_template/ruin/exoplanet/electra_garage
	name = "garage"
	id = "planetsite_anomalies_garage"
	description = "anomalies lol."
	mappaths = list('mods/anomaly/maps/electra_ruins/garage.dmm')
	spawn_cost = 1
	ruin_tags = RUIN_ELECTRA_ANOMALIES
	apc_test_exempt_areas = list(
		/area/map_template/garage = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/map_template/garage/first_home = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/map_template/garage/second_home = NO_SCRUBBER|NO_VENT|NO_APC
	)

/area/map_template/garage
	name = "\improper Science garage"
	icon_state = "A"

/area/map_template/garage/first_home

/area/map_template/garage/second_home

/obj/forcefield/blocker
	invisibility = 101
