///Данная подсистемка отключит менеджера при подозрительной активности
/datum/weather_manager
	var/warnings_ammout = 0
	///После 5
	var/critical_warnings_ammout = 5
	///Сколько должно минимально пройти времени
	var/safe_time_between_blowouts = 15 SECONDS
	var/next_safe_blowout_time
	var/safe_time_between_changes = 15 SECONDS
	var/next_safe_change_time

/datum/weather_manager/proc/check_change_safety()
	if(warnings_ammout == critical_warnings_ammout)
		activity_blocked_by_safe_protocol = TRUE
		report_progress("WARNING ERROR: Критическая ситуация подтверждена, предпринимаем действия.")
		delete_manager()
		QDEL_NULL(src) //Если delete_manager не сработает
		CRASH("WARNING ERROR: Критическая ситуация подтверждена, клапон безопасности сорван.")
	if(world.time < next_safe_change_time)
		warnings_ammout++
		report_progress("WARNING ANOM: Слишком малый интервал перед вызовами смены погоды, вероятно опасная ситуация.")
		calculate_next_safe_change()
		calculate_change_time()
		return FALSE
	calculate_next_safe_change()
	return TRUE

///Функция проверит безопасность вызова функции
/datum/weather_manager/proc/check_blowout_safety()
	if(warnings_ammout == critical_warnings_ammout)
		activity_blocked_by_safe_protocol = TRUE
		report_progress("WARNING ERROR: Критическая ситуация подтверждена, предпринимаем действия.")
		delete_manager()
		QDEL_NULL(src) //Если delete_manager не сработает
		CRASH("WARNING ERROR: Критическая ситуация подтверждена, клапон безопасности сорван.")
	if(world.time < next_safe_blowout_time)
		warnings_ammout++
		report_progress("WARNING ANOM: Слишком малый интервал перед вызовами выброса, вероятно опасная ситуация.")
		calculate_next_safe_blowout()
		calculate_blowout_time()
		return FALSE
	calculate_next_safe_blowout()
	return TRUE


/datum/weather_manager/proc/calculate_next_safe_blowout()
	next_safe_blowout_time = world.time + safe_time_between_blowouts

/datum/weather_manager/proc/calculate_next_safe_change()
	next_safe_change_time = world.time + safe_time_between_changes
