/obj/overmap/visitable/sector/exoplanet/water
	name = "water planet"
	desc = "Планета покрытая толстым слоем воды."
	color = "#ebe3e3"
	rock_colors = list(COLOR_WHITE)
	//Большие артефакты
	big_anomaly_artefacts_min_amount = 4
	big_anomaly_artefacts_max_amount = 6
	big_artefacts_types = list()
	big_artefacts_can_be_close = FALSE
	weather_manager_type = /datum/weather_manager/titan_rain
	big_artefacts_range_spawn = 30
	//
	possible_themes = list(
		/datum/exoplanet_theme = 100
		)
	planetary_area = /area/exoplanet/water
	map_generators = list(/datum/random_map/automata/cave_system/mountains/water, /datum/random_map/noise/exoplanet/titan_water)
	surface_color = "#0d0844"
	water_color = "#0d0844"
	daycycle_range = list(5 HOURS, 5 HOURS)
	sun_process_interval = 10 HOURS
	//Вечный день
	sun_position = 1
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_HOT_ANOMALIES|RUIN_ELECTRA_ANOMALIES|RUIN_GRAVI_ANOMALIES
	ruin_tags_whitelist = RUIN_CHUDO_ANOMALIES
	habitability_weight = HABITABILITY_EXTREME
	has_trees = FALSE
	flora_diversity = 0
	//ANOM
	can_spawn_anomalies = TRUE
	anomalies_types = list(
		/obj/anomaly/labirint = 7,
		/obj/anomaly/doubled_teleporter/with_second = 5,
		/obj/anomaly/doubled_teleporter/with_second/oneway = 5,
		/obj/anomaly/doubled_teleporter/with_second/changing = 4,
		/obj/anomaly/vspishka = 3
		)
	///Минимальное количество заспавненных артов
	min_artefacts_ammount = 1
	///Максимальное количество заспавненных артов
	max_artefacts_ammount = 2

	min_anomalies_ammout = 500
	max_anomalies_ammout = 700

/obj/overmap/visitable/sector/exoplanet/water/build_level()
	. = ..()
	update_sun()

/datum/random_map/noise/exoplanet/titan_water
	descriptor = "ice exoplanet"
	smoothing_iterations = 5
	land_type = /turf/simulated/floor/exoplanet/titan_water/minimal
	water_type = /turf/simulated/floor/exoplanet/titan_water/minimal
	water_level_min = 5
	water_level_max = 6
	fauna_prob = 0
	flora_prob = 0
	large_flora_prob = 0

/datum/random_map/automata/cave_system/mountains/water
	iterations = 6
	descriptor = "water"
	wall_type =  /turf/simulated/floor/exoplanet/titan_water/middle
	mineral_turf =  /turf/simulated/floor/exoplanet/titan_water/middle
	rock_color = COLOR_BLUE

/obj/overmap/visitable/sector/exoplanet/water/generate_atmosphere()
	atmosphere = new
	atmosphere.temperature = rand(290, 330)
	atmosphere.update_values()
	var/good_gas = list(GAS_OXYGEN = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)
	atmosphere.gas = good_gas


/area/exoplanet/water
	ambience = list('sound/effects/wind/tundra0.ogg', 'mods/anomaly/sounds/gravi_planet_wind_1.ogg')
	base_turf = /turf/simulated/floor/exoplanet/titan_water/minimal
	can_have_awakening_event = FALSE

/obj/overmap/visitable/sector/exoplanet/water/update_sun()
	var/low_brightness = 2
	var/high_brightness = 2
	var/low_color = "#33ddff"
	var/high_color = "#33ddff"
	var/min = 0.70
	var/max = 1.0
	sun_position = 1

	var/interpolate_weight = (sun_position - min) / (max - min)
	var/new_brightness = (Interpolate(low_brightness, high_brightness, interpolate_weight) ) * sun_brightness_modifier
	var/new_color = UNLINT(gradient(low_color, high_color, space = COLORSPACE_HSV, index=interpolate_weight))

	if(ambient_group_index > 0)
		var/datum/ambient_group/A = SSambient_lighting.ambient_groups[ambient_group_index]
		A.set_color(new_color, new_brightness)
	else
		ambient_group_index = SSambient_lighting.create_ambient_group(new_color, new_brightness)
