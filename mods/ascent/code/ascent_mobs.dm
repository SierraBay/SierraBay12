/mob/living/carbon/human/ascent_alate/New(new_loc)
	gender = MALE
	..(new_loc, SPECIES_MANTID_ALATE)

/mob/living/carbon/human/ascent_gyne/New(new_loc)
	gender = FEMALE
	..(new_loc, SPECIES_MANTID_GYNE)

/mob/living/carbon/human/ascent_monarch/New(new_loc)
	gender = MALE
	..(new_loc, SPECIES_MONARCH_WORKER)

/mob/living/carbon/human/ascent_monarch_queen/New(new_loc)
	gender = FEMALE
	..(new_loc, SPECIES_MONARCH_QUEEN)
