//Wireweeds are created by the AI's nanites to spread its connectivity through the ship.
//When they reach any machine, they annihilate them and re-purpose them to the AI's needs. They are the 'hands' of our rogue AI.

/obj/vine/hivemind
	layer = 2
	health_max = 80 //we are a little bit durable
	var/list/killer_reagents = list("pacid", "sacid", "hclacid", "thermite")
	//internals
	var/obj/machinery/hivemind_machine/node/master_node
	var/list/wires_connections = list("0", "0", "0", "0")


/obj/vine/hivemind/New()
	..()
	icon = 'mods/hivemind/icons/hivemind_obj.dmi'
	spawn(2)
		update_neighbors()


/obj/vine/hivemind/Destroy()
	if(master_node)
		master_node.my_wireweeds.Remove(src)
	return ..()


/obj/vine/hivemind/after_spread(obj/vine/child, turf/target_turf)
	if(master_node)
		master_node.add_wireweed(child)
	spawn(1)
		child.dir = get_dir(loc, target_turf) //actually this means nothing for wires, but need for animation
		flick("spread_anim", child)
		child.forceMove(target_turf)
		update_icon()

// Насильно обновляем соседей - LordNest
/obj/vine/proc/update_neighbors(location = loc)
	for (var/dir in GLOB.cardinal)
		var/obj/vine/hivemind/L = locate(/obj/vine/hivemind/, get_step(location, dir))
		if(L)
			L.update_icon()

/obj/vine/hivemind/proc/try_to_assimilate()
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


/obj/vine/hivemind/update_neighbors()
	..()
	update_connections()
	update_icon()


/obj/vine/hivemind/spread()
	if(hive_mind_ai && master_node)
		..()


/obj/vine/hivemind/life()
	if(hive_mind_ai && master_node)
		try_to_assimilate()
		chem_handler()
	else
		//slow vanishing after node death
		health_current -= 10
		alpha = 255 * health_current/health_max
		update_health()


/obj/vine/hivemind/is_mature()
	return TRUE


/obj/vine/hivemind/update_icon()
	overlays.Cut()
	var/image/I
	for(var/i = 1 to 4)
		I = image(src.icon, "wires[wires_connections[i]]", dir = 1<<(i-1))
		overlays += I
	for(var/d in GLOB.cardinal)
		var/turf/T = get_step(loc, d)
		if((locate(/obj/structure/window) in T) || istype(T, /turf/simulated/wall))
			var/image/wall_hug_overlay = image(icon = src.icon, icon_state = "wall_hug", dir = d)
			if (T.x < x)
				wall_hug_overlay.pixel_x -= 32
			else if (T.x > x)
				wall_hug_overlay.pixel_x += 32
			if (T.y < y)
				wall_hug_overlay.pixel_y -= 32
			else if (T.y > y)
				wall_hug_overlay.pixel_y += 32
			wall_hug_overlay.layer = ABOVE_WINDOW_LAYER
			overlays += wall_hug_overlay


/obj/vine/hivemind/proc/update_connections(propagate = 0)
	var/list/dirs = list()
	for(var/obj/vine/hivemind/W in range(1, src) - src)
		if(propagate)
			W.update_connections()
			W.update_icon()
		dirs += get_dir(src, W)

	wires_connections = dirs_to_corner_states(dirs)


/obj/vine/hivemind/door_interaction(obj/machinery/door/airlock/door)
	if(!door || !istype(door))
		return FALSE

	//if our door isn't broken, we will try to break open. We can do only one action per call
	if(!(door.stat & MACHINE_BROKEN_GENERIC))
		anim_shake(door)
		//first, we open our panel to give our wireweeds access to exposed airlock's electronics
		if(!door.p_open)
			if(prob(20))
				door.p_open = TRUE
			return FALSE
		//but if airlock is welded, we just shake it like we rummage inside
		if(door.welded)
			return FALSE
		//if panel opened, we begin to destruct it from inside of airlock
		if(door.p_open)
			//bolts are down? Our wireweeds infest electronics, so this isn't a problem cause it part of us
			if(door.locked)
				if(prob(50))
					door.unlock()
				return FALSE
			//and then, if airlock is closed, we begin destroy it electronics
			if(door.density)
				door.damage_health(rand(15, 50))
				return FALSE

	return TRUE


/obj/vine/hivemind/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(mover == src)
		if(target.density)
			return FALSE

		if(locate(/obj/structure) in target)
			for(var/obj/structure/S in target)
				if(S.density)
					return FALSE

		if(locate(/obj/machinery/door) in target)
			return FALSE

		return TRUE
	else
		return ..()



//What a pity that we haven't some kind proc as special library to use it somewhere
/obj/vine/hivemind/proc/anim_shake(atom/thing)
	var/init_px = thing.pixel_x
	var/shake_dir = pick(-1, 1)
	animate(thing, transform=turn(matrix(), 8*shake_dir), pixel_x=init_px + 2*shake_dir, time=1)
	animate(transform=null, pixel_x=init_px, time=6, easing=ELASTIC_EASING)


//assimilation process
/obj/vine/hivemind/proc/assimilate(var/atom/subject)
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

				if(hive_mind_ai.hives.len < 10)
					if(hive_mind_ai.evo_points < (hive_mind_ai.hives.len * 100)) //one hive per 100 EP
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
				new_machine.update_icon()

	if(istype(subject, /mob/living) && !istype(subject, /mob/living/simple_animal/hostile/hivemind))
		//human bodies
		if(istype(subject, /mob/living/carbon/human))
			var/mob/living/L = subject
			for(var/obj/item/W in L)
				L.drop_from_inventory(W)
			var/M = pick(/mob/living/simple_animal/hostile/hivemind/himan, /mob/living/simple_animal/hostile/hivemind/phaser)
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


//in fact, this is some kind of reinforced wires, so we can't take samples from it and inject something too
//but we still can slice it with something sharp

/*
/obj/vine/hivemind/use_weapon(obj/item/weapon/W, mob/user, list/click_params)
	. = ..()
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	var/weapon_type
	if (W.has_edge(weapon))
		weapon_type = QUALITY_CUTTING
	else if (W.has_quality(QUALITY_WELDING))
		weapon_type = QUALITY_WELDING

	if(weapon_type)
		if(W.use_tool(user, src, WORKTIME_FAST, weapon_type, FAILCHANCE_EASY, required_stat = STAT_ROB))
			user.visible_message(SPAN_DANGER("[user] cuts down [src]."), SPAN_DANGER("You cut down [src]."))
			kill_health()
			return
		return
	else
		if(W.sharp && W.force >= 10)
			health_current -= rand(W.force/2, W.force) //hm, maybe make damage based on player's robust stat?
			user.visible_message(SPAN_DANGER("[user] slices [src]."), SPAN_DANGER("You slice [src]."))
		else
			user.visible_message(SPAN_DANGER("[user] tries to slice [src] with [W], but seems to do nothing."),
								SPAN_DANGER("You try to slice [src], but it's useless!"))
	update_health()
*/

/obj/vine/hivemind/use_weapon(obj/item/weapon/W, mob/user, list/click_params)
	. = ..()
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if(W.sharp && W.force >= 30)
		user.visible_message(SPAN_DANGER("[user] cuts down [src]."), SPAN_DANGER("You cut down [src]."))
		kill_health()
		return
	if(W.sharp && W.force >= 10)
		health_current -= rand(W.force/2, W.force) //hm, maybe make damage based on player's robust stat?
		user.visible_message(SPAN_DANGER("[user] slices [src]."), SPAN_DANGER("You slice [src]."))
	else
		user.visible_message(SPAN_DANGER("[user] tries to slice [src] with [W], but seems to do nothing."),
							SPAN_DANGER("You try to slice [src], but it's useless!"))

	return ..()

//fire is effective, but there need some time to melt the covering
/obj/vine/hivemind/fire_act()
	health_current -= rand(1, 4)
	update_health()


//emp is effective too
//it causes electricity failure, so our wireweeds just blowing up inside, what makes them fragile
/obj/vine/hivemind/emp_act(severity)
	if(severity)
		kill_health()


//Some acid and there's no problem
/obj/vine/hivemind/proc/chem_handler()
	for(var/obj/effect/smoke/chem/smoke in loc)
		for(var/lethal in killer_reagents)
			if(smoke.reagents.has_reagent(lethal))
				kill_health()
				return
