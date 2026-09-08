/singleton/psionic_power/shaymanism/chalk
	name =            "Ritual equipment"
	cost =            10
	cooldown =        15
	use_manifest =    TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Используйте пустую руку в режиме разоружения целясь в глаза чтобы излить душу в форме мела."

/singleton/psionic_power/shaymanism/chalk/invoke(mob/living/user)
	if(user.a_intent != I_DISARM || user.zone_sel.selecting != BP_EYES)
		return FALSE

	. = ..()
	if(.)
		return new /obj/item/psychic_power/chalk(user)


// -------------
//		МЕЛ
// -------------
/obj/item/psychic_power/chalk
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonmime"
	color = COLOR_CYAN
	w_class = ITEM_SIZE_TINY
	attack_verb = list("attacked", "coloured")

/obj/item/psychic_power/chalk/Initialize(mapload)
	. = ..()

/obj/item/psychic_power/chalk/use_after(atom/target, mob/living/user)
	. = ..()
	var/shaman_lvl = user.psi.get_rank(PSI_SHAYMANISM)
	var/list/options = list(
		"Благословение Тая-А’аша-Та’апа" = mutable_appearance('icons/effects/crayondecal.dmi', "rune2", COLOR_CYAN),
		"Зрение духов" = mutable_appearance('icons/effects/crayondecal.dmi', "rune4", COLOR_CYAN)
	)
	if(shaman_lvl >= PSI_RANK_OPERANT)
		options += list("Разговор с усопшим" = mutable_appearance('icons/effects/crayondecal.dmi', "rune3", COLOR_CYAN))

	var/choice = show_radial_menu(user, user, options, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))

	if (!choice)
		return

	if(do_after(user, 10 SECONDS, do_flags = DO_PUBLIC_UNIQUE))
		switch(choice)
			if ("Благословение Тая-А’аша-Та’апа")
				new /obj/decal/cleanable/psychic/lang(get_turf(user))
			if ("Разговор с усопшим")
				new /obj/decal/cleanable/psychic/speaktothedamned(get_turf(user))
			if ("Зрение духов")
				new /obj/decal/cleanable/psychic/eversee(get_turf(user))

// ----------------
//		ДЕКАЛЬ
// ----------------
/obj/decal/cleanable/psychic
	name = "rune"
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1s"
	var/runenumber = 1
	var/cost = 45
	var/cooldown

/obj/decal/cleanable/psychic/Initialize()
	. = ..()
	var/icon/mainOverlay = new/icon('icons/effects/crayondecal.dmi',"rune[runenumber]", 2.1)
	var/icon/shadeOverlay = new/icon('icons/effects/crayondecal.dmi',"rune[runenumber]s", 2.1)
	mainOverlay.Blend(COLOR_CYAN,ICON_ADD)
	shadeOverlay.Blend(COLOR_TEAL,ICON_ADD)
	AddOverlays(mainOverlay)
	AddOverlays(shadeOverlay)

/obj/decal/cleanable/psychic/attack_hand(mob/living/user)
	if(user.psi && user.psi.get_rank(PSI_SHAYMANISM) >= PSI_RANK_LATENT && !user.psi.suppressed)
		cast(user, cost)
	else
		. = ..()

/obj/decal/cleanable/psychic/proc/cast(mob/living/user, spend_power)
	if(cooldown > world.time)
		return
	cooldown = world.time + 30 SECONDS

	var/obj/effect = new(src.loc)
	effect.appearance = src.appearance
	animate(effect, 1 SECOND, transform = matrix()*1.5, alpha = 0)
	user.psi.spend_power(spend_power)
	QDEL_IN(effect, 1 SECOND)

// --------------------
//		РУНА ЯЗЫКА
// --------------------
/obj/decal/cleanable/psychic/lang
	runenumber = 2
	cost = 50

/obj/decal/cleanable/psychic/lang/cast(mob/living/user, spend_power)
	. = ..()
	var/datum/language/L = all_languages[LANGUAGE_SIMPTAJARAN]
	var/mob/living/carbon/target = null
	for(var/mob/living/carbon/M in get_turf(src))
		if(!M.is_dead())
			target = M
			break
	if(target && target != user)
		to_chat(user, SPAN_CLASS("tajaran", FONT_LARGE("Мы начинаем ритуал, духи направляют наши уста")))
		for(var/i = 1; i <= 4; i++)
			if(do_after(user, 5 SECONDS, target, DO_PUBLIC_UNIQUE))
				user.say(L.scramble(generate_text()), L)
				user.psi.spend_power(20)
			else
				animate(src, 1 SECOND, alpha = 0)
				QDEL_IN(src, 1 SECOND)
				return

		if(LANGUAGE_SIMPTAJARAN in target.languages)
			target.add_language(LANGUAGE_SIIK_MAAS)
			target.say(L.scramble(generate_text() + "!"), L)
			to_chat(target, SPAN_CLASS("tajaran", "Я не могу описать словами эту ясность. Я знаю то что не мог себе и представить."))
		else
			target.add_language(LANGUAGE_SIMPTAJARAN)
			target.say(L.scramble(generate_text() + "!"), L)
			to_chat(target, SPAN_CLASS("tajaran", "Я не могу сосредоточится, я знаю то, что будет трудно описать словами."))
		animate(src, 3 SECONDS, alpha = 0, easing = EASE_IN | BOUNCE_EASING)
		QDEL_IN(src, 3 SECONDS)

	else
		to_chat(user, SPAN_CLASS("tajaran", FONT_LARGE("На сигиле должен стоять неведающий")))

/obj/decal/cleanable/psychic/lang/proc/generate_text()
	var/result = ""
	var/length = rand(10, 30)
	for(var/i = 1; i <= length; i++)
		result += ascii2text(rand(97, 122)) // a-z
	return result

// ------------------------
//		РУНА РАЗГОВОРА
// ------------------------
/obj/decal/cleanable/psychic/speaktothedamned
	runenumber = 3
	cost = 20

/obj/decal/cleanable/psychic/speaktothedamned/cast(mob/living/user, spend_power)
	. = ..()
	var/mob/observer/ghost/target = null
	var/mob/living/carbon/M
	for(M in get_turf(src))
		if(M.is_dead())
			target = find_dead_player(M.last_ckey, TRUE)
			break
	if(target)
		if(target.was_asked >= user.psi.get_rank(PSI_SHAYMANISM) - 2) // Оп. задает 1 вопрос, Гранд. 3 вопроса.
			to_chat(user, SPAN_CLASS("tajaran", "Дух больше не может ответить на мои вопросы"))
			return

		var/original_pos = get_turf(M)
		var/question = input(user, "Спрашивай", "Какой вопрос донести духу?") as null|text
		var/choice = alert(target, "Шаман взывает к тебе и просит поговорить с ним. Ты согласен?", "Нарушенный покой", "Да", "Нет")
		if(choice == "Да")
			var/phrase = input(target, question, "Отвечай?") as null|text
			if(get_turf(M) == original_pos)
				new /mob/living/ventriloquist_decoy(get_turf(src), user, target, phrase)
				target.was_asked += 1
			else
				to_chat(user, SPAN_CLASS("tajaran", "Дух подал сигнал, но не нашел пути к нам."))
		else
			to_chat(user, SPAN_CLASS("tajaran", "Дух противится мне"))
			user.psi.backblast(1)
			return

/mob/observer/ghost
	var/was_asked = 0

// ---------------------
//		РУНА ЗРЕНИЯ
// ---------------------

/obj/decal/cleanable/psychic/eversee
	runenumber = 4
	cost = 20
	var/currently_casting = FALSE

/obj/decal/cleanable/psychic/eversee/cast(mob/living/user, spend_power)
	. = ..()
	var/org_view = user.client.view
	to_chat(user, SPAN_CLASS("tajaran", "Мы погружаемся в транс, мы безмятежны, сместив свое сознание за горизонт"))
	if(do_after(user, 5 SECONDS, do_flags = DO_PUBLIC_UNIQUE))
		if(get_turf(src) == get_turf(user))
			if(!user.psi.spend_power(30))
				to_chat(user, SPAN_CLASS("tajaran", "...Но оказались чужими среди духов."))
				return
			user.Stun(20)
			user.mutations.Add(MUTATION_XRAY)
			user.anchored = TRUE
			currently_casting = TRUE
			user.client.view = world.view + 6
			sleep(20 SECONDS)
			user.mutations.Remove(MUTATION_XRAY)
			user.anchored = FALSE
			currently_casting = FALSE
			user.client.view = org_view

/obj/decal/cleanable/psychic/eversee/Destroy()
	if(currently_casting)
		return
	. = ..()
