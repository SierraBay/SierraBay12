/obj/item/device/paint_sprayer/apply_paint(atom/A, mob/user, click_parameters)
	if (A.atom_flags & ATOM_FLAG_CAN_BE_PAINTED)
		A.set_color(paint_color)
		. = TRUE
	else if (istype(A, /turf/simulated/floor))
		. = paint_floor(A, user, click_parameters)
	else if (istype(A, /obj/machinery/door/airlock))
		. = paint_airlock(A, user)
	//Передаём сигнал о краске меху.
	else if (ismech(A))
		var/mob/living/exosuit/mech = A
		. = mech.paint_spray_interaction(user, paint_color)
	//Запрещаем красить каркас меха напрямую
	if (istype(A, /obj/structure/heavy_vehicle_frame))
		var/obj/structure/heavy_vehicle_frame/frame = A
		. = frame.paint_spray_interaction(user, paint_color)
	if (.)
		playsound(get_turf(src), 'sound/effects/spray3.ogg', 30, 1, -6)
	return .
