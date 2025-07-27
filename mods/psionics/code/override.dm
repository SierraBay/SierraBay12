/datum/job/proc/give_psi(mob/living/carbon/human/H)

	if(!(H.species.name == SPECIES_HUMAN || H.species.name == SPECIES_VATGROWN || H.species.name == SPECIES_SPACER || H.species.name == SPECIES_GRAVWORLDER || H.species.name == SPECIES_MULE))
		return
	/*
	if(H.client.prefs.organ_data[BP_CHEST] == "cyborg")
		return // No psionics for cyborgs.
	*/
	if(psi_latency_chance && prob(psi_latency_chance))
		H.set_psi_rank(pick(PSI_COERCION, PSI_REDACTION, PSI_ENERGISTICS, PSI_PSYCHOKINESIS, PSI_CONSCIOUSNESS, PSI_MANIFESTATION, PSI_METAKINESIS), 1, defer_update = TRUE)

	if(!whitelist_lookup(SPECIES_PSI, H.client.ckey))
		return

	var/list/psi_abilities_by_name = H.client.prefs.psi_abilities

	if(!H.client.prefs.psi_threat_level)
		return

	LAZYINITLIST(psi_faculties)
	for(var/faculty_name in list("Coercion", "Consciousness", "Energistics", "Manifestation", "Metakinesis", "Psychokinesis", "Redaction"))
		var/singleton/psionic_faculty/faculty = SSpsi.faculties_by_name[faculty_name]
		var/faculty_id = faculty.id
		psi_faculties |= list("[faculty_id]" = psi_abilities_by_name[faculty_name] - 1)

	for(var/psi in psi_faculties)
		if(psi_faculties[psi] > 0)
			H.set_psi_rank(psi, psi_faculties[psi], take_larger = TRUE, defer_update = TRUE)

	H.psi.update()

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
		switch(H.mind.assigned_job.department)
			if("Охранный")
				if(H.mind.assigned_job.title == "Criminal Investigator" || H.mind.assigned_job.title == "Forensic Technician")
					return
				imp.psi_mode = "Issue Reprimand"
	to_chat(H, SPAN_DANGER("As a registered psionic, you are fitted with a psi-dampening control implant. Using psi-power while the implant is active will result in neural shocks and your violation being reported."))

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

/datum/job

	give_psionic_implant_on_join = FALSE // Псиота не имплантируется при заходе. Сделано для ИПиБС

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
