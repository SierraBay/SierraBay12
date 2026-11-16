/singleton/psionic_faculty/consciousness
	id = PSI_CONSCIOUSNESS
	name = "Consciousness"
	associated_intent = I_HELP
	armour_types = list(DAMAGE_PSIONIC, "melee")

/singleton/psionic_power/consciousness
	faculty = PSI_CONSCIOUSNESS
	abstract_type = /singleton/psionic_power/consciousness

/singleton/psionic_power/consciousness/invoke(mob/living/user, mob/living/target)
	if (!istype(target))
		return FALSE

	if(target.is_species(SPECIES_IPC) || target.is_species(SPECIES_ADHERENT))
		return FALSE

	. = ..()
	if (!.)
		return FALSE


	var/mob/living/carbon/human/V
	if(istype(V) && V != user)
		if(V.psi.deflect_psionic_attack(user))
			return FALSE
