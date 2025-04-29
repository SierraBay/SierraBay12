///Ремонт части меха при помощи листа материалов
/proc/material_repair(mob/living/exosuit/mech , obj/item/stack/material/material_sheet, mob/user, user_understand, obj/item/mech_component/repair_part)
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


/obj/item/mech_component/repair_brute_damage(amt)
	take_brute_damage(-amt)
	if(current_hp > 0)
		part_has_been_restored()

/obj/item/mech_component/repair_burn_damage(amt)
	take_burn_damage(-amt)
	if(current_hp > 0)
		part_has_been_restored()

/obj/item/mech_component/take_brute_damage(amt)
	brute_damage = max(0, brute_damage + amt)
	update_health()
	if(total_damage == max_damage)
		part_has_been_destroyed()
		take_component_damage(amt,0)

/obj/item/mech_component/take_burn_damage(amt)
	burn_damage = max(0, burn_damage + amt)
	update_health()
	if(total_damage == max_damage)
		part_has_been_destroyed()
		take_component_damage(0,amt)
