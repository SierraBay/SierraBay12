/mob/living/var/next_agony_scream = 0

/mob/living/proc/agony_scream()
	if(stat || is_species(SPECIES_MONKEY))
		return

	if(world.time < next_agony_scream)
		return
	next_agony_scream = world.time + 2 SECONDS

	if(is_species(SPECIES_NABBER))
		emote(pick("chitter", "buzz", "hiss"))
		return
    
	var/scream_sound = null
	var/message = null

	if(ishuman(src))
		if(!is_muzzled())
			switch(gender)
				if(MALE)
					scream_sound = pick('mods/emote_panel/sound/pain_male_1.ogg','mods/emote_panel/sound/pain_male_2.ogg','mods/emote_panel/sound/pain_male_3.ogg')
				if(FEMALE)
					scream_sound = pick('mods/emote_panel/sound/agony_female_1.ogg') //найти что-то лучше криков ведьмы L4D для вариаций агонии
			message = "кричит от боли!"
			playsound(src, scream_sound, 50, 0, 1)
		else
			message = "издает громкое мычание!"

	if(message)
		custom_emote(2, message)

/mob/living/proc/agony_moan()
	if(stat || is_species(SPECIES_MONKEY))
		return
	if(is_species(SPECIES_NABBER))
		emote(pick("chitter", "buzz", "hiss"))
		return
	var/moan_sound = null
	var/message = null

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(!is_muzzled())
			switch(gender)
				if(MALE)
					moan_sound = pick('mods/emote_panel/sound/moan_male_1.ogg','mods/emote_panel/sound/moan_male_2.ogg','mods/emote_panel/sound/moan_male_3.ogg')
				if(FEMALE)
					moan_sound = pick('mods/emote_panel/sound/moan_female_1.ogg','mods/emote_panel/sound/moan_female_2.ogg','mods/emote_panel/sound/moan_female_3.ogg')
			message = "стонет от боли!"
		else
			message = "издает громкое мычание!"

		if(moan_sound)
			if(H.species.name in SOUNDED_SPECIES)
				playsound(src, moan_sound, 50, 0, 1)

	if(message)
		custom_emote(2, message)
