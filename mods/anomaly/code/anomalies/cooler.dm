/obj/anomaly/cooler
	name = "Refractions of light"
	with_sound = FALSE
	can_born_artifacts = TRUE
	//Длинна эффекта подогрева
	effect_time = 30 SECONDS
	effect_type = LONG_ANOMALY_EFFECT
	cooldown_time = 30 SECONDS
	iniciators = list(
		/mob/living
	)
	artefacts = list()
	/*
	min_artefact_spawn_chance = 1
	max_spawn_chance = 5
	*/
	chance_to_be_detected = 120
	time_between_effects = 0.5 SECOND


/obj/anomaly/cooler/Initialize()
	. = ..()
	for(var/obj/anomaly/part/choosed_part in list_of_parts)
		LAZYADD(effected_turfs, get_turf(choosed_part))
	LAZYADD(effected_turfs, get_turf(src))


//Хитер начинает долгую обработку
/obj/anomaly/cooler/process_long_effect()
	heat_everybody_around()
	start_processing_long_effect()


/obj/anomaly/cooler/proc/heat_everybody_around()
	for(var/turf/turfs in effected_turfs)
		for(var/mob/living/victim in turfs)
			victim.bodytemperature -= 2


/obj/anomaly/cooler/Crossed(atom/movable/O)
	if(currently_active)
		return
	if(currently_charging_after_activation)
		return
	if(can_be_activated(O))
		activate_anomaly()
	return
