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

// У меня большие вопросы ко всей части ниже. Помимо того, что мы добавляем анимацию распространения и диры мы делаем... что? - LordNest
/*
/obj/vine/proc/life()
	var/turf/simulated/T = get_turf(src)
	var/obj/vine/vine
	if(istype(T))
		health_current -= seed.handle_environment(T,T.return_air(),null,1)
	if(health_current < health_max)
		//Plants can grow through closed airlocks, but more slowly, since they have to force metal to make space
		var/obj/machinery/door/D = (locate(/obj/machinery/door) in loc)
		if (D)
			health_current += rand(0,0.5)
		else
			health_current += rand(1,2.5)
		update_icon()
		if(health_current > health_max)
			health_current = health_max
	else if(health_current == health_max && !vine) // && (seed.type != /datum/seed/mushroom/maintshroom) - у нас этих грибов нет вроде, это глоукэпы емнип - LordNest
		vine = new(T,seed)
		vine.dir = src.dir
		vine.transform = src.transform
		vine.growth = seed.get_trait(TRAIT_MATURATION)-1
		vine.update_icon()
		if(growth_type==0) //Vines do not become invisible.
			invisibility = INVISIBILITY_MAXIMUM
		else
			vine.layer = layer + 0.1
*/

/* Оверрадйы ради оверрайдов. Теоретически это оверрадит прок spread_to(turf/target_turf).
/obj/vine/proc/spread()
	//spread to 1-3 adjacent turfs depending on yield trait.
	var/max_spread = between(1, round(seed.get_trait(TRAIT_YIELD)*3/14), 3)

	for(var/i in 1 to max_spread)
		if(prob(spread_chance))
			sleep(rand(3,5))
			if(!get_neighbors.length(1))
				break
			var/turf/target_turf = pick(get_neighbors)
			target_turf = connecting_turfs(target_turf, loc)
			var/obj/vine/child = new type(get_turf(src),seed,src)
			after_spread(child, target_turf)
			// Update neighboring squares.
			for(var/obj/vine/neighbor in range(1,target_turf))
				neighbor.get_neighbors -= target_turf
*/

//after creation act
//by default, there goes an animation code
/obj/vine/proc/after_spread(obj/vine/child, turf/target_turf)
	sleep(1) // This should do a little bit of animation.
