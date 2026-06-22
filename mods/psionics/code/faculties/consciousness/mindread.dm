/singleton/psionic_power/consciousness/mindread
	name =            "Read Mind"
	cost =            6
	cooldown =        80
	use_ranged =     TRUE
	use_melee =      TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Выберите голову на зелёном интенте и затем нажмите по цели находясь на расстоянии, чтобы попытаться прочитать его мысли."

/singleton/psionic_power/consciousness/mindread/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_HEAD || user.a_intent != I_HELP || target == user || !istype(target))
		return FALSE
	. = ..()
	if(.)

		var/distance = get_dist(get_turf(user), get_turf(target))
		if(distance > user.psi.get_rank(PSI_CONSCIOUSNESS))
			to_chat(user, SPAN_WARNING("Я не могу сконцентрироватся настолько далеко."))
			return FALSE

		if(target.is_dead() || !target.client)
			to_chat(user, SPAN_WARNING("[target] не в состоянии ответить мне."))
			return FALSE

		var/question =  input(user, "Что вы хотите сказать?", "Чтение мыслей", "Идеи?") as null|text
		if(!question || user.incapacitated())
			return FALSE

		to_chat(user, SPAN_NOTICE("Я концентрируюсь на сознании [target]"))
		if(!do_after(user, 40 / user.psi.get_rank(PSI_CONSCIOUSNESS), do_flags = DO_USER_UNIQUE_ACT))
			return FALSE

		var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
		to_chat(user, SPAN_NOTICE("<b>Я погружаюсь в глубины сознания [target], выискивая ответ на вопрос: <i>[question]</i></b>"))
		var/option = alert(target, "Кто-то пытается проникнуть в ваше сознание! Вы позволите этому случиться?", "Выбирай!", "Да", "Нет")
		if (!option)
			if(target.psi)
				var/con_rank_target = target.psi.get_rank(PSI_CONSCIOUSNESS)
				if(con_rank_target > con_rank_user)
					to_chat(user, SPAN_NOTICE("<b>[target] блокирует мои попытки узнать что-либо!</b>"))
					to_chat(target, SPAN_NOTICE("<b>Я защитил свой разум от вторжения</b>"))
					return
				else
					if (target.getBrainLoss() < 5)
						target.adjustBrainLoss(5)
					to_chat(user, SPAN_NOTICE("<b>[target] удаётся предотвратить мое проникновение, но часть его мозга была повреждена в процессе</b>"))
					to_chat(target, SPAN_NOTICE("<b>Мне удаётся защитить свои воспоминания. Моя голова просто раскалывается.</b>"))
					return
			else if(!target.psi)
				if (target.getBrainLoss() < 5)
					target.adjustBrainLoss(5)
				to_chat(user, SPAN_NOTICE("<b>[target] удаётся предотвратить моё проникновение, но часть его мозга была повреждена в процессе!</b>"))
				to_chat(target, SPAN_NOTICE("<b>Мне удаётся защитить свои воспоминания. Моя голова просто раскалывается.</b>"))
				return
		if(option == "Да")
			to_chat(target, SPAN_NOTICE("<b>Что-то пытается получить ответ на вопрос: <i>[question]</i></b>"))
		if(option == "Нет")
			if(target.psi)
				var/con_rank_target = target.psi.get_rank(PSI_CONSCIOUSNESS)
				if(con_rank_target > con_rank_user)
					to_chat(user, SPAN_NOTICE("<b>[target] без труда блокирует мои попытки узнать что-либо!</b>"))
					to_chat(target, SPAN_NOTICE("<b>Я защитил свой разум от вторжения!</b>"))
					return
				else
					if (target.getBrainLoss() < 5)
						target.adjustBrainLoss(5)
					to_chat(user, SPAN_NOTICE("<b>[target] удаётся предотвратить мое проникновение, но часть его мозга была повреждена в процессе!</b>"))
					to_chat(target, SPAN_NOTICE("<b>Мне удаётся защитить свои воспоминания. Моя голова просто раскалывается.</b>"))
					return
			else if(!target.psi)
				if (target.getBrainLoss() < 5)
					target.adjustBrainLoss(5)
				to_chat(user, SPAN_NOTICE("<b>[target] удаётся предотвратить моё проникновение, но часть его мозга была повреждена в процессе!</b>"))
				to_chat(target, SPAN_NOTICE("<b>Мне удаётся защитить свои воспоминания. Моя голова просто раскалывается.</b>"))
				return


		var/answer =  input(target, question, "Чтение мыслей") as null|text
		if(!answer || user.stat != CONSCIOUS || target.stat == DEAD)
			to_chat(user, SPAN_NOTICE("<b>Мне не удалось добиться чего-либо полезного от [target].</b>"))
		else
			to_chat(user, SPAN_NOTICE("<b>В разуме [target], вы находите: <i>[answer]</i></b>"))
		msg_admin_attack("[key_name(user)] использует чтение мыслей на [key_name(target)] с вопросом \"[question]\" и [answer?"следующим ответом \"[answer]\".":"не получил никакого ответа."]")
		return TRUE
