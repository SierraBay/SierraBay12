/mob/living/exosuit/add_pilot(mob/user)
	. = ..()
	to_chat(user,SPAN_NOTICE("<b><font color = green> Press Middle mouse button for fast swap current hardpoint. </font></b>"))
	to_chat(user,SPAN_NOTICE("<b><font color = green> Press SPACE mouse for toggle strafe mod. </font></b>"))

/mob/living/exosuit/remove_pilot(mob/user)
	. = ..()
	clear_sensors_effects(user)


/mob/living/exosuit/proc/check_passenger(mob/user) // Выбираем желаемое место, проверяем можно ли его занять, стартуем прок занятия
	var/local_dir = get_dir(src, user)
	if(local_dir != turn(dir, 90) && local_dir != turn(dir, -90) && local_dir != turn(dir, -135) && local_dir != turn(dir, 135) && local_dir != turn(dir, 180))
	// G G G
	// G M G  ↓ (Mech dir, look on SOUTH)
	// B B B
	// M - mech, B - cant climb ON mech from this side, G - can climb ON mech from this side
		to_chat(user, SPAN_WARNING("You cant climb in passenger place of [src ] from this side."))
		return FALSE
	var/choose
	var/choosed_place = input(usr, "Choose passenger place which you want to take.", name, choose) as null|anything in passenger_places
	if(!user.Adjacent(src)) // <- Мех рядом?
		return FALSE
	if(user.r_hand != null || user.l_hand != null)
		to_chat(user,SPAN_NOTICE("You need two free hands to take [choosed_place]."))
		return
	if(user.mob_size > MOB_MEDIUM)
		to_chat(user,SPAN_NOTICE("Looks like you too big to take [choosed_place]."))
		return
	if(choosed_place == "Back")
		if(LAZYLEN(passenger_compartment.back_passengers) > 0)
			to_chat(user,SPAN_NOTICE("[choosed_place] is busy"))
			return 0
		else if(body.allow_passengers == FALSE)
			to_chat(user,SPAN_NOTICE("[choosed_place] not able with [body.name]"))
			return 0
	else if(choosed_place == "Left back")
		if(LAZYLEN(passenger_compartment.left_back_passengers) > 0)
			to_chat(user,SPAN_NOTICE("[choosed_place] is busy"))
			return 0
		else if(arms.allow_passengers == FALSE)
			to_chat(user,SPAN_NOTICE("[choosed_place] not able with [arms.name]"))
			return 0
	else if(choosed_place == "Right back")
		if(LAZYLEN(passenger_compartment.right_back_passengers) > 0)
			to_chat(user,SPAN_NOTICE("[choosed_place] is busy"))
			return 0
		else if(arms.allow_passengers == FALSE)
			to_chat(user,SPAN_NOTICE("[choosed_place] not able with [arms.name]"))
			return 0
	else if(!choosed_place)
		return 0
	if(check_hardpoint_passengers(choosed_place,user) == TRUE)
		enter_passenger(user,choosed_place)

/mob/living/exosuit/proc/check_hardpoint_passengers(place,mob/user)// Данный прок проверяет, доступна ли часть тела для занятия её пассажиром в данный момент
	var/obj/item/mech_equipment/checker
	if(place == "Back" && hardpoints["back"] != null)
		checker = hardpoints["back"]
		if(checker.disturb_passengers == TRUE)
			to_chat(user,SPAN_NOTICE("[place] covered by [checker] and cant be taked."))
			return FALSE
	else if(place == "Left back" && hardpoints["left shoulder"] != null)
		checker = hardpoints["left shoulder"]
		if(checker.disturb_passengers == TRUE)
			to_chat(user,SPAN_NOTICE("[place] covered by [checker] and cant be taked."))
			return FALSE
	else if(place == "Right back" && hardpoints["right shoulder"] != null)
		checker = hardpoints["right shoulder"]
		if(checker.disturb_passengers == TRUE)
			to_chat(user,SPAN_NOTICE("[place] covered by [checker] and cant be taked."))
			return FALSE
	return TRUE

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
	if(mode == MECH_DROP_ALL_PASSENGER) // Полная разгрузка
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

/mob/living/exosuit/use_tool(obj/item/tool, mob/user, list/click_params)
	if(istype(tool, /obj/item/card/id))// Мы тычем ID картой в меха, словно ключами от иномарки.
		if(inmech(user, src))
			to_chat(user, "You cannot interacti with mech inside mech.")
			return
		//Если есть пилоты, мы никому ничего не откроем
		if(LAZYLEN(pilots))
			to_chat(user, SPAN_WARNING("There is somebody inside, ID scaner ignores you."))
			return
		var/user_undertand = FALSE // <-Персонаж пытающийся взаимодействовать ID-картой имеет опыт в мехах?
		if(user.skill_check(SKILL_DEVICES , SKILL_BASIC) && user.skill_check(SKILL_MECH , SKILL_BASIC))
			user_undertand = TRUE // <- Мы даём пользователю больше информации
		if(power != MECH_POWER_ON)
			if(user_undertand)
				to_chat(user, "[src] is turned off, external LEDs are inactive. Obviously the ID scanner is not working.")
				return
			else
				to_chat(user, "Nothing happens")
				return
		if(!id_holder) //К меху ничего не привязано
			if(user_undertand)
				to_chat(user, "[src] does not react in any way to your action. It looks like there is simply no ID card connected to it")
				return
			else
				to_chat(user, "Nothing happens")
				return
		if(id_holder) //У меха ЕСТЬ записанный доступ
			if(id_holder == "EMAGED")
				to_chat(user, "Nothing happens")
				return
			var/obj/item/card/id/card = tool
			if(has_access(id_holder, card.access)) //Доступ в мехе и карте совпадают!
				if(user_undertand)
					to_chat(user, "[src] accepted your ID card.")
				src.visible_message("Green LED's of [src] blinks.", "your ID scanner has found a suitable card", "You hear an approving chirp", 7)
				selftoggle_mech_hatch_close() //Мех изменит своё состояние на обратное (Откроется, или закроется)
				selftoggle_mech_hatch_lock()
				return
			else//Доступы не совпадают
				if(user_undertand)
					to_chat(user, "[src] access does not match access on this ID card, access is denied. ")
					return
				else
					to_chat(user, "Red LED's of [src] blinks")
					return


	if(istype(tool, /obj/item/stack/material))
		if(inmech(user, src))
			to_chat(user, "You cannot interacti with mech inside mech.")
			return
		var/obj/item/mech_component/choice = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
		if(!choice)
			return
		if(choice.current_hp > choice.max_repair)
			to_chat(user, "This part does not require repair.")
			return
		var/obj/item/stack/material/material_sheet = tool
		var/user_undertand = FALSE // <-Персонаж пытающийся провернуть ремонт что-то смыслит в мехах для ремонта.
		if(user.skill_check(SKILL_DEVICES , SKILL_TRAINED) && user.skill_check(SKILL_CONSTRUCTION, SKILL_BASIC))
			user_undertand = TRUE // <- Мы даём пользователю больше информации, разрешаем проводить ремонт
		if(choice && choice.req_material != material_sheet.default_type)
			if(user_undertand)
				to_chat(user, "My experience tells me that this material is not suitable for repairs this part. I need [choice.req_material]")
				return
			else
				to_chat(user, "I don’t know anything about bellows repair, I stand there and look at him like an idiot.")
				return
		material_repair(src, material_sheet, user, user_undertand, choice)


	//Saw/welder - destroy mech security bolts
	if( ((istype(tool, /obj/item/circular_saw)) || (isWelder(tool))) && user.a_intent == I_HURT)
		if(inmech(user, src))
			to_chat(user, "You cannot interacti with mech inside mech.")
			return
		if (!body)
			USE_FEEDBACK_FAILURE("\The [src] has no cockpit to force.")
			return FALSE
		if (!hatch_locked)
			USE_FEEDBACK_FAILURE("\The [src]'s cockpit isn't locked, you can't reach cockpit security bolts.")
			return FALSE
		var/delay = min(100 * user.skill_delay_mult(SKILL_DEVICES), 100 * user.skill_delay_mult(SKILL_EVA))
		visible_message(SPAN_NOTICE("\The [user] starts destroing the \the [src]'s [body.name] security bolts "))
		if(!do_after(user, delay, src, DO_DEFAULT | DO_PUBLIC_PROGRESS))
			return
		playsound(src, 'sound/machines/bolts_up.ogg', 25, TRUE)
		hatch_locked = FALSE
		body.hatch_bolts_status = BOLTS_DESTROYED
		hud_open.update_icon()
		update_icon()
		return TRUE
	.=..()


/proc/material_repair( mob/living/exosuit/mech , obj/item/stack/material/material_sheet, mob/user, user_understand, obj/item/mech_component/repair_part)
	//Выполняем первую проверку ПЕРЕД началом ремонта
	//Убедимся кто цель ремонта.
	var/atom/target
	if(!mech)
		target = repair_part
	else
		target = mech
	if(!user.Adjacent(target)) // <- Мех рядом?
		return FALSE
	//Определим в какой руке материал
	var/obj/item/stack/material/sheet_hand
	var/obj/item/weldingtool/welder_hand
	// Мы определяем в какой руке лежит материал
	if(user.r_hand != material_sheet)
		sheet_hand = user.l_hand
		if(isWelder(user.r_hand))
			welder_hand = user.r_hand
		else
			to_chat(user,SPAN_NOTICE("You need welding in the other hand."))
			return
	else
		sheet_hand = user.r_hand
		if(isWelder(user.l_hand))
			welder_hand = user.l_hand
		else
			to_chat(user,SPAN_NOTICE("You need welding in the other hand."))
			return
	if(!welder_hand.can_use(1, user)) //Сварка включена и достаточно топлива?
		return
	//Мы узнали в какой руке лежит материал, в какой сварка и готова ли она к работе. Теперь мы переходим к самому ремонту.
	var/delay = 20 SECONDS - (user.get_skill_value(SKILL_DEVICES)*3 + user.get_skill_value(SKILL_CONSTRUCTION))
	if(do_after(user, delay, target, DO_REPAIR_CONSTRUCT))
		if(!welder_hand.remove_fuel(1, user))
			return
		sheet_hand.use(1)
		if(!user_understand)
			var/num = rand(1,100)
			if(num < 90)
				USE_FEEDBACK_FAILURE("Nothing worked for me, I just wasted the material, after my repair attempt, a sheet of material fell off part of it..")
				return
		var/repair_ammount = 50 +  ((user.get_skill_value(SKILL_DEVICES) +  user.get_skill_value(SKILL_CONSTRUCTION)) * 7)
		repair_part.repair_brute_damage(repair_ammount)
		repair_part.max_damage = repair_part.max_damage - repair_part.repair_damage
		repair_part.unrepairable_damage += repair_part.repair_damage
		if(repair_part.min_damage > repair_part.max_damage)
			repair_part.max_damage = repair_part.min_damage

/mob/living/exosuit/proc/selftoggle_mech_hatch_close()
	playsound(src.loc, 'mods/mechs_by_shegar/sounds/mech_peek.ogg', 80, 0, -6)
	//Данный прок выполняет простейшую задачу, либо открывает, либо закрывает меха без участвия человека.
	if(hatch_closed) // <- Кабина закрыта?
		hatch_closed = FALSE
		playsound(src.loc, 'sound/machines/suitstorage_cycledoor.ogg', 50, 1, -6)
	else // <- кабина открыта
		hatch_closed = TRUE
		playsound(src.loc, 'sound/machines/suitstorage_cycledoor.ogg', 50, 1, -6)
	hud_open.update_icon()
	update_icon()
	need_update_sensor_effects = TRUE

/mob/living/exosuit/proc/selftoggle_mech_hatch_lock()
	if(hatch_locked) // <- Замок включен
		hatch_locked = FALSE //<- выключили замок
		playsound(src.loc, 'sound/machines/suitstorage_lockdoor.ogg', 50, 1, -6)
	else
		hatch_locked = TRUE
		playsound(src.loc, 'sound/machines/suitstorage_lockdoor.ogg', 50, 1, -6)
	update_icon()
	need_update_sensor_effects = TRUE

/mob/living/exosuit/proc/selfopen_mech_hatch()
	playsound(src.loc, 'mods/mechs_by_shegar/sounds/mech_peek.ogg', 80, 0, -6)
	//Данный прок выполняет простейшую задачу, либо открывает, либо закрывает меха без участвия человека.
	if(hatch_closed) // <- Кабина закрыта?
		if(hatch_locked) // <- Замок включен
			hatch_locked = FALSE //<- выключили замок
			playsound(src.loc, 'sound/machines/suitstorage_lockdoor.ogg', 50, 1, -6)
		hatch_closed = FALSE
		playsound(src.loc, 'sound/machines/suitstorage_cycledoor.ogg', 50, 1, -6)
	update_icon()
	need_update_sensor_effects = TRUE

/mob/living/exosuit/emag_act(remaining_charges, mob/user, emag_source)
	id_holder = "EMAGED"
	selfopen_mech_hatch()
