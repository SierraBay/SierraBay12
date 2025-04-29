/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("smash") soundin = pick(GLOB.smash_sound)
			//if ("heavystep") soundin = pick(GLOB.heavystep_sound) - нигде не используются
			//if ("light_strike") soundin = pick(GLOB.light_strike_sound) - не работает как нужно :с
			//if ("gunshot") soundin = pick(GLOB.gun_sound) - нигде не используются
	return soundin


//smash_sound = звук стука об стенку (больно)
/mob/living/turf_collision(turf/T,speed)
	playsound(T, pick(GLOB.smash_sound), 50, 1, 1)

//fracture
/obj/item/organ/external/fracture()
	. = ..()
	if(owner)
		if(can_feel_pain())
			//owner.emote("scream")
			owner.agony_scream()
			playsound(src.loc, pick(GLOB.trauma_sound), 100, 1, -2)
		//playsound(src.loc, "fracture", 100, 1, -2)

//падение
/mob/living/carbon/human/handle_fall_effect(/turf/landing)
	. = ..()
	if(src.isSynthetic())
		return
	playsound(loc, pick(GLOB.smash_sound), 50, 1, -1)
	if(client) shake_camera(src, 7, 0.5)

//спарринговые шлёпания
/datum/unarmed_attack/light_strike
	attack_sound = list('packs/infinity/sound/effects/hit_punch.ogg','packs/infinity/sound/effects/hit_kick.ogg') //не работает как задумано, но хоть даёт hit_punch, нуждается в реворке


//музыка в лифте :3
/area/turbolift
	forced_ambience = list('packs/infinity/sound/SS2/music/02_elevator.mp3')

//гиб конечностей - отрубание, сжигание и т.д.
/obj/item/organ/external/droplimb(clean, disintegrate = DROPLIMB_EDGE, ignore_children, silent)
	.=..()
	var/mob/living/carbon/human/victim = owner

	var/use_flesh_colour = species.get_flesh_colour(owner)
	var/use_blood_colour = species.get_blood_colour(owner)
	switch(disintegrate)
		if(DROPLIMB_EDGE)

			if(!clean)
				playsound(victim, pick('packs/infinity/sound/effects/gore/chop2.ogg', 'packs/infinity/sound/effects/gore/chop3.ogg', 'packs/infinity/sound/effects/gore/chop4.ogg'), 100, 0)
			else
				playsound(victim, 'packs/infinity/sound/effects/gore/severed.ogg', 100, 0)

				if(victim.can_feel_pain() && prob(50))
					victim.agony_scream()
		if(DROPLIMB_BURN)
			if(victim.can_feel_pain() && prob(50))
				victim.agony_scream()
		if(DROPLIMB_BLUNT)
			var/obj/gore
			if(BP_IS_CRYSTAL(src))
				gore = new /obj/item/material/shard(get_turf(victim), MATERIAL_CRYSTAL)
			else if(BP_IS_ROBOTIC(src))
				gore = new /obj/decal/cleanable/blood/gibs/robot(get_turf(victim))
			else
				gore = new /obj/decal/cleanable/blood/gibs(get_turf(victim))
				if(species)
					var/obj/decal/cleanable/blood/gibs/G = gore
					G.fleshcolor = use_flesh_colour
					G.basecolor =  use_blood_colour
					G.update_icon()
				playsound(victim, 'packs/infinity/sound/effects/gore/chop6.ogg', 100 , 0)//Splat.

				if(victim.can_feel_pain() && prob(50))
					victim.agony_scream()

//попадания пулями
/obj/item/projectile/attack_mob(mob/living/target_mob, distance, special_miss_modifier=0)
	.=..()
	if(silenced)
		if(damage_type == DAMAGE_BRUTE)
			playsound(target_mob.loc, pick('packs/infinity/sound/effects/bullethit1.ogg', 'packs/infinity/sound/effects/bullethit2.ogg', 'packs/infinity/sound/effects/bullethit3.ogg', 'packs/infinity/sound/effects/bullethit4.ogg'), 100, 1)


//бросок штуки
/mob/living/carbon/throw_item(atom/target)
	.=..()
	playsound(src, 'packs/infinity/sound/effects/throw.ogg', 50, 1)
