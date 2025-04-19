//Анимация уворота для мобиков.
/mob/proc/dodge_animation(input_animation_time = 1 SECONDS, atom/attacker = null)
	//Выставляем нулевые значения
	var/x_move = 0
	var/y_move = 0
	//Сперва создаём список направлений, куда будет уклонятся кукла
	var/list/directions = list(NORTH, EAST, WEST, SOUTH)
	//Теперь удалим 1 лишние направление, т.к для уклонения нельзя сдвигаться навстречу противнику(Не красиво)
	if(attacker)
		//берём противоположное направление атакующего
		var/dir_to_enemy = turn(attacker.dir, 180)
		if(dir_to_enemy == NORTHWEST || dir_to_enemy == SOUTHWEST)
			dir_to_enemy = WEST
		else if(dir_to_enemy == SOUTHWEST || dir_to_enemy == SOUTHEAST)
			dir_to_enemy = EAST
		LAZYREMOVE(directions, dir_to_enemy)
	switch(pick(directions))
		if(NORTH)
			y_move = 6
		if(SOUTH)
			y_move = -6
		if(WEST)
			x_move = -6
		if(EAST)
			x_move = 6
	animate(src, input_animation_time, TRUE, LINEAR_EASING, pixel_x = x_move, pixel_y = y_move)
	sleep(input_animation_time)
	animate(src, time = input_animation_time, easing = LINEAR_EASING, pixel_x = -x_move, pixel_y = -y_move)
	sleep(input_animation_time)
