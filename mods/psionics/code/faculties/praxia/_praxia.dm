// Praxia: все способности, связанные с действием на псионику. Поглощение чужой силы, анализ потенциала, ритуалы.

/singleton/psionic_faculty/praxia
	id = PSI_PRAXIA
	name = "Praxia"
	associated_intent = I_DISARM
	ui_icon_state = "redaction"
	armour_types = list(DAMAGE_PSIONIC)

/singleton/psionic_power/praxia
	faculty = PSI_PRAXIA
	abstract_type = /singleton/psionic_power/praxia

// Воздействие на псионику другого существа.
/singleton/psionic_power/praxia/consciousness
	abstract_type = /singleton/psionic_power/praxia/consciousness

/singleton/psionic_power/praxia/consciousness/invoke(mob/living/user, mob/living/target)
	if(!is_valid_mind_target(target))
		return FALSE
	return ..()

// Ритуалы, использующие псионическую энергию.
/singleton/psionic_power/praxia/ritual
	admin_log = FALSE
	use_sound = 'mods/psionics/sounds/spiritcast.ogg'
	abstract_type = /singleton/psionic_power/praxia/ritual
