/singleton/psionic_power/redaction/cleanse
	name =            "Cleanse"
	cost =            9
	cooldown =        60
	use_melee =       TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Нажмите по цели на зелёном интенте, чтобы очистить его от генетических отклонений и воздействий радиации."

/singleton/psionic_power/redaction/cleanse/invoke(mob/living/user, mob/living/carbon/human/target)
	if(!istype(user) || !istype(target))
		return FALSE
	. = ..()
	if(.)
		// No messages, as Mend procs them even if it fails to heal anything, and Cleanse is always checked after Mend.
		var/removing = rand(20,25)
		if(target.radiation)
			to_chat(user, SPAN_NOTICE("Вы выводите нежелательные частицы из тела [target]..."))
			if(target.radiation > removing)
				target.radiation -= removing
			else
				target.radiation = 0
			return TRUE
		if(target.getCloneLoss())
			to_chat(user, SPAN_NOTICE("Вы с трудом восстанавливаете прежнюю структуру ДНК [target]..."))
			if(target.getCloneLoss() >= removing)
				target.adjustCloneLoss(-removing)
			else
				target.adjustCloneLoss(-(target.getCloneLoss()))
			return TRUE
		to_chat(user, SPAN_NOTICE("У [target] нет ни радиационного заражения, ни генетических отклонений."))
		return FALSE
