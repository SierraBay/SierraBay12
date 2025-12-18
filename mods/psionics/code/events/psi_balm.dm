/datum/event/psi/balm
	var/static/list/balm_messages = list(
		"Успокаивающие мысли омывают вашу психонетику.",
		"На момент, ты слышишь приятный, знакомый голос, что поет песню где-то в дали.",
		"Чувство покоя и комфорта окутывает вас, словно теплое одеяло."
		)

/datum/event/psi/balm/apply_psi_effect(datum/psi_complexus/psi)
	var/soothed
	if(psi.stun > 1)
		psi.stun--
		soothed = TRUE
	else if(psi.stamina < psi.max_stamina)
		psi.stamina = min(psi.max_stamina, psi.stamina + rand(1,3))
		soothed = TRUE
	else if(psi.owner.getBrainLoss() > 0)
		psi.owner.adjustBrainLoss(-1)
		soothed = TRUE
	if(soothed && prob(10))
		to_chat(psi.owner, SPAN_NOTICE("<i>[pick(balm_messages)]</i>"))
