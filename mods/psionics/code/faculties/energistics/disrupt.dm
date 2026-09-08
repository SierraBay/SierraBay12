/singleton/psionic_power/energistics/disrupt
	name =            "Disrupt"
	cost =            10
	cooldown =        60
	use_melee =       TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Выберите глаза на красном интенте и нажмите на любой объект, чтобы создать мощный электромагнитный импульс, направленный в него."

/singleton/psionic_power/energistics/disrupt/invoke(mob/living/user, mob/living/target)
	var/en_rank = user.psi.get_rank(PSI_ENERGISTICS)
	if(user.zone_sel.selecting != BP_EYES)
		return FALSE
	if(user.a_intent != I_HURT)
		return FALSE
	if(istype(target, /turf))
		return FALSE
	. = ..()
	if(.)
		if(en_rank == PSI_RANK_GRANDMASTER)
			var/option = input(user, "Выбирай!", "Насколько большой должен быть импульс?") in list("Сконцентрированный", "Бесконтрольный")
			if (!option)
				return
			if(option == "Concentrated")
				new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "blue_electricity_constant")
				target.visible_message(SPAN_DANGER("[user] переполняет [target] энергией, провоцируя внезапное высвобождение ЭМИ-импульса!"))
				empulse(target, 0, 1)
			if(option == "Uncontrolled")
				new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "blue_electricity_constant")
				target.visible_message(SPAN_DANGER("[user] взмахивает рукой, создавая мощную ЭМИ-волну!"))
				empulse(target, 6, 8)
		if(en_rank <= PSI_RANK_OPERANT)
			new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "blue_electricity_constant")
			target.visible_message(SPAN_DANGER("[user] взмахивает рукой, создавая мощный ЭМИ-импульс!"))
			empulse(target, rand(2,4) - en_rank, rand(3,6) - en_rank)
		if(en_rank == PSI_RANK_MASTER)
			new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "blue_electricity_constant")
			target.visible_message(SPAN_DANGER("[user] взмахивает рукой, создавая мощный ЭМИ-импульс!"))
			empulse(target, 1, 2)
		return TRUE
