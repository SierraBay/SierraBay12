/singleton/psionic_faculty/psychokinesis
	id = PSI_PSYCHOKINESIS
	name = "Psychokinesis"
	associated_intent = I_GRAB
	armour_types = list("melee", "bullet")

/singleton/psionic_power/psychokinesis
	faculty = PSI_PSYCHOKINESIS
	use_sound = null
	abstract_type = /singleton/psionic_power/psychokinesis

/singleton/psionic_power/psychokinesis/invoke(mob/living/user, mob/living/target)
	. = ..()

	if(. && target.psi?.deflect_psionic_attack(user))
		return FALSE
