// Kinesis: все физические способности. Телекинез, стихии, энергия, материализация, воздействие на тело.

/singleton/psionic_faculty/kinesis
	id = PSI_KINESIS
	name = "Кинез"
	associated_intent = I_GRAB
	ui_icon_state = "psychokinesis"
	armour_types = list("melee", "bullet", "energy", "bio", "rad")

/singleton/psionic_power/kinesis
	faculty = PSI_KINESIS
	abstract_type = /singleton/psionic_power/kinesis

// Телекинез: перемещение предметов, полёт, удары.
/singleton/psionic_power/kinesis/psychokinesis
	use_sound = null
	abstract_type = /singleton/psionic_power/kinesis/psychokinesis

/singleton/psionic_power/kinesis/psychokinesis/invoke(mob/living/user, mob/living/target)
	. = ..()

	if(. && target.psi)
		if(target.psi.deflect_psionic_attack(user))
			return FALSE

// Энергия: лучи, ЭМИ, дымовая завеса.
/singleton/psionic_power/kinesis/energistics
	abstract_type = /singleton/psionic_power/kinesis/energistics

// Материализация: оружие и инструменты из псионической энергии.
/singleton/psionic_power/kinesis/manifestation
	use_manifest = TRUE
	use_sound = null
	abstract_type = /singleton/psionic_power/kinesis/manifestation

// Стихии: электричество, огонь, лёд.
/singleton/psionic_power/kinesis/metakinesis
	use_manifest = TRUE
	abstract_type = /singleton/psionic_power/kinesis/metakinesis

// Тело: лечение, диагностика, регенерация.
/singleton/psionic_power/kinesis/redaction
	admin_log = FALSE
	abstract_type = /singleton/psionic_power/kinesis/redaction

/singleton/psionic_power/kinesis/redaction/proc/check_dead(mob/living/target)
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD || (target.status_flags & FAKEDEATH))
		return TRUE
	return FALSE

/singleton/psionic_power/kinesis/redaction/invoke(mob/living/user, mob/living/target)
	if(check_dead(target))
		return FALSE
	. = ..()

// Физическое воздействие на цель в пространстве: обмен местами, невидимость.
/singleton/psionic_power/kinesis/projection
	abstract_type = /singleton/psionic_power/kinesis/projection

/singleton/psionic_power/kinesis/projection/invoke(mob/living/user, mob/living/target)
	if(!is_valid_mind_target(target))
		return FALSE
	return ..()
