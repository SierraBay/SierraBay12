#define DEFAULT_SEED "glowshroom"
#define VINE_GROWTH_STAGES 5

/proc/spacevine_infestation(potency_min=70, potency_max=100, maturation_min=5, maturation_max=15)
	spawn() //to stop the secrets panel hanging
		var/turf/T = pick_subarea_turf(/area/hallway , list(/proc/is_station_turf, /proc/not_turf_contains_dense_objects))
		if(T)
			var/datum/seed/seed = SSplants.create_random_seed(1)
			seed.set_trait(TRAIT_SPREAD,2)             // So it will function properly as vines.
			seed.set_trait(TRAIT_POTENCY,rand(potency_min, potency_max)) // 70-100 potency will help guarantee a wide spread and powerful effects.
			seed.set_trait(TRAIT_MATURATION,rand(maturation_min, maturation_max))
			seed.set_trait(TRAIT_HARVEST_REPEAT, 1)
			seed.set_trait(TRAIT_STINGS, 1)
			seed.set_trait(TRAIT_CARNIVOROUS,2)

			seed.display_name = "strange plants" //more thematic for the vine infestation event

			//make vine zero start off fully matured
			new /obj/effect/vine(T,seed, start_matured = 1)

			log_and_message_admins("Spacevines spawned in \the [get_area(T)]", location = T)
			return
		log_and_message_admins(SPAN_NOTICE("Event: Spacevines failed to find a viable turf."))

/obj/effect/dead_plant
	anchored = TRUE
	opacity = 0
	density = FALSE
	color = DEAD_PLANT_COLOUR

/obj/effect/dead_plant/attack_hand()
	qdel(src)

/obj/effect/dead_plant/attackby()
	..()
	qdel(src)

/obj/effect/vine
	name = "vine"
	anchored = TRUE
	icon = 'icons/obj/hydroponics_growing.dmi'
	icon_state = ""
	pass_flags = PASS_FLAG_TABLE
	buckle_sound = null
	health_max = 100
	var/growth_threshold = 0
	var/growth_type = 0
	var/max_growth = 0
	var/obj/effect/vine/parent
	var/datum/seed/seed
	var/floor = 0
	var/possible_children = 20
	var/spread_chance = 30
	var/spread_distance = 4
	var/evolve_chance = 2
	var/mature_time		//minimum maturation time
	var/obj/machinery/portable_atmospherics/hydroponics/soil/invisible/plant

/obj/effect/vine/single
	spread_chance = 0

/obj/effect/vine/New(newloc, datum/seed/newseed, obj/effect/vine/newparent, start_matured = 0)
	if(!newparent)
		parent = src
	else
		parent = newparent
		parent.possible_children = max(0, parent.possible_children - 1)
	seed = newseed
	if(start_matured)
		mature_time = 0
	..()

/obj/effect/vine/Initialize(mapload, datum/seed/newseed, obj/effect/vine/newparent, start_matured = 0)
	. = ..()

	if(!SSplants)
		log_error(SPAN_DANGER("Plant controller does not exist and [src] requires it. Aborting."))
		return INITIALIZE_HINT_QDEL
	if(!istype(seed))
		seed = SSplants.seeds[DEFAULT_SEED]
	if(!seed)
		return INITIALIZE_HINT_QDEL
	name = seed.display_name
	health_max = round(seed.get_trait(TRAIT_ENDURANCE)/2)
	if(seed.get_trait(TRAIT_SPREAD) == 2)
		mouse_opacity = 2
		max_growth = VINE_GROWTH_STAGES
		growth_threshold = health_max / VINE_GROWTH_STAGES
		growth_type = seed.get_growth_type()
	else
		max_growth = seed.growth_stages
		growth_threshold = max_growth && health_max / max_growth

	if (!start_matured)
		health_current = 10

	if(max_growth > 2 && prob(50))
		max_growth-- //Ensure some variation in final sprite, makes the carpet of crap look less wonky.

	mature_time = world.time + seed.get_trait(TRAIT_MATURATION) + 15 //prevent vines from maturing until at least a few seconds after they've been created.
	spread_chance = seed.get_trait(TRAIT_POTENCY)
	spread_distance = (growth_type ? round(spread_chance*0.6) : round(spread_chance*0.3))
	possible_children = seed.get_trait(TRAIT_POTENCY)
	update_icon()

	START_PROCESSING(SSvines, src)

/obj/effect/vine/Destroy()
	wake_neighbors()
	STOP_PROCESSING(SSvines, src)
	return ..()

/obj/effect/vine/on_update_icon()
	overlays.Cut()
	var/growth = growth_threshold ? min(max_growth, round(get_current_health() / growth_threshold)) : 1
	var/at_fringe = get_dist(src,parent)
	if(spread_distance > 5)
		if(at_fringe >= spread_distance-3)
			max_growth = max(2,max_growth-1)
		if(at_fringe >= spread_distance-2)
			max_growth = max(1,max_growth-1)

	growth = max(1,max_growth)

	var/ikey = "\ref[seed]-plant-[growth]"
	if(!SSplants.plant_icon_cache[ikey])
		SSplants.plant_icon_cache[ikey] = seed.get_icon(growth)
	overlays += SSplants.plant_icon_cache[ikey]

	if(growth > 2 && growth == max_growth)
		layer = (seed && seed.force_layer) ? seed.force_layer : ABOVE_OBJ_LAYER
		if(growth_type in list(GROWTH_VINES,GROWTH_BIOMASS))
			set_opacity(1)
		if(LAZYACCESS(seed.chems, /datum/reagent/woodpulp))
			set_density(1)
			set_opacity(1)

	if((!density || !opacity) && seed.get_trait(TRAIT_LARGE))
		set_density(1)
		set_opacity(1)
	else
		layer = (seed && seed.force_layer) ? seed.force_layer : ABOVE_OBJ_LAYER
		set_density(0)

	if(!growth_type && !floor)
		SetTransform(
			rotation = dir == WEST ? 90 : dir == NORTH ? 180 : dir == EAST ? 270 : 0,
			offset_y = -rand(12, 14)
		)

	// Apply colour and light from seed datum.
	if(seed.get_trait(TRAIT_BIOLUM))
		set_light(3, 0.5, l_color = seed.get_trait(TRAIT_BIOLUM_COLOUR))
	else
		set_light(0)

/obj/effect/vine/proc/calc_dir()
	set background = 1
	var/turf/T = get_turf(src)
	if(!istype(T)) return

	var/direction = 16

	for(var/wallDir in GLOB.cardinal)
		var/turf/newTurf = get_step(T,wallDir)
		if(newTurf && newTurf.density)
			direction |= wallDir

	for(var/obj/effect/vine/shroom in T.contents)
		if(shroom == src)
			continue
		if(shroom.floor) //special
			direction &= ~16
		else
			direction &= ~shroom.dir

	var/list/dirList = list()

	for(var/i=1,i<=16, i = SHIFTL(i, 1))
		if(direction & i)
			dirList += i

	if(length(dirList))
		var/newDir = pick(dirList)
		if(newDir == 16)
			floor = 1
			newDir = 1
		return newDir

	floor = 1
	return 1

/obj/effect/vine/attackby(obj/item/W, mob/user)
	START_PROCESSING(SSvines, src)

	if(W.edge && W.w_class < ITEM_SIZE_NORMAL && user.a_intent != I_HURT)
		if(!is_mature())
			to_chat(user, SPAN_WARNING("\The [src] is not mature enough to yield a sample yet."))
			return TRUE
		if(!seed)
			to_chat(user, SPAN_WARNING("There is nothing to take a sample from."))
			return TRUE
		var/needed_skill = seed.mysterious ? SKILL_ADEPT : SKILL_BASIC
		if(prob(user.skill_fail_chance(SKILL_BOTANY, 90, needed_skill)))
			to_chat(user, SPAN_WARNING("You failed to get a usable sample."))
		else
			seed.harvest(user,0,1)
		damage_health(rand(15, 25), W.damtype)
		return TRUE

	return ..()

/obj/effect/vine/AltClick(mob/user)
	if(!CanPhysicallyInteract(user) || user.incapacitated())
		return ..()
	var/obj/item/W = user.get_active_hand()
	if(istype(W) && W.edge && W.w_class >= ITEM_SIZE_NORMAL)
		visible_message(SPAN_NOTICE("[user] starts chopping down \the [src]."))
		playsound(, W.hitsound, 100, 1)
		var/chop_time = (get_current_health() / W.force) * 0.5 SECONDS
		if(user.skill_check(SKILL_BOTANY, SKILL_ADEPT))
			chop_time *= 0.5
		if (do_after(user, chop_time, src, DO_PUBLIC_UNIQUE))
			visible_message(SPAN_NOTICE("[user] chops down \the [src]."))
			playsound(get_turf(src), W.hitsound, 100, 1)
			kill_health()

//handles being overrun by vines - note that attacker_parent may be null in some cases
/obj/effect/vine/proc/vine_overrun(datum/seed/attacker_seed, obj/effect/vine/attacker_parent)
	var/aggression = 0
	aggression += (attacker_seed.get_trait(TRAIT_CARNIVOROUS) - seed.get_trait(TRAIT_CARNIVOROUS))
	aggression += (attacker_seed.get_trait(TRAIT_SPREAD) - seed.get_trait(TRAIT_SPREAD))

	var/resiliance
	if(is_mature())
		resiliance = 0
		switch(seed.get_trait(TRAIT_ENDURANCE))
			if(30 to 70)
				resiliance = 1
			if(70 to 95)
				resiliance = 2
			if(95 to INFINITY)
				resiliance = 3
	else
		resiliance = -2
		if(seed.get_trait(TRAIT_ENDURANCE) >= 50)
			resiliance = -1
	aggression -= resiliance

	if(aggression > 0)
		damage_health(aggression * 5)

/obj/effect/vine/on_death()
	if(plant)
		plant.die()
	wake_neighbors()
	qdel(src)

/obj/effect/vine/post_health_change(health_mod, prior_health, damage_type)
	..()
	queue_icon_update()

/obj/effect/vine/proc/is_mature()
	return (get_damage_percentage() < 66 && world.time > mature_time)

/obj/effect/vine/is_burnable()
	return seed.get_trait(TRAIT_HEAT_TOLERANCE) < 1000
