//БРОДЯЧИЕ АНОМАЛИИ. Некоторые аномалии могут "Бродить", спонтанно перемещаясь в пространстве
/obj/anomaly
	//Это бродячая аномалия?
	var/can_walking = FALSE
	// от 0 до 20. 0 - не активна. 20 - ходит каждый предоставленный ШАНС
	var/walking_activity = 0
	///Время, спустя которое аномалия думает, а не пора ли ей сделать шаг
	var/walk_time = 5 SECONDS
	///Шанс заспавнить подтипа "Бродячий"
	var/chance_spawn_walking = 0

/obj/anomaly/proc/check_anomaly_ai()
	if(!can_walking)
		return
	var/req_activity = rand(0, 20)
	if(walking_activity >= req_activity)
		try_anomaly_walk()
	addtimer(new Callback(src, PROC_REF(check_anomaly_ai)), walk_time)

/obj/anomaly/proc/try_anomaly_walk()
	//Перед тем как сделать шаг, мы найдём список доступных для шага сторон
	var/list/list_of_good_turfs = list()
	var/list/all_posible_turfs = list()
	LAZYADD(all_posible_turfs, get_edge_target_turf(src, NORTH))
	LAZYADD(all_posible_turfs, get_edge_target_turf(src, EAST))
	LAZYADD(all_posible_turfs, get_edge_target_turf(src, WEST))
	LAZYADD(all_posible_turfs, get_edge_target_turf(src, SOUTH))
	//Проверим, куда нам можно ходить
	for(var/turf/picked_turf in all_posible_turfs)
		if(!TurfBlocked(picked_turf) && !TurfBlockedByAnomaly(picked_turf))
			LAZYADD(list_of_good_turfs, picked_turf)
	//Выбираем любуюу сторону
	var/turf/input_turf = pick(list_of_good_turfs)
	//Делаем шаг
	if(input_turf)
		if(step(src, get_dir(src, input_turf)))
			//Пересчитываем зону поражения
			calculate_effected_turfs_from_moving_anomaly(src)


/*
Формула ИИ

*/
