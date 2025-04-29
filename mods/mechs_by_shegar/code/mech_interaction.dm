/mob/living/exosuit/add_pilot(mob/user)
	. = ..()
	to_chat(user,SPAN_NOTICE("<b><font color = green> Press Middle mouse button for fast swap current hardpoint. </font></b>"))
	to_chat(user,SPAN_NOTICE("<b><font color = green> Press SPACE mouse for toggle strafe mod. </font></b>"))

/mob/living/exosuit/remove_pilot(mob/user)
	. = ..()
	clear_sensors_effects(user)


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
