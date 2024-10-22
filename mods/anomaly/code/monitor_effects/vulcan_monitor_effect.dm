//Эффект вулкана
/obj/monitor_effect_triger/vulcan
	icon_state = "light_storm"
	icon = 'mods/anomaly/icons/weather_effects.dmi'
	invisibility = FALSE
/*
/obj/monitor_effect_triger/snow/add_monitor_effect(mob/living/input_mob)
	input_mob.overlay_fullscreen("snow_monitor", /obj/screen/fullscreen/snow_effect)
	if(!(input_mob in GLOB.messaged_by_snow))
		to_chat(input_mob, SPAN_BAD(pick(trigger_messages_list)))

/obj/monitor_effect_triger/snow/remove_monitor_effect(mob/living/input_mob)
	input_mob.clear_fullscreen("snow_monitor")
*/
