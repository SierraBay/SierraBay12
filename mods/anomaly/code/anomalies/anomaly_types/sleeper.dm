//Усыпляющая всех кто в неё войдёт
/obj/anomaly/sleeper
	name = "Absolutly nothing"
	anomaly_tag = "Sleeper"
	idle_effect_type = "sleeper_idle"
	with_sound = FALSE
	effect_type = MOMENTUM_ANOMALY_EFFECT
	cooldown_time = 3 MINUTES
	multitile = TRUE
	min_x_size = 2
	max_x_size = 10
	min_y_size = 2
	max_y_size = 10
	iniciators = list(
		/mob/living
	)
	artefacts = list()
	chance_to_be_detected = 100

/obj/anomaly/sleeper/activate_anomaly()
	for(var/turf/T in anomaly_turfs)
		for(var/mob/living/carbon/detected_living in T)
			get_effect_by_anomaly(detected_living)

/obj/anomaly/sleeper/get_effect_by_anomaly(mob/living/carbon/detected_living)
	detected_living.SetStasis(10)
