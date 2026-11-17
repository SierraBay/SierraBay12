/singleton/psionic_power/patia/coercion/emotions
	use_intent =     I_DISARM
	name =            "Emotion Amplifier"
	cost =            20
	cooldown =        30
	use_melee =     TRUE
	use_ranged =     TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Выберите грудь и переключитесь на синий интент. Затем, нажмите по вашей цели, чтобы многократно усилить одну из её эмоций."

/singleton/psionic_power/patia/coercion/emotions/invoke(mob/living/user, mob/living/target)
	var/list/options = list(
		"Joy" = image('mods/psionics/icons/psi.dmi', "JOY"),
		"Sadness" = image('mods/psionics/icons/psi.dmi', "SADNESS"),
		"Fear" = image('mods/psionics/icons/psi.dmi', "FEAR"),
		"Caution" = image('mods/psionics/icons/psi.dmi', "ANXIETY"),
		"Anger" = image('mods/psionics/icons/psi.dmi', "ANGER"),
		"Stillness" = image('mods/psionics/icons/psi.dmi', "STILLNESS")
	)

	if(user.zone_sel.selecting != BP_CHEST)
		return FALSE
	if(target == user)
		return FALSE
	if(isrobot(target))
		return FALSE
	. = ..()
	if(.)

		var/chosen_option = show_radial_menu(user, user, options, radius = 25, require_near = TRUE)
		if (!chosen_option)
			return 0
		if(user.psi.suppressed)
			return 0
		switch(chosen_option)
			if("Joy")
				var/funny_option = pick("смеетесь над несмешной шуткой", "стараетесь не обидеть друга", "насмехаетесь над [user]")
				to_chat(target, SPAN_WARNING("Внезапно, вы ощущаете принужденный смех. Как будто вы [funny_option]."))
				var/mob/living/carbon/C = target
				C.Weaken(5)
				C.spin(32,2)
				C.emote("giggle")
				sleep(3 SECONDS)
				C.emote("giggle")
				sleep(6 SECONDS)
				C.emote("giggle")
				return 1
			if("Sadness")
				var/sad_option = pick("то, как умирают солдаты на войне", "мысль о том, что после смерти ничего нет", "то, что вы никчемны", "воспоминание, как вы опозорились")
				to_chat(target, SPAN_WARNING("В голове проскакивает [sad_option]."))
				var/mob/living/carbon/C = target
				C.eye_blurry = max(C.eye_blurry, 10)
				C.emote("whimper")
				sleep(3 SECONDS)
				C.emote("whimper")
				sleep(6 SECONDS)
				C.emote("whimper")
				return 1
			if("Fear")
				to_chat(target, SPAN_OCCULT("Вы цепенеете, завидев [user]. Холодный пот стекает по вашему лбу."))
				var/cn_rank = user.psi.get_rank(PSI_PATIA)
				var/mob/living/carbon/C = target
				C.make_dizzy(10)
				C.Stun(5 + cn_rank)
				return 1
			if("Caution")
				var/strange_option = pick("ощущаете чьё-то зловещее присутствие", "сильно потеете", "чувствуете, что за вами что-то наблюдает", "ощущаете странный холод", "чувствуете, как что-то ползает по вам")
				to_chat(target, SPAN_DANGER("Вы [strange_option]."))
				return 1
			if("Anger")
				var/anger_option = pick("к самому себе", "к человеку, что стоит рядом", "к месту, в котором вы находитесь", "к своей жизни", "по отношению к ситуации", "к сегодняшнему дню", "к погоде", "к вашей работе", "к тому, что было вчера")
				to_chat(target, SPAN_DANGER("Внезапно, вы ощущаете злобу [anger_option]."))
				return 1
			if("Stillness")
				to_chat(target, SPAN_NOTICE("Вы ощущаете странное умиротворение."))
				if(target.psi)
					target.psi.stamina = min(target.psi.max_stamina, target.psi.stamina + rand(15,20))
				return 1
