// будет использоваться Life() дабы исключить моменты, когда по какой-то причине пассажир слез с меха, лежа на полу. Life вызовется, обработается pinned, всем в кайф.
/mob/living/exosuit/proc/leave_passenger(mob/user)// Пассажир сам покидает меха
	src.visible_message(SPAN_NOTICE("[user] jump off [src]!"))
	user.dropInto(loc)
	user.pinned -= src
	user.Life()
	if(user in passenger_compartment.back_passengers)
		LAZYREMOVE(passenger_compartment.back_passengers,user)
		have_back_passenger = FALSE
	else if(user in passenger_compartment.left_back_passengers)
		LAZYREMOVE(passenger_compartment.left_back_passengers,user)
		have_left_passenger = FALSE
	else if(user in passenger_compartment.right_back_passengers)
		LAZYREMOVE(passenger_compartment.right_back_passengers,user)
		have_right_passenger = FALSE
	passenger_compartment.count_passengers()
	update_passengers()

/mob/living/exosuit/proc/forced_leave_passenger(place,mode,author)// Нечто внешнее насильно опустошает Одно/все места пассажиров
// mode 1 - полный выгруз, mode 2 - рандомного одного, mode 0(Отсутствие мода) - ручной скид пассажира мехводом
	if(mode == MECH_DROP_ALL_PASSENGERS) // Полная разгрузка
		if(LAZYLEN(passenger_compartment.back_passengers)>0)
			for(var/mob/i in passenger_compartment.back_passengers)
				LAZYREMOVE(passenger_compartment.back_passengers,i)
				have_back_passenger = FALSE
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				passenger_compartment.count_passengers()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
		if(LAZYLEN(passenger_compartment.left_back_passengers)>0)
			for(var/mob/i in passenger_compartment.left_back_passengers)
				LAZYREMOVE(passenger_compartment.left_back_passengers,i)
				have_left_passenger = FALSE
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				passenger_compartment.count_passengers()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
		if(LAZYLEN(passenger_compartment.right_back_passengers) > 0)
			for(var/mob/i in passenger_compartment.right_back_passengers)
				LAZYREMOVE(passenger_compartment.right_back_passengers,i)
				have_right_passenger = FALSE
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				passenger_compartment.count_passengers()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
		update_passengers()

	else if(mode == MECH_DROP_ANY_PASSENGER) // Сброс по приоритету спина - левый бок - правый бок.
		if(LAZYLEN(passenger_compartment.back_passengers) > 0)
			for(var/mob/i in passenger_compartment.back_passengers)
				LAZYREMOVE(passenger_compartment.back_passengers,i)
				have_back_passenger = FALSE
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
				passenger_compartment.count_passengers()
				update_passengers()
				return
		else if(LAZYLEN(passenger_compartment.left_back_passengers)>0)
			for(var/mob/i in passenger_compartment.left_back_passengers)
				LAZYREMOVE(passenger_compartment.left_back_passengers,i)
				have_left_passenger = FALSE
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
				passenger_compartment.count_passengers()
				update_passengers()
				return
		else if(LAZYLEN(passenger_compartment.right_back_passengers)>0)
			for(var/mob/i in passenger_compartment.right_back_passengers)
				LAZYREMOVE(passenger_compartment.right_back_passengers,i)
				have_right_passenger = FALSE
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				i.Life()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
				passenger_compartment.count_passengers()
				update_passengers()
				return

	else // <- Опустошается определённое место
		if(place == "Back")
			for(var/mob/i in passenger_compartment.back_passengers)
				have_back_passenger = FALSE
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
				i.dropInto(loc)
				i.pinned -= src
				LAZYREMOVE(passenger_compartment.back_passengers,i)
		else if(place == "Left back")
			for(var/mob/i in passenger_compartment.left_back_passengers)
				have_left_passenger = FALSE
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]!"))
				i.dropInto(loc)
				i.pinned -= src
				LAZYREMOVE(passenger_compartment.left_back_passengers,i)
		else if(place == "Right back")
			for(var/mob/i in passenger_compartment.right_back_passengers)
				have_right_passenger = FALSE
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]!"))
				i.dropInto(loc)
				i.pinned -= src
				LAZYREMOVE(passenger_compartment.right_back_passengers,i)
		passenger_compartment.count_passengers()
		update_passengers()
