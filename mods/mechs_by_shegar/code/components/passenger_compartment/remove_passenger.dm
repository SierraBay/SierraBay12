///Функция заставляет персонажа покинуть пассажирку меха. Источников может быть много
/mob/living/exosuit/proc/leave_passenger(mob/user)// Пассажир сам покидает меха
	user.dropInto(get_turf(src))
	user.reset_view()
	user.Life()
	if(passenger_compartment.left_back_passenger == user)
		passenger_compartment.left_back_passenger = null
	else if(passenger_compartment.back_passenger == user)
		passenger_compartment.back_passenger = null
	else if(passenger_compartment.right_back_passenger == user)
		passenger_compartment.right_back_passenger = null
	passenger_compartment.count_passengers()
	update_passengers()

/// Нечто внешнее насильно опустошает Одно/все места пассажиров
/mob/living/exosuit/proc/external_leaving_passenger(place, mode)
// MECH_DROP_ALL_PASSENGERS - полный выгруз,MECH_DROP_ANY_PASSENGER - рандомного одного, Отсутствие мода - ручной скид пассажира мехводом
	if(mode == MECH_DROP_ALL_PASSENGERS) // Полная разгрузка
		if(passenger_compartment.left_back_passenger)
			leave_passenger(passenger_compartment.left_back_passenger)
		else if(passenger_compartment.back_passenger)
			leave_passenger(passenger_compartment.back_passenger)
		else if(passenger_compartment.right_back_passenger)
			leave_passenger(passenger_compartment.right_back_passenger)

	else if(mode == MECH_DROP_ANY_PASSENGER) // Сброс по приоритету спина - левый бок - правый бок.
		if(passenger_compartment.left_back_passenger)
			leave_passenger(passenger_compartment.left_back_passenger)
			return
		else if(passenger_compartment.back_passenger)
			leave_passenger(passenger_compartment.back_passenger)
			return
		else if(passenger_compartment.right_back_passenger)
			leave_passenger(passenger_compartment.right_back_passenger)
			return

	else //Определённое место что выбрал сам мехвод
		switch(place)
			if("Спина")
				if(passenger_compartment.left_back_passenger)
					leave_passenger(passenger_compartment.left_back_passenger)
			if("Левый бок")
				if(passenger_compartment.back_passenger)
					leave_passenger(passenger_compartment.back_passenger)
			if("Правый бок")
				if(passenger_compartment.right_back_passenger)
					leave_passenger(passenger_compartment.right_back_passenger)
