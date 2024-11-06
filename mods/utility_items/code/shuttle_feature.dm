/obj/overmap/visitable/ship
	//Большие суда НЕ УМЕЮТ скидывать с себя другие суда
	var/can_throw_off = FALSE
/obj/overmap/visitable/ship/landable
	//Маленькие суда способные садится как раз таки умеют скидывать с себя другие суда
	can_throw_off = TRUE


/obj/machinery/computer/ship/helm
	var/last_throw_off = 0
	var/throw_off_cooldown = 10 SECONDS

//Смысл фичи в том, что шаттл может сбросить с себя "Подсосов" (Тех кто подлетел к судну, но не состыковался)
//Работает оно так, что все судна которые сбрасываются, просто отлетают на свой Space(Свой пустой космос)
/obj/machinery/computer/ship/helm/proc/Throw_off_the_pursuers(mob/living/user)
	if(!linked.can_throw_off)
		to_chat(user, SPAN_BAD("This ship cant use this maneuver."))
		return
	if(!LAZYLEN(contents))
		to_chat(user, SPAN_BAD("No ships close to our ship."))
		return


	//SKILL расчёт и КД
	var/iniciator_pilot_skill = user.get_skill_value(SKILL_PILOT)
	if(iniciator_pilot_skill == 1)
		throw_off_cooldown = 120 SECONDS
	else if(iniciator_pilot_skill == 2)
		throw_off_cooldown = 90 SECONDS
	else if(iniciator_pilot_skill == 3)
		throw_off_cooldown = 60 SECONDS
	else if(iniciator_pilot_skill == 4)
		throw_off_cooldown = 45 SECONDS
	else if(iniciator_pilot_skill == 5)
		throw_off_cooldown = 30 SECONDS


	if(world.time - last_throw_off  <= throw_off_cooldown)
		to_chat(user, SPAN_BAD("Ship still not ready for throw-off maneuver"))
		return
	last_throw_off = world.time
	for(var/obj/overmap/visitable/ship/landable/picked_shuttle in linked.contents) // <- Выбираем все судна, которые подлетели к нам
		var/mob/living/oponent_pilot
		var/success = FALSE
		for(var/obj/machinery/computer/ship/helm/picked_control_console  in picked_shuttle.consoles)
			oponent_pilot = picked_control_console.current_operator
			break

		if(!oponent_pilot) //Если у судна противника нет пилота, попросту некому сопротивляться увороту
			success = TRUE
		else
			var/need_calculate_chance = TRUE
			var/oponent_skill = oponent_pilot.get_skill_value(SKILL_PILOT)
			if((iniciator_pilot_skill - oponent_skill) > 2) //Автоуспех
				success = TRUE
				need_calculate_chance = FALSE
			else if((oponent_skill - iniciator_pilot_skill) > 2) //Автопровал
				success = FALSE
				need_calculate_chance = FALSE
			if(need_calculate_chance)
				if(prob(50 + (iniciator_pilot_skill - oponent_skill * 25) )) //у нас возможна разница в 1 число, т.е либо 25 процентов успеха, либо 75 процентов успеха, либо 50 процентов успеха если навыки равны
					success = FALSE



		if(success)
			if(oponent_pilot)
				to_chat(oponent_pilot, SPAN_BAD("Вас сбросили с хвоста!"))
			to_chat(user, SPAN_GOOD("Вы успешно сбросили с хвоста судно [picked_shuttle.shuttle]."))
			linked.burn()
			var/datum/shuttle/shuttle_datum = SSshuttle.shuttles[picked_shuttle.shuttle]
			shuttle_datum.attempt_move(picked_shuttle.landmark) //<- Заставляем отлететь от нас на свой спейс
		else
			if(oponent_pilot)
				to_chat(oponent_pilot, SPAN_GOOD("Вас попытались сбросить с хвоста, но вы смогли удержать судно рядом."))
			to_chat(user, SPAN_BAD("Вы не смогли сбросить с хвоста [picked_shuttle.shuttle]."))
