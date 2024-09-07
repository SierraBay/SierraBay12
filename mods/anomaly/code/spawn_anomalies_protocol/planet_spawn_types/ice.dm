/obj/overmap/visitable/sector/exoplanet/ice
	name = "ice exoplanet"
	desc = "A distant, abandoned and cold world, rich in artifacts and anomalous activity."
	color = "#ebe3e3"
	rock_colors = list(COLOR_WHITE)
	can_spawn_anomalies = TRUE
	anomalies_type = list(
		/obj/anomaly/electra/three_and_three = 5,
		/obj/anomaly/electra/three_and_three/tesla = 2,
		/obj/anomaly/electra/three_and_three/tesla_second = 1,
		/obj/anomaly/cooler/two_and_two = 3,
		/obj/anomaly/cooler/three_and_three = 3
		)
	min_anomaly_size = 4
	max_anomaly_size = 9
	min_anomalies_ammout = 250
	max_anomalies_ammout = 400
	planetary_area = /area/exoplanet/ice
	map_generators = list(/datum/random_map/automata/cave_system/mountains/ice, /datum/random_map/noise/exoplanet/ice)
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_HOT_ANOMALIES
	surface_color = "#ffffff"
	water_color = "#0700c7"
	habitability_weight = HABITABILITY_EXTREME
	has_trees = FALSE
	flora_diversity = 0


/obj/overmap/visitable/sector/exoplanet/ice/get_atmosphere_color()
	var/air_color = ..()
	return MixColors(COLOR_GRAY20, air_color)

/datum/random_map/automata/cave_system/mountains/ice
	iterations = 2
	descriptor = "space ice rocks"
	wall_type =  /turf/simulated/mineral/ice
	mineral_turf =  /turf/simulated/mineral/ice
	rock_color = COLOR_WHITE

/turf/simulated/mineral/ice
	name = "Ice wall"
	icon_state = "ice_wall"
	icon = 'mods/anomaly/icons/planets.dmi'
	color = COLOR_WHITE

/turf/simulated/mineral/random/ice
	name = "Ice wall"
	icon_state = "ice_wall"
	icon = 'mods/anomaly/icons/planets.dmi'
	color = COLOR_WHITE

/obj/overmap/visitable/sector/exoplanet/ice/generate_atmosphere()
	..()
	var/datum/species/H = all_species[SPECIES_HUMAN]
	var/generator/new_temp = generator("num", H.cold_level_1 - 50, H.cold_level_3, NORMAL_RAND)
	atmosphere.temperature = new_temp.Rand()
	atmosphere.update_values()


/datum/random_map/noise/exoplanet/ice
	descriptor = "ice exoplanet"
	smoothing_iterations = 5
	land_type = /turf/simulated/floor/exoplanet/ice
	water_type = /turf/simulated/floor/exoplanet/ice
	water_level_min = 5
	water_level_max = 6
	fauna_prob = 0
	flora_prob = 0
	large_flora_prob = 0


/area/exoplanet/ice
	ambience = list('sound/effects/wind/tundra0.ogg','sound/effects/wind/tundra1.ogg','sound/effects/wind/tundra2.ogg','sound/effects/wind/spooky0.ogg','sound/effects/wind/spooky1.ogg')
	base_turf = /turf/simulated/floor/exoplanet/ice



//ICE ROCK


/turf/simulated/mineral/ice/on_update_icon(update_neighbors)
	if(!istype(mineral))
		SetName(initial(name))
		icon_state = "ice_wall"
	else
		SetName("[mineral.ore_name] deposit")

	ClearOverlays()

	for(var/direction in GLOB.cardinal)
		var/turf/turf_to_check = get_step(src,direction)
		if(update_neighbors && istype(turf_to_check,/turf/simulated/floor/asteroid))
			var/turf/simulated/floor/asteroid/T = turf_to_check
			T.updateMineralOverlays()
		else if(istype(turf_to_check,/turf/space) || istype(turf_to_check,/turf/simulated/floor))
			var/image/rock_side = image(icon, "ice_side", dir = turn(direction, 180))
			rock_side.turf_decal_layerise()
			switch(direction)
				if(NORTH)
					rock_side.pixel_y += world.icon_size
				if(SOUTH)
					rock_side.pixel_y -= world.icon_size
				if(EAST)
					rock_side.pixel_x += world.icon_size
				if(WEST)
					rock_side.pixel_x -= world.icon_size
			AddOverlays(rock_side)

	if(ore_overlay)
		AddOverlays(ore_overlay)

	if(excav_overlay)
		AddOverlays(excav_overlay)

	if(archaeo_overlay)
		AddOverlays(archaeo_overlay)
