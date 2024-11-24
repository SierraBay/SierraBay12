//В случае если нам нужно чтоб аномалия сперва зарядилась перед тем как воздействовать - этот код для нас
/obj/anomaly
	var/preload_effect_type
	var/preload_time

/obj/anomaly/proc/start_preload()
	start_preload_visual_effect()
	playsound(src, preload_sound_type, 100, FALSE  )
	sleep(cooldown_time)
	stop_preload_visual_effect()

/obj/anomaly/proc/start_preload_visual_effect()
	if(preload_effect_type)
		invisibility = 0
		icon_state = preload_effect_type
		if(light_after_activation)
			start_light()

/obj/anomaly/proc/stop_preload_visual_effect()
	invisibility = INVISIBILITY_OBSERVER
	icon_state = idle_effect_type
