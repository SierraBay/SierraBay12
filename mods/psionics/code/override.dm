/datum/job/proc/give_psi(mob/living/carbon/human/H)

	if(!(GLOB.species_by_name[SPECIES_HUMAN]) || !(GLOB.species_by_name[SPECIES_VATGROWN]) || !(GLOB.species_by_name[SPECIES_SPACER]) || !(GLOB.species_by_name[SPECIES_GRAVWORLDER]) || !(GLOB.species_by_name[SPECIES_MULE]))
		return

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

	give_psionic_implant_on_join = FALSE // If psionic, will be implanted for control.
