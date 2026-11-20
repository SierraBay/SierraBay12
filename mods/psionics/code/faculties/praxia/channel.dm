/singleton/psionic_power/praxia/psionics/channel
	use_intent =      I_GRAB
	name =            "Обмен"
	cost =            5
	cooldown =        100
	use_grab =        TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Схватите другого псионика, выберите руки или кисти и нажмите по нему захватом на жёлтом интенте, чтобы забрать или передать часть своего потенциала, повышая или понижая свой запас сил."

/singleton/psionic_power/praxia/psionics/channel/invoke(mob/living/user, mob/living/target)
	if(!istype(target) || target == user || user.a_intent != I_GRAB || !(user.zone_sel.selecting in BP_ARMS_HANDS))
		return FALSE
	if(!target.psi)
		to_chat(user, SPAN_NOTICE("[target] не пробужден."))
		return FALSE
	. = ..()
	if(.)
		var/amount = round(min(target.psi.max_stamina, user.psi.max_stamina))
		if(amount <= 20)
			to_chat(user, SPAN_NOTICE("Передавать нечего"))
			return TRUE
		var/choice = alert(user, "Ты хочешь", "", "Забрать", "Отдать", "Передумать")
		switch(choice)
			if("Забрать")
				if(target.psi.deflect_psionic_attack(user))
					return TRUE
				target.psi.max_stamina -= floor(target.psi.max_stamina / (7 - user.psi.get_rank(PSI_PRAXIA)))
				user.psi.max_stamina += floor(target.psi.max_stamina / (7 - user.psi.get_rank(PSI_PRAXIA)))
				target.psi.ui?.update_icon()
				user.psi.ui?.update_icon()
				to_chat(user, SPAN_WARNING("Ты забираешь у [target] часть энергии."))
				to_chat(target, SPAN_WARNING("Ты слабеешь."))
				return TRUE
			if("Отдать")
				target.psi.max_stamina += floor(user.psi.max_stamina / (7 - user.psi.get_rank(PSI_PRAXIA)))
				user.psi.max_stamina -= floor(user.psi.max_stamina / (7 - user.psi.get_rank(PSI_PRAXIA)))
				target.psi.ui?.update_icon()
				user.psi.ui?.update_icon()
				to_chat(user, SPAN_NOTICE("Ты отдаёшь [target] часть своей силы."))
				to_chat(target, SPAN_NOTICE("Чужая сила вливается в тебя."))
				return TRUE
			if("Передумать")
				return TRUE
