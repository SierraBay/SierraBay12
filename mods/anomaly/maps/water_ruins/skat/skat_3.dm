/datum/map_template/ruin/exoplanet/drowned_skat_third_deck
	name = "drowned SKAT"
	id = "planetsite_anomalies_flying_home"
	description = "anomalies lol"
	mappaths = list('mods/anomaly/maps/water_ruins/skat/skat-3.dmm')
	spawn_cost = 100000
	apc_test_exempt_areas = list(
		/area/map_template/anomaly/skat_third_deck = NO_SCRUBBER|NO_VENT|NO_APC
	)
	ruin_tags = RUIN_CHUDO_ANOMALIES
	skip_main_unit_tests = TRUE

/area/map_template/anomaly/skat_third_deck
	name = "\improper SKAT third deck"
	icon_state = "A"
	turfs_airless = TRUE
