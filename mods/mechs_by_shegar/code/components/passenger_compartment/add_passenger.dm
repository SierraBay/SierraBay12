/mob/living/exosuit/proc/enter_passenger(mob/user, place)// Пытается пихнуть на пассажирское место пассажира, перед этим ещё раз проверяя их
	//Проверка спины
	src.visible_message(SPAN_NOTICE(" [user] начинает залезать на спину [src]."))
	if(do_after(user, 2 SECONDS, get_turf(src),DO_SHOW_PROGRESS|DO_FAIL_FEEDBACK|DO_USER_CAN_TURN| DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
		if(!user.Adjacent(src)) // <- Мех рядом?
			return FALSE
		if(user.r_hand != null && user.l_hand != null)
			to_chat(user,SPAN_WARNING("Мне нужна хотя бы одна свободная рука."))
			return
		if(place == "Левый бок" && !passenger_compartment.left_back_passenger)
			passenger_compartment.left_back_passenger = user
		else if(place == "Спина" && !passenger_compartment.back_passenger)
			passenger_compartment.back_passenger = user
		else if(place == "Правый бок" && !passenger_compartment.right_back_passenger)
			passenger_compartment.right_back_passenger = user
		else
			to_chat(user,SPAN_NOTICE("[place] занят."))
			return
		user.forceMove(passenger_compartment)
		src.visible_message(SPAN_NOTICE(" [user] влез на [src]."))
		passenger_compartment.count_passengers()
		update_passengers()
