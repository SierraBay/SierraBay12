///Функция вычислит жертву для своего действия и выведет его турф
/datum/planet_storyteller/proc/calculate_victim_for_action()
	if(!my_z || !LAZYLEN(my_z))
		log_problem("В [time2text(world.realtime,"hh:mm:ss")] У рассказчика оказался пустым список z уровней.")
		CRASH("В [time2text(world.realtime,"hh:mm:ss")] У рассказчика оказался пустым список z уровней.")
	var/list/possible_victims = list()
	for(var/z in my_z) //Все Z уровни
		for(var/mob/living/carbon/human/human in GLOB.living_players)
			if(get_z(human) == z)
				LAZYADD(possible_victims, human)
	if(!LAZYLEN(possible_victims))
		log_problem("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик не смог расчитать жертву, введёные Z уровни оказались без игроков.")
		CRASH("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик не смог расчитать жертву, введёные Z уровни оказались без игроков.")
	else
		var/turf/result_turf = get_turf(pick(possible_victims))
		return result_turf
