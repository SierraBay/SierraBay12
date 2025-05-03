//Жертвы двигаются по углам. Высчитаем углы.
/obj/anomaly/circus
	var/right_up_corner
	var/left_up_corner
	var/left_down_corner
	var/right_down_corner

/obj/anomaly/circus/proc/calculate_corners()
	right_up_corner += locate(floor(parts_x_width/2), floor(parts_y_width/2))
	left_up_corner += locate(-floor(parts_x_width/2), floor(parts_y_width/2))
	left_down_corner += locate(-floor(parts_x_width/2), -floor(parts_y_width/2))
	right_down_corner += locate(floor(parts_x_width/2), -floor(parts_y_width/2))

// Получаем координаты угла по индексу
/obj/anomaly/circus/proc/get_corner_coords(index)
	switch(index)
		if(1)
			return right_up_corner
		if(2)
			return left_up_corner
		if(3)
			return left_down_corner
		if(4)
			return right_down_corner
	return list(0, 0)
