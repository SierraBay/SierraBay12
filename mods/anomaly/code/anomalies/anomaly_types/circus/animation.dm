/obj/anomaly/circus
	//Все те кто крутится внутри аномалии
	//Жертвы внутри должны выглядеть как
	//Жертва = обьект, ступень
	// Жертвы и их текущий угол: list(victim = corner_index)
	var/list/victims_inside = list()
	// Параметры анимации
	var/list/current_path = list()    // Текущий путь углов
	var/current_path_index = 1        // Текущая точка пути
	// Время движения между углами (в секундах)
	var/movement_duration = 1.5 SECONDS

	// Таймер анимации
	var/animation_timer

// Начинаем движение жертвы
/obj/anomaly/circus/proc/start_movement(atom/movable/victim)
	if(!victim || !(victim in victims_inside))
		return

	var/corner_index = victims_inside[victim]
	var/target_coords = get_corner_coords(corner_index)

	animate(victim, pixel_x = target_coords[1], pixel_y = target_coords[2], time = movement_duration, easing = SINE_EASING)
