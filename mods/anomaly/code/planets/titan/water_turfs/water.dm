/turf/simulated/floor/exoplanet/titan_water
	name = "low water"
	icon = 'mods/anomaly/icons/titan_water.dmi'
	icon_state = "middle_deep_water"
	//Игра выберет какое-то одно изображение для водички из листа спрайтов
	var/list/possible_icons = list()
	var/deep_status = NO_DEEP
	var/mask_icon_state
	var/mask_icon_state_item = "middle_deep_item"
	var/swim_stamina_spend
	var/next_possible_process
	var/effect_to_drowning = DEEQUIP

/turf/simulated/floor/exoplanet/titan_water/minimal
	name = "low water"
	deep_status = MIN_DEEP
	mask_icon_state = "min_deep"
	icon_state = "min_deep_water1"
	possible_icons = list("min_deep_water1", "min_deep_water2", "min_deep_water3", "min_deep_water4")
	footstep_type = /singleton/footsteps/min_water
	movement_delay = 3

/singleton/footsteps/min_water
	footstep_sounds = list(
		'mods/anomaly/sounds/water/minimal/water_move1.ogg',
		'mods/anomaly/sounds/water/minimal/water_move2.ogg',
		'mods/anomaly/sounds/water/minimal/water_move3.ogg',
		'mods/anomaly/sounds/water/minimal/water_move5.ogg',
		'mods/anomaly/sounds/water/minimal/water_move6.ogg')

/turf/simulated/floor/exoplanet/titan_water/middle
	name = "middle water"
	deep_status = MIDDLE_DEEP
	mask_icon_state = "middle_deep"
	icon_state = "middle_deep_water1"
	possible_icons = list("middle_deep_water1", "middle_deep_water2", "middle_deep_water3", "middle_deep_water4")
	footstep_type = /singleton/footsteps/mid_water
	movement_delay = 6

/singleton/footsteps/mid_water
	footstep_sounds = list(
		'mods/anomaly/sounds/water/mid/move_vater_mid1.ogg',
		'mods/anomaly/sounds/water/mid/move_vater_mid2.ogg',
		'mods/anomaly/sounds/water/mid/move_vater_mid3.ogg')

/turf/simulated/floor/exoplanet/titan_water/maximum
	name = "deep water"
	deep_status = MAX_DEEP
	mask_icon_state = "max_deep"
	icon_state = "max_deep_water1"
	possible_icons = list("max_deep_water1", "max_deep_water2", "max_deep_water3", "max_deep_water4")
	footstep_type = /singleton/footsteps/max_water
	swim_stamina_spend = 3
	movement_delay = 10

/singleton/footsteps/max_water
	footstep_sounds = list('mods/anomaly/sounds/water/max/water_move7.ogg')

/turf/simulated/floor/exoplanet/titan_water/Initialize()
	.=..()
	set_icons()

/turf/simulated/floor/exoplanet/titan_water/post_change()
	.=..()
	set_icons()

/turf/simulated/floor/exoplanet/titan_water/proc/set_icons()
	if(LAZYLEN(possible_icons))
		icon_state = pick(possible_icons)


/turf/simulated/floor/exoplanet/titan_water/use_tool(obj/item/O, mob/living/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	return

/turf/simulated/floor/exoplanet/titan_water/proc/get_better()
	return

//get_better
/turf/simulated/floor/exoplanet/titan_water/minimal/get_better()
	ChangeTurf(/turf/simulated/floor/exoplanet/titan_water/middle)

/*
/turf/simulated/floor/exoplanet/titan_water/middle/get_better()
	ChangeTurf(/turf/simulated/floor/exoplanet/titan_water/maximum)
*/

//get_worst
/turf/simulated/floor/exoplanet/titan_water/proc/get_worst()
	ChangeTurf(/turf/simulated/floor/exoplanet/titan_water/minimal)
