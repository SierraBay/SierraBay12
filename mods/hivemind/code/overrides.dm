// Hivemind wireweeds
/datum/seed/wires
	name = "wires"
	seed_name = "strange wires"
	display_name = "strange wires"
	seed_noun = "wires"
	force_layer = 3
	chems = list("fuel" = list(1,5))

/datum/seed/wires/New()
	..()
	set_trait(TRAIT_IMMUTABLE,1)
	set_trait(TRAIT_PLANT_COLOUR,null)
	set_trait(TRAIT_YIELD,-1)
	set_trait(TRAIT_SPREAD,3)
	set_trait(TRAIT_POTENCY,50)



/obj/effect/plant/proc/life()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		health -= seed.handle_environment(T,T.return_air(),null,1)
	if(health < max_health)
		//Plants can grow through closed airlocks, but more slowly, since they have to force metal to make space
		var/obj/machinery/door/D = (locate(/obj/machinery/door) in loc)
		if (D)
			health += rand_between(0,0.5)
		else
			health += rand_between(1,2.5)
		refresh_icon()
		if(health > max_health)
			health = max_health
	else if(health == max_health && !plant && (seed.type != /datum/seed/mushroom/maintshroom))
		plant = new(T,seed)
		plant.dir = src.dir
		plant.transform = src.transform
		plant.age = seed.get_trait(TRAIT_MATURATION)-1
		plant.update_icon()
		if(growth_type==0) //Vines do not become invisible.
			invisibility = INVISIBILITY_MAXIMUM
		else
			plant.layer = layer + 0.1


/obj/effect/plant/proc/spread()
	//spread to 1-3 adjacent turfs depending on yield trait.
	var/max_spread = between(1, round(seed.get_trait(TRAIT_YIELD)*3/14), 3)

	for(var/i in 1 to max_spread)
		if(prob(spread_chance))
			sleep(rand(3,5))
			if(!neighbors.len)
				break
			var/turf/target_turf = pick(neighbors)
			target_turf = get_connecting_turf(target_turf, loc)
			var/obj/effect/plant/child = new type(get_turf(src),seed,src)
			after_spread(child, target_turf)
			// Update neighboring squares.
			for(var/obj/effect/plant/neighbor in range(1,target_turf))
				neighbor.neighbors -= target_turf


//after creation act
//by default, there goes an animation code
/obj/effect/plant/proc/after_spread(obj/effect/plant/child, turf/target_turf)
	spawn(1) // This should do a little bit of animation.
