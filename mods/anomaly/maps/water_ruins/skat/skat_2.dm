/datum/map_template/ruin/exoplanet/drowned_skat_underwater
	name = "drowned SKAT"
	id = "planetsite_anomalies_flying_home"
	description = "anomalies lol"
	mappaths = list('mods/anomaly/maps/water_ruins/skat/skat-2.dmm')
	spawn_cost = 100000
	apc_test_exempt_areas = list(
		/area/map_template/skat_underwater = NO_SCRUBBER|NO_VENT|NO_APC
	)
	ruin_tags = RUIN_CHUDO_ANOMALIES

/area/map_template/skat_underwater
	name = "\improper Drowned ship underwater"
	icon_state = "A"
	turfs_airless = TRUE

/obj/fluid/deep
	fluid_amount = 10000
