/datum/event/spontaneous_heart_attack

/datum/event/spontaneous_heart_attack/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mobs))
		if(H.client && H.stat != DEAD && H.should_have_organ(BP_HEART))
			var/obj/item/organ/internal/heart/heart = H.internal_organs_by_name[BP_HEART]
			if(!istype(heart) || BP_IS_ROBOTIC(heart) || (heart.status & ORGAN_DEAD) || heart.infarct_progress > 0)
				continue
			heart.infarct_progress = 1
			break
