/singleton/psionic_power/consciousness/telepathy
	name =            "Telepathy"
	cost =            2
	cooldown =        50
	use_ranged =     TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Выберите рот на зелёном интенте, и затем нажмите по цели с любого расстояния, чтобы установить ментальную связь."

/datum/psi_complexus
	var/list/linked_souls = list()

/mob/living/proc/ContactSoulmate()
	set name     = "Contact your friend"
	set category = "Psionics"

	if (!psi?.linked_souls)
		return

	var/phrase =  input(usr, "Что вы хотите сказать?", "Связаться", "Ты меня слышишь?") as null|text
	if(!phrase || usr.incapacitated())
		return FALSE

	to_chat(usr, SPAN_NOTICE("<b>Я говорю сам себе: <i>[phrase]</i></b>"))

	for(var/mob/living/soul in psi?.linked_souls)
		var/televoicename
		switch(soul.gender)
			if(NEUTER, PLURAL)
				televoicename = pick("чужой", "необычный", "странный")
			if(MALE)
				televoicename = pick("мужской", "грубый", "сильный", "низкий")
			if(FEMALE)
				televoicename = pick("женский", "тонкий", "красивый", "высокий")
		to_chat(soul, SPAN_OCCULT("<b>Я слышу [televoicename] голос в голове: <i>[phrase]</i></b>"))

/singleton/psionic_power/consciousness/telepathy/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_MOUTH || user.a_intent != I_HELP || target == user)
		return FALSE
	. = ..()
	if(.)
		if(target.is_dead() || !target.client)
			to_chat(user, SPAN_WARNING("[target] не в состоянии ответить мне."))
			return FALSE

		if(user.psi.get_rank(PSI_CONSCIOUSNESS) >= PSI_RANK_MASTER && target != user)
			var/option = input(user, "Связь", "Что вы хотите сделать?") in list("Поговорить", "Привязать", "Отвязать")
			if (!option)
				return
			if(option == "Привязать")
				var/answer = alert(target, "[user] пытается открыть мой разум для связи. Я позволю ему сделать это?", "Слияние", "Да", "Нет")
				switch(answer)
					if("Да")
						user.psi.linked_souls += target
						user.verbs += /mob/living/proc/ContactSoulmate
						to_chat(user, SPAN_NOTICE("<b>Я ощущаю, как моё сознание становится связанным с сознанием [target]</b>"))
						return 0
					else
						to_chat(user, SPAN_NOTICE("<b>[target] не поддается.</b>"))
						return 0
			if(option == "Отвязать")
				if(user.psi.linked_souls == target)
					user.psi.linked_souls -= target
					if(LAZYLEN(user.psi.linked_souls) < 1)
						user.verbs -= /mob/living/proc/ContactSoulmate
					to_chat(user, SPAN_NOTICE("<b>Я рву узы с [target]!</b>"))
					to_chat(target, SPAN_WARNING("Я ощущаю странную потерю..."))
					return 0
				else
					to_chat(user, SPAN_NOTICE("<b>У меня нет никаких уз с [target]!</b>"))
			if(option == "Поговорить")

				var/phrase =  input(user, "Что вы хотите сказать?", "Связаться", "Ты меня слышишь?") as null|text
				if(!phrase || user.incapacitated() || !do_after(user, 40 / user.psi.get_rank(PSI_CONSCIOUSNESS)))
					return 0

				var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
				to_chat(user, SPAN_NOTICE("<b>Я пытаюсь установить контакт с сознанием [target], чтобы донести до него: <i>[phrase]</i></b>"))
				if(target.psi)
					var/con_rank_target = target.psi.get_rank(PSI_CONSCIOUSNESS)
					if(con_rank_target >= con_rank_user)
						to_chat(target, SPAN_OCCULT("<b>Я слышу отчётливый голос [user] в своей голове, он говорит мне: <i>[phrase]</i></b>"))
					if(con_rank_target > con_rank_user)
						var/what =  alert(target, "Вы хотите ответить?", "Обратная связь", "Да", "Нет")
						switch(what)
							if("Да")
								var/answer =  input(user, "Что вы хотите передать в ответ?", "Связаться", "...") as null|text
								to_chat(user, SPAN_OCCULT("<b>[target] отвечает мне: <i>[answer]</i></b>"))
							else
								return 0
					else
						to_chat(target, SPAN_OCCULT("<b>Шёпот говорит мне: <i>[phrase]</i></b>"))
				else if(!target.psi)
					to_chat(target, SPAN_OCCULT("<b>Шёпот говорит мне: <i>[phrase]</i></b>"))
				return 1

	/// ///

		var/phrase =  input(user, "Что вы хотите сказать?", "Связаться", "Ты меня слышишь?") as null|text
		if(!phrase || user.incapacitated() || !do_after(user, 40 / user.psi.get_rank(PSI_CONSCIOUSNESS)))
			return FALSE

		var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
		to_chat(user, SPAN_NOTICE("<b>Я пытаюсь установить контакт с сознанием [target], чтобы донести до него: <i>[phrase]</i></b>"))
		if(target.psi)
			var/con_rank_target = target.psi.get_rank(PSI_CONSCIOUSNESS)
			if(con_rank_target >= con_rank_user)
				to_chat(target, SPAN_OCCULT("<b>Я слышите отчётливый голос [user] в своей голове, он говорит мне: <i>[phrase]</i></b>"))
				if(con_rank_target > con_rank_user)
					var/option =  alert(target, "Вы хотите ответить?", "Обратная связь", "Да", "Нет")
					switch(option)
						if("Да")
							var/answer =  input(target, "Что вы хотите передать в ответ?", "Связаться", "...") as null|text
							to_chat(user, SPAN_OCCULT("<b>[target] отвечает мне: <i>[answer]</i></b>"))
						else
							return
			else
				to_chat(target, SPAN_OCCULT("<b>Шёпот говорит мне: <i>[phrase]</i></b>"))
		else if(!target.psi)
			to_chat(target, SPAN_OCCULT("<b>Шёпот говорит мне: <i>[phrase]</i></b>"))
		return TRUE
