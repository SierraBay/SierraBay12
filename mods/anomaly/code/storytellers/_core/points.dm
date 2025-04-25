/datum/planet_storyteller
	/// Очки для перехода между стадиями
	var/current_evolution_points = 0
	/// Очки для размещения аномалий
	var/current_anomaly_points = 0
	/// Очки для размещения мобов
	var/current_mob_points = 0
	/// Очки для обманных тактик
	var/current_scam_points = 0



/datum/planet_storyteller/proc/check_points_generating()
	if(world.time < next_point_generation) //Рановато для новой генерации
		return FALSE
	generate_points()
	calculate_points_generation_time()

//ЭК сделало что-то за что можно и получить очки рассказчику
/datum/planet_storyteller/proc/add_points(evolution, mob, anomaly, scam, source)
	if(evolution)
		current_evolution_points += evolution
		check_level_up()
	if(mob)
		current_mob_points += mob
	if(anomaly)
		current_anomaly_points += anomaly
	if(scam)
		current_scam_points += scam

/datum/planet_storyteller/proc/can_storyteller_afford_ability(ability_type)
	var/datum/storyteller_ability/ability_prototype = ability_type
	var/price = initial(ability_prototype.point_price)
	var/point_type = initial(ability_prototype.point_type)
	//Если количество поинтов у сторителлера больше чем цена, то позволить он может себе данную способность
	switch(point_type)
		if("scam")
			return current_scam_points > price
		if("anomaly")
			return current_anomaly_points > price
		if("mob")
			return current_mob_points > price

/datum/planet_storyteller/proc/spend_points_for_ability(ability_type)
	var/datum/storyteller_ability/ability_prototype = ability_type
	var/price = initial(ability_prototype.point_price)
	var/point_type = initial(ability_prototype.point_type)
	log_point_spend(initial(ability_prototype.ability_name), price, point_type)
	switch(point_type)
		if("scam")
			current_scam_points -= price
		if("anomaly")
			current_anomaly_points -= price
		if("mob")
			current_mob_points -= price

/// Генерирует очки в соответствии с текущим уровнем
/datum/planet_storyteller/proc/generate_points()
	var/level_data = rage_levels[current_angry_level]
	if(!level_data)
		CRASH("Отсутствуют данные для текущего уровня [current_angry_level]")

	// Генерация очков
	current_evolution_points += level_data["evolution_points"]
	log_point_getting(level_data["evolution_points"], "Эволюционные", "Генерация")

	current_scam_points += level_data["scam_points"]
	log_point_getting(level_data["scam_points"], "Обманные", "Генерация")

	current_anomaly_points += level_data["anomaly_points"]
	log_point_getting(level_data["anomaly_points"], "Аномальные", "Генерация")

	current_mob_points += level_data["mob_points"]
	log_point_getting(level_data["mob_points"], "Мобы", "Генерация")

	check_level_up()
