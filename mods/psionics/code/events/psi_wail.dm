/datum/event/psi/wail
	var/static/list/whine_messages = list(
		"Вой, что угнетает твой мозг, вторгается в твою голову.",
		"Ужасный, отвлекающий жужжащий звук прерывает ход твоих мыслей.",
		"Ты ощущаешь страшную мигрень, как в твою голову вторгается знакомый вой."
		)

/datum/event/psi/wail/apply_psi_effect(datum/psi_complexus/psi)
	var/annoyed
	if(prob(1))
		psi.stunned(1)
		annoyed = TRUE
	else if(psi.stamina > 0)
		psi.stamina = max(0, psi.stamina - rand(1,3))
		annoyed = TRUE
	if(annoyed && prob(1))
		to_chat(psi.owner, SPAN_NOTICE("<i>[pick(whine_messages)]</i>"))
