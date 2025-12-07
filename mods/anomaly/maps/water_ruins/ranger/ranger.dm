/datum/map_template/ruin/exoplanet/ranger
	name = "drowned ranger"
	id = "planetsite_anomalies_ranger"
	description = "anomalies lol"
	mappaths = list('mods/anomaly/maps/water_ruins/ranger/ranger.dmm')
	spawn_cost = 1
	ruin_tags = RUIN_CHUDO_ANOMALIES
	skip_main_unit_tests = TRUE

/turf/simulated/wall/r_wall/hull/titan_no_opacity/Initialize()
	. = ..()
	opacity = FALSE
