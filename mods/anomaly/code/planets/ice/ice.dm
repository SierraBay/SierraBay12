/obj/overmap/visitable/sector/exoplanet/ice
	name = "ice exoplanet"
	desc = "A distant, abandoned and cold world, rich in artefacts and anomalous activity. WARNING: large electro-anomalous activity detected. Extreme caution is required."
	color = "#ebe3e3"
	rock_colors = list(COLOR_WHITE)
	//Большие артефакты
	big_anomaly_artefacts_min_amount = 2
	big_anomaly_artefacts_max_amount = 4
	big_artefacts_types = list(
		/obj/structure/big_artefact/electra
		)
	big_artefacts_can_be_close = FALSE
	big_artefacts_range_spawn = 30
	weather_manager_type = /datum/weather_manager/snow
	//
	possible_themes = list(
		/datum/exoplanet_theme = 45,
		/datum/exoplanet_theme/radiation_bombing = 10
		)
	planetary_area = /area/exoplanet/ice
	map_generators = list(/datum/random_map/automata/cave_system/mountains/ice, /datum/random_map/noise/exoplanet/ice)
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_HOT_ANOMALIES|RUIN_GRAVI_ANOMALIES|RUIN_CHUDO_ANOMALIES
	ruin_tags_whitelist = RUIN_ELECTRA_ANOMALIES
	surface_color = "#ffffff"
	water_color = "#0700c7"
	habitability_weight = HABITABILITY_EXTREME
	has_trees = FALSE
	flora_diversity = 0

/obj/overmap/visitable/sector/exoplanet/ice/generate_atmosphere()
	atmosphere = new
	atmosphere.temperature = rand(50, 150)
	atmosphere.update_values()
	var/good_gas = list(GAS_OXYGEN = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)
	atmosphere.gas = good_gas

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
	icon = 'mods/anomaly/icons/clouds.dmi'
	color = COLOR_WHITE
	blocks_air = FALSE
	initial_gas = list(GAS_OXYGEN = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)

/turf/simulated/mineral/random/ice
	name = "Ice wall"
	icon_state = "ice_wall"
	icon = 'mods/anomaly/icons/clouds.dmi'
	color = COLOR_WHITE

/obj/overmap/visitable/sector/exoplanet/ice/generate_map()
	..()
	//После создания карты, разместим камушки
	var/list/list_of_turfs =  get_area_turfs(planetary_area)
	//Соберём все подходящие для нас турфы льда
	for(var/turf/picked_turf in list_of_turfs)
		if(density)
			LAZYREMOVE(list_of_turfs, picked_turf)
		else if(!istype(picked_turf, /turf/simulated/floor/exoplanet/ice/ice_planet))
			LAZYREMOVE(list_of_turfs, picked_turf)
	var/ice_block_ammout = rand(500, 1000)
	//Спавним камушки на льду
	while(ice_block_ammout > 0)
		var/turf/current_turf = pick(list_of_turfs)
		new /obj/structure/ice_rock(current_turf)
		LAZYREMOVE(list_of_turfs, current_turf)
		if(!LAZYLEN(list_of_turfs))
			ice_block_ammout = 0
		ice_block_ammout--


/obj/overmap/visitable/sector/exoplanet/ice/generate_atmosphere()
	..()
	atmosphere.temperature = rand(70, 150)
	atmosphere.update_values()


/datum/random_map/noise/exoplanet/ice
	descriptor = "ice exoplanet"
	smoothing_iterations = 5
	land_type = /turf/simulated/floor/exoplanet/ice/ice_planet
	water_type = /turf/simulated/floor/exoplanet/ice/ice_planet
	water_level_min = 5
	water_level_max = 6
	fauna_prob = 0
	flora_prob = 0
	large_flora_prob = 0


/area/exoplanet/ice
	ambience = list('sound/effects/wind/tundra0.ogg','sound/effects/wind/tundra1.ogg','mods/anomaly/sounds/electra_planet_wind_2.ogg')
	base_turf = /turf/simulated/floor/exoplanet/ice/ice_planet
	can_have_awakening_event = FALSE

/turf/simulated/floor/exoplanet/ice/ice_planet

/turf/simulated/floor/exoplanet/ice/ice_planet/use_tool(obj/item/C, mob/living/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	return


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

/turf/simulated/mineral/ice/Bumped(AM)
	return

//Большие ледяные камни, красиво
/obj/structure/ice_rock
	name = "ice rock"
	desc = "A large block of ice, the edges of which can easily cut you. "
	icon = 'mods/anomaly/icons/icerocks.dmi'
	icon_state = "rock_1"
	anchored = TRUE
	density = TRUE
	var/icon_state_list = list("rock_1", "rock_2", "rock_3")

/obj/structure/ice_rock/Initialize()
	.=..()
	icon_state = pick(icon_state_list)
