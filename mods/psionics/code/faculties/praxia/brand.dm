/singleton/psionic_power/praxia/psionics/brand
	use_intent =      I_HURT
	name =            "Brand"
	cost =            20
	cooldown =        200
	use_grab =        TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Схватите псионика, выберите голову и нажмите по нему захватом на красном интенте, чтобы отметить его на некоторое время. Вы почувствуете, когда он применяет силу, и где."

/singleton/psionic_power/praxia/psionics/brand/invoke(mob/living/user, mob/living/target)
	if(!istype(target) || target == user || user.a_intent != I_HURT || user.zone_sel.selecting != BP_HEAD)
		return FALSE
	if(!target.psi)
		return FALSE
	. = ..()
	if(.)
		if(target.psi.deflect_psionic_attack(user))
			return TRUE
		if(!do_after(user, 2 SECONDS, target))
			return TRUE
		LAZYSET(target.psi.branded_by, user, world.time + ((30 MINUTES) * user.psi.get_rank(PSI_PRAXIA)))
		to_chat(user, SPAN_NOTICE("Ты оставляешь на силе [target] метку. Она продержится около пяти минут."))
		to_chat(target, SPAN_WARNING("Ты чувствуешь на себе чужой пристальный взгляд, от которого не избавиться."))
		return TRUE
