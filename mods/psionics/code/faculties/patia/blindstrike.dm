/singleton/psionic_power/patia/coercion/blindstrike
	use_intent =     I_DISARM
	name =           "Blindstrike"
	cost =           25
	cooldown =       120
	use_ranged =     TRUE
	min_rank =       PSI_RANK_OPERANT
	use_description = "Выберите глаза и переключитесь на синий интент. Затем, нажмите куда угодно чтобы применить круговую атаку, слепящую и оглушающую всех, кто оказался поблизости."

/singleton/psionic_power/patia/coercion/blindstrike/invoke(mob/living/user, atom/target)
	if(user.zone_sel.selecting != BP_EYES)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(SPAN_DANGER("[user] закидывает голову назад, издавая пронзительный крик!"))
		to_chat(user, SPAN_DANGER("Я издаю пронзительный крик, оглушая всех вокруг!"))
		var/cn_rank = user.psi.get_rank(PSI_PATIA)
		for(var/mob/living/M in range(user, user.psi.get_rank(PSI_PATIA)))
			if(M == user)
				continue
			if(M.disrupts_psionics())
				return
			if(M.psi?.deflect_psionic_attack(user))
				return
			if(prob(cn_rank * 20) && iscarbon(M))
				var/mob/living/carbon/C = M
				if(C.can_feel_pain())
					M.emote("scream")
			to_chat(M, SPAN_DANGER("Ты ощущаешь, как земля уходит у тебя из под ног!"))
			M.flash_eyes()
			new /obj/temporary(get_turf(user),6, 'icons/effects/effects.dmi', "summoning")
			new /obj/temporary(get_turf(M),3, 'icons/effects/effects.dmi', "purple_electricity_constant")
			M.eye_blind = max(M.eye_blind,cn_rank)
			M.ear_deaf = max(M.ear_deaf,cn_rank * 2)
			M.mod_confused(cn_rank * rand(1,3))
		return TRUE
