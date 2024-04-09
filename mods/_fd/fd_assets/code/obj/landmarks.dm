/obj/reactor_radiate
	name = "Reactor Radiation Spawner"
	icon = 'icons/effects/landmarks.dmi'
	icon_state = "x2"
	var/radiation_power = 70
	var/datum/radiation_source/S
	var/req_range = 2

/obj/reactor_radiate/Initialize()
	. = ..()

	name = null
	icon = null
	icon_state = null

	S = new()
	S.flat = TRUE
	S.range = req_range
	S.respect_maint = FALSE
	S.decay = FALSE
	S.source_turf = get_turf(src)
	S.update_rad_power(radiation_power)
	SSradiation.add_source(S)

	loc.set_light(0.2, 1, req_range, l_color = COLOR_LIME) //The goo doesn't last, so this is another indicator

/obj/reactor_radiate/Destroy()
	. = ..()
	QDEL_NULL(S)

//Applies fire act to the turf
/obj/landmark/explosion
	name = "explosion"
	icon_state = "x"
	var/range = 5

/obj/landmark/explosion/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/landmark/explosion/LateInitialize()
	var/turf/T = get_turf(src)
	if(T)
		explosion(T, range, EX_ACT_DEVASTATING, FALSE)
	qdel(src)
	. = ..()

/obj/landmark/explosion/medium
	range = 10

/obj/landmark/explosion/large
	range = 20

/obj/landmark/explosion/random
	range = 14
	var/explosion_chance = 50

/obj/landmark/explosion/random/LateInitialize()
	if(prob(explosion_chance))
		. = ..()
	else
		qdel(src)


/obj/landmark/damager
	name = "damager"
	icon_state = "fire"
	var/random_dam_min = 20
	var/random_dam_max = 80

/obj/landmark/damager/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/landmark/damager/LateInitialize()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.damage_health(rand(random_dam_min,random_dam_max))
	qdel(src)
