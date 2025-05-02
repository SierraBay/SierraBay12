#define CUBE_BLOCKED 1
#define CUBE_UNBLOCKED 2

/obj/anomaly/labirint/proc/start_labirint(atom/movable/O)
	start_turf = get_turf(O)
	lock_all_cubes()
	setup_borders(O)
	setup_pathweights()
	setup_exit_path(O)
	if(!LAZYLEN(exit_path))
		full_open_labirint()

/obj/anomaly/labirint/proc/lock_all_cubes()
	for(var/obj/anomaly/part/labirint_cube/part in list_of_parts)
		part.STATUS = CUBE_BLOCKED

/obj/anomaly/labirint/proc/setup_borders(atom/movable/movable_atom)
	//Всё довольно просто. Включаются в список тех кто на краю те, что находятся на максимальных/минимальных X и Y
	var/max_x = 0
	var/min_x = 10000
	var/max_y = 0
	var/min_y = 10000
	for(var/obj/anomaly/part/labirint_cube/part in list_of_parts)
		if(!part.x || !part.y)
			continue
		if(part.x < min_x)
			min_x = part.x
		if(part.x > max_x)
			max_x = part.x
		if(part.y < min_y)
			min_y = part.y
		if(part.y > max_y)
			max_y = part.y
	for(var/obj/anomaly/part/labirint_cube/part in list_of_parts)
		var/turf/my_turf = get_turf(part)
		if(part.x == max_x)
			if(TurfBlocked(get_step(my_turf, EAST)))
				part.is_playable = FALSE
		else if(part.x == min_x)
			if(TurfBlocked(get_step(my_turf, WEST)))
				part.is_playable = FALSE
		else if(part.y == max_y)
			if(TurfBlocked(get_step(my_turf, NORTH)))
				part.is_playable = FALSE
		else if(part.y == min_y)
			if(TurfBlocked(get_step(my_turf, SOUTH)))
				part.is_playable = FALSE

	//Вычисляем все те части что находятся скраю
	for(var/obj/anomaly/part/labirint_cube/picked_part in list_of_parts)
		if(picked_part.x == max_x || picked_part.x == min_x || picked_part.y == max_y || picked_part.y == min_y)
			LAZYADD(border_parts, picked_part)
	setup_exit_cube(movable_atom, max_x, min_x, max_y, min_y)

/obj/anomaly/labirint/proc/setup_pathweights()
	for(var/obj/anomaly/part/labirint_cube/picked_part in list_of_parts)
		picked_part.pathweight = rand(1, 10) //Мы выдаём рандомный вес чтоб игра строила более извилистые пути

#undef CUBE_BLOCKED
#undef CUBE_UNBLOCKED
