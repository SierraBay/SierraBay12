/singleton/psionic_power/praxia/psionics/brand
	use_intent =      I_HURT
	name =            "Метка"
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

/datum/psi_complexus/proc/notify_brands()
	if(!LAZYLEN(branded_by) || !owner)
		return
	for(var/mob/living/brander in branded_by.Copy())
		if(QDELETED(brander) || world.time >= branded_by[brander])
			branded_by -= brander
			continue
		if(brander.z != owner.z)
			to_chat(brander, SPAN_OCCULT("Метка на [owner] вспыхивает: он применил силу где-то очень далеко."))
		else
			to_chat(brander, SPAN_OCCULT("Метка на [owner] вспыхивает: он применил силу, примерно в [get_dist(brander, owner)] шагах на [dir2text(get_dir(brander, owner))]."))
	if(!LAZYLEN(branded_by))
		branded_by = null
