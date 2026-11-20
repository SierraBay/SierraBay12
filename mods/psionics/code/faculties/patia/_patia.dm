// Patia: все телепатические способности. Чтение мыслей, связь, эмоции, боль, иллюзии, контроль над разумом.

/singleton/psionic_faculty/patia
	id = PSI_PATIA
	name = "Патия"
	associated_intent = I_HELP
	ui_icon_state = "consciousness"
	armour_types = list(DAMAGE_PSIONIC, "melee")

/singleton/psionic_power/patia
	faculty = PSI_PATIA
	abstract_type = /singleton/psionic_power/patia

// Принуждение: боль, спазмы, подавление воли.
/singleton/psionic_power/patia/coercion
	abstract_type = /singleton/psionic_power/patia/coercion

/singleton/psionic_power/patia/coercion/invoke(mob/living/user, atom/target)
	if(!istype(target))
		return FALSE
	return ..()

// Сознание: телепатия, чтение мыслей, иллюзии, страх.
/singleton/psionic_power/patia/consciousness
	abstract_type = /singleton/psionic_power/patia/consciousness

/singleton/psionic_power/patia/consciousness/invoke(mob/living/user, mob/living/target)
	if(!is_valid_mind_target(target))
		return FALSE
	return ..()

// Духи: чревовещание.
/singleton/psionic_power/patia/spirit
	admin_log = FALSE
	use_sound = 'mods/psionics/sounds/spiritcast.ogg'
	abstract_type = /singleton/psionic_power/patia/spirit
