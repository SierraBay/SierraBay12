/mob/living/exosuit/proc/id_card_interaction(obj/item/tool, mob/user)
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
