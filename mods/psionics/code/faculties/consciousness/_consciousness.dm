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
