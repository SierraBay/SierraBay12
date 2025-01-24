/obj/overmap/visitable/sector/exoplanet/flying
	name = "flying exoplanet"
	desc = "A cluster of floating islands moving around an unknown object. WARNING: large gravity-anomalous activity detected. Extreme caution is required."
	color = "#ebe3e3"
	rock_colors = list(COLOR_WHITE)
	//Большие артефакты
	big_anomaly_artefacts_min_amount = 2
	big_anomaly_artefacts_max_amount = 4
	big_artefacts_types = list(
		/obj/structure/big_artefact/gravi
		)
	big_artefacts_can_be_close = FALSE
	big_artefacts_range_spawn = 30
	//
	possible_themes = list(
		/datum/exoplanet_theme = 100
		)
	planetary_area = /area/exoplanet/flying
	map_generators = list(/datum/random_map/automata/cave_system/mountains/flying, /datum/random_map/noise/exoplanet/flying)
	surface_color = "#11420c"
	water_color = "#ffffff"
	daycycle_range = list(5 HOURS, 5 HOURS)
	sun_process_interval = 10 HOURS
	//Вечный день
	sun_position = 1
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_HOT_ANOMALIES|RUIN_ELECTRA_ANOMALIES
	ruin_tags_whitelist = RUIN_GRAVI_ANOMALIES
	habitability_weight = HABITABILITY_EXTREME
	has_trees = FALSE
	flora_diversity = 5


/obj/overmap/visitable/sector/exoplanet/flying/build_level()
	.=..()
	//Рисуем задник
	var/turf/any_turf
	for(var/turf/turfs in planetary_area)
		any_turf = turfs
		break
	var/planet_z = get_z(any_turf)
	var/datum/event/change_z_skybox = new /datum/event/change_z_skybox(new /datum/event_meta(EVENT_LEVEL_MAJOR))
	change_z_skybox.affecting_z = list(planet_z)
	change_z_skybox.setup('mods/anomaly/icons/planet_backgrounds.dmi', "mods/anomaly/sounds/gravi_planet_wind_1.ogg")
	SSskybox.generate_skybox(planet_z)
	update_sun()

/obj/overmap/visitable/sector/exoplanet/flying/get_atmosphere_color()
	var/air_color = ..()
	return MixColors(COLOR_GRAY20, air_color)


/obj/overmap/visitable/sector/exoplanet/flying/generate_atmosphere()
	atmosphere = new
	atmosphere.temperature = rand(290, 330)
	atmosphere.update_values()
	var/good_gas = list(GAS_OXYGEN = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)
	atmosphere.gas = good_gas


/datum/random_map/noise/exoplanet/flying
	descriptor = "flying islands"
	smoothing_iterations = 5
	land_type = /turf/simulated/floor/exoplanet/clouds
	//Указываем облака так же и водой, чтоб трава не могла спавнить на них флору и травушку
	fauna_prob = 0
	flora_prob = 0
	grass_prob = 0

/datum/random_map/automata/cave_system/mountains/flying
	descriptor = "flying islands"
	wall_type =  /turf/simulated/floor/exoplanet/grass
	mineral_turf =  /turf/simulated/floor/exoplanet/grass

/area/exoplanet/flying
	ambience = list('sound/effects/wind/tundra0.ogg','mods/anomaly/sounds/gravi_planet_wind_1.ogg')
	base_turf = /turf/simulated/floor/exoplanet/clouds





/obj/overmap/visitable/sector/exoplanet/flying/update_sun()
	var/low_brightness = 2
	var/high_brightness = 2
	var/low_color = "#ff9933"
	var/high_color = "#ff9933"
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
