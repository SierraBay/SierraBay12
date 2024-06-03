/datum/species/machine/New()
	LAZYINITLIST(inherent_verbs)
	inherent_verbs += /mob/living/carbon/human/proc/enter_exonet
	inherent_verbs += /mob/living/carbon/human/proc/detach_limb
	inherent_verbs += /mob/living/carbon/human/proc/attach_limb
	..()
