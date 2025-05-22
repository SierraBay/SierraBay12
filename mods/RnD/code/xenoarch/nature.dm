/datum/artifact_effect/nature
	name = "Nature"
	var/grav_type
	var/range = 4
	var/last_time_active
	var/cooldown
	var/spread = 0
	var/datum/seed/seed
	var/seed_type

/datum/artifact_effect/nature/New()
	..()
	effect_type = EFFECT_ORGANIC
	artifact_id = "nature"
	cooldown = rand(4 SECONDS, 10 SECONDS)
	range = (rand(2,5))

	if(seed_type)
		seed = new seed_type()
	else
		seed = SSplants.create_random_seed(1)

	seed.set_trait(TRAIT_SPREAD,2) //make it grow.
	spread = 30

/datum/artifact_effect/nature/DoEffectTouch(mob/living/user)
	if(user)
		grove(spread*2)

/datum/artifact_effect/nature/DoEffectPulse()
	grove(spread)

/datum/artifact_effect/nature/DoEffectAura()
	grove(spread/2)

/datum/artifact_effect/nature/proc/grove(spread)
	if(world.time - last_time_active > cooldown)
		last_time_active = world.time
		var/turf/placed = get_turf(holder)
		var/turf/picked_turf = pick(RANGE_TURFS(placed, range))
		var/obj/vine/P = new(picked_turf,seed)
		P.spread_chance = spread
		playsound(holder, 'sound/magic/repulse.ogg', 100, TRUE)
