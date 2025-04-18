/datum/planet_storyteller
	var/list/points_generating_in_levels = list(
		// impotent: медленное развитие, только обманные тактики
		list(
			level_name = "impotent",
			evolution_points_generation = 0.1,
			scam_points_generation = 4,
			anomaly_points_generation = 0,
			mob_points_generation = 0
			),
		// active: умеренная активность
		list(
			level_name = "active",
			scam_points_generation = 10,
			evolution_points_generation = 2,
			anomaly_points_generation = 5,
			mob_points_generation = 5
			),
		// angry: максимальная агрессия
		list(
			level_name = "angry",
			evolution_points_generation = 0,
			scam_points_generation = 50,
			anomaly_points_generation = 50,
			mob_points_generation = 25
			)
	)
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
/datum/planet_storyteller/proc/add_points(evolution_points, mob_points, anomaly_points, scam_points)
	if(evolution_points)
		current_evolution_points += evolution_points
	if(mob_points)
		current_mob_points += mob_points
	if(anomaly_points)
		current_anomaly_points += anomaly_points
	if(scam_points)
		current_scam_points += scam_points

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
	var/level_data
	for(var/list/level in points_generating_in_levels)
		if(level[1] == current_level_name)
			level_data = level
			break

	if(!level_data)
		return

	current_evolution_points += level_data[2]
	log_point_getting(level_data[2], "Эволюционные")
	current_scam_points += level_data[3]
	log_point_getting(level_data[3], "Обманные")
	current_anomaly_points += level_data[4]
	log_point_getting(level_data[4], "Аномальные")
	current_mob_points += level_data[5]
	log_point_getting(level_data[5], "Мобы")

	check_level_up()

/// Проверяет возможность повышения уровня
/datum/planet_storyteller/proc/check_level_up()
	if(current_angry_level >= LAZYLEN(rages_levels_changes_prices))
		return

	var/required_points = rages_levels_changes_prices[current_angry_level]
	if(current_evolution_points >= required_points)
		level_up()

// Повышает уровень рассказчика
/datum/planet_storyteller/proc/level_up()
	current_angry_level++
	// Обновляем имя текущего уровня
	for(var/level_name in rages_levels)
		if(rages_levels[level_name]["level"] == current_angry_level)
			current_level_name = level_name
			log_in_general("Режисёр получил повышение уровня. Текущий уровень - [current_level_name]")
			break
