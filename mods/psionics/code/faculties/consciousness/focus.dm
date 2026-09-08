/singleton/psionic_power/consciousness/focus
	name =          "Focus"
	cost =          10
	cooldown =      80
	use_grab =      TRUE
	min_rank =      PSI_RANK_APPRENTICE
	use_description = "Схватите цель, затем выберите рот на зелёном интенте и нажмите по ней захватом ещё раз, чтобы частично очистить её сознание от возможного урона."

/singleton/psionic_power/consciousness/focus/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_MOUTH || user.a_intent != I_HELP)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(SPAN_WARNING("[user] ставит палец на лоб [target]"))
		to_chat(user, SPAN_NOTICE("Я проверяю разум [target] на наличие повреждений..."))
		to_chat(target, SPAN_WARNING("Я ощущаю, как мой разум очищается, становясь яснее."))
		if(!do_after(user, (target.stat == CONSCIOUS ? 50 : 25), target))
			user.psi.backblast(rand(5,10))
			return TRUE
		to_chat(user, SPAN_WARNING("Я почистил сознание [target] от негатива."))
		to_chat(target, SPAN_WARNING("Я ощущаю ясность мыслей."))

		var/coercion_rank = user.psi.get_rank(PSI_COERCION)
		if(coercion_rank > PSI_RANK_OPERANT)
			target.AdjustParalysis(-1)
		target.drowsyness = 0
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.adjust_hallucination(-30)
		return TRUE
