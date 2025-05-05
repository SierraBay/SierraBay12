/mob/observer/alive_planet
	icon = 'mods/anomaly/icons/alive_planet.dmi'
	icon_state = "ghost_icon"
	var/datum/planet_storyteller/connected_storyteller

/mob/observer/alive_planet/Initialize(mapload)
	. = ..()
	setup_hud()

/mob/observer/alive_planet/proc/connect_player(mob/input_mob)
	ckey = input_mob.ckey
	setup_hud_on_screen()

/mob/observer/alive_planet/OnMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params)
	if(ismob(over_object))
		var/mob/mobik = over_object
		connect_player(mobik)
