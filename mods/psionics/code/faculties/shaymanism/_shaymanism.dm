/singleton/psionic_faculty/shaymanism
	id = PSI_SHAYMANISM
	name = "Shaymanism"
	associated_intent = I_HELP
	armour_types = list("psi")

/singleton/psionic_power/shaymanism
	faculty = PSI_SHAYMANISM
	admin_log = FALSE
	abstract_type = /singleton/psionic_power/shaymanism
	use_sound = 'mods/psionics/sounds/spiritcast.ogg'

/*
/singleton/psionic_power/shaymanism/proc/check_dead(mob/living/target)
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD || (target.status_flags & FAKEDEATH))
		return TRUE
	return FALSE

/singleton/psionic_power/shaymanism/invoke(mob/living/user, mob/living/target)
	if(check_dead(target))
		return FALSE
	. = ..()
*/
