//Этот код отвечает за логику кода отвечающая за то, под ударом ли турф, или нет. Игра динамически реагирует на
//Изменение положение, удаление и появление новых аномалий
/turf
	///Список аномалий, которые способны дотягиваться до этого турфа электростатикой
	var/list/list_of_in_range_anomalies

//Функция добавляет электростатику в подверженные турфы от аномалии
/proc/calculate_effected_turfs_from_new_anomaly(obj/anomaly/spawned_anomaly)
	//Аномалии вообще нужно что-то расчитывать?
	if(spawned_anomaly.detectable_effect_range)
		for(var/turf/Turf in trange(spawned_anomaly.effect_range, spawned_anomaly))
			LAZYADD(spawned_anomaly.effected_turfs, Turf)
		for(var/turf/picked_turf in spawned_anomaly.effected_turfs)
			LAZYADD(picked_turf.list_of_in_range_anomalies, spawned_anomaly)


//Функция удаляет электростатику из подверженных турфов
/proc/calculate_effected_turfs_from_deleting_anomaly(obj/anomaly/spawned_anomaly)
	for(var/turf/picked_turf in spawned_anomaly.effected_turfs)
		LAZYREMOVE(picked_turf.list_of_in_range_anomalies, spawned_anomaly) //<- Очистили у подверженных турфов ссылку на самого себя
	//А дальше, игра сама удалит второй список

//Функция пересчитает по новой подверженные электростатике турфы
/proc/calculate_effected_turfs_from_moving_anomaly(obj/anomaly/spawned_anomaly)
	if(spawned_anomaly.detectable_effect_range)
		for(var/turf/picked_turf in spawned_anomaly.effected_turfs)
			LAZYREMOVE(picked_turf.list_of_in_range_anomalies, spawned_anomaly) //<- Очистили у подверженных турфов ссылку на самого себя
		LAZYCLEARLIST(spawned_anomaly.effected_turfs)
		calculate_effected_turfs_from_new_anomaly(spawned_anomaly)
