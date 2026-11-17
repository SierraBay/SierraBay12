/singleton/psionic_power/praxia/psionics/burnout
	use_intent =      I_HURT
	name =            "Burnout"
	cost =            60
	cooldown =        1200
	use_grab =        TRUE
	min_rank =        PSI_RANK_MASTER
	use_description = "Схватите псионика, выберите глаза и нажмите по нему захватом на красном интенте, чтобы выжечь его запас сил и надолго оглушить. Отдача сильно бьёт и по вам."

/singleton/psionic_power/praxia/psionics/burnout/invoke(mob/living/user, mob/living/target)
	if(!istype(target) || target == user || user.a_intent != I_HURT || user.zone_sel.selecting != BP_EYES)
		return FALSE
	if(!target.psi)
		to_chat(user, SPAN_NOTICE("У [target] нечего выжигать."))
		return FALSE
	. = ..()
	if(.)
		if(target.psi.deflect_psionic_attack(user))
			return TRUE
		if(!do_after(user, 4 SECONDS, target))
			return FALSE
		if(prob(contest_chance(user, target)))
			target.psi.stamina = 0
			target.psi.suppressed = 0
			target.psi.backblast(rand(2, 5))
			to_chat(user, SPAN_WARNING("Ты перенапрягаешь [target]."))
			to_chat(target, SPAN_DANGER("Что-то выжигает твою силу изнутри, оставляя пустоту."))
			target.apply_damage(15, DAMAGE_PAIN, BP_HEAD)
		else
			to_chat(user, SPAN_DANGER("[target] переосилил твое воздействие!"))
			user.psi.backblast(rand(5, 10))
			user.apply_damage(15, DAMAGE_PAIN, BP_HEAD)
		return TRUE
