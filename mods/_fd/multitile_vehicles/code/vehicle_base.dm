#define BASE_VEHICLE_DEATH_EXPLODE_DAMAGE 35

/obj/vehicles
	name = "Vehicle"
	desc = "Vehicle"
	density = 1
	layer = ABOVE_HUMAN_LAYER

	var/active = 0
	var/guns_disabled = 0
	var/movement_destroyed = 0
	var/block_enter_exit //Set this to block entering/exiting.
	var/can_traverse_zs = 0

	var/next_move_input_at = 0 //When can we send our next movement input?
	var/moving_x = 0
	var/moving_y = 0
	var/last_moved_axis = 0 //1 = X axis, 2 = Y axis.
	var/list/speed = list(0,0) //The delay on movement in these directions.
	var/drag = 2 //How much do we slow down per tick if no input is applied in a direction?
	var/min_speed = 5 //What's the highest delay we can have?
	var/max_speed = 1 //What's the lowest number we can go to in terms of delay?
	var/acceleration = 1 //By how much does our speed change per input?
	var/braking_mode = 0 //1 = brakes active, -1 = purposefully reducing drag to slide.
	var/can_space_move = 0

	//Action Button Handling
	var/list/driver_actions = list()

	//Advanced Damage Handling
	var/datum/component_profile/comp_prof = /datum/component_profile

	var/list/sprite_offsets = list("1" = list(0,0),"2" = list(0,0),"4" = list(0,0),"8" = list(0,0)) //Handled Directionally. Numbers correspond to directions

	//Passenger Management
	var/list/occupants = list(1,1) //Contains all occupants of the vehicle including the driver. First 2 values defines max passengers /gunners. Format: [MobRef] = [PositionName]
	var/list/passengers = list()
	var/list/exposed_positions = list(VP_DRIVER = 0.0) //Assoc. Value is the chance of hitting this position

	//Cargo
	var/used_cargo_space = 0
	var/cargo_capacity = 0
	var/capacity_flag = ITEM_SIZE_SMALL
	var/list/cargo_contents = list()

	//Vehicle ferrying//
	var/vehicle_size = ITEM_SIZE_VEHICLE//The size of the vehicle, used by vehicle cargo ferrying to determine allowed amount and allowed size.
	var/vehicle_carry_size = 0			//the max size of a carried vehicle
	var/obj/vehicles/carried_vehicle

	var/vehicle_view_modifier = 1 //The view-size modifier to apply to the occupants of the vehicle.
	var/move_sound = null
	var/collision_sound = 'sound/effects/meteorimpact.ogg'

	var/datum/gas_mixture/internal_air = null//If this is new()'d, the vehicle provides air to the occupants.
	//I would make it require refilling, but that's likely to just be boring tedium for players.

	var/has_headlights = TRUE
	var/headlights_state = 1

	var/light_brightness = 0.7
	var/light_inrange = 3
	var/light_outrange = 6
	var/colored = "#f1f0cf"

	var/serial_number
	var/obj/item/key/car/inserted_key
	var/key_type = /obj/item/key/car

/obj/vehicles/verb/toggle_headlights()
	set name = "Toggle Headlights"
	set category = "Vehicle"
	set src in view(1)
	var/mob/living/user = usr
	if(!istype(user) || !(user in get_occupants_in_position(VP_DRIVER)))
		to_chat(user,"<span class = 'notice'>You must be the driver of [src] to toggle the headlights.</span>")
		return

	if(headlights_state == 2)
		to_chat(user,"<span class = 'notice'>You toggle [src]'s headlights on.</span>")
		set_light(light_brightness, light_inrange, light_outrange, l_color = colored)
		headlights_state = 1
	else
		to_chat(user,"<span class = 'notice'>You toggle [src]'s headlights off.</span>")
		headlights_state = 2
		set_light(0,0,0,l_color = "#ffffff")
		update_light()

/obj/vehicles/New()
	. = ..()
	comp_prof = new comp_prof(src)
	START_PROCESSING(SSobj, src)
	if(has_headlights)
		verbs += /obj/vehicles/verb/toggle_headlights
		headlights_state = 2
	cargo_capacity = BASE_STORAGE_CAPACITY(capacity_flag)
	init_vehicle_actions()

/obj/vehicles/Initialize()
	. = ..()
	if(internal_air)
		internal_air.volume = 2500
		internal_air.temperature = T20C
	if(!inserted_key)
		inserted_key = new key_type(src)
		inserted_key.key_data = serial_number

/obj/vehicles/lost_in_space()
	if(!can_space_move)
		return TRUE
	return FALSE

/obj/vehicles/return_air_for_internal_lifeform(mob/living/carbon/human/form)
	if(!internal_air || !istype(form))
		return loc.return_air()
	internal_air.gas[form.species.breath_type] = 0
	for(var/gas in internal_air.gas)
		internal_air.gas[gas] = 100/internal_air.gas.len
	return internal_air

/obj/vehicles/return_air()
	if(internal_air)
		return internal_air
	return loc.return_air()

/obj/vehicles/attack_generic( mob/living/simple_animal/attacker, damage, text)
	visible_message("<span class = 'danger'>[attacker] [text] [src]</span>")
	var/pos_to_dam = should_damage_occ()
	if(!isnull(pos_to_dam))
		var/list/occ_list = get_occupants_in_position(pos_to_dam)
		if(isnull(occ_list) || !occ_list.len)
			return 1
		var/mob/mob_to_hit = pick(occ_list)
		if(isnull(mob_to_hit))
			return 1
		attacker.UnarmedAttack(mob_to_hit)
	comp_prof.take_component_damage(damage,"brute")

/obj/vehicles/proc/get_display_filled_amt(amt, amt_initial)
	. = "is empty!"
	if(amt == amt_initial)
		. = "is full!"
	else if(amt >= amt_initial * 0.75)
		. = "is about 3 quarters full."
	else if(amt > amt_initial * 0.5)
		. = "is about half full."
	else if(amt > amt_initial * 0.25)
		. = "is about a quarter full."

/obj/vehicles/examine(mob/user)
	. = ..()
	if(!active)
		to_chat(user,"[src]'s engine is inactive.")
	if(active)
		to_chat(user,"[src]'s engine is up and ready.")
	if(movement_destroyed)
		to_chat(user,"[src]'s movement is damaged beyond use.")
	if(cargo_capacity)
		if(!src.Adjacent(user))
			if(used_cargo_space > 0)
				to_chat(user,"<span>It looks like there is something in the cargo hold.</span>")
		else
			to_chat(user,"<span>It's cargo hold contains [used_cargo_space] of [cargo_capacity] units of cargo ([round(100*used_cargo_space/cargo_capacity)]% full).</span>")
	if(carried_vehicle)
		to_chat(user,"<span>It has a [carried_vehicle] mounted on it.</span>")

	show_occupants_contained(user)

/obj/vehicles/proc/pick_valid_exit_loc()
	var/list/valid_exit_locs = list()
	var/list/valid_exit_locs_fallback = list()

	//check for atmos safe turfs
	for(var/turf/t in locs)
		for(var/turf/t_2 in range(1,t))
			if(!(t_2 in locs) && !istype(t_2,/turf/simulated/open) && t_2.density == 0)
				if(locate(/obj/shield) in t_2.contents) //No putting people inside shields.
					continue
				if(locate(/obj/structure/wall_frame) in t_2.contents)
					continue
				if(locate(/obj/structure/grille) in t_2.contents)
					continue
				if(locate(/obj/structure/girder) in t_2.contents)
					continue
				if(locate(/obj/structure/window) in t_2.contents) //Just no windows.
					valid_exit_locs_fallback += t_2
					continue
				if(!IsTurfAtmosUnsafe(t_2))
					valid_exit_locs |= t_2
				else
					valid_exit_locs_fallback += t_2

	//try again for anny turfs
	if(valid_exit_locs.len == 0)
		valid_exit_locs = valid_exit_locs_fallback

	if(valid_exit_locs.len == 0)
		return null

	return pick(valid_exit_locs)
//
/obj/vehicles/Destroy()
	STOP_PROCESSING(SSobj, src)
	kick_occupants()
	. = ..()

/obj/vehicles/on_death()
	movement_destroyed = 1
	guns_disabled = 1
	icon_state = "[initial(icon_state)]_destroyed"
	fall()

	//get a viable list of places to eject our cargo
	density = 0
	var/list/turfs_base = list()
	for(var/turf/T in src.locs)
		if(not_turf_contains_dense_objects(T))
			turfs_base.Add(T)
	if(!turfs_base.len)
		turfs_base = src.locs.Copy()
	var/list/free_turfs = turfs_base.Copy()

	//reset the vehicle density
	density = 1

	while(cargo_contents.len)

		//remove it from the list
		var/atom/movable/A = cargo_contents[1]
		cargo_contents -= A

		//get a random turf
		var/turf/T = pick(free_turfs)

		//dont double up turfs
		free_turfs -= T
		if(!free_turfs.len)
			free_turfs = turfs_base.Copy()

		//eject it
		eject_cargo_item(A, T)
	for(var/mob/living/l in occupants)
		var/dam_max = BASE_VEHICLE_DEATH_EXPLODE_DAMAGE * ((bound_height / 32) + (bound_width / 32))/2
		l.adjustBruteLoss(dam_max/2)
		dam_max /= 2
		while(dam_max > 0)
			var/dam_deal = rand(dam_max/3,dam_max)
			dam_max -= dam_deal
			l.adjustBruteLoss(dam_deal)
	kick_occupants()
	explosion(loc, 20, 10)

/obj/vehicles/proc/inactive_pilot_effects() //Overriden on a vehicle-by-vehicle basis.

/obj/vehicles/Process()
	if(world.time % 3)
		if(active)
			var/list/drivers = get_occupants_in_position("driver")
			if(!drivers.len || isnull(drivers) || movement_destroyed)
				inactive_pilot_effects()

/obj/vehicles/verb/verb_toggle_brakes()
	set name = "Toggle Brakes"
	set category = "Vehicle"
	set src in view(1)

	var/mob/living/user = usr
	if(!istype(user))
		return

	var/list/driver_list = get_occupants_in_position("driver")
	var/is_driver = FALSE
	for(var/mob/driver in driver_list)
		if(user == driver)
			is_driver = TRUE
			break
	if(!is_driver)
		to_chat(user,"<span class = 'notice'>You need to be the driver to do that.</span>")
		return

	toggle_brakes(user)

/obj/vehicles/proc/toggle_brakes(mob/toggler)
	var/message = ""
	switch(braking_mode)
		if(0)
			braking_mode = 1
			drag *= 3
			message = "Braking system enabled."
		if(1)
			braking_mode = 0
			drag = initial(drag)
			message = "Braking system disabled."
		if(-1)
			message = "Enable brake safeties first."

	if(toggler)
		to_chat(toggler,"<span class = 'notice'>[message]</span>")

/obj/vehicles/verb/verb_toggle_brake_safeties()
	set name = "Toggle Brake Safeties"
	set category = "Vehicle"
	set src in view(1)

	var/mob/living/user = usr
	if(!istype(user))
		return

	var/list/driver_list = get_occupants_in_position("driver")
	var/is_driver = FALSE
	for(var/mob/driver in driver_list)
		if(user == driver)
			is_driver = TRUE
			break
	if(!is_driver)
		to_chat(user,"<span class = 'notice'>You need to be the driver to do that.</span>")
		return

	toggle_brake_safeties(user)

/obj/vehicles/proc/toggle_brake_safeties(mob/toggler)
	var/message = ""
	switch(braking_mode)
		if(0)
			braking_mode = -1
			drag /= 2
			message = "Braking system safeties disabled."
		if(-1)
			braking_mode = 0
			drag = initial(drag)
			message = "Braking system safeties enabled."
		if(1)
			message = "Disable the brakes first."

	if(toggler)
		to_chat(toggler,"<span class = 'notice'>[message]</span>")

/obj/vehicles/Move(turf/newloc, newdir)
	if(abs(speed[1]) > abs(speed[2]))
		if(speed[1] > 0)
			newdir = EAST
		else
			newdir = WEST
	else
		if(speed[2] > 0)
			newdir = NORTH
		else
			newdir = SOUTH
	if(anchored)
		anchored = 0
		. = ..()
		anchored = 1
	else
		. = ..()

/obj/vehicles/can_fall()
	if(can_traverse_zs && !movement_destroyed && active)
		return 0
	. = ..()

/obj/vehicles/proc/collide_with_obstacle(atom/obstacle)
	if(istype(obstacle,/mob/living))
		var/mob/living/hit_mob = obstacle
		playsound(loc,collision_sound,100,0,4)
		hit_mob.Weaken(2) //No damage for now, let's just knock them over.
	else
		next_move_input_at = world.time + min_speed
		if(last_move == EAST || last_move == WEST)
			moving_x = 0
			speed[1] = 0
		else if(last_move == NORTH || last_move == SOUTH)
			speed[2] = 0
			moving_y = 0
		last_moved_axis = 0
	visible_message("<span class = 'notice'>[src] collides wth [obstacle]</span>")
	if(istype(obstacle,/obj/structure/wall_frame))
		comp_prof.take_component_damage(5)
		qdel(obstacle)
	if(istype(obstacle,/obj/structure/grille))
		comp_prof.take_component_damage(5)
		qdel(obstacle)
	if(istype(obstacle,/obj/structure/girder))
		comp_prof.take_component_damage(5)
		qdel(obstacle)
	if(istype(obstacle,/obj/structure/window))
		comp_prof.take_component_damage(5)
		qdel(obstacle)

/obj/vehicles/Bump(atom/obstacle)
	..()
	. = collide_with_obstacle(obstacle)

/obj/vehicles/proc/drag_slowdown(index, slowdown_amount = drag)
	if(speed[index] > 0)
		speed[index] = max(speed[index] - drag,0)
	else
		speed[index] = min(speed[index] + drag,0)

/obj/vehicles/proc/movement_loop(speed_index_target = 1)
	var/noprocstart = 0
	if(moving_x || moving_y)
		noprocstart = 1
	switch(speed_index_target)
		if(1)
			moving_x = 1
		if(2)
			moving_y = 1
	if(noprocstart)
		return
	spawn()
		while (moving_x || moving_y)
			sleep(max(min_speed - (abs(speed[1]) + abs(speed[2]) ),max_speed))
			if(speed[1] == 0)
				moving_x = 0
			else
				if(speed[1] > 0)
					last_move = EAST
					. = Move(get_step(loc,EAST),EAST)
				else
					last_move = WEST
					. = Move(get_step(loc,WEST),WEST)

			if(speed[2] == 0)
				moving_y = 0
			else
				if(speed[2] > 0)
					last_move = NORTH
					. = Move(get_step(loc,NORTH),NORTH)
				else
					last_move = SOUTH
					. = Move(get_step(loc,SOUTH),SOUTH)
			var/list/index_list = list(1,2)
			for(var/index in index_list)
				if(last_moved_axis == index)
					continue
				drag_slowdown(index)
			if(world.time >= next_move_input_at)
				last_moved_axis = 0
			if(move_sound && world.time % 2 == 0)
				playsound(loc,move_sound,75,0,4)

/obj/vehicles/bullet_act(obj/item/projectile/P, def_zone)
	var/pos_to_dam = should_damage_occ()
	var/mob/mob_to_dam
	if(movement_destroyed)
		var/list/mobs = list()
		for(var/mob/m in occupants)
			mobs += m
		if(mobs.len == 0)
			return
		mob_to_dam = pick(mobs)
		if(!isnull(mob_to_dam))
			mob_to_dam.bullet_act(P)
			return
	if(!isnull(pos_to_dam))
		var/should_continue = damage_occupant(pos_to_dam,P)
		if(!should_continue)
			return
	comp_prof.take_component_damage(P.get_structure_damage())
	visible_message("<span class = 'danger'>[P] hits [src]!</span>")

/obj/vehicles/ex_act(severity)
	comp_prof.take_comp_explosion_dam(severity)
	for(var/position in exposed_positions)
		for(var/mob/living/m in get_occupants_in_position(position))
			m.apply_damage(250/severity, DAMAGE_BRUTE)

/obj/vehicles/relaymove(mob/user, direction)
	if(world.time < next_move_input_at)
		return 0
	if(isspace(loc) && !can_space_move)
		to_chat(user,"<span class = 'notice'>[src] cannot move in space!</span>")
		return
	if(movement_destroyed)
		to_chat(user,"<span class = 'notice'>[src] is in no state to move!</span>")
		return 0
	if(!active)
		to_chat(user,"<span class = 'notice'>[src] needs to be active to move!</span>")
		return 0
	next_move_input_at = world.time + max(max_speed,min_speed - (abs(speed[1]) + abs(speed[2])))

	if(!user.skill_check(SKILL_MECH, SKILL_BASIC))
		to_chat(user, SPAN_NOTICE("You can't understand how to control [src]!"))
		return
	if(occupants[user] != VP_DRIVER)
		return -1

	if(!(direction in list(NORTH,SOUTH,EAST,WEST)))
		var/dirturn = 45
		if(prob(50))
			dirturn = -45
		direction = turn(direction,dirturn)
	switch(direction)
		if(NORTH)
			last_moved_axis = 2
			speed[2] = min(speed[2] + acceleration,min_speed)

		if(SOUTH)
			last_moved_axis = 2
			speed[2] = max(speed[2] - acceleration,-min_speed)

		if(EAST)
			last_moved_axis = 1
			speed[1] = min(speed[1] + acceleration,min_speed)

		if(WEST)
			last_moved_axis = 1
			speed[1] = max(speed[1] - acceleration,-min_speed)
	if(last_moved_axis == 1)
		drag_slowdown(2,acceleration)
	else
		drag_slowdown(1,acceleration)
	if(braking_mode == 1) //If we're braking, we don't get the leeway in movement.
		last_moved_axis = 0

	if(speed[1] != 0 && !moving_x)
		movement_loop(1)
	else if(speed[2] != 0 && !moving_y)
		movement_loop(2)
	return 1

/obj/vehicles/forceMove(atom/destination)
	. = ..()

/obj/vehicles/verb/verb_inspect_components()
	set name = "Inspect Components"
	set category = "Vehicle"
	set src in view(1)

	var/mob/living/user = usr
	if(!istype(user))
		return

	comp_prof.inspect_components(user)

/obj/vehicles/attack_hand(mob/user)
	if(user.a_intent != "harm")
		if(user in occupants)
			usr = user
			switch_seats()
			return

		for(var/pos in get_all_positions())
			if(enter_as_position(user, pos))
				return
		to_chat(user, "There is no space left in \The [src]")
	else
		. = ..()

/obj/vehicles/use_tool(obj/item/I, mob/user)
/*	if(elevation > user.elevation || elevation > I.elevation)
		to_chat(user,"<span class = 'notice'>[name] is too far away to interact with!</span>")
		return*/
	if(!istype(I))
		return
	if(istype(I,/obj/item/grab))
		handle_grab_attack(I,user)
		return
	if(istype(I, /obj/item/key/car))
		return attack_key(I, user)
	if(user.a_intent == I_HURT)
		if(comp_prof.is_repair_tool(I))
			comp_prof.repair_inspected_with_tool(I,user)
			return
		if(istype(I,/obj/item/stack))
			comp_prof.repair_inspected_with_sheet(I,user)
			return
		. = ..()
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		var/pos_to_dam = should_damage_occ()
		if(!isnull(pos_to_dam))
			damage_occupant(pos_to_dam,I,user)
			return
		comp_prof.take_component_damage(I.force,I.damtype)
		return
	put_cargo_item(user,I)

/obj/vehicles/proc/get_overall_resistance(resistance_type)
	return comp_prof.get_overall_resistance(resistance_type)

#undef BASE_VEHICLE_DEATH_EXPLODE_DAMAGE
