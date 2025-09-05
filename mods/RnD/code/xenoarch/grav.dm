
#define GRAVITY_PULL 0
#define GRAVITY_REPELL 1

/datum/artifact_effect/gravity
	name = "Gravity"
	var/grav_type
	var/range = 4
	var/last_time_active
	var/cooldown

/datum/artifact_effect/gravity/New()
	..()
	effect_type = EFFECT_BLUESPACE
	artifact_id = "grav"
	grav_type = pick(GRAVITY_PULL, GRAVITY_REPELL)
	cooldown = rand(4 SECONDS, 10 SECONDS)
	range = (rand(2,5))

/datum/artifact_effect/gravity/DoEffectTouch(mob/living/user)
	if(user)
		if(istype(user, /mob/living))
			var/turf/T = get_turf(holder)
			for(var/mob/living/receiver in range(range, T))
				calc_protection_and_step(receiver, T)

/datum/artifact_effect/gravity/DoEffectPulse()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(range, curr_turf))
		calc_protection_and_step(receiver, curr_turf)

/datum/artifact_effect/gravity/DoEffectAura()
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/receiver in range(range, curr_turf))
		calc_protection_and_step(receiver, curr_turf)

/datum/artifact_effect/gravity/proc/calc_protection_and_step(mob/living/M, turf/T)
	if(world.time - last_time_active > cooldown)
		last_time_active = world.time
		var/protection = GetAnomalySusceptibility(M)
		playsound(holder, 'sound/effects/EMPulse.ogg', 100, TRUE)
		if(!protection)
			return
		var/turfs_to_step = 0
		turfs_to_step = round(protection * 8 / 2) //4 turfs in no protection, 1 turf in 0,1 protection
		while(turfs_to_step > 0)
			grav_type ? step_away(M, T) : step_towards(M, T)
			turfs_to_step--
			sleep(0.2 SECONDS)

#undef GRAVITY_PULL
#undef GRAVITY_REPELL
