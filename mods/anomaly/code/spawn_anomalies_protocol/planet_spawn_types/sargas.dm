/* Не доделан
/obj/overmap/visitable/sector/exoplanet/swamp
	name = "Sargassov swamp"
	desc = "Wild and mysterious planet, covered in vast swamplands and impenetrable swamps that provide both spectacular and dangerous terrain. Its unique ecosystem includes a variety of species of flora and fauna that have adapted to the conditions of such an environment."
	color = "#054515"
	rock_colors = list(COLOR_WHITE)
	can_spawn_anomalies = TRUE
	monitor_effect_type = /obj/monitor_effect_triger/swamp
	anomalies_type = list()
	min_anomaly_size = 4
	max_anomaly_size = 9
	min_anomalies_ammout = 250
	max_anomalies_ammout = 400
	planetary_area = /area/exoplanet/swamp
	map_generators = list(/datum/random_map/noise/exoplanet/swamp)
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_HOT_ANOMALIES
	surface_color = "#ffffff"
	water_color = "#263908"
	habitability_weight = HABITABILITY_EXTREME
	has_trees = FALSE
	flora_diversity = 0


/obj/overmap/visitable/sector/exoplanet/swamp/get_atmosphere_color()
	var/air_color = ..()
	return MixColors(COLOR_GRAY20, air_color)



/obj/overmap/visitable/sector/exoplanet/swamp/generate_atmosphere()
	..()
	var/generator/new_temp = generator("num", 250, 300, NORMAL_RAND)
	atmosphere.temperature = new_temp.Rand()
	atmosphere.update_values()


/datum/random_map/noise/exoplanet/swamp
	descriptor = "ice exoplanet"
	smoothing_iterations = 5
	land_type = /turf/simulated/floor/exoplanet/grass
	water_type = /turf/simulated/floor/exoplanet/swamp
	water_level_min = 5
	water_level_max = 6
	fauna_prob = 0
	flora_prob = 0
	large_flora_prob = 0


/area/exoplanet/swamp
	ambience = list('sound/effects/wind/tundra0.ogg','sound/effects/wind/tundra1.ogg','sound/effects/wind/tundra2.ogg','sound/effects/wind/spooky0.ogg','sound/effects/wind/spooky1.ogg')
	base_turf = /turf/simulated/floor/exoplanet/grass

/turf/simulated/floor/exoplanet/swamp
	name = "блядская вода"
	desc = "В ней немного тонешь, хуя"

/turf/simulated/floor/exoplanet/swamp/medium
	name = "Средняя вода"
	desc = "По пузо"

/turf/simulated/floor/exoplanet/swamp/deep
	name = "Глубокая вода"
	desc = "По горло"
*/
