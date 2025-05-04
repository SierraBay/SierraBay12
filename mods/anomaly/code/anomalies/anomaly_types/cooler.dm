/obj/anomaly/cooler
	name = "Refractions of light"
	anomaly_tag = "Cooler"
	with_sound = FALSE
	can_born_artefacts = TRUE
	//Длинна эффекта подогрева
	effect_time = 30 SECONDS
	effect_type = LONG_ANOMALY_EFFECT
	cooldown_time = 30 SECONDS
	iniciators = list(
		/mob/living
	)
	artefacts = list()
	chance_to_be_detected = 120
	time_between_effects = 0.5 SECOND
	var/list/all_spawned_visuals = list()

//Хитер начинает долгую обработку
/obj/anomaly/cooler/process_long_effect()
	heat_everybody_around()
	start_processing_long_effect()


/obj/anomaly/cooler/proc/heat_everybody_around()
	for(var/turf/turfs in anomaly_turfs)
		for(var/mob/living/victim in turfs)
			if(victim.bodytemperature > 200)
				victim.bodytemperature -= 30

/obj/anomaly/cooler/start_long_visual_effect()
	for(var/turf/T in anomaly_turfs)
		var/obj/spawned_effect = new /obj/effect/warp/cold_effect(T)
		LAZYADD(all_spawned_visuals, spawned_effect)

/obj/anomaly/cooler/stop_long_visual_effect()
	for(var/obj/effect in all_spawned_visuals)
		effect.Destroy()
	LAZYCLEARLIST(all_spawned_visuals)

/obj/effect/warp/cold_effect
	icon = 'mods/anomaly/icons/effects.dmi'
	icon_state = "colding"
	pixel_x = 0
	pixel_y = 0

/obj/anomaly/cooler/Crossed(atom/movable/O)
	if(currently_active)
		return
	if(currently_charging_after_activation)
		return
	if(can_be_activated(O))
		activate_anomaly()
	return
