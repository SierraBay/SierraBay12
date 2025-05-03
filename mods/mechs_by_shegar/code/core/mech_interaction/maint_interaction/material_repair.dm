/mob/living/exosuit/proc/material_interaction(obj/item/tool, mob/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
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
		repair_part.max_hp = repair_part.max_hp - repair_part.repair_damage
		repair_part.unrepairable_damage += repair_part.repair_damage
		if(repair_part.min_damage > repair_part.max_hp)
			repair_part.max_hp = repair_part.min_damage
