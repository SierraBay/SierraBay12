/singleton/psionic_faculty/consciousness
	id = PSI_CONSCIOUSNESS
	name = "Consciousness"
	associated_intent = I_HELP
	armour_types = list(DAMAGE_PSIONIC)

/singleton/psionic_power/consciousness
	faculty = PSI_CONSCIOUSNESS
	abstract_type = /singleton/psionic_power/consciousness

/singleton/psionic_power/consciousness/invoke(mob/living/user, mob/living/target)
	. = ..()
	if (!.)
		return FALSE

	if(target.is_species(SPECIES_IPC) || target.is_species(SPECIES_ADHERENT))
		return FALSE

	if (!istype(target))
		to_chat(user, SPAN_WARNING("Я не могу пробиться в сознание [target]."))
		return FALSE

	if(. && target.deflect_psionic_attack(user) && target != user)
		return FALSE

/singleton/psionic_power/consciousness/telepathy
	name =            "Telepathy"
	cost =            2
	cooldown =        50
	use_ranged =     TRUE
	use_melee =     TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Выберите рот на зелёном интенте, и затем нажмите по цели с любого расстояния, чтобы установить ментальную связь."

/mob/living
	var/space = 0
	var/linked_soul

/mob/living/proc/ContactSoulmate()
	set name     = "Contact your friend"
	set category = "Psionics"

	if (!linked_soul)
		return

	var/phrase =  input(usr, "Что вы хотите сказать?", "Связаться", "Ты меня слышишь?") as null|text
	if(!phrase || usr.incapacitated())
		return FALSE

	to_chat(usr, SPAN_NOTICE("<b>Я пытаюсь установить контакт с сознанием [linked_soul], произнеся: <i>[phrase]</i></b>"))
	to_chat(linked_soul, SPAN_OCCULT("<b>Я слышу чужой голос в голове: <i>[phrase]</i></b>"))
	var/option =  alert(linked_soul, "Вы хотите ответить?", "Обратная связь", "Да", "Нет")
	switch(option)
		if("Да")
			var/answer =  input(linked_soul, "Что вы хотите передать в ответ?", "Связаться", "...") as null|text
			to_chat(usr, SPAN_OCCULT("<b>[linked_soul] отвечает мне: <i>[answer]</i></b>"))
		else
			return

/singleton/psionic_power/consciousness/telepathy/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_MOUTH || user.a_intent != I_HELP || target == user)
		return FALSE
	. = ..()
	if(.)
		if(target.is_dead() || !target.client)
			to_chat(user, SPAN_WARNING("[target] не в состоянии ответить мне."))
			return FALSE

		if(user.psi.get_rank(PSI_CONSCIOUSNESS) >= PSI_RANK_MASTER && target != user)
			var/option = input(user, "Связь!", "Что вы хотите сделать?") in list("Поговорить", "Привязать", "Отвязать")
			if (!option)
				return
			if(option == "Привязать")
				if(user.space >= 1)
					to_chat(user, SPAN_NOTICE("<b>Я не могу поддерживать столь личную связь с более чем одним человеком!</b>"))
					return 0
				var/answer = alert(target, "[user] пытается связать наши разумы воедино. Я позволю ему сделать это?", "Слияние", "Да", "Нет")
				switch(answer)
					if("Да")
						user.linked_soul = target
						user.space = 1
						user.verbs += /mob/living/proc/ContactSoulmate
						to_chat(user, SPAN_NOTICE("<b>Я ощущаю, как моё сознание становится единым целым с сознанием [target]</b>"))
						return 0
					else
						to_chat(user, SPAN_NOTICE("<b>[target] отказался от моего предложения.</b>"))
						return 0
			if(option == "Отвязать")
				if(user.linked_soul == target)
					user.verbs -= /mob/living/proc/ContactSoulmate
					user.linked_soul = null
					user.space = 0
					to_chat(user, SPAN_NOTICE("<b>Я рву узы с [target]!</b>"))
					to_chat(target, SPAN_WARNING("Я ощущаю странную потерю..."))
					return 0
				else
					to_chat(user, SPAN_NOTICE("<b>У меня нет никаких уз с [target]!</b>"))
			if(option == "Поговорить")

	///Yes. And no, i don't know how to do it better///

				var/phrase =  input(user, "Что вы хотите сказать?", "Связаться", "Ты меня слышишь?") as null|text
				if(!phrase || user.incapacitated() || !do_after(user, 40 / user.psi.get_rank(PSI_CONSCIOUSNESS)))
					return 0

				var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
				to_chat(user, SPAN_NOTICE("<b>Я пытаюсь установить контакт с сознанием [target], чтобы донести до него следующее: <i>[phrase]</i></b>"))
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
		to_chat(user, SPAN_NOTICE("<b>Я пытаюсь установить контакт с сознанием [target], чтобы донести до него следующее: <i>[phrase]</i></b>"))
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


/singleton/psionic_power/consciousness/mindread
	name =            "Read Mind"
	cost =            6
	cooldown =        80
	use_ranged =     TRUE
	use_melee =     TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Выберите голову на зелёном интенте и затем нажмите по цели находясь на любом расстоянии, чтобы попытаться прочитать его мысли."

/singleton/psionic_power/consciousness/mindread/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_HEAD || user.a_intent != I_HELP || target == user)
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
					to_chat(user, SPAN_NOTICE("<b>[target] без труда блокирует мои попытки узнать что-либо!</b>"))
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

/singleton/psionic_power/consciousness/focus
	name =          "Focus"
	cost =          10
	cooldown =      80
	use_grab =     TRUE
	min_rank =      PSI_RANK_APPRENTICE
	use_description = "Схватите цель, затем выберите рот на зелёном интенте и нажмите по ней захватом ещё раз, чтобы частично очистить её сознание от возможного урона."

/singleton/psionic_power/consciousness/focus/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_MOUTH || user.a_intent != I_HELP)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(SPAN_WARNING("[user] целует [target] в лоб"))
		to_chat(user, SPAN_NOTICE("Я проверяю разум [target] на наличие повреждений..."))
		to_chat(target, SPAN_WARNING("Я ощущаю, как мой разум очищается, становясь яснее."))
		if(!do_after(user, (target.stat == CONSCIOUS ? 50 : 25), target))
			user.psi.backblast(rand(5,10))
			return TRUE
		to_chat(user, SPAN_WARNING("Я полностью очистил сознание [target] от негатива."))
		to_chat(target, SPAN_WARNING("Я ощущаю ясность мыслей."))

		var/coercion_rank = user.psi.get_rank(PSI_COERCION)
		if(coercion_rank > PSI_RANK_OPERANT)
			target.AdjustParalysis(-1)
		target.drowsyness = 0
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.adjust_hallucination(-30)
		return TRUE

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

/singleton/psionic_power/consciousness/absorb
	name =            "Absorption"
	cost =            10
	cooldown =        40
	use_ranged =     TRUE
	use_melee =     TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Выберите верхнюю часть тела на зелёном интенте, и затем нажмите по цели с любого расстояния, чтобы попытаться поглотить часть псионической силы жертвы."

/singleton/psionic_power/consciousness/absorb/invoke(mob/living/user, mob/living/target)
	var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
	if(user.zone_sel.selecting != BP_CHEST || user.a_intent != I_HELP)
		return FALSE
	. = ..()
	if(.)
		if(target == user)
			to_chat(user, SPAN_WARNING("Я не могу применить эту способность на себе!"))
			return 0
		if(target.psi)
			var/con_rank_target = target.psi.get_rank(PSI_CONSCIOUSNESS)
			if(con_rank_user > con_rank_target)
				sound_to(user, 'sound/effects/psi/power_fail.ogg')
				if(prob(30))
					to_chat(user, SPAN_DANGER("Я попытался проникнуть в разум [target], но тот ускользнул из под моего воздействия."))
					to_chat(target, SPAN_WARNING("Я рефлекторно избежал губительного воздействия [user] на ваш разум."))
					return 0
				to_chat(user, SPAN_NOTICE("Я разбил защиту [target], забрав часть его сил себе."))
				to_chat(target, SPAN_DANGER("Я ощущаю сильную головную боль, пока [user] пристально сверлит меня взглядом."))
				target.adjustBrainLoss(20)
				user.psi.stamina = min(user.psi.max_stamina, user.psi.stamina + rand(25,30))
				target.psi.spend_power(rand(15,25))
			if(con_rank_user == con_rank_target)
				sound_to(user, 'sound/effects/psi/power_fail.ogg')
				if(prob(50))
					to_chat(user, SPAN_WARNING("Я попытался проникнуть в разум [target], но в ходе битвы сам получил значительный урон!"))
					to_chat(target, SPAN_DANGER("Я сопротивлялся [user] повлиять на мой разум, но в конечном счёте всё равно проиграл."))
					user.psi.stamina = min(user.psi.max_stamina, user.psi.stamina + rand(10,20))
					target.psi.spend_power(rand(10,20))
					user.adjustBrainLoss(20)
					target.adjustBrainLoss(20)
					user.emote("scream")
					target.emote("scream")
					return 0
				to_chat(user, SPAN_WARNING("Я с лёгкостью разбил защиту [target], забрав часть его сил себе."))
				to_chat(target, SPAN_DANGER("Я ощущаю сильную головную боль, пока [user] пристально сверлит вас взглядом."))
				target.adjustBrainLoss(20)
				user.psi.stamina = min(user.psi.max_stamina, user.psi.stamina + rand(25,30))
				target.psi.spend_power(rand(15,25))
			if(con_rank_user < con_rank_target)
				sound_to(user, 'sound/effects/psi/power_fail.ogg')
				if(prob(30))
					to_chat(user, SPAN_WARNING("Мне удалось пробиться через псионическую завесу [target]!"))
					to_chat(target, SPAN_DANGER("[user] пробился в мой разум чистой, грубой силой, нанеся в процессе значительный урон."))
					target.adjustBrainLoss(20)
					user.psi.stamina = min(user.psi.max_stamina, user.psi.stamina + rand(30,45))
					target.psi.spend_power(35)
					return 0
				to_chat(user, SPAN_DANGER("Я пытаюсь пробиться через барьер [target], но встречаю серьёзное сопротивление!"))
				to_chat(target, SPAN_NOTICE("[user] попытался пробиться в мое сознание."))
				user.emote("scream")
				user.adjustBrainLoss(30)
				user.psi.spend_power(50)
		else
			to_chat(user, SPAN_NOTICE("У [target] нет пробужденного псионического потенциала."))
			return 0

/singleton/psionic_power/consciousness/invis
	name =            "Invisibility"
	cost =            50
	cooldown =        250
	use_ranged =     TRUE
	use_melee =     TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Выберите глаза на зелёном интенте, и затем нажмите по себе или другому человеку(начиная с мастера), чтобы временно сделать его или себя невидимым для остальных."

/mob/living/proc/run_timer_invisibility()
	var/invis_timer = 10
	set waitfor = 0
	var/T = invis_timer
	while(T > 0)
		sleep(1 SECOND)
		T--
	src.visible_message(SPAN_WARNING("[src] внезапно материализуется из воздуха!"))
	animate(src, alpha = 255, time = 3 SECONDS)

/singleton/psionic_power/consciousness/invis/invoke(mob/living/user, mob/living/target)
	var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
	if(user.zone_sel.selecting != BP_EYES || user.a_intent != I_HELP)
		return FALSE

	if (!istype(target))
		to_chat(user, SPAN_WARNING("Я не могу сделать [target] невидимым."))
		return FALSE

	if(istype(target, /mob/living/carbon) && target != user && con_rank_user >= PSI_RANK_MASTER)
		if(do_after(user, 30))
			user.visible_message(SPAN_WARNING("[user] касается [target] и тот исчезает на глазах!"))
			animate(target, alpha = 0, time = 3 SECONDS)
			target.run_timer_invisibility()
			return TRUE

	if(target == user)
		user.visible_message(SPAN_WARNING("[user] исчезает у всех на глазах!"))
		animate(target, alpha = 0, time = 3 SECONDS)
		target.run_timer_invisibility()
		return TRUE

/singleton/psionic_power/consciousness/curse
	name =            "Hallucinations"
	cost =            20
	cooldown =        50
	use_grab =        TRUE
	use_melee =     TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Схватите цель, затем выберите верхнюю часть тела на зелёном интент. После этого, нажмите по цели захватом, чтобы погрузить её в мир галлюцинаций."

/singleton/psionic_power/consciousness/curse/invoke(mob/living/user, mob/living/carbon/target)
	var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
	if(user.zone_sel.selecting != BP_CHEST || user.a_intent != I_HELP)
		return FALSE
	if(target == user)
		return FALSE
	. = ..()
	if(.)
		new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "eye_opening")
		playsound(target.loc, 'sound/hallucinations/far_noise.ogg', 15, 1)
		target.hallucination(rand(10,20) * con_rank_user, 100)

/singleton/psionic_power/consciousness/swap
	name =           "Shadow Swap"
	cost =           30
	cooldown =       100
	use_ranged =     TRUE
	min_rank =       PSI_RANK_MASTER
	use_description = "Выберите пятки или ноги на зелёном интенте. Затем, нажмите по цели на дистанции, чтобы незаметно обменяться с ней местами."

/singleton/psionic_power/consciousness/swap/invoke(mob/living/user, mob/living/carbon/human/target)
	var/cn_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)

	if(!istype(target))
		return FALSE

	if(user.a_intent != I_HELP)
		return FALSE

	if(!(user.zone_sel.selecting in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)))
		return FALSE

	. = ..()
	if(.)
		var/turf/target_turf = get_turf(target)
		var/turf/user_turf = get_turf(user)

		var/list/mobs = GLOB.alive_mobs + GLOB.dead_mobs
		for(var/mob/living/M in mobs)
			if(M == user)
				continue
			if(get_dist(user, M) > cn_rank_user)
				continue
			M.eye_blind = max(M.eye_blind,cn_rank_user)
		target.forceMove(user_turf)
		user.forceMove(target_turf)

		return TRUE

//This differs from how TG does it, they have a dedicated turf type for open turf, we have to check the density. Thanks Bay, always be special.
///Returns a list with all the adjacent open turfs. Clears the list of nulls in the end.
/proc/get_adjacent_open_turfs(atom/center)
	var/list/hand_back = list()
	// Inlined get_open_turf_in_dir, just to be fast
	var/turf/new_turf = get_step(center, NORTH)
	if(istype(new_turf) && !new_turf.density)
		hand_back += new_turf
	new_turf = get_step(center, SOUTH)
	if(istype(new_turf) && !new_turf.density)
		hand_back += new_turf
	new_turf = get_step(center, EAST)
	if(istype(new_turf) && !new_turf.density)
		hand_back += new_turf
	new_turf = get_step(center, WEST)
	if(istype(new_turf) && !new_turf.density)
		hand_back += new_turf
	return hand_back

/singleton/psionic_power/consciousness/copies
	name =            "Non-Existing Copies"
	cost =            50
	cooldown =        100
	use_melee =     TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Выберите рот на синем интенте, и затем нажмите по себе, чтобы создать сразу несколько копий самого себя."
	var/amount = 1

/singleton/psionic_power/consciousness/copies/invoke(mob/living/user, mob/living/carbon/human/target)
	var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
	switch(con_rank_user)
		if(PSI_RANK_OPERANT)
			amount = 3
		if(PSI_RANK_MASTER)
			amount = 4
		if(PSI_RANK_GRANDMASTER)
			amount = 6

	if(user.zone_sel.selecting != BP_MOUTH)
		return FALSE

	if(user.a_intent != I_DISARM)
		return FALSE

	if(target != user)
		return FALSE

	. = ..()
	if(.)
		if(do_after(user, 10))
			to_chat(user, SPAN_WARNING("Я разделяю своё подсознание на [amount] копий"))
			for(var/i = 1 to amount)
				var/mob/living/simple_animal/hostile/mirror_shade/MS = new(pick(get_adjacent_open_turfs(user)), user)
				MS.CopyOverlays(user, TRUE)
				MS.icon = null
			return TRUE

/obj/item/natural_weapon/punch/holo
	damtype = DAMAGE_PAIN

/mob/living/simple_animal/hostile/mirror_shade

	name = "Mirror Shade"
	turns_per_move = 2
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	movement_cooldown = 0
	maxHealth = 20
	health = 20
	harm_intent_damage = 5
	natural_weapon = /obj/item/natural_weapon/punch/holo
	a_intent = I_HURT
	status_flags = CANPUSH
	blood_color = null

	var/mob/living/carbon/human/owner

/mob/living/simple_animal/hostile/mirror_shade/Initialize(mapload, mob/set_owner)
	. = ..()
	if(set_owner)
		owner = set_owner
		friends += owner
		name = owner.name
	QDEL_IN(src, 30 SECONDS)

/mob/living/simple_animal/hostile/mirror_shade/examine(mob/user)
	if(!QDELETED(owner))
		/// Technically suspicious, but these have 30 seconds of lifetime so it's probably fine.
		return owner.examine(user)
	return ..()

/mob/living/simple_animal/hostile/mirror_shade/Destroy()
	owner = null
	visible_message(SPAN_WARNING("[src] пропадает!"))
	return ..()
