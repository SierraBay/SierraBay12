/datum/artifact_effect/humanify/create_new_human(mob/living/carbon/human/H)
	.= ..()
	new_human.loc = get_turf(holder)
