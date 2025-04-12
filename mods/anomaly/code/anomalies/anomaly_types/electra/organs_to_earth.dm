// Возвращает список конечностей от указанной до земли
/mob/living/carbon/human/proc/list_organs_to_earth(input_organ)
	var/attack_zone = input_organ || get_exposed_defense_zone()

	// Полный ассоциативный список всех возможных путей
	var/static/list/limb_paths = list(
		// Голова и туловище
		BP_HEAD   = list(BP_HEAD, BP_CHEST, BP_GROIN, BP_R_LEG, BP_L_LEG),
		BP_CHEST  = list(BP_CHEST, BP_GROIN, BP_R_LEG, BP_L_LEG),
		BP_GROIN  = list(BP_GROIN, BP_R_LEG, BP_L_LEG),

		// Правая сторона
		BP_R_ARM  = list(BP_R_ARM, BP_CHEST, BP_GROIN, BP_R_LEG, BP_L_LEG),
		BP_R_HAND = list(BP_R_HAND, BP_R_ARM, BP_CHEST, BP_GROIN, BP_R_LEG, BP_L_LEG),

		// Левая сторона
		BP_L_ARM  = list(BP_L_ARM, BP_CHEST, BP_GROIN, BP_R_LEG, BP_L_LEG),
		BP_L_HAND = list(BP_L_HAND, BP_L_ARM, BP_CHEST, BP_GROIN, BP_R_LEG, BP_L_LEG),

		// Ноги
		BP_R_LEG  = list(BP_R_LEG, BP_R_FOOT),
		BP_L_LEG  = list(BP_L_LEG, BP_L_FOOT),
		BP_R_FOOT = list(BP_R_FOOT),
		BP_L_FOOT = list(BP_L_FOOT)
	)

	// Получаем путь для указанной зоны
	var/list/result = limb_paths[attack_zone]?:Copy()

	// Если зона не найдена, возвращаем только её саму
	if(!result)
		return list(attack_zone)

	// Обрабатываем специальные случаи с выбором ноги
	for(var/i in 1 to LAZYLEN(result))
		if(result[i] == BP_R_LEG)
			result[i] = prob(50) ? BP_R_LEG : BP_L_LEG
		else if(result[i] == BP_L_LEG)
			result[i] = prob(50) ? BP_L_LEG : BP_R_LEG

	return result
