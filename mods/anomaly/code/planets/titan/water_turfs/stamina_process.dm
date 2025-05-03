/turf/simulated/floor/exoplanet/titan_water/proc/start_spend_stamina()
	next_possible_process = 1 SECOND
	START_PROCESSING(SSanom, src)

/turf/simulated/floor/exoplanet/titan_water/proc/stop_spend_stamina()
	var/must_we_stop = FALSE
	for(var/mob/living/carbon/human/detected_human in src)
		must_we_stop = TRUE
		break
	if(must_we_stop)
		next_possible_process = null
		STOP_PROCESSING(SSanom, src)

//Глубокая вода затрачивает силы персонажа дабы оставаться на плаву
/turf/simulated/floor/exoplanet/titan_water/Process()
	var/should_continue_process = FALSE
	if(next_possible_process > world.time)
		return
	for(var/mob/living/carbon/human/detected_human in src)
		if(detected_human.lying)
			continue
		if(detected_human.species.name == SPECIES_SKRELL || detected_human.species.name == SPECIES_TRITONIAN || detected_human.species.name == SPECIES_YEOSA) //Скреллы и тритоны неуязвимы к затратам стамины от воды
			continue
		else
			should_continue_process = TRUE
			detected_human.adjust_stamina(-swim_stamina_spend)
			if(detected_human.stamina == 0) //Персонажик то выдохся
				drown_human(detected_human)
	for(var/obj/item/detected_item in src)
		should_continue_process = TRUE
		if(!detected_item.throwing && !detected_item.anchored && world.time - detected_item.inertia_next_move > 3 && detected_item.loc == src)
			drown_item(detected_item)
	if(!should_continue_process)
		STOP_PROCESSING(SSanom, src)
