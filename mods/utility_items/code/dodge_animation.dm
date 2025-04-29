//Анимация уворота для мобиков.
/mob/proc/dodge_animation(input_animation_time = 0.4 SECONDS, atom/attacker = null)
	//Выставляем нулевые значения
	pixel_x = 0
	pixel_y = 0
	//Сперва создаём список направлений, куда будет уклонятся кукла
	var/list/directions = list(NORTH, EAST, WEST, SOUTH)
	//Теперь удалим 1 лишние направление, т.к для уклонения нельзя сдвигаться навстречу противнику(Не красиво)
	if(attacker)
		//берём противоположное направление атакующего
		var/enemy_dir = turn(attacker.dir, 180)
		if(enemy_dir == NORTHWEST || enemy_dir == SOUTHWEST)
			enemy_dir = WEST
		else if(enemy_dir == SOUTHWEST || enemy_dir == SOUTHEAST)
			enemy_dir = EAST
		LAZYREMOVE(directions, enemy_dir)
	var/dodge_direction = pick(directions)
	//определяемся с временем анимации уворота
	var/result_animation_time = input_animation_time
	var/middle_number = result_animation_time/2
	//Обычный цикл
	for(var/current_iteration = 1, current_iteration <= result_animation_time, current_iteration++)
		sleep(1)
		if(dodge_direction == NORTH)
			if(current_iteration <= middle_number)
				pixel_y += 2
			else
				pixel_y -= 2

		else if(dodge_direction == SOUTH)
			if(current_iteration <= middle_number)
				pixel_y -= 2
			else
				pixel_y += 2

		else if(dodge_direction == WEST)
			if(current_iteration <= middle_number)
				pixel_x -= 2
			else
				pixel_x += 2

		else if(dodge_direction == EAST)
			if(current_iteration <= middle_number)
				pixel_x += 2
			else
				pixel_x -= 2
