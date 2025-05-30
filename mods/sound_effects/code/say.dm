/singleton/species/human
	speech_chance = 40

/mob/living/carbon/human/handle_speech_sound()
	if(species.name == SPECIES_HUMAN) // gender check
		species.speech_sounds = GLOB.human_clearing_throat[gender]
	.=..()
