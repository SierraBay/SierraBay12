
/datum/psi_complexus
	var/instability_until = 0
	var/instability_total = 0
	var/instability_severity = 1

/datum/psi_complexus/proc/is_unstable()
	return world.time < instability_until

/datum/psi_complexus/proc/get_instability_targets(radius)
	. = list()
	if(!owner)
		return
	for(var/mob/living/M in oview(radius, owner))
		if(M.stat == DEAD || M.disrupts_psionics())
			continue
		. += M

/datum/psi_complexus/proc/trigger_instability(severity = 1, effect)
	if(!owner || owner.stat == DEAD)
		return FALSE
	severity = clamp(round(severity), 1, 3)
	if(suppressed)
		severity = max(1, severity - 1) // подавленная сила прорывается слабее

	if(!effect)
		var/list/pool = list("flicker", "shudder", "whispers", "kinetic", "drain")
		if(severity >= 2)
			pool += "surge"
		effect = pick(pool)

	switch(effect)
		if("flicker")
			instability_flicker(severity)
		if("shudder")
			instability_shudder(severity)
		if("whispers")
			instability_whispers(severity)
		if("surge")
			instability_surge(severity)
		if("kinetic")
			instability_kinetic(severity)
		if("drain")
			instability_drain(severity)
		else
			return FALSE
	return TRUE

/datum/psi_complexus/proc/start_instability(duration = 3 MINUTES, severity = 2)
	set waitfor = FALSE

	var/was_unstable = is_unstable()
	instability_until = max(instability_until, world.time + duration)
	instability_total = max(instability_total, duration)
	instability_severity = clamp(max(instability_severity, severity), 1, 3)
	if(was_unstable)
		return

	while(owner && !QDELETED(src) && is_unstable())
		sleep(rand(8 SECONDS, 20 SECONDS))
		if(!owner || QDELETED(src) || !is_unstable())
			break
		var/remaining = (instability_until - world.time) / max(instability_total, 1)
		trigger_instability(ceil(instability_severity * clamp(remaining, 0, 1)))

	instability_total = 0
	instability_severity = 1
	if(owner && !QDELETED(src))
		to_chat(owner, SPAN_NOTICE("Бурлящая внутри сила наконец успокаивается и ложится ровнее."))

/datum/psi_complexus/proc/stop_instability()
	instability_until = 0

/datum/psi_complexus/proc/instability_flicker(severity = 1)
	set waitfor = FALSE
	if(!owner)
		return
	var/radius = 2 + severity * 2
	for(var/obj/machinery/light/L in view(radius, owner))
		if(prob(40 + severity * 15))
			L.flicker(rand(3, 4 + severity * 3))

	var/image/aura = get_aura_image()
	if(aura)
		animate(aura, alpha = 220, time = 2, easing = SINE_EASING)
		animate(alpha = max(last_aura_alpha, 40), time = 15)
	playsound(owner, 'sound/effects/psi/power_unlock.ogg', 30 + severity * 10, 1)
	to_chat(owner, SPAN_WARNING("Твоя аура вспыхивает, и свет вокруг мигает в такт пульсу."))
	for(var/mob/living/M in get_instability_targets(radius))
		to_chat(M, SPAN_WARNING("Свет вокруг [owner] мигает, и на мгновение кажется, что по краю зрения расплываются цветные пятна."))

	sleep(2 SECONDS)
	if(owner && !QDELETED(src))
		start_aura_pulse()

/datum/psi_complexus/proc/instability_shudder(severity = 1)
	set waitfor = FALSE
	if(!owner)
		return
	var/mob/living/L = owner
	var/start_x = L.pixel_x
	var/start_y = L.pixel_y
	to_chat(L, SPAN_WARNING(pick(
		"Тело сводит мелкой дрожью, будто через него пропустили ток.",
		"Что-то внутри тебя дёргается и не желает подчиняться.",
		"Сила рвётся наружу, и ты едва удерживаешь её.")))
	for(var/i in 1 to (4 + severity * 3))
		animate(L, pixel_x = start_x + rand(-3, 3), pixel_y = start_y + rand(-2, 2), time = 1)
		sleep(1)
	animate(L, pixel_x = start_x, pixel_y = start_y, time = 2)

	if(iscarbon(L))
		L.make_jittery(15 * severity)
	for(var/mob/living/M in get_instability_targets(1 + severity))
		to_chat(M, SPAN_WARNING("Воздух возле [owner] дрожит, у тебя закладывает уши, а в висках начинает стучать."))
		if(iscarbon(M))
			M.make_dizzy(4 * severity)

/datum/psi_complexus/proc/instability_whispers(severity = 1)
	if(!owner)
		return
	var/list/lines = list(
		"Убей.",
		"Калечь.",
		"Трави их.",
		"Убейся.",
		"Вскройся.",
		". . .",
		"Беги отсюда.",
		"Уже поздно.",
		"Ты спишь.",
		"Ты должен проснутся.",
		"Сигналу некуда дется.",
		"[pick("Земля", "Вода", "Булыжник", "Растительность", "Потолок", "Червь")] [pick("синтезирует", "растворяет", "аннигилирует", "бросает", "гниёт", "пьянеет")] [pick("ЗАДУМАЙСЯ", "УБЕЙ СЕБЯ", "ГЛУПЕЙ", "ПОДЕЛИСЬ", "ВНУШАЙСЯ")]",
		"Покажи себя.",
		"Ты - повелитель этих недолюдей.",
		"Ты зверь.",
		"Закончи это.",
		"Ты ужасен.",
		"Ты нелюдь.",
		"Ты сверхчеловек.",
		"Вернись.")
	sound_to(owner, sound('sound/effects/psi/power_evoke.ogg', volume = 30))
	to_chat(owner, SPAN_OCCULT(pick(lines)))
	for(var/mob/living/carbon/M in get_instability_targets(3 + severity * 2))
		if(M.psi || prob(35 * severity))
			to_chat(M, SPAN_OCCULT(pick(lines)))
			M.adjust_hallucination(rand(3, 6) * severity)

/datum/psi_complexus/proc/instability_surge(severity = 1)
	if(!owner)
		return
	playsound(owner, 'sound/effects/psi/power_feedback.ogg', 50 + severity * 10, 1)
	new /obj/temporary(get_turf(owner), 6, 'icons/effects/effects.dmi', "summoning")
	for(var/turf/T in range(1 + severity, owner))
		if(prob(30))
			new /obj/temporary(T, 4, 'icons/effects/effects.dmi', "purple_electricity_constant")

	to_chat(owner, SPAN_DANGER("Сила вырывается из тебя неуправляемой волной!"))
	stamina = max(0, stamina - rand(4, 8) * severity)
	if(severity >= 3)
		owner.adjustBrainLoss(rand(1, 3))
		owner.emote("scream")
	if(ui)
		ui.update_icon()

	for(var/mob/living/M in get_instability_targets(2 + severity))
		to_chat(M, SPAN_DANGER("От [owner] расходится волна жара, и перед глазами всё вспыхивает белым!"))
		M.flash_eyes()
		if(iscarbon(M))
			M.mod_confused(rand(1, 2) * severity)
		if(M.psi && !M.psi.suppressed)
			M.psi.spend_power(rand(2, 5) * severity)

/datum/psi_complexus/proc/instability_kinetic(severity = 1)
	if(!owner)
		return
	var/radius = 2 + severity
	var/moved = 0
	for(var/obj/item/I in view(radius, owner))
		if(I.anchored || !isturf(I.loc) || I.w_class > ITEM_SIZE_NORMAL)
			continue
		if(!prob(30 + severity * 15))
			continue
		animate(I, pixel_x = I.pixel_x + rand(-3, 3), pixel_y = I.pixel_y + rand(2, 5), time = 2)
		animate(pixel_x = I.pixel_x, pixel_y = I.pixel_y, time = 3)
		if(severity >= 2)
			step_rand(I)
		moved++
	if(moved)
		playsound(owner, 'sound/effects/psi/power_used.ogg', 30, 1)
		owner.visible_message(
			SPAN_WARNING("Мелкие предметы вокруг [owner] начинают подрагивать и сами собой ползти по полу."),
			SPAN_WARNING("Вещи вокруг дрожат и ползут по полу, повинуясь твоим невольным мыслям."))

/datum/psi_complexus/proc/instability_drain(severity = 1)
	if(!owner)
		return
	var/drained = FALSE
	for(var/mob/living/M in get_instability_targets(2 + severity * 2))
		if(M.psi && !M.psi.suppressed)
			M.psi.stamina = max(0, M.psi.stamina - rand(3, 8) * severity)
			if(M.psi.ui)
				M.psi.ui.update_icon()
			to_chat(M, SPAN_WARNING("Что-то из [owner] тянет твою силу, как сквозняк тянет тепло."))
			drained = TRUE
		else
			to_chat(M, SPAN_WARNING("По коже пробегает холод, будто рядом с [owner] кто-то открыл дверь в вакуум."))
			if(iscarbon(M))
				M.make_jittery(5 * severity)
	if(drained)
		stamina = min(max_stamina, stamina + rand(2, 5) * severity)
		to_chat(owner, SPAN_NOTICE("Ты ощущаешь чужую силу, и она тебе слишком легко достаётся."))
		if(ui)
			ui.update_icon()
