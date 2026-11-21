/singleton/psionic_power/praxia/psionics/catalyst
	use_intent =      I_HURT
	name =            "Catalyst"
	cost =            50
	cooldown =        1200
	use_grab =        TRUE
	min_rank =        PSI_RANK_GRANDMASTER
	use_description = "Схватите существо со скрытым потенциалом, выберите грудь и нажмите по нему захватом на красном интенте, чтобы принудительно запустить его пробуждение. Он сам выберет способности, но вы заплатите болью."

/singleton/psionic_power/praxia/psionics/catalyst/invoke(mob/living/user, mob/living/target)
	if(!istype(target) || target == user || user.a_intent != I_HURT || user.zone_sel.selecting != BP_CHEST)
		return FALSE
	. = ..()
	if(.)
		if(!target.psi || !LAZYLEN(target.psi.latencies))
			to_chat(user, SPAN_WARNING("В [target] нет скрытого потенциала, который можно разбудить!"))
			user.psi.backblast(rand(5, 25))
			return TRUE
		if(target.psi.pending_awakening)
			to_chat(user, SPAN_NOTICE("[target] уже пробуждается."))
			return TRUE
		user.visible_message(SPAN_DANGER("[user] вжимает ладони в грудь [target]."))
		to_chat(target, SPAN_DANGER("Что-то глубоко внутри тебя раскачивают, пытаясь вырвать наружу!"))
		if(!do_after(user, 8 SECONDS, target))
			user.psi.backblast(rand(5, 10))
			return TRUE
		target.psi.next_latency_trigger = 0
		if(target.psi.check_latency_trigger(100, "пробуждения от [user]", TRUE))
			log_and_message_admins("пробудил псионику у [key_name(target)].", user)
			target.apply_damage(100, DAMAGE_PAIN, BP_HEAD)
			to_chat(user, SPAN_WARNING("Ты разбудил чужую силу, и отдача обжигает разум."))
		else
			to_chat(user, SPAN_WARNING("Сила [target] не откликается."))
		return TRUE
