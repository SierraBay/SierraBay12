#define CUBE_BLOCKED 1
#define CUBE_UNBLOCKED 2

/obj/anomaly/labirint/proc/setup_exit_path(atom/movable/input_movable)
	var/turf/start = get_turf(input_movable)
	//Собираем лист турфов
	var/list/list_of_exit_turfs = AStar(start, current_exit_cube, TYPE_PROC_REF(/turf, CardinalTurfsWithAccess), TYPE_PROC_REF(/turf, Distance), 0, 50, id = null, exclude = null) //Строим путь через алгоритм АСтар
	//Теперь собираем кубы на пути
	for(var/turf/turf in list_of_exit_turfs)
		for(var/obj/anomaly/part/labirint_cube/cube in turf)
			cube.is_path_part = TRUE
			cube.STATUS = CUBE_UNBLOCKED
			LAZYADD(exit_path, cube)

/obj/anomaly/labirint/proc/setup_exit_cube(movable_atom, max_x, min_x, max_y, min_y)
	if(!max_x || !min_x || !max_y || !min_y)
		CRASH("Создание выходного куба у лабиринта получила некорректные данные")
	QDEL_NULL(current_exit_cube)
	//После того как мы нашли все крайние блоки аномалии, нужно определиться какой из них выходной
	var/turf/start_turf = get_turf(movable_atom)
	var/start_x
	var/start_y
	var/failsafe = 0
	var/list/good_borders = border_parts
	start_x = get_x(start_turf)
	start_y = get_y(start_turf)
	while(failsafe <= 50 && LAZYLEN(good_borders))
		if(failsafe == 50)
			failsafe = "ERROR"
			break
		var/obj/anomaly/part/labirint_cube/picked = pick(good_borders)
		if(!picked.is_playable)
			failsafe++
			LAZYREMOVE(good_borders, picked)
			continue
		///Проверим что в нашем кубе нет
		if(get_turf(picked) == start_turf)
			failsafe++
			LAZYREMOVE(good_borders, picked)
			continue
		if(start_x == get_x(picked) && start_y == get_y(picked))
			failsafe++
			LAZYREMOVE(good_borders, picked)
			continue
		picked.STATUS = CUBE_UNBLOCKED
		current_exit_cube = picked
		break
	if(failsafe == "ERROR")
		CRASH("Сработал FAILSAFE при генерации лабиринта")

#undef CUBE_BLOCKED
#undef CUBE_UNBLOCKED
