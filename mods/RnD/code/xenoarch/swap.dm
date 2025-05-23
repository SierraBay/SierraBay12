/datum/artifact_effect/swap
	name = "Swap"
	effect_type = EFFECT_BLUESPACE
	var/range = 4
	var/datum/beam = null
	var/last_swap
	var/cooldown


/datum/artifact_effect/swap/New(atom/location)
	..()
	effect = EFFECT_PULSE
	artifact_id = "tesla"
	range = (rand(5,15))
	cooldown = rand(20 SECONDS, 60 SECONDS)


/datum/artifact_effect/swap/proc/swap(mob/user)
	if(world.time - last_swap > cooldown)
		last_swap = world.time
		var/weakness = GetAnomalySusceptibility(user)
		if(prob(weakness * 100))
			for(var/mob/T in range(range, holder))
				var/turf/aT = get_turf(T)
				var/turf/bT = get_turf(user)

				T.forceMove(bT)
				user.forceMove(aT)
				playsound(holder, 'sound/magic/mandswap.ogg', 100, FALSE)


/datum/artifact_effect/swap/DoEffectTouch(mob/user)
	if(user)
		if(istype(user, /mob/living))
			swap(user)

/datum/artifact_effect/swap/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/mob/living/carbon/human/H in range(src.range,T))
			if(prob(30))
				to_chat(H, SPAN_WARNING("You feel a tingle run through your body"))
			else
				swap()

/datum/artifact_effect/swap/DoEffectAura()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/mob/living/carbon/human/H in range(src.range,T))
			if(prob(60))
				to_chat(H, SPAN_WARNING("You feel a tingle shock run through your body"))
			else
				swap()
