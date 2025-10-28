//Wireweeds are created by the AI's nanites to spread its connectivity through the ship.
//When they reach any machine, they annihilate them and re-purpose them to the AI's needs. They are the 'hands' of our rogue AI.

// Hivemind wireweeds

// Поскольку код с Эриса не работает, мы просто будем работать от блоба

// Vine section
/obj/wireweed
	name = "strange wires"
	desc = "strange wires"
	icon = 'mods/hivemind/icons/hivemind_obj.dmi'
	icon_state = "wires"
	layer = ABOVE_CATWALK_LAYER
	health_max = 80 //we are a little bit durable

	density = FALSE
	opacity = 0
	mouse_opacity = 1
	anchored = TRUE
	damage_hitsound = 'sound/effects/razorweb_break.ogg'

	health_resistances = list(
		DAMAGE_BRUTE     = 1,
		DAMAGE_BURN      = 3,
		DAMAGE_FIRE      = 3,
		DAMAGE_EXPLODE   = 1,
		DAMAGE_STUN      = 0,
		DAMAGE_EMP       = 4,
		DAMAGE_RADIATION = 0,
		DAMAGE_BIO       = 0,
		DAMAGE_PAIN      = 0,
		DAMAGE_TOXIN     = 0,
		DAMAGE_GENETIC   = 0,
		DAMAGE_OXY       = 0,
		DAMAGE_BRAIN     = 0
	)

	var/list/killer_reagents = list("pacid", "sacid", "hclacid", "thermite")

	//internals
	var/obj/machinery/hivemind_machine/node/master_node
	var/list/wires_connections = list("0", "0", "0", "0")

	var/regen_rate = 2
	var/expandType = /obj/wireweed

	var/my_area

/obj/wireweed/New()
	..()
	spawn(2)
		update_neighbors()

	var/area/A = get_area(src)
	if(!A)
		QDEL_IN(src, 1)
		return
	my_area = A.name
	if(!(my_area in GLOB.hivemind_areas))
		GLOB.hivemind_areas.Add(my_area)
	GLOB.hivemind_areas[my_area]++

/obj/wireweed/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/wireweed/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()
	if(master_node)
		master_node.my_wireweeds.Remove(src)
	GLOB.hivemind_areas[my_area]--
	if(!GLOB.hivemind_areas[my_area]) // Last wire in that area
		GLOB.hivemind_areas.Remove(my_area)
	return ..()

/obj/wireweed/on_death()
	playsound(loc, 'sound/effects/razorweb_break.ogg', 50, 1)
	qdel(src)

/obj/wireweed/proc/regen()
	restore_health(regen_rate)

/obj/wireweed/proc/expand(turf/T)
	if (!istype(T) || T.turf_flags & TURF_DISALLOW_BLOB || istype(T, /turf/simulated/open) & !locate(/obj/structure/catwalk) in T) // We're using same logic plus open spaces won't became traps for personnel
		return

	if (!istype(T) || T.density || locate(/obj/structure/wall_frame) in T) // We can go under machines or doors, but not through solid walls plus wallframes
		return

	else
		var/obj/wireweed/child = new(T, min(get_current_health(), 30))
		if(master_node)
			master_node.add_wireweed(child)
		spawn(1)
			child.dir = get_dir(loc, T) //actually this means nothing for wires, but need for animation
			flick("spread_anim", child)
			child.forceMove(T)
			for(var/obj/wireweed/neighbor in range(1, child))
				neighbor.update_neighbors()

/obj/wireweed/proc/pulse(forceLeft, list/dirs)
	sleep(4)
	var/pushDir = pick(dirs)
	var/turf/T = get_step(src, pushDir)
	var/obj/wireweed/W = (locate() in T)
	if(!W)
		if(prob(get_current_health()))
			expand(T)
		return
	if(forceLeft)
		W.pulse(forceLeft - 1, dirs)


/obj/wireweed/proc/update_neighbors(location = loc)
	for (var/dir in GLOB.cardinal)
		var/obj/wireweed/L = locate(/obj/wireweed, get_step(location, dir))
		if(L)
			L.on_update_icon()

/obj/wireweed/proc/try_to_assimilate()
	if(hive_mind_ai && master_node)
		for(var/obj/machinery/machine_on_my_tile in loc)
			var/can_assimilate = TRUE

			//whitelist check
			if(is_type_in_list(machine_on_my_tile, hive_mind_ai.restricted_machineries))
				can_assimilate = FALSE

			//assimilation is slow process, so it's take some time
			//there we use our failure chance. Then it lower, then faster hivemind learn how to properly assimilate it
			if(can_assimilate && prob(hive_mind_ai.failure_chance))
				can_assimilate = FALSE
				anim_shake(machine_on_my_tile)
				return

			 //only one machine per turf
			if(can_assimilate && !locate(/obj/machinery/hivemind_machine) in loc)
				assimilate(machine_on_my_tile)
			//other will be... merged
			else if(can_assimilate)
				qdel(machine_on_my_tile)

		//modular computers handling
		var/obj/item/modular_computer/mod_comp = locate() in loc
		if(mod_comp)
			assimilate(mod_comp)

		//dead bodies handling
		for(var/mob/living/dead_body in loc)
			if(dead_body.stat == DEAD)
				assimilate(dead_body)


/obj/wireweed/update_neighbors()
	..()
	update_connections()
	on_update_icon()

/obj/wireweed/Process()
	if(hive_mind_ai && master_node)
		try_to_assimilate()
		chem_handler()
	else
		//slow vanishing after node death
		health_current -= 10
		alpha = 255 * health_current/health_max
		get_current_health()
		if(health_current == 0)
			Destroy()

/obj/wireweed/on_update_icon()
	CutOverlays()
	var/image/I
	for(var/i = 1 to 4)
		I = image(src.icon, "wires[wires_connections[i]]", dir = SHIFTL(1, i-1))
		AddOverlays(I)
	//wallhug
	for(var/direction in GLOB.cardinal)
		var/turf/T = get_step(loc, direction)
		if((locate(/obj/structure/wall_frame) in T) || istype(T, /turf/simulated/wall))
			var/image/wall_hug_overlay = image(icon = src.icon, icon_state = "wall_hug", dir = direction)
			if (T.x < x)
				wall_hug_overlay.pixel_x -= 32
			else if (T.x > x)
				wall_hug_overlay.pixel_x += 32
			if (T.y < y)
				wall_hug_overlay.pixel_y -= 32
			else if (T.y > y)
				wall_hug_overlay.pixel_y += 32
			wall_hug_overlay.layer = ABOVE_WINDOW_LAYER
			AddOverlays(wall_hug_overlay)
		var/image/wall_hug_corner = (image(icon = src.icon, icon_state = "wall_corner", dir = direction))
		var/turf/Y = get_step(loc, NORTH)
		if((locate(/obj/structure/wall_frame) in T) && (locate(/obj/structure/wall_frame) in Y) || istype(T, /turf/simulated/wall) && istype(Y, /turf/simulated/wall))
			if(T == Y)
				CutOverlays(wall_hug_corner)
			if (T.x > x)
				wall_hug_corner.pixel_x += 32
				wall_hug_corner.pixel_y += 32
			else if (T.x < x)
				wall_hug_corner.pixel_x -= 32
				wall_hug_corner.pixel_y += 32
			wall_hug_corner.layer = ABOVE_WINDOW_LAYER
			AddOverlays(wall_hug_corner)

/obj/wireweed/proc/update_connections(propagate = 0)
	var/list/dirs = list()
	for(var/obj/wireweed/W in range(1, src) - src)
		if(propagate)
			W.update_connections()
			W.on_update_icon()
		dirs += get_dir(src, W)

	wires_connections = dirs_to_corner_states(dirs)


/obj/wireweed/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover, /mob/living/simple_animal/hostile/hivemind))
		return 1
	else if(istype(mover, /mob/living))
		if(prob(10))
			to_chat(mover, SPAN_WARNING("You get stuck in \the [src] for a moment."))
			return 0
	else if(istype(mover, /obj/item/projectile))
		return 1
	return 1


//What a pity that we haven't some kind proc as special library to use it somewhere
/obj/wireweed/proc/anim_shake(atom/thing)
	var/init_px = thing.pixel_x
	var/shake_dir = pick(-1, 1)
	animate(thing, transform=turn(matrix(), 8*shake_dir), pixel_x=init_px + 2*shake_dir, time=1)
	animate(transform=null, pixel_x=init_px, time=6, easing=ELASTIC_EASING)


//assimilation process
/obj/wireweed/proc/assimilate(atom/subject)
	if(istype(subject, /obj/machinery) || istype(subject, /obj/item/modular_computer))
		if(prob(hive_mind_ai.failure_chance))
			//critical failure! This machine would be a dummy, which means - without any ability
			//let's make an infested sprite
			var/obj/machinery/hivemind_machine/new_machine = new (loc)
			var/icon/infected_icon = new('mods/hivemind/icons/hivemind_machines.dmi', icon_state = "wires-[rand(1, 3)]")
			var/icon/new_icon = new(subject.icon, icon_state = subject.icon_state, dir = subject.dir)
			new_icon.Blend(infected_icon, ICON_OVERLAY)
			new_machine.icon = new_icon
			var/prefix = pick("strange", "interesting", "marvelous", "unusual")
			new_machine.name = "[prefix] [subject.name]"
		else
			//of course, here we have a very little chance to spawn him, our mini-boss
			if(prob(1))
				new /mob/living/simple_animal/hostile/hivemind/mechiver(loc)
				qdel(subject)
				return
			else
				var/picked_machine
				var/list/possible_machines = subtypesof(/obj/machinery/hivemind_machine)

				if(LAZYLEN(hive_mind_ai.hives) < MAX_NODES_AMOUNT)
					if(hive_mind_ai.evo_points < (LAZYLEN(hive_mind_ai.hives) * 100)) //one hive per 100 EP
						possible_machines -= /obj/machinery/hivemind_machine/node
					else
						//we make new nodes asap, cause it has higher priority to survive, so we force it here
						picked_machine = /obj/machinery/hivemind_machine/node

				//here we compare hivemind's EP with machine's required value
				for(var/machine_path in possible_machines)
					if(hive_mind_ai.evo_points <= hive_mind_ai.EP_price_list[machine_path])
						possible_machines.Remove(machine_path)

				if(!picked_machine)
					picked_machine = pick(possible_machines)
				var/obj/machinery/hivemind_machine/new_machine = new picked_machine(loc)
				new_machine.on_update_icon()

	if(istype(subject, /mob/living) && !istype(subject, /mob/living/simple_animal/hostile/hivemind))
		//human bodies
		if(istype(subject, /mob/living/carbon/human))
			var/mob/living/L = subject
			for(var/obj/item/W in L)
				L.drop_from_inventory(W)
			var/M = pick(/mob/living/simple_animal/hostile/hivemind/himan)
			new M(loc)
		//robot corpses
		else if(istype(subject, /mob/living/silicon))
			new /mob/living/simple_animal/hostile/hivemind/hiborg(loc)
		//other dead bodies
		else
			var/mob/living/simple_animal/hostile/hivemind/resurrected/transformed_mob =  new(loc)
			transformed_mob.take_appearance(subject)

	qdel(subject)


//////////////////////////////////////////////////////////////////
/////////////////////////>RESPONSE CODE<//////////////////////////
//////////////////////////////////////////////////////////////////

/obj/wireweed/use_weapon(obj/item/weapon/W, mob/user, list/click_params)
	. = ..()
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if(W.sharp && W.force >= 30)
		user.visible_message(SPAN_DANGER("[user] cuts down [src]."), SPAN_DANGER("You cut down [src]."))
		kill_health()
		return
	if(W.sharp && W.force >= 10)
		health_current -= rand(W.force/2, W.force)
		user.visible_message(SPAN_DANGER("[user] slices [src]."), SPAN_DANGER("You slice [src]."))
	else
		user.visible_message(SPAN_DANGER("[user] tries to slice [src] with [W], but seems to do nothing."),
							SPAN_DANGER("You try to slice [src], but it's useless!"))

	return ..()

/obj/wireweed/post_use_item(obj/item/tool, mob/user, interaction_handled, use_call, click_params)
	. = ..()
	if (interaction_handled && use_call == "weapon" && isWelder(tool))
		playsound(loc, 'sound/items/Welder.ogg', 100, TRUE)

//fire is effective, but there need some time to melt the covering
/obj/wireweed/fire_act()
	health_current -= rand(1, 4)
	get_current_health()


//emp is effective too
//it causes electricity failure, so our wireweeds just blowing up inside, what makes them fragile
/obj/wireweed/emp_act(severity)
	if(severity)
		kill_health()
	..()

//Some acid and there's no problem
/obj/wireweed/proc/chem_handler()
	for(var/obj/effect/smoke/chem/smoke in loc)
		for(var/lethal in killer_reagents)
			if(smoke.reagents.has_reagent(lethal))
				kill_health()
				return

// Master wireweed node. Because we don't wanna mess with machinery

/obj/wireweed/master
	var/growth_range = 12 // Maximal distance for new wireweed pieces from this core.
	var/blob_may_process = 1
	var/reported_low_damage = FALSE
	var/times_to_pulse = 1 // Because we not THAT dangerous as blob tiles

/obj/wireweed/master/Process()
	for(var/I in 1 to times_to_pulse)
		pulse(30, GLOB.alldirs)
	..()

#undef HIVE_FACTION
