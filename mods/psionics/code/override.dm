/datum/job/proc/give_psi(mob/living/carbon/human/H)

	if(!(H.species.name in HUMAN_SPECIES) && H.species.name != SPECIES_TAJARA)
		return
	/*
	if(H.client.prefs.organ_data[BP_CHEST] == "cyborg")
		return // No psionics for cyborgs.
	*/

	if(psi_latency_chance && prob(psi_latency_chance) || H.species.name == SPECIES_MULE)
		H.set_psi_rank(pick(GLOB.psi_faculty_ids), TRUE, take_larger = TRUE, defer_update = TRUE)
	if(H.species.name == SPECIES_MULE)
		H.psi.max_stamina = 100
		H.psi.cooldown_modifier -= 0.1

		var/buff_per_mutation = 0
		for(var/obj/item/organ/external/E in H.organs)
			if(E.status & ORGAN_MUTATED)
				buff_per_mutation += 0.1
		H.psi.cooldown_modifier -= buff_per_mutation

	if(!H.client || !whitelist_lookup(SPECIES_PSI, H.client.ckey))
		return

	var/datum/preferences/P = H.client.prefs

	if(!P.psi_threat_level)
		return

	var/list/faculty_ranks = list()
	var/list/job_choices = list()
	if(islist(psi_faculties))
		for(var/job_faculty in psi_faculties)
			var/job_rank = psi_faculties[job_faculty]
			var/job_faculty_id = psi_normalize_faculty(job_faculty)
			if(job_rank >= PSI_RANK_APPRENTICE)
				job_choices[job_faculty_id] = max(job_choices[job_faculty_id], job_rank)
			else
				faculty_ranks[job_faculty_id] = max(faculty_ranks[job_faculty_id], job_rank)
	var/list/chosen_powers = list()

	for(var/i in 1 to length(GLOB.psi_faculty_names))
		var/faculty_name = GLOB.psi_faculty_names[i]
		var/faculty_id = GLOB.psi_faculty_ids[i]
		var/rank = P.get_psi_faculty_rank(faculty_name)
		if(rank <= 0)
			continue
		faculty_ranks[faculty_id] = max(faculty_ranks[faculty_id], rank)
		var/list/ids = list()
		for(var/singleton/psionic_power/power in P.get_chosen_psi_powers(faculty_name))
			ids += power.get_id()
		chosen_powers[faculty_id] = ids

	for(var/psi in faculty_ranks)
		if(faculty_ranks[psi] > 0)
			H.set_psi_rank(psi, faculty_ranks[psi], take_larger = TRUE, defer_update = TRUE)

	for(var/job_faculty_id in job_choices)
		if(H.psi && (H.psi.get_rank(job_faculty_id) || 0) >= job_choices[job_faculty_id])
			job_choices -= job_faculty_id
		else if(!H.psi)
			H.set_psi_rank(job_faculty_id, PSI_RANK_LATENT, take_larger = TRUE, defer_update = TRUE)

	if(H.psi)
		for(var/faculty_id in chosen_powers)
			H.psi.set_selected_powers(faculty_id, chosen_powers[faculty_id])
		H.psi.update()
		H.psi.apply_pref_disorders(P)
		if(length(job_choices))
			H.psi.queue_job_awakenings(job_choices, "профессия: [title]")

	give_psionic_implant_on_join ||= (H.client.prefs.psi_openness && H.client.prefs.psi_threat_level > 0)

	if(!give_psionic_implant_on_join)
		return

	var/obj/item/implant/psi_control/imp = new
	imp.implanted(H)
	imp.forceMove(H)
	imp.imp_in = H
	imp.implanted = TRUE
	var/obj/item/organ/external/affected = H.get_organ(BP_HEAD)
	if(affected)
		affected.implants += imp
		imp.part = affected
		switch(H.mind.assigned_job.get_department_display_name())
			if("Охранный")
				if(H.mind.assigned_job.title == "Criminal Investigator" || H.mind.assigned_job.title == "Forensic Technician")
					return
				imp.psi_mode = "Security Level Derived"
				to_chat(H, SPAN_DANGER("Ваш имплант подавитель активен в не-чрезвычайной ситуации"))
	to_chat(H, SPAN_DANGER("Как зарегистрированный псионик, вам выдан имплант подавления, для вашего контроля."))

/datum/job/equip(mob/living/carbon/human/H, alt_title, datum/mil_branch/branch, datum/mil_rank/grade)

	if (required_language)
		H.add_language(required_language)
		H.set_default_language(all_languages[required_language])

	if (!length(H.languages))
		H.add_language(LANGUAGE_SPACER)
		H.set_default_language(all_languages[LANGUAGE_SPACER])

	give_psi(H)

	var/singleton/hierarchy/outfit/outfit = get_outfit(H, alt_title, branch, grade)
	if(outfit) . = outfit.equip(H, title, alt_title)
	if(faction)
		H.faction = faction
		H.last_faction = faction

/datum/job/submap
	give_psionic_implant_on_join = FALSE

// ranged interaction telekinesis
/obj/machinery/button/do_simple_ranged_interaction(mob/user)
	if(!LAZYLEN(req_access))
		activate(user)
		return TRUE

/obj/machinery/access_button/do_simple_ranged_interaction(mob/user)
	if(!LAZYLEN(req_access))
		if(radio_connection)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = master_tag
			signal.data["command"] = command

			radio_connection.post_signal(src, signal, RADIO_AIRLOCK, AIRLOCK_CONTROL_RANGE)
	flick("access_button_cycle", src)
	return TRUE

/obj/machinery/airlock_sensor/do_simple_ranged_interaction(mob/user)
	if(!LAZYLEN(req_access))
		if(radio_connection)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = master_tag
			signal.data["command"] = command

			radio_connection.post_signal(src, signal, RADIO_AIRLOCK, AIRLOCK_CONTROL_RANGE)
	flick("airlock_sensor_cycle", src)
	return TRUE

/obj/machinery/disposal/do_simple_ranged_interaction(mob/user)
	flush()
	return TRUE

/obj/machinery/floodlight/do_simple_ranged_interaction(mob/user)
	if(use_power)
		turn_off(1)
	else
		if(!turn_on(1))
			to_chat(user, "You try to turn on \the [src] but it does not work.")
			playsound(src.loc, 'sound/effects/flashlight.ogg', 50, 0)

	update_icon()
	return TRUE

/obj/machinery/light_switch/do_simple_ranged_interaction(mob/user)
	playsound(src, "switch", 30)
	set_state(!on)
	return TRUE

/obj/structure/lift/button/do_simple_ranged_interaction(mob/user)
	interact()
	return TRUE

// w_class
/obj/structure/closet
	w_class = ITEM_SIZE_LARGE

/obj/item/card/operant_card
	name = "operant registration card"
	icon_state = "warrantcard_civ"
	desc = "A registration card in a faux-leather case. It marks the named individual as a registered, law-abiding psionic."
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("whipped")
	hitsound = 'sound/weapons/towelwhip.ogg'
	var/info
	var/use_rating
	var/disorder


/obj/item/card/operant_card/proc/set_info(mob/living/carbon/human/human)
	if(!istype(human))
		return
	switch(human.psi?.rating)
		if(0)
			use_rating = "Нет"
		if(1)
			use_rating = "[human.psi.rating]-Омикрон"
		if(2)
			use_rating = "[human.psi.rating]-Омега"
		if(3)
			use_rating = "[human.psi.rating]-Ламед"
		if(4)
			use_rating = "[human.psi.rating]-Гиммель"
		if(5)
			use_rating = "[human.psi.rating]-Алеф"
		if (6 to INFINITY)
			use_rating = "[human.psi.rating]-Пост Алеф"
		else
			use_rating = "Нет"

	disorder = ""
	if(human.psi.disorders)
		for(var/id in human.psi.disorders)
			var/singleton/psi_disorder/D = get_psi_disorder(id)
			if(!D)
				continue
			disorder += "<li>[D.name]</li>"


	info = {"\
		Имя: [human.real_name]\n\
		Отпечаток: [human.dna?.uni_identity ? md5(human.dna.uni_identity) : "Нет"]\n\
		Рейтинг: [use_rating]\n\
		Диагноз: <ul>[disorder ? disorder : "Нет"]</ul>\
	"}

/obj/item/card/operant_card/attack_self(mob/living/user)
	user.visible_message(
		SPAN_ITALIC("\The [user] examines \a [src]."),
		SPAN_ITALIC("You examine \the [src]."),
		3
	)
	to_chat(user, info || SPAN_WARNING("\The [src] is completely blank!"))

/datum/antagonist/thrall
	skill_setter = null // Issue #3698 Баг: Траллирование псиоником сбрасывает все скиллы цели на бейсик

/datum/reagent/drugs/three_eye
	metabolism = REM * 0.5
	overdose = 10

	var/boosted = FALSE
	var/boosted_overdose = FALSE

/datum/reagent/drugs/three_eye/affect_blood(mob/living/carbon/M, removed)
	M.add_client_color(/datum/client_color/thirdeye)
	M.add_chemical_effect(CE_THIRDEYE, 1)
	M.add_chemical_effect(CE_MIND, -2)
	M.hallucination(50, 50)
	M.make_jittery(3)
	M.make_dizzy(3)
	if(M.psi)
		if(!boosted)
			for(var/rank in M.psi.ranks)
				if(M.psi.ranks[rank] > 1 && M.psi.ranks[rank] < 5)
					M.set_psi_rank(rank, M.psi.get_rank(rank) + 1, take_larger = TRUE, temporary = TRUE)
			boosted = TRUE
		M.psi.stamina = M.psi.max_stamina
	if(prob(0.1) && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.adjustBrainLoss(rand(8, 12))
	..()

/datum/reagent/drugs/three_eye/process_overdose(mob/living/carbon/M)
	M.add_chemical_effect(CE_TOXIN, 1)
	M.adjustToxLoss(REM)
	M.adjustBrainLoss(rand(1, 5))
	if(ishuman(M) && prob(10))
		var/mob/living/carbon/human/H = M
		H.vomit()
	if(prob(10))
		to_chat(M, SPAN_DANGER(SPAN_SIZE(rand(2,4), pick(overdose_messages))))
	if(M.psi)
		M.psi.check_latency_trigger(30, "передоза Три-глазом", TRUE) // Урон мозгу может и клево, но выжить почти нереально.
		if(!boosted_overdose)
			for(var/rank in M.psi.ranks)
				if(M.psi.ranks[rank] > 1 && M.psi.ranks[rank] < 5)
					M.set_psi_rank(rank, M.psi.get_rank(rank) + 1, take_larger = TRUE, temporary = TRUE)
			boosted_overdose = TRUE

/datum/reagent/drugs/three_eye/on_leaving_metabolism(mob/parent, metabolism_class)
	var/mob/living/carbon/human/M = parent
	parent.remove_client_color(/datum/client_color/thirdeye)
	if(M.psi)
		boosted = FALSE
		boosted_overdose = FALSE
		if(!istype(M.head, /obj/item/clothing/head/helmet/space/psi_amp) && M.head.canremove != TRUE)
			M.psi.reset()
		M.psi.stamina = 0

		M.empty_stomach()

		sound_to(M, sound('mods/psionics/sounds/screamer.ogg'))

		var/obj/screen/fullscreen/revelation = new /obj/screen/fullscreen()
		revelation.screen_loc = "1,1"
		revelation.icon = 'mods/psionics/icons/fullscreen.dmi'
		revelation.icon_state = "scary[rand(1,9)]"
		revelation.mouse_opacity = FALSE
		revelation.scale_to_view = TRUE

		M.client.screen += revelation
		sleep(1 SECOND)
		animate(revelation, 4 SECONDS, alpha = 0)
		QDEL_IN(revelation, 4 SECONDS)
