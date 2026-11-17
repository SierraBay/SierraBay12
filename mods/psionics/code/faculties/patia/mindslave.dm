/singleton/psionic_power/patia/coercion/mindslave
	use_intent =     I_DISARM
	name =          "Mindslave"
	cost =          28
	cooldown =      200
	use_grab =      TRUE
	min_rank =      PSI_RANK_GRANDMASTER
	use_description = "Схватите жертву, цельтесь в глаза, нажмите захватом с синим интентом на цель, чтобы обратить цель в раба. Процесс занимает время, а прерывание может оглушить вас."

/singleton/psionic_power/patia/coercion/mindslave/invoke(mob/living/user, mob/living/target)
	if(!istype(target) || user.zone_sel.selecting != BP_EYES)
		return FALSE
	. = ..()
	if(.)
		if(target.is_dead())
			to_chat(user, SPAN_WARNING("\The [target] мертв!"))
			return TRUE
		if(!target.mind || !target.key)
			to_chat(user, SPAN_WARNING("\The [target] не обладает разумом!"))
			return TRUE
		if(GLOB.thralls.is_antagonist(target.mind))
			to_chat(user, SPAN_WARNING("\The [target] уже кому-то принадлежит!"))
			return TRUE
		user.visible_message(SPAN_DANGER("<i>\The [user] хватает голову \the [target] руками...</i>"))
		to_chat(user, SPAN_WARNING("Ты ввергаешь свою ментальность в \the [target]..."))
		to_chat(target, SPAN_DANGER("В твой разум стучится \the [user]! Он пытается поработить тебя!"))
		if(!do_after(user, (target.stat == CONSCIOUS ? 8 : 4) SECONDS, target, DO_DEFAULT | DO_USER_UNIQUE_ACT))
			user.psi.backblast(rand(10,25))
			return TRUE
		to_chat(user, SPAN_DANGER("Ты прорываешься через мозг \the [target], изменяя его под твое желание, оставляя его подчиненным твоей воле!"))
		to_chat(target, SPAN_DANGER("Ты ослаб и \the [user] поработил тебя."))
		alert(target, "Ты теперь подчинен воле [user], служи ему слепо и верно, пока он не скажет обратного.", "Ты был порабощен")
		GLOB.thralls.add_antagonist(target.mind, new_controller = user)
		return TRUE
