/singleton/psionic_power/revive
	name =            "Revive"
	cost =            25
	cooldown =        80
	use_grab =        TRUE
	min_rank =        PSI_RANK_GRANDMASTER
	faculty =         PSI_REDACTION
	use_description = "Схватите цель, выберите голову и зелёный интент, затем нажмите по нему захватом, чтобы попытаться вернуть его к жизни."
	admin_log = FALSE

/singleton/psionic_power/revive/invoke(mob/living/user, mob/living/target)
	if(!isliving(target) || !istype(target) || user.zone_sel.selecting != BP_HEAD)
		return FALSE
	. = ..()
	if(.)
		if(target.stat != DEAD && !(target.status_flags & FAKEDEATH))
			to_chat(user, SPAN_WARNING("Этот человек ещё жив!"))
			return TRUE

		if((world.time - target.timeofdeath) > 6000)
			to_chat(user, SPAN_WARNING("[target] пролежал здесь слишком долго. Нет никакой надежды на то, что его выйдет оживить."))
			return TRUE

		user.visible_message(SPAN_NOTICE("<i>[user] кладёт обе руки на тело [target]...</i>"))
		new /obj/temporary(get_turf(target),6, 'icons/effects/effects.dmi', "green_sparkles")
		if(!do_after(user, 100, target))
			user.psi.backblast(rand(10,25))
			return TRUE

		for(var/mob/observer/G in GLOB.dead_mobs)
			if(G.mind && G.mind.current == target && G.client)
				to_chat(G, SPAN_NOTICE("<font size = 3><b>Your body has been revived, <b>Re-Enter Corpse</b> to return to it.</b></font>"))
				break
		to_chat(target, SPAN_NOTICE("<font size = 3><b>Вы просыпаетесь от вечного сна, вместе с ужасающими воспоминаниями с того света.</b></font>"))
		target.visible_message(SPAN_NOTICE("[target] трясётся в ужасе!"))
		new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "rune_convert")
		target.adjustOxyLoss(-rand(30,45))
		target.basic_revival()
		return TRUE
