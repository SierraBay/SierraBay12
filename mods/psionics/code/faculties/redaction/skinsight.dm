/singleton/psionic_power/redaction/skinsight
	name =            "Skinsight"
	cost =            3
	cooldown =        30
	use_melee =        TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите на торс цели, чтобы проверить физическое состояние цели."

/singleton/psionic_power/redaction/skinsight/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_CHEST)
		return FALSE
	. = ..()
	if(.)
		if(!do_after(user, 1 SECOND, target, DO_PUBLIC_UNIQUE))
			return FALSE
		user.visible_message(SPAN_NOTICE("[user] кладёт руку на [target]."))
		to_chat(user, medical_scan_results(target, TRUE, user.get_skill_value(SKILL_MEDICAL)))
		return TRUE
