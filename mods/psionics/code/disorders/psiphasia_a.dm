/singleton/psi_disorder/psiphasia_a
	id =          "psiphasia_a"
	name =        "Псифазия группы А"
	group =       "blue"
	description = "Пациент имеет псионический потенциал и убежден что он умеет его использовать, но дисциплина, может не проявится или быть галлюцинацией."
	delay_min =   1 MINUTES
	delay_max =   60 MINUTES

/singleton/psi_disorder/psiphasia_a/blocks_power(mob/living/owner, datum/psi_complexus/psi, singleton/psionic_power/power, list/state)
	if(prob(30))
		psi.stamina = max(0, psi.stamina - round((power.cost || 0) * 0.5))
		psi.ui?.update_icon()
		sound_to(owner, sound('sound/effects/psi/power_used.ogg', volume = 40))
		to_chat(owner, SPAN_WARNING("Что?"))
		return TRUE
	return FALSE

/singleton/psi_disorder/psiphasia_a/process(mob/living/owner, datum/psi_complexus/psi, list/state)
	sound_to(owner, sound('sound/effects/psi/power_used.ogg', volume = 30))
