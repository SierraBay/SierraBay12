/singleton/psionic_faculty/praxia
	id = PSI_PRAXIA
	name = "Праксия"
	associated_intent = I_DISARM
	ui_icon_state = "redaction"
	armour_types = list(DAMAGE_PSIONIC)

/singleton/psionic_power/praxia
	faculty = PSI_PRAXIA
	abstract_type = /singleton/psionic_power/praxia

/singleton/psionic_power/praxia/consciousness
	abstract_type = /singleton/psionic_power/praxia/consciousness

/singleton/psionic_power/praxia/consciousness/invoke(mob/living/user, mob/living/target)
	if(!is_valid_mind_target(target))
		return FALSE
	return ..()

/singleton/psionic_power/praxia/ritual
	admin_log = FALSE
	use_sound = 'mods/psionics/sounds/spiritcast.ogg'
	abstract_type = /singleton/psionic_power/praxia/ritual

/datum/psi_complexus
	var/ward_until = 0
	var/mirror_until = 0
	var/null_field_active = FALSE
	var/list/branded_by

/singleton/psionic_power/praxia/psionics
	abstract_type = /singleton/psionic_power/praxia/psionics

/singleton/psionic_power/praxia/psionics/proc/contest_chance(mob/living/user, mob/living/target)
	var/user_rank = user.psi.get_rank(PSI_PRAXIA)
	var/target_rank = 0
	if(target.psi)
		for(var/faculty in target.psi.ranks)
			target_rank = max(target_rank, target.psi.ranks[faculty])
	return clamp(50 + 30 * (user_rank - target_rank), 10, 100)
