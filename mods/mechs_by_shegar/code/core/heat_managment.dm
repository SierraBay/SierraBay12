/mob/living/exosuit
	///Максимальное возможное количество тепла в мехе
	var/max_heat = 1000
	//Минимальное возможное количество тепла в мехе
	var/min_heat = 0
	///Текущее количество тепла в мехе
	var/current_heat = 0
	///Мех находится в статусе перегрева?
	var/overheat = FALSE
	///Требуется обработка тепла?
	var/process_heat = FALSE
	///Когда в последний раз обрабатывали тепло
	var/last_heat_process = 0
	///Сумарная скорость утилизации тепла в мехе
	var/total_heat_cooling = 0
	///Тепло, создающееся при перегреве при перегреве
	var/overheat_heat_generation = 0
	///Модификатор начисления тепла
	var/overheat_heat_modificator = 1

/obj/item/mech_component
	///Максимальное тепло, которое может хранить в себе часть меха.
	var/max_heat = 100
	///Количество тепла, которое сбрасывает данная часть
	var/heat_cooling = 5
	///Количество тепла, которое вырабатывает данная часть при использовании
	var/heat_generation = 5
	///Количество тепла, выделяемое при ЭМИ ударе
	var/emp_heat_generation = 50

/mob/living/exosuit/proc/add_heat(ammount,)
	current_heat += ammount * overheat_heat_modificator
	advanced_heat_indicator.Update()
	if(current_heat != 0)
		process_heat = TRUE
	if(current_heat > max_heat || current_heat == max_heat)
		current_heat = max_heat
		overheat()


/mob/living/exosuit/proc/sub_heat(ammount) // substruct heat
	current_heat -= ammount
	advanced_heat_indicator.Update()
	if(current_heat < min_heat || current_heat == min_heat)
		current_heat = min_heat
		process_heat = FALSE
		if(overheat)
			advanced_heat_indicator.stop_overheat()
			overheat = FALSE
			overheat_heat_modificator = 1
			if(power == MECH_POWER_OFF)
				fast_toggle_power_garanted()
		overheat = FALSE
	else if(current_heat > max_heat || current_heat == max_heat)
		current_heat = max_heat
		overheat()

/mob/living/exosuit/proc/overheat()
	//При повторном перегреве, перегретый мех лопается
	if(overheat)
		gib()
		return
	advanced_heat_indicator.start_overheat()
	overheat_heat_modificator = 2
	if(power == MECH_POWER_ON)
		toggle_power()
	overheat = TRUE
	delayed_power_up()

/mob/living/exosuit/proc/delayed_power_up()
	set waitfor = 0
	sleep(body.overheat_time)
	if(power != MECH_POWER_OFF)
		return

/mob/living/exosuit/proc/process_heat()
	if((world.time - last_heat_process) < body.heat_process_speed)
		return
	if(overheat)
		sub_heat(total_heat_cooling * 2.5)
		return
	else if(power == MECH_POWER_OFF)
		sub_heat(total_heat_cooling * 4)
		return
	sub_heat(total_heat_cooling)
