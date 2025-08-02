/client/proc/check_cybernetic_avability()
	//Аугменты
	for(var/augment in prefs.augments_list)
		var/aug_singl_type = prefs.augments_list[augment]
		if(aug_singl_type == "Пусто")
			continue
		var/singleton/cyber_choose/augment/augment_choose_prototype = GET_SINGLETON(text2path(aug_singl_type))
		if(!augment_choose_prototype)
			continue

		if(!augment_choose_prototype.check_avaibility(prefs)) //Протез/аугмент/имплант недоступен
			to_chat(src, SPAN_BAD("ВНИМАНИЕ, ошибка загрузки аугментов персонажа. Обратитесь в меню cybernetics в лодауте и проверьте, чтоб все выбранные вами аугменты не были окрашены в красный цвет."))
			return FALSE


	//Конечности
	for(var/limb_name in prefs.limb_list)
		var/limb_type = prefs.limb_list[limb_name]
		if(limb_type == "Пусто")
			continue

		var/singleton/cyber_choose/limb/data = GET_SINGLETON(text2path(limb_type))
		if(!data.check_avaibility(prefs)) //Протез/аугмент/имплант недоступен
			to_chat(src, SPAN_BAD("ВНИМАНИЕ, ошибка загрузки конечность персонажа. Обратитесь в меню cybernetics в лодауте и проверьте, чтоб все выбранные вами конечности не были окрашены в красный цвет."))
			return FALSE

	//Органы
	for(var/organ_name in prefs.organ_list)
		var/organ_type = prefs.organ_list[organ_name]
		if(organ_type == "Пусто")
			continue

		var/singleton/cyber_choose/organ/organ_data = GET_SINGLETON(text2path(organ_type))
		if(!organ_data.check_avaibility(prefs)) //Протез/аугмент/имплант недоступен
			to_chat(src, SPAN_BAD("ВНИМАНИЕ, ошибка загрузки органов персонажа. Обратитесь в меню cybernetics в лодауте и проверьте, чтоб все выбранные вами органы не были окрашены в красный цвет."))
			return FALSE
	return TRUE

/client/proc/join_avaible_by_loadout()
	if(!config || config.max_gear_cost == INFINITY)
		return TRUE
	var/total_price = 0
	for(var/gear_name in prefs.gear_list[prefs.gear_slot])
		var/datum/gear/G = gear_datums[gear_name]
		if(istype(G))
			total_price += G.cost

	for(var/aug_type in prefs.augments_list)
		var/singleton/cyber_choose/augment/aug = GET_SINGLETON(text2path(prefs.augments_list[aug_type]))
		if(!aug)
			continue
		total_price += aug.loadout_price

	if(total_price > config.max_gear_cost)
		to_chat(usr, SPAN_BAD("Количество очков лодаута больше, чем вы можете себе позволить. Уберите лишние аугменты или вещи."))
		return FALSE

	return TRUE
