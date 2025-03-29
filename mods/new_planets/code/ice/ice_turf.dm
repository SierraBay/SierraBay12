//СКАЛОЛАЗАНЬЕ
/turf/simulated/mineral/ice
	//По горе кто-то уже лезет
	var/busy_by_climber = FALSE

/turf/simulated/mineral/ice/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, SPAN_GOOD("Перетащите спрайт персонажа на гору для скалолазанья."))

/turf/simulated/mineral/ice/MouseDrop(atom/over_atom, atom/source_loc, atom/over_loc, source_control, over_control, list/mouse_params)
	if(!over_atom || !ishuman(over_atom) || isghost(over_atom))
		return
	var/mob/living/carbon/human/human = over_atom
	if(busy_by_climber)
		to_chat(human, SPAN_BAD("Кто-то тут уже лезет."))
		return
	if(human.get_stamina() < 60)
		to_chat(human, SPAN_BAD("Я слишком устал!"))
		return


/turf/simulated/mineral/ice/CanPass(atom/movable/mover, turf/target, height, air_group)
	if(istype(mover, /mob/living/carbon/human)) //Если пытается шагнуть человек - он может взабраться на скалу
		if(!istype(mover.loc, /turf/simulated/mineral/ice))
			var/mob/living/carbon/human/user = mover
			if(user.stamina < 60)
				to_chat(mover, SPAN_BAD("Я слишком устал!"))
				return
			visible_message("[user] начинает взбираться вверх по склону.", "Вы слышите как кто-то залезает вверх по склону.", 5)
			if(do_after(user, (15 SECONDS - (2 SECONDS *user.get_skill_value(SKILL_HAULING)))))
				//Помощь друга даёт 25 процентов на успех и не даёт пораниться при падении
				//Макс бонус от навыка составит 50 процентов
				//Бонус от кирки при подьёме составит 25 процентов
				var/helper_chance = 0
				var/pickaxe_chance = 0
				for(var/mob/living/carbon/human/helper in src)
					if(helper.a_intent == I_HELP && turn(user.dir, 180) == helper.dir) //Лезущий и помощник должны смотреть друг другу в лицо
						helper_chance = 25
						to_chat(user, SPAN_GOOD("[helper] помогает вам взобраться на скалу."))
						to_chat(helper, SPAN_GOOD("Вы помогаете [user] взобраться на скалу."))
						break //Помощник найден
				if(user.IsHolding(/obj/item/pickaxe))
					to_chat(user, SPAN_NOTICE("Вам куда легче взбираться вверх с киркой."))
					pickaxe_chance = 25
				var/success_chance = (10 * user.get_skill_value(SKILL_HAULING)) + helper_chance + pickaxe_chance //Максимально - 100 процентов
				if(prob(success_chance))
					user.forceMove(get_turf(src))
					to_chat(user, SPAN_GOOD("Вы успешно взбираетесь на гору."))
				else
					var/list/result_effects = calculate_artefact_reaction(user, "Падение с высоты")
					if(result_effects)
						if(result_effects.Find("Защищает от падения"))
							to_chat(user, SPAN_GOOD("Вы срываетесь вниз, но что-то ловит вас прямо у земли, оберегая от повреждений."))
							return
					if(!helper_chance) //Нам никто не помог
						for(var/picked_organ in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT))
							user.apply_damage(2.5, DAMAGE_BRUTE, picked_organ, used_weapon="Gravitation")
						user.adjust_stamina(-50)
						to_chat(user, SPAN_BAD("Вы срываетесь вниз, ударяясь в процессе."))
					else
						user.adjust_stamina(-50)
						to_chat(user, SPAN_COLOR("#ffa500","Вы срываетесь вниз, но стоящий сверху удерживает вас, предотвращая ранения."))

		else
			mover.forceMove(get_turf(src))
	. = ..()

/turf/simulated/mineral/ice/Exit(O, newloc)
	if(istype(O, /mob/living/carbon/human) && !istype(newloc,/turf/simulated/mineral/ice)) //Человек пытается слезть с скалы
		var/mob/living/carbon/human/user = O
		if(do_after(user, (15 SECONDS - (2 SECONDS * user.get_skill_value(SKILL_HAULING))))) //Чем лучше атлетика, тем быстрее спуск
			//Помощь друга даёт 25 процентов на успех и не даёт пораниться при падении
			//Макс бонус от навыка составит 50 процентов
			//Бонус от кирки при подьёме составит 25 процентов
			var/helper_chance = 0
			var/pickaxe_chance = 0
			for(var/mob/living/carbon/human/helper in newloc)
				if(helper.a_intent == I_HELP && turn(user.dir, 180) == helper.dir) //Лезущий и помощник должны смотреть друг другу в лицо
					helper_chance = 25
				to_chat(user, SPAN_GOOD("[helper] помогает вам взобраться на скалу."))
				to_chat(helper, SPAN_GOOD("Вы помогаете [user] взобраться на скалу."))
				break //Помощник найден
			if(user.IsHolding(/obj/item/pickaxe))
				to_chat(user, SPAN_NOTICE("Вам куда легче взбираться вверх с киркой."))
				pickaxe_chance = 25
			var/success_chance = (10 * user.get_skill_value(SKILL_HAULING)) + helper_chance + pickaxe_chance //Максимально - 100 процентов
			if(prob(success_chance))
				to_chat(user, SPAN_GOOD("Вы аккуратно слезаете со скалы."))
				user.forceMove(newloc)
			else
				var/list/result_effects = calculate_artefact_reaction(user, "Падение с высоты")
				if(result_effects)
					if(result_effects.Find("Защищает от падения"))
						to_chat(user, SPAN_GOOD("Вы срываетесь вниз, но что-то ловит вас прямо у земли, оберегая от повреждений."))
						return
				if(!helper_chance)
					to_chat(user, SPAN_BAD("Вы срываетесь вниз со скалы."))
					for(var/picked_organ in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT))
						user.apply_damage(5, DAMAGE_BRUTE, picked_organ, used_weapon="Gravitation")
					user.adjust_stamina(-100)
					user.forceMove(newloc)
				else
					to_chat(user, SPAN_COLOR("#ffa500", "Вы срываетесь вниз со скалы, но вас ловят предотвращая ранения."))
					user.adjust_stamina(-100)
					user.forceMove(newloc)
		else
			return FALSE
	. = ..()
