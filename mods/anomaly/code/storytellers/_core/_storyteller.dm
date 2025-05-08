#include "admin.dm"
#include "evolution.dm"
#include "logging.dm"
#include "points.dm"
#include "processing.dm"
#include "spawn_and_delete.dm"
#include "types.dm"
#include "victim.dm"
#include "../abilities/abilities.dm"
#include "../player_support/_player_support.dm"

/datum/planet_storyteller
	var/action_delay = 3 MINUTES
	var/next_possible_action
	var/list/activity_levels = list(
		list(
			name = "impotent",
			scam_chance = 100,
			anomaly_chance = 0,
			mob_chance = 0,
		),
		list(
			name = "active",
			scam_chance = 50,
			anomaly_chance = 25,
			mob_chance = 25,
		),
		list(
			name = "angry",
			scam_chance = 33,
			anomaly_chance = 33,
			mob_chance = 33,
		)
	)
	var/list/scam_abilities = list(
		/datum/storyteller_ability/spawn_fake_anomaly/electra_ice
	)
	var/list/anomaly_activities = list(
		/datum/storyteller_ability/spawn_anomaly/gravi
	)
	var/list/mob_abilities = list(

	)

/datum/planet_storyteller/proc/calculate_action_time()
	next_possible_action = world.time + action_delay

//Здесь происходит главный цикл активности - то что и будет делать режисёр
/datum/planet_storyteller/proc/check_action()
	if(world.time < next_possible_action)
		return
	var/level_data
	for(var/list/level in activity_levels)
		if(level["name"] == current_level_name)
			level_data = level
			break

	if(!level_data)
		CRASH("level_data на 46-ой строке оказался null.")

	calculate_action_time() //Для безопасности подсчитаем заранее
	log_in_general("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик пытается что-то предпринять.")
	//Теперь выбираем тип активности которую попытается провернуть
	var/selected_action = create_possible_actions_and_choose(level_data)
	var/success = FALSE
	//Далее игра совершает функцию поиска жертвы рассказчика
	var/turf/result_turf = calculate_victim_for_action()
	if(!result_turf)
		return
	// Выполняем выбранное действие
	switch(selected_action)
		if("scam")
			log_activity("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик пытается применить обманную тактику")
			success = execute_ability(scam_abilities, result_turf)
		if("anomaly")
			log_activity("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик пытается применить аномальную способность")
			success = execute_ability(anomaly_activities, result_turf)
		if("mob")
			log_activity("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик пытается применить способность мобов")
			success = execute_ability(mob_abilities, result_turf)
	if(success)
		log_in_general("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик выполнил действие: [selected_action]")
	else
		log_in_general("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик не смог выполнить действие: [selected_action]")
	calculate_action_time()

//Исходя из текущего состояния рассказчика, собирает все способности которые может выполнить рассказчик
/datum/planet_storyteller/proc/create_possible_actions_and_choose(level_data)
	// Явно инициализируем ассоциативный список
	var/list/possible_actions = list()
	if(level_data["scam_chance"] > 0 && LAZYLEN(scam_abilities))
		possible_actions["scam"] = level_data["scam_chance"]
	if(level_data["anomaly_chance"] > 0 && LAZYLEN(anomaly_activities))
		possible_actions["anomaly"] = level_data["anomaly_chance"]
	if(level_data["mob_chance"] > 0 && LAZYLEN(mob_abilities))
		possible_actions["mob"] = level_data["mob_chance"]

	// Добавляем проверку на пустой список
	if(!LAZYLEN(possible_actions))
		return null
	return pickweight(possible_actions)

//Нап подаётся список возможных способностей, основываясь на их шансе и цене пытаемся что-то предпринять
/datum/planet_storyteller/proc/execute_ability(list/input_abilities_list, input_turf)
	if(!LAZYLEN(input_abilities_list) || !input_turf)
		return FALSE

	// Создаем ассоциативный список: способность -> вес
	var/list/weighted_abilities = list()
	for(var/ability_type in input_abilities_list)
		if(can_storyteller_afford_ability(ability_type))
			var/datum/storyteller_ability/ability_prototype = ability_type
			weighted_abilities[ability_type] = initial(ability_prototype.proc_chance)

	if(!LAZYLEN(weighted_abilities))
		log_in_general("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик не смог себе позволить ни одну способность.")
		return FALSE

	// Выбираем и выполняем способность за один шаг
	var/picked_ability_type = pickweight(weighted_abilities)
	var/datum/storyteller_ability/spawned_ability = new picked_ability_type(src)
	var/success = spawned_ability.execute(input_turf)
	if(success)
		spend_points_for_ability(picked_ability_type)
		log_in_general("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик выполнил способность: [spawned_ability.ability_name]")

	else
		log_in_general("В [time2text(world.realtime,"hh:mm:ss")] Рассказчик не смог выполнить способность: [spawned_ability.ability_name]")

	qdel(spawned_ability)

	return success
