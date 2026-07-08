/datum/event/spontaneous_heart_attack

/datum/event/spontaneous_heart_attack/start()
	var/list/candidates = list()
	var/list/priority_candidates = list()
	for(var/mob/living/carbon/human/H in GLOB.alive_mobs)
		if(H.client && H.stat != DEAD && H.should_have_organ(BP_HEART))
			var/obj/item/organ/internal/heart/heart = H.internal_organs_by_name[BP_HEART]
			if(!istype(heart) || BP_IS_ROBOTIC(heart) || (heart.status & ORGAN_DEAD) || heart.infarct_progress > 0)
				continue
			if(H.weak_heart)
				priority_candidates += H
			else
				candidates += H

	var/mob/living/carbon/human/chosen
	if(length(priority_candidates))
		chosen = pick(priority_candidates)
	else if(length(candidates))
		chosen = pick(candidates)

	if(chosen)
		var/obj/item/organ/internal/heart/heart = chosen.internal_organs_by_name[BP_HEART]
		heart.infarct_progress = 1
