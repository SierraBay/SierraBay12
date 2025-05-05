#define OUT 1
#define IN 2
#define BOTH 3
#define FORCE_OUT 4
#define FORCE_IN 5
#define FORCE_BOTH 6
#define FORCE_BLOCKED 7

/obj/anomaly/labirint/proc/setup_exit_path(atom/movable/input_movable)
	var/turf/start = get_turf(input_movable)
	var/obj/anomaly/part/labirint_cube/exit = get_turf(pick(exit_parts))
	//Собираем лист турфов
	var/list/list_of_exit_turfs = AStar(start, exit, TYPE_PROC_REF(/turf, CardinalTurfsWithAccess), TYPE_PROC_REF(/turf, Distance), 0, 50, id = null, exclude = null) //Строим путь через алгоритм АСтар
	//Теперь собираем кубы на пути
	for(var/turf/turf in list_of_exit_turfs)
		for(var/obj/anomaly/part/labirint_cube/cube in turf)
			LAZYADD(exit_path, cube)
	//Теперь изменяем кубы в пути
	for(var/obj/anomaly/part/labirint_cube/cube in exit_path)
		cube.is_path_part = TRUE
	// Делаем проходы между кубами пути FORCE_BOTH
	for(var/i in 1 to (LAZYLEN(exit_path) - 1))
		var/obj/anomaly/part/labirint_cube/current = exit_path[i]
		var/obj/anomaly/part/labirint_cube/next = exit_path[i + 1]

		if(!current || !next)  // На всякий случай проверяем
			continue

		var/dir_to_next = get_dir(current, next)

		// Открываем сторону current в направлении next
		switch(dir_to_next)
			if(NORTH)
				current.NORTH_STATUS = FORCE_OUT
				current.SOUTH_STATUS = FORCE_IN
				current.EAST_STATUS = FORCE_IN
				current.WEST_STATUS = FORCE_IN
			if(SOUTH)
				current.NORTH_STATUS = FORCE_IN
				current.SOUTH_STATUS = FORCE_OUT
				current.EAST_STATUS = FORCE_IN
				current.WEST_STATUS = FORCE_IN
			if(EAST)
				current.NORTH_STATUS = FORCE_IN
				current.SOUTH_STATUS = FORCE_IN
				current.EAST_STATUS = FORCE_OUT
				current.WEST_STATUS = FORCE_IN
			if(WEST)
				current.NORTH_STATUS = FORCE_IN
				current.SOUTH_STATUS = FORCE_IN
				current.EAST_STATUS = FORCE_IN
				current.WEST_STATUS = FORCE_BOTH

		// Открываем сторону next в направлении current (чтобы можно было идти обратно)
		var/dir_to_prev = turn(dir_to_next, 180)
		switch(dir_to_prev)
			if(NORTH)
				next.NORTH_STATUS = FORCE_BOTH
			if(SOUTH)
				next.SOUTH_STATUS = FORCE_BOTH
			if(EAST)
				next.EAST_STATUS = FORCE_BOTH
			if(WEST)
				next.WEST_STATUS = FORCE_BOTH

		current.refresh_icon_state()
		next.refresh_icon_state()
	if(!LAZYLEN(exit_path))
		CRASH("Лабиринт не смог создать путь выхода из себя и раскрылся.")

///Забудет о существовании выходного пути
/obj/anomaly/labirint/proc/desetup_exit_path()
	for(var/obj/anomaly/part/labirint_cube/cube in exit_path)
		cube.is_path_part = FALSE
	exit_path = null

/obj/anomaly/labirint/proc/setup_exit_cube(movable_atom, max_x, min_x, max_y, min_y)
	if(!max_x || !min_x || !max_y || !min_y)
		CRASH("Создание выходного куба у лабиринта получила некорректные данные")
	LAZYCLEARLIST(exit_parts)
	//После того как мы нашли все крайние блоки аномалии, нужно определиться какой из них выходной
	var/turf/start_turf = get_turf(movable_atom)
	var/start_x
	var/start_y
	var/i = 0
	var/failsafe = 0
	var/list/good_borders = border_parts
	start_x = get_x(start_turf)
	start_y = get_y(start_turf)
	while(exits_ammount > i)
		if(failsafe == 50)
			failsafe = "ERROR"
			break
		var/obj/anomaly/part/labirint_cube/picked = pick(good_borders)
		///Проверим что в нашем кубе нет
		if(get_turf(picked) == start_turf)
			failsafe++
			LAZYREMOVE(good_borders, picked)
			continue
		if(start_x == get_x(picked) || start_y == get_y(picked))
			failsafe++
			LAZYREMOVE(good_borders, picked)
			continue
		if(picked.x == max_x)
			picked.EAST_STATUS = FORCE_OUT
		if(picked.x == min_x)
			picked.WEST_STATUS = FORCE_OUT
		if(picked.y == max_y)
			picked.NORTH_STATUS = FORCE_OUT
		if(picked.y == min_y)
			picked.SOUTH_STATUS = FORCE_OUT
		i++
		LAZYADD(exit_parts, picked)
	if(failsafe == "ERROR")
		CRASH("Сработал FAILSAFE при генерации лабиринта")

#undef OUT
#undef IN
#undef BOTH
#undef FORCE_OUT
#undef FORCE_IN
#undef FORCE_BOTH
#undef FORCE_BLOCKED
