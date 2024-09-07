//Артефакт передаёт на генерацию все турфы вокруг себя в определённом радиусе
/obj/machinery/artifact
	//Генерирует ли при спавне данный артефакт вокруг себя артефакты?
	var/can_born_anomalies = TRUE
	///Минимальное количество аномалий, которое заспавнит артефакт
	var/min_anomalies_ammout = 10
	///Максимальное количество аномалий, которое заспавнит артефакт
	var/max_anomalies_ammout = 20
	//Честно указываем какой максимальный и минимальный размер аномалий, что могут быть заспавнены артефактом
	var/max_anomaly_size = 9
	var/min_anomaly_size = 1
	var/min_artefacts_ammount = 1
	var/max_artefacts_ammount = 2
	///Область в которой будет спавнить аномалии
	var/range_spawn = 5
	//Лист возможных аномалий для спавна
	var/list/possible_anomalies = list(
		/obj/anomaly/electra/three_and_three = 5,
		/obj/anomaly/electra/three_and_three/tesla = 1,
		/obj/anomaly/thamplin/random = 5,
		/obj/anomaly/zjarka/short_effect = 3,
		/obj/anomaly/zjarka/long_effect = 2,
		/obj/anomaly/rvach/three_and_three = 4
		)

/obj/machinery/artifact/Initialize()
	. = ..()
	if(icon_num == 0 || icon_num == 1 || icon_num == 7 || icon_num == 11 || icon_num == 12)
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
	generate_anomalies_in_turfs(possible_anomalies, turfs_for_spawn, min_anomalies_ammout, max_anomalies_ammout, min_artefacts_ammount, max_artefacts_ammount, min_anomaly_size, max_anomaly_size, "big artefact generation", started_in)
