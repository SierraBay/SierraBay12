/datum/artifact_effect/tesla
	name = "Tesla"
	effect_type = EFFECT_ELECTRO
	var/range = 4
	var/datum/beam = null
	var/last_electra_attack
	var/electra_attack_cooldown


/datum/artifact_effect/tesla/New(atom/location)
	..()
	effect = EFFECT_PULSE
	artifact_id = "tesla"
	range = (rand(2,5))
	electra_attack_cooldown = rand(2 SECONDS, 10 SECONDS)


/datum/artifact_effect/tesla/proc/attack()
	var/picked_mobs_to_attack = list()
	if(world.time - last_electra_attack > electra_attack_cooldown)
		last_electra_attack = world.time
		var/turf/picked_turf
		var/turf/placed = get_turf(holder)
		picked_turf = pick(RANGE_TURFS(placed, range))
		for(var/mob/living/carbon/picked_robotic in range(src.range, placed))
			for(var/obj/item/organ/O in picked_robotic.organs)
				if(BP_IS_ROBOTIC(O))
					if(picked_robotic in picked_mobs_to_attack)
						continue
					picked_mobs_to_attack += picked_robotic

		for(var/mob/living/picked_robotic in picked_turf)
			electroanomaly_act(picked_robotic, FALSE)

		for(var/mob/living/picked_robohobo in picked_mobs_to_attack)
			if(picked_robohobo)
				electroanomaly_act(picked_robohobo, FALSE)
				beam = placed.Beam(BeamTarget = picked_robohobo, icon_state = "electra_long",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)
		playsound(placed, 'mods/anomaly/sounds/electra_blast.ogg', 100, FALSE)
		beam = placed.Beam(BeamTarget = picked_turf, icon_state = "electra_long",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)


/datum/artifact_effect/tesla/DoEffectTouch(mob/user)
	if(user)
		if(istype(user, /mob/living))
			attack()

/datum/artifact_effect/tesla/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/mob/living/carbon/human/H in range(src.range,T))
			if(prob(30))
				to_chat(H, SPAN_WARNING("You feel a tingle run through your body"))
			else
				attack()

/datum/artifact_effect/tesla/DoEffectAura()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/mob/living/carbon/human/H in range(src.range,T))
			if(prob(60))
				to_chat(H, SPAN_WARNING("You feel a tingle shock run through your body"))
			else
				attack()
