/singleton/psionic_faculty/redaction
	id = PSI_REDACTION
	name = "Redaction"
	associated_intent = I_HELP
	armour_types = list("bio", "rad")

/singleton/psionic_power/redaction
	faculty = PSI_REDACTION
	admin_log = FALSE
	abstract_type = /singleton/psionic_power/redaction

/singleton/psionic_power/redaction/proc/check_dead(mob/living/target)
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD || (target.status_flags & FAKEDEATH))
		return TRUE
	return FALSE

/singleton/psionic_power/redaction/invoke(mob/living/user, mob/living/target)
	if(check_dead(target))
		return FALSE
	. = ..()
