//Артефакт передаёт на генерацию все турфы вокруг себя в определённом радиусе
/obj/machinery/artifact
	//Генерирует ли при спавне данный артефакт вокруг себя артефакты?
	var/can_born_anomalies = TRUE
	///Минимальное количество аномалий, которое заспавнит артефакт
	var/min_anomalies_ammout = 1
	///Максимальное количество аномалий, которое заспавнит артефакт
	var/max_anomalies_ammout = 2
	var/min_artefacts_ammount = 0
	var/max_artefacts_ammount = 0
	///Область в которой будет спавнить аномалии
	var/range_spawn = 3
	//Лист возможных аномалий для спавна
	var/list/possible_anomalies = list(
		/obj/anomaly/zharka,
		/obj/anomaly/zharka/short_effect,
		/obj/anomaly/zharka/long_effect,
		/obj/anomaly/electra/three_and_three,
		/obj/anomaly/electra/three_and_three/tesla,
		/obj/anomaly/electra/three_and_three/tesla_second,
		/obj/anomaly/vspishka,
		/obj/anomaly/rvach/three_and_three,
		/obj/anomaly/heater/three_and_three,
		/obj/anomaly/heater/two_and_two,
		/obj/anomaly/cooler/two_and_two,
		/obj/anomaly/cooler/three_and_three
		)


//Выведено из ротации, большой артефакт ничего не спавнит
/obj/machinery/artifact/Initialize()
	. = ..()
	if(icon_num == 0 || icon_num == 1 || icon_num == 7 || icon_num == 11)
		if(can_born_anomalies)
			born_anomalies()

/obj/machinery/artifact/no_anomalies
	can_born_anomalies = FALSE

///Функция, которая заспавнит вокруг большого артефакта аномалии
/obj/machinery/artifact/proc/born_anomalies(range, ammount)
	set background = 1
	var/started_in = world.time
	var/list/turfs_for_spawn = list()
	//У нас нет турфа?
	if(!src.loc)
		return
		//Собираем все турфы в определённом радиусе
	for(var/turf/turfs in RANGE_TURFS(src.loc, range_spawn))
		if(!TurfBlocked(turfs) || TurfBlockedByAnomaly(turfs))
			LAZYADD(turfs_for_spawn, turfs)
	generate_anomalies_in_turfs(possible_anomalies, turfs_for_spawn, min_anomalies_ammout, max_anomalies_ammout, min_artefacts_ammount, max_artefacts_ammount, null, null, "big artefact generation", started_in)
