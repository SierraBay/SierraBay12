/singleton/psionic_power/praxia/psionics/boost
	use_intent =      I_GRAB
	name =            "Boost"
	cost =            40
	cooldown =        600
	use_grab =        TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Схватите псионика, выберите голову и нажмите по нему захватом на жёлтом интенте, \
	чтобы на полминуты поднять его сильнейшую школу на ранг выше. \
	После применения, какое-то время будет трудно фокусировать силы, \
	а по окончанию действия, жертва может перегрется."

/singleton/psionic_power/praxia/psionics/boost/invoke(mob/living/user, mob/living/target)
	if(!istype(target) || target == user || user.a_intent != I_GRAB || user.zone_sel.selecting != BP_HEAD)
		return FALSE
	. = ..()
	if(.)
		if(!target.psi)
			to_chat(user, SPAN_NOTICE("У [target] нет силы, которую можно усилить."))
			return TRUE
		var/best
		var/best_rank = 0
		for(var/faculty in target.psi.ranks)
			var/rank = target.psi.ranks[faculty]
			if(rank >= PSI_RANK_APPRENTICE && rank < PSI_RANK_GRANDMASTER && rank > best_rank)
				best = faculty
				best_rank = rank
		if(!best)
			to_chat(user, SPAN_NOTICE("В [target] нечего усиливать."))
			return TRUE
		if(!do_after(user, 3 SECONDS, target))
			return TRUE
		if(!user.psi.spend_power(20))
			return TRUE
		target.psi.set_rank(best, best_rank + 1, FALSE, TRUE)
		to_chat(user, SPAN_NOTICE("Ты выплёскиваешь силу в [target], и она растёт."))
		to_chat(target, SPAN_OCCULT("Твоя сила вспыхивает, поднимаясь выше обычного. Это ненадолго."))
		end_boost(target, best, best_rank + 1, best_rank)
		return TRUE

/singleton/psionic_power/praxia/psionics/boost/proc/end_boost(mob/living/target, faculty, boosted_rank, old_rank)
	set waitfor = FALSE
	sleep(30 SECONDS)
	if(!target || QDELETED(target) || !target.psi)
		return
	if(target.psi.get_rank(faculty) == boosted_rank)
		target.psi.set_rank(faculty, old_rank, FALSE, TRUE)
	target.psi.stunned(10)
	to_chat(target, SPAN_DANGER("Усиление гаснет, и накатывает слабость."))
