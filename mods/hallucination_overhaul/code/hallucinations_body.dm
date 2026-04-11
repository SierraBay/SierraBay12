// Spiders in your body
/datum/hallucination/spiderbabies
	category = "body"
	base_weight = 8
	category_cooldown = 10 SECONDS
	theme_tags = list("body")
	min_power = 40

/datum/hallucination/spiderbabies/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!istype(C, /mob/living/carbon/human))
		return "requires human body"
	return null

/datum/hallucination/spiderbabies/start()
	if(istype(holder, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = holder
		var/obj/O = pick(H.organs)
		to_chat(H, SPAN_WARNING("You feel something [pick("moving", "squirming", "skittering")] inside of your [O.name]!"))
		return TRUE
	return FALSE

// Fake internal body failures
/datum/hallucination/body_failure
	category = "body"
	base_weight = 10
	category_cooldown = 10 SECONDS
	theme_tags = list("body")
	min_power = 30

/datum/hallucination/body_failure/start()
	var/list/messages = list(
		"You can't feel your heartbeat for a terrifying second.",
		"Your left arm suddenly feels numb.",
		"Something squirms beneath your skin.",
		"Your teeth ache like they're about to loosen.",
		"You feel a cold pressure behind your eyes.",
		"Your lungs forget how to breathe for a moment."
	)
	var/message = pick(messages)
	feedback_details = " Body failure: [message]"
	to_chat(holder, SPAN_WARNING("[message]"))
	return TRUE

// Fake attack
/datum/hallucination/fakeattack
	category = "body"
	base_weight = 8
	category_cooldown = 10 SECONDS
	theme_tags = list("body")
	min_power = 30

/datum/hallucination/fakeattack/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	for(var/mob/living/M in oview(C, 1))
		return null
	return "no attacker nearby"

/datum/hallucination/fakeattack/start()
	for(var/mob/living/M in oview(holder, 1))
		to_chat(holder, SPAN_CLASS("danger", "[M] has punched [holder]!"))
		holder.playsound_local(get_turf(holder), "punch", 50)
	return TRUE

// Fake injection
/datum/hallucination/fakeattack/hypo
	min_power = 30

/datum/hallucination/fakeattack/hypo/start()
	holder.custom_pain(SPAN_WARNING("You feel a tiny prick!"), 1, TRUE)
	return TRUE

// Fake injection or bite with lingering symptoms
/datum/hallucination/fakeattack/venom
	theme_tags = list("body")
	min_power = 40
	duration = 5 SECONDS

/datum/hallucination/fakeattack/venom/start()
	holder.custom_pain(SPAN_WARNING("A sudden sting shoots through your neck!"), 1, TRUE)
	to_chat(holder, SPAN_WARNING("Your skin around the wound starts to tingle."))
	feedback_details = " Fake venom sting"
	return TRUE

/datum/hallucination/fakeattack/venom/end()
	to_chat(holder, SPAN_WARNING("Your arm goes numb for a second, then the sensation fades."))
