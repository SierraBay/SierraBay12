/datum/planet_storyteller
	var/list/general_logs = list()
	///Логи всех получений поинтов
	var/list/points_logs = list()
	///Логи активности рассказчика
	var/list/activiti_logs = list()
	var/list/problems_logs = list()
	///Если TRUE то всё время пишет в админ чат о своём состоянии и действиях
	var/DEBUG_MODE = TRUE

/datum/planet_storyteller/proc/log_point_getting(point_ammout, point_type, source)
	var/text = "В [time2text(world.realtime,"hh:mm:ss")] Получено [point_ammout] очков класса [point_type], причина: [source]"
	LAZYADD(points_logs, text)
	if(DEBUG_MODE)
		for(var/ckey in SSanom.debug_storyteller_listeners)
			to_chat(ckey, SPAN_WARNING(text))



/datum/planet_storyteller/proc/log_point_spend(ability_name, point_ammout, point_type)
	var/text = "В [time2text(world.realtime,"hh:mm:ss")] рассказчик затратил [point_ammout] очков типа:[point_type] на применение способности: [ability_name]. "
	LAZYADD(points_logs, text)
	if(DEBUG_MODE)
		for(var/ckey in SSanom.debug_storyteller_listeners)
			to_chat(ckey, SPAN_WARNING(text))

/datum/planet_storyteller/proc/log_in_general(input_log)
	LAZYADD(general_logs, input_log)
	if(DEBUG_MODE)
		for(var/ckey in SSanom.debug_storyteller_listeners)
			to_chat(ckey, SPAN_WARNING(input_log))

/datum/planet_storyteller/proc/log_problem(input_log)
	LAZYADD(problems_logs, input_log)
	if(DEBUG_MODE)
		for(var/ckey in SSanom.debug_storyteller_listeners)
			to_chat(ckey, SPAN_WARNING(input_log))

/datum/planet_storyteller/proc/log_activity(input_log)
	LAZYADD(activiti_logs, input_log)
	if(DEBUG_MODE)
		for(var/ckey in SSanom.debug_storyteller_listeners)
			to_chat(ckey, SPAN_WARNING(input_log))
