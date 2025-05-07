/datum/planet_storyteller
	///Активен ли вообще рассказчик? Активируется когда кого-то находится на наших Z уровнях
	var/is_active = FALSE
	///КД проверки активности
	var/delay_activity_check = 3 MINUTES
	///Следущее время проверки активности
	var/next_activity_check
	var/generation_cooldown = 1 MINUTES
	var/next_point_generation


/datum/planet_storyteller/proc/calculate_activity_check()
	next_activity_check = world.time + delay_activity_check

/datum/planet_storyteller/proc/check_activity()
	//Рановато
	if(world.time < next_activity_check)
		if(is_active)
			return TRUE
		else
			return FALSE
	calculate_activity_check() //Мы тут - значит посчитаем время до некст проверки активности
	var/detected_somebody = FALSE
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) in my_z)
			detected_somebody = TRUE
			break
	if(!detected_somebody && is_active)
		go_sleep()
		return FALSE
	else if(detected_somebody && !is_active)
		wake_up()
		return TRUE
	else if(!detected_somebody && !is_active)
		return FALSE
	else if(detected_somebody && is_active)
		return TRUE

//Сторителлер засыпает
/datum/planet_storyteller/proc/go_sleep()
	is_active = FALSE
	log_in_general("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик больше никого не обнаружил на планете и заснул.")

/datum/planet_storyteller/proc/wake_up()
	is_active = TRUE
	log_in_general("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик кого-то обнаружил на своём Z уровне и пробудился")
	calculate_points_generation_time()
	calculate_action_time()

/datum/planet_storyteller/proc/calculate_points_generation_time()
	next_point_generation = world.time + generation_cooldown

/datum/planet_storyteller/Process()
	///Рассказчик спит, не тревожим
	if(!check_activity())
		return
	check_points_generating() //Может, рассказчику пора получить очки от генерации?
	check_action() //Может, рассказчику пора действовать?
