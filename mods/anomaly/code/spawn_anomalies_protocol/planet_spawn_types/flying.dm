/*
Вне ротации
/obj/overmap/visitable/sector/exoplanet/flying
	name = "flying exoplanet"
	desc = "Flying around a certain center of the island."
	color = "#ebe3e3"
	rock_colors = list(COLOR_WHITE)
	can_spawn_anomalies = TRUE
	anomalies_type = list(
		)
	min_anomaly_size = 1
	max_anomaly_size = 9
	min_anomalies_ammout = 40
	max_anomalies_ammout = 100
	planetary_area = /area/exoplanet/flying
	map_generators = list(/datum/random_map/noise/exoplanet/flying)
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_HOT_ANOMALIES
	surface_color = "#a46610"
	water_color = "#ffffff"
	habitability_weight = HABITABILITY_EXTREME
	has_trees = FALSE
	flora_diversity = 0


/obj/overmap/visitable/sector/exoplanet/flying/get_atmosphere_color()
	var/air_color = ..()
	return MixColors(COLOR_GRAY20, air_color)


/obj/overmap/visitable/sector/exoplanet/flying/generate_atmosphere()
	..()
	var/datum/species/H = all_species[SPECIES_HUMAN]
	var/generator/new_temp = generator("num", H.cold_level_1 - 50, H.cold_level_3, NORMAL_RAND)
	atmosphere.temperature = new_temp.Rand()
	atmosphere.update_values()


/datum/random_map/noise/exoplanet/flying
	descriptor = "ice exoplanet"
	smoothing_iterations = 5
	land_type = /turf/simulated/floor/exoplanet/flying_rocks
	water_type = /turf/simulated/floor/exoplanet/clouds
	water_level_min = 5
	water_level_max = 6
	fauna_prob = 0
	flora_prob = 0
	large_flora_prob = 0


/area/exoplanet/flying
	ambience = list('sound/effects/wind/tundra0.ogg','sound/effects/wind/tundra1.ogg','sound/effects/wind/tundra2.ogg','sound/effects/wind/spooky0.ogg','sound/effects/wind/spooky1.ogg')
	base_turf = /turf/simulated/floor/exoplanet/flying_rocks


//Облачка
/turf/simulated/floor/exoplanet/clouds
	name = "clouds"
	icon_state = "clouds"
	icon = 'mods/anomaly/icons/planets.dmi'
	color = COLOR_WHITE
	//TRUE - облака раскрыты (видно что внизу), FALSE - не видно
	var/opened = FALSE
	//Обрабатывает раскрытие
	var/started_openning = FALSE

/turf/simulated/floor/exoplanet/clouds/Entered(atom/movable/AM)
	..()
	if(!opened && started_openning)
		return
	if(!opened && !started_openning)
		open_clouds()
		return
	else if(opened)
		check_clouds_turf(AM)

/turf/simulated/floor/exoplanet/clouds/proc/open_clouds()
	flick("clouds_open", src)
	icon_state = "clouds_clean"
	opened = TRUE
	addtimer(new Callback(src, PROC_REF(close_clouds)), 10 SECONDS)

/turf/simulated/floor/exoplanet/clouds/proc/close_clouds()
	flick("clouds_closed", src)
	icon_state = "clouds"
	opened = FALSE

/turf/simulated/floor/exoplanet/clouds/proc/check_clouds_turf(atom/movable/AM)
	if(!AM)
		for(var/atom/target in src)
			visible_message("[target] со свистом улетает вниз", null, 7)
			qdel(target)

//Пол каменный
/turf/simulated/floor/exoplanet/flying_rocks
	name = "flying_rock"
	icon_state = "flying_rock"
	icon = 'mods/anomaly/icons/flying_floor.dmi'
	color = COLOR_BROWN
*/
