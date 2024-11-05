/datum/species/adherent/New()
	LAZYINITLIST(inherent_verbs)
	inherent_verbs += /mob/living/carbon/human/proc/toggle_emergency_discharge
	..()

/datum/species/adherent/handle_movement_delay_special(mob/living/carbon/human/H)
	var/tally = 0

	for(var/obj/item/organ/external/O in H.organs)
		if(BP_IS_ROBOTIC(O))
			tally += O.slowdown
	return tally
