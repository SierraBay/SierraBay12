/singleton/psionic_power/consciousness/assay
	name =            "Assay"
	cost =            15
	cooldown =        100
	use_grab =        TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Схватите цель, затем выберите голову и зелёном интент. После этого, нажмите по цели захватом, чтобы погрузится в глубины её разума и отыскать там скрытый потенциал."

/singleton/psionic_power/consciousness/assay/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_HEAD || user.a_intent != I_HELP)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(SPAN_WARNING("[user] обхватывает голову [target] обеими руками..."))
		to_chat(user, SPAN_NOTICE("Я погружаюсь в глубины сознания [target]..."))
		to_chat(target, SPAN_WARNING("Я ощущаю, как [user] копается в моём подсознании, что-то выискивая."))
		if(!do_after(user, (target.stat == CONSCIOUS ? 50 : 25), target))
			user.psi.backblast(rand(5,10))
			return TRUE
		to_chat(user, SPAN_NOTICE("Я покидаю разум [target], получив желаемое."))
		to_chat(target, SPAN_DANGER("[user] наконец покидает моё сознание, узнав желаемое."))
		target.show_psi_assay(user)
		return TRUE
