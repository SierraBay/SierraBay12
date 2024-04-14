/datum/species/unathi/yeosa/New()
	if (/datum/unarmed_attack/bite/venom in unarmed_types)
		unarmed_types -= /datum/unarmed_attack/bite/venom
	unarmed_types += /datum/unarmed_attack/bite/venom/yeosa
	inherent_verbs += list(/mob/living/carbon/human/unathi/yeosa/proc/decant_venom)
	. = ..()
