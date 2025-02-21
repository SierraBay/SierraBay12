/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("smash") soundin = pick(GLOB.smash_sound)
			//if ("heavystep") soundin = pick(GLOB.heavystep_sound)
			//if ("light_strike") soundin = pick(GLOB.light_strike_sound)
			//if ("gunshot") soundin = pick(GLOB.gun_sound)
	return soundin


//smash_sound = звук стука об стенку (больно)
/mob/living/turf_collision(turf/T,speed)
	playsound(T, pick(GLOB.smash_sound), 50, 1, 1)

//fracture
/obj/item/organ/external/fracture()
	.=..()
	if(owner)
		if(can_feel_pain())
			//owner.emote("scream")
			owner.agony_scream()
		playsound(src.loc, pick(GLOB.trauma_sound), 100, 1, -2)
		//playsound(src.loc, "fracture", 100, 1, -2)

//падение
/mob/living/carbon/human/handle_fall_effect(/turf/landing)
	.=..()
	playsound(loc, pick(GLOB.smash_sound), 50, 1, -1)
	if(client) shake_camera(src, 7, 0.5)

//спарринговые шлёпания
/datum/unarmed_attack/light_strike
	attack_sound = list('packs/infinity/sound/effects/hit_punch.ogg','packs/infinity/sound/effects/hit_kick.ogg') //не работает как задумано, но хоть даёт hit_punch, нуждается в реворке


//музыка в лифте :3
/area/turbolift
	forced_ambience = list('packs/infinity/sound/SS2/music/02_elevator.mp3')
