/mob/living/exosuit/proc/enter_passenger(mob/user, place)// Пытается пихнуть на пассажирское место пассажира, перед этим ещё раз проверяя их
	//Проверка спины
	src.visible_message(SPAN_NOTICE(" [user] starts climb on the [place] of [src]!"))
	if(do_after(user, 2 SECONDS, get_turf(src),DO_SHOW_PROGRESS|DO_FAIL_FEEDBACK|DO_USER_CAN_TURN| DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
		if(!user.Adjacent(src)) // <- Мех рядом?
			return FALSE
		if(user.r_hand != null || user.l_hand != null)
			to_chat(user,SPAN_NOTICE("You need two free hands to clim on[place] of [src]."))
			return
		if(place == "Back" && LAZYLEN(passenger_compartment.back_passengers) == 0)
			user.forceMove(passenger_compartment)
			LAZYDISTINCTADD(passenger_compartment.back_passengers,user)
			have_back_passenger = TRUE
			user.pinned += src
		else if(place == "Left back" && LAZYLEN(passenger_compartment.left_back_passengers) == 0)
			user.forceMove(passenger_compartment)
			LAZYDISTINCTADD(passenger_compartment.left_back_passengers,user)
			have_left_passenger = TRUE
			user.pinned += src
		else if(place == "Right back" && LAZYLEN(passenger_compartment.right_back_passengers) == 0)
			user.forceMove(passenger_compartment)
			LAZYDISTINCTADD(passenger_compartment.right_back_passengers,user)
			have_right_passenger = TRUE
			user.pinned += src
		else
			to_chat(user,SPAN_NOTICE("Looks like [place] is busy!"))
			return 0
		src.visible_message(SPAN_NOTICE(" [user] climbed on [place] of [src]!"))
		passenger_compartment.count_passengers()
		update_passengers()
