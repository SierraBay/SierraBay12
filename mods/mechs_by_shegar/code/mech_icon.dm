/mob/living/exosuit/proc/update_passengers(update_overlays = TRUE)
	var/local_dir = dir // <- Для того чтоб не руинить направление передвижения меха, мы применим эту переменную
	if(update_overlays && LAZYLEN(back_passengers_overlays))
		overlays -= back_passengers_overlays
	if(update_overlays && LAZYLEN(left_back_passengers_overlays))
		overlays -= left_back_passengers_overlays
	if(update_overlays && LAZYLEN(right_back_passengers_overlays))
		overlays -= right_back_passengers_overlays
	back_passengers_overlays = null
	left_back_passengers_overlays = null
	right_back_passengers_overlays = null
	var/passenger_back_layer
	var/passenger_left_back_layer
	var/passenger_right_back_layer
	// Дабы исключить момент когда при боковом движении пассажиров не видно, помимо обычных направлений, будут прописаны следующие:

	if(local_dir == EAST || local_dir == NORTHEAST || local_dir == SOUTHEAST)
		local_dir = EAST
		passenger_back_layer = MECH_BACK_LAYER
		passenger_left_back_layer = MECH_BACK_LAYER - 0.01
		passenger_right_back_layer = MECH_GEAR_LAYER
	else if(local_dir == WEST || local_dir == NORTHWEST || local_dir == SOUTHWEST)
		local_dir = WEST
		passenger_back_layer = MECH_BACK_LAYER
		passenger_left_back_layer = MECH_GEAR_LAYER
		passenger_right_back_layer = MECH_BACK_LAYER - 0.01
	else if(local_dir == SOUTH)
		passenger_back_layer  = MECH_BACK_LAYER
		passenger_left_back_layer = MECH_BACK_LAYER
		passenger_right_back_layer = MECH_BACK_LAYER
	else if(local_dir == NORTH)
		passenger_back_layer  = MECH_GEAR_LAYER + 0.01
		passenger_left_back_layer = MECH_GEAR_LAYER + 0.01
		passenger_right_back_layer = MECH_GEAR_LAYER + 0.01
	//
	//
	if(LAZYLEN(passenger_compartment.back_passengers) > 0) // Отрисовка среднего пассажирка
		var/mob/passenger_back = passenger_compartment.back_passengers[1]
		var/image/draw_passenger_back = new
		draw_passenger_back.appearance = passenger_back
		draw_passenger_back.plane = FLOAT_PLANE
		var/list/back_offset_values = body.back_passengers_positions
		var/list/back_directional_offset_values = back_offset_values["[local_dir]"]
		draw_passenger_back.pixel_x = passenger_back.default_pixel_x + back_directional_offset_values["x"]
		draw_passenger_back.pixel_y = passenger_back.default_pixel_y + back_directional_offset_values["y"]
		draw_passenger_back.pixel_z = 0
		draw_passenger_back.transform = null
		draw_passenger_back.layer = passenger_back_layer
		LAZYADD(back_passengers_overlays, draw_passenger_back)
	//
	if(LAZYLEN(passenger_compartment.left_back_passengers) > 0) // Отрисовка левого пассажира
		var/mob/passenger_left_back = passenger_compartment.left_back_passengers[1]
		var/image/draw_passenger_left_back = new
		draw_passenger_left_back.appearance = passenger_left_back
		draw_passenger_left_back.plane = FLOAT_PLANE
		var/list/left_offset_values = body.left_back_passengers_positions
		var/list/left_directional_offset_values = left_offset_values["[local_dir]"]
		draw_passenger_left_back.pixel_x = passenger_left_back.default_pixel_x + left_directional_offset_values["x"]
		draw_passenger_left_back.pixel_y = passenger_left_back.default_pixel_y + left_directional_offset_values["y"]
		draw_passenger_left_back.pixel_z = 0
		draw_passenger_left_back.transform = null
		draw_passenger_left_back.layer = passenger_left_back_layer
		LAZYADD(left_back_passengers_overlays, draw_passenger_left_back)
	//
	if(LAZYLEN(passenger_compartment.right_back_passengers) > 0) // Отрисовка правого пассажира
		var/mob/passenger_right_back = passenger_compartment.right_back_passengers[1]
		var/image/draw_passenger_right_back = new
		draw_passenger_right_back.layer = passenger_right_back_layer
		draw_passenger_right_back.appearance = passenger_right_back
		draw_passenger_right_back.plane = FLOAT_PLANE
		var/list/right_offset_values = body.right_back_passengers_positions
		var/list/right_directional_offset_values = right_offset_values["[local_dir]"]
		draw_passenger_right_back.pixel_x = passenger_right_back.default_pixel_x + right_directional_offset_values["x"]
		draw_passenger_right_back.pixel_y = passenger_right_back.default_pixel_y + right_directional_offset_values["y"]
		draw_passenger_right_back.pixel_z = 0
		draw_passenger_right_back.transform = null
		draw_passenger_right_back.layer = passenger_right_back_layer
		LAZYADD(right_back_passengers_overlays, draw_passenger_right_back)
	//
	if(update_overlays && LAZYLEN(back_passengers_overlays))
		overlays += back_passengers_overlays
	if(update_overlays && LAZYLEN(left_back_passengers_overlays))
		overlays += left_back_passengers_overlays
	if(update_overlays && LAZYLEN(right_back_passengers_overlays))
		overlays += right_back_passengers_overlays
