/datum/uplink_item/item/tools/shackles
	name = "Shackle module"
	desc = "A module that can be used on IPC brain to take it under control. \
	All you need to do is write a law and install shackle on directly on IPC brain."
	item_cost = 15
	path = /obj/item/organ/internal/shackles


/obj/vehicle/bike/
	name = "space-bike"
	desc = "Space wheelies! Woo!"
	icon = 'icons/obj/medium_vehicles.dmi'
	icon_state = "hover_bike"
	dir = SOUTH
	layer = LYING_MOB_LAYER
	atom_flags = ATOM_FLAG_CAN_BE_PAINTED

	load_item_visible = 1
	buckle_pixel_shift = list(0, 0, 0)
	var/list/bike_buckle_pixel_shifts = null
	health = 100
	maxhealth = 100
	pixel_x = -17
	pixel_y = -20
	locked = 0
	fire_dam_coeff = 0.6
	brute_dam_coeff = 0.5
	var/protection_percent = 40 //0 is no protection, 100 is full protection (afforded to the pilot) from projectiles fired at this vehicle

	var/land_speed = 3 //if 0 it can't go on turf (increased to slow movement)
	var/space_speed = 2
	var/bike_icon = "hover_bike"

	var/datum/effect/effect/system/trail/trail
	var/obj/item/engine/engine = null
	var/engine_type = null
	var/processing_hover = 0
	// Whether the engine has been loosened by a wrench (required before prying with a crowbar)
	var/engine_loosened = 0
	// Fuel tank support (phoron fuel)
	var/obj/item/tank/fuel_tank = null
	var/fuel_bay_open = 0

/obj/vehicle/bike/New()
	..()
	if(engine_type)
		load_engine(new engine_type(src.loc))
	update_icon()

/obj/vehicle/bike/verb/toggle()
	set name = "Toggle Engine"
	set category = "Object"
	set src in view(0)

	if(usr.incapacitated()) return
	if(!engine)
		to_chat(usr, "<span class='warning'>\The [src] does not have an engine block installed...</span>")
		return

	if(!on)
		turn_on(usr)
	else
		turn_off()

/obj/vehicle/bike/verb/toggle_fuel_bay()
	set name = "Toggle Fuel Bay"
	set category = "Object"
	set src in view(0)

	if(usr.incapacitated()) return
	fuel_bay_open = !fuel_bay_open
	playsound(src, fuel_bay_open ? 'sound/effects/locker_open.ogg' : 'sound/effects/locker_close.ogg', 40, TRUE)
	usr.visible_message(fuel_bay_open ? "\The [usr] opens the fuel bay." : "\The [usr] closes the fuel bay.")


/obj/vehicle/bike/proc/load_engine(obj/item/engine/E, mob/user)
	if(engine)
		return
	if(user && !user.unEquip(E))
		return
	engine = E
	engine.forceMove(src)
	if(trail)
		qdel(trail)
	trail = engine.get_trail()
	if(trail)
		trail.set_up(src)

/obj/vehicle/bike/proc/unload_engine()
	if(!engine)
		return
	engine.dropInto(loc)
	if(trail)
		trail.stop()
		qdel(trail)
	trail = null
	engine = null

/obj/vehicle/bike/load(atom/movable/C)
	var/mob/living/M = C
	if(!istype(M)) return 0
	if(M.buckled || M.restrained() || !Adjacent(M) || !M.Adjacent(src))
		return 0
	return ..(M)


/obj/vehicle/bike/use_tool(obj/item/W as obj, mob/user as mob)

	if(open)
		// If the bike's fuel bay has been opened, allow inserting a tank
		if(fuel_bay_open && istype(W, /obj/item/tank))
			if(fuel_tank)
				to_chat(user, "<span class='warning'>There is already a fuel tank installed in \the [src].</span>")
				return 1

			if(!user.unEquip(W))
				return 1
			// Move tank into the bike and register it
			fuel_tank = W
			W.forceMove(src)
			user.visible_message("\The [user] inserts \the [W] into \the [src].")
			return 1
		// Engine installation/interaction
		if(istype(W, /obj/item/engine))
			if(engine)
				to_chat(user, "<span class='warning'>There is already an engine block in \the [src].</span>")
				return 1
			user.visible_message("<span class='warning'>\The [user] installs \the [W] into \the [src].</span>")
			load_engine(W)
			return 1
		else if(engine && engine.use_tool(W,user))
			return 1
		// Use a wrench to loosen the engine first; then use a crowbar to pry it out
		else if(isWrench(W) && engine)
			engine_loosened = 1
			// Loosened state times out after 10 seconds (use interruptible do_after)
			if(do_after(user, 10 SECONDS, src))
				user.visible_message("\The [user] loosens the engine on \the [src] with \the [W].")
				src.engine_loosened = 0
			return 1
		else if(isCrowbar(W) && engine)
			if(!engine_loosened)
				to_chat(user, "<span class='warning'>You need to loosen the engine with a wrench before prying it out.</span>")
				return 1
			to_chat(user, "You pry out \the [engine] from \the [src].")
			unload_engine()
			engine_loosened = 0
			return 1
		// Crowbar can also be used to remove an installed fuel tank
		else if(isCrowbar(W) && fuel_tank)
			var/obj/item/tank/T = fuel_tank
			fuel_tank = null
			if(T && !QDELETED(T))
				user.put_in_hands(T)
				to_chat(user, "You remove \the [T] from \the [src].")
			return 1
	return ..()

/obj/vehicle/bike/MouseDrop_T(atom/movable/C, mob/user as mob)
	if(!load(C))
		to_chat(user, "<span class='warning'> You were unable to load \the [C] onto \the [src].</span>")
		return

/obj/vehicle/bike/attack_hand(mob/user as mob)
	if(user == load)
		unload(load)
		to_chat(user, "You unbuckle yourself from \the [src]")

/obj/vehicle/bike/relaymove(mob/user, direction)
	if(user != load || !on)
		return
	if(user.incapacitated())
		unload(user)
		visible_message("<span class='warning'>\The [user] falls off \the [src]!</span>")
		return
	return Move(get_step(src, direction))

/obj/vehicle/bike/Move(turf/destination)
	if(world.time <= l_move_time + move_delay) return
	//these things like space, not turf. Dragging shouldn't weigh you down.
	if(!pulledby)
		if(istype(destination,/turf/space) || pulledby)
			if(!space_speed)
				return 0
			move_delay = space_speed
		else
			if(!land_speed)
				return 0
			move_delay = land_speed
		// Require engine power; engine handles consumption via `consume_fuel`
		if(!engine || !engine.consume_fuel(engine.cost_per_move))
			turn_off()
			return 0
	return ..()

/obj/vehicle/bike/turn_on(mob/user = null)
	if(!engine || on)
		return

	// Prevent starting if engine requires fuel but no tank or insufficient fuel is installed
	if(istype(engine, /obj/item/engine/thermal))
		var/needed = engine.cost_per_move
		if(!fuel_tank || !fuel_tank.air_contents || fuel_tank.air_contents.get_by_flag(XGM_GAS_FUEL) < needed)
			if(user)
				to_chat(user, "<span class='warning'>\The [src] won't start — no fuel tank installed or insufficient phoron.</span>")
			return

	engine.rev_engine(src)
	if(trail)
		trail.start()
	anchored = TRUE

	update_icon()

	if(pulledby)
		pulledby.stop_pulling()
	// Start levitation loop while engine is on
	start_hover_animation()

	..()

/obj/vehicle/bike/turn_off()
	if(!on)
		return
	if(engine)
		engine.putter(src)

	if(trail)
		trail.stop()

	anchored = FALSE

	update_icon()

	// Stop levitation animation and reset pixel_z
	// Immediate reset; the hover loop also resets on exit
	animate(src, pixel_z = initial(src.pixel_z), time = 0)
	if(buckled_mob)
		animate(buckled_mob, pixel_z = initial(buckled_mob.pixel_z), time = 0)

	..()

/obj/vehicle/bike/bullet_act(obj/item/projectile/Proj)
	if(buckled_mob && prob((100-protection_percent)))
		buckled_mob.bullet_act(Proj)
		return
	..()

/obj/vehicle/bike/on_update_icon()
	overlays.Cut()

	icon_state = "hover_bike"
	// If the bike has a color, draw the paint overlay layer (hover_bike_paint)
	if(!isnull(src.color))
		AddOverlays(overlay_image(icon, "[icon_state]_paint", src.color))
	overlays += image('icons/obj/medium_vehicles.dmi', "[icon_state]_cover", MECH_COCKPIT_LAYER)
	..()


/obj/vehicle/bike/Destroy()
	qdel(trail)
	qdel(engine)
	..()
/obj/vehicle/bike/set_dir(dir_new)
	if(!on)
		return

	// Normalize incoming direction to one of four cardinals (NORTH, EAST, SOUTH, WEST)
	if(dir_new == NORTH || dir_new == NORTHWEST || dir_new == NORTHEAST)
		dir_new = NORTH
	else if(dir_new == EAST)
		dir_new = EAST
	else if(dir_new == SOUTH || dir_new == SOUTHEAST || dir_new == SOUTHWEST)
		dir_new = SOUTH
	else if(dir_new == WEST)
		dir_new = WEST

	. = ..(dir_new)
	if(!bike_buckle_pixel_shifts)
		bike_buckle_pixel_shifts = list(list(0,5,0), list(10,0,0), list(0,-13,0), list(-12,0,0))

	var/list/shift
	if(dir_new == NORTH)
		shift = bike_buckle_pixel_shifts[1]
	else if(dir_new == EAST)
		shift = bike_buckle_pixel_shifts[2]
	else if(dir_new == SOUTH)
		shift = bike_buckle_pixel_shifts[3]
	else if(dir_new == WEST)
		shift = bike_buckle_pixel_shifts[4]

	// Apply selected shift so the buckled mob will be moved to match the sprite
	buckle_pixel_shift = shift

	if(buckled_mob)
		post_buckle_mob(buckled_mob)
	return


/obj/vehicle/bike/post_buckle_mob(mob/living/M)
	// Instant reposition of buckled mob to avoid smooth animation when bike rotates
	var/list/shift = buckle_pixel_shift ? buckle_pixel_shift : list(0,0,6)
	if (M == buckled_mob)
		M.pixel_x = M.default_pixel_x + shift[1]
		M.pixel_y = M.default_pixel_y + shift[2]
		M.pixel_z = M.default_pixel_z + shift[3]
	else
		M.pixel_x = M.default_pixel_x
		M.pixel_y = M.default_pixel_y
		M.pixel_z = M.default_pixel_z



/obj/vehicle/bike/proc/start_hover_animation()
	if(processing_hover) return
	processing_hover = 1
	spawn(0)
		while(src && src.on)
			// animate up
			animate(src, pixel_z = initial(src.pixel_z) + 3, time = 1.2 SECONDS, easing = SINE_EASING, flags = ANIMATION_RELATIVE | ANIMATION_END_NOW | ANIMATION_PARALLEL)
			if(buckled_mob)
				animate(buckled_mob, pixel_z = initial(buckled_mob.pixel_z) + 3, time = 1.2 SECONDS, easing = SINE_EASING, flags = ANIMATION_RELATIVE | ANIMATION_END_NOW | ANIMATION_PARALLEL)
			sleep(1.2 SECONDS)
			// animate down
			animate(src, pixel_z = initial(src.pixel_z) - 3, time = 1.2 SECONDS, easing = SINE_EASING, flags = ANIMATION_RELATIVE | ANIMATION_END_NOW | ANIMATION_PARALLEL)
			if(buckled_mob)
				animate(buckled_mob, pixel_z = initial(buckled_mob.pixel_z) - 3, time = 1.2 SECONDS, easing = SINE_EASING, flags = ANIMATION_RELATIVE | ANIMATION_END_NOW | ANIMATION_PARALLEL)
			sleep(1.2 SECONDS)
		if(src)
			animate(src, pixel_z = initial(src.pixel_z), time = 0)
			if(buckled_mob)
				animate(buckled_mob, pixel_z = initial(buckled_mob.pixel_z), time = 0)
		processing_hover = 0
		return


/obj/vehicle/bike/thermal
	engine_type = /obj/item/engine/thermal


/obj/item/engine
	name = "engine"
	desc = "An engine used to power a small vehicle."
	//icon = 'icons/obj/objects.dmi'
	w_class = ITEM_SIZE_HUGE
	var/stat = 0
	var/trail_type
	var/cost_per_move = 1

	// Default engine-level fuel consumption hook. Returns 1 on success, 0 on failure.
/obj/item/engine/proc/consume_fuel(amount)
		if(!amount) amount = cost_per_move
		return 0

/obj/item/engine/proc/get_trail()
	if(trail_type)
		return new trail_type
	return null


/obj/item/engine/proc/use_power()
	// Backwards-compatible: delegate to consume_fuel
	return src.consume_fuel(cost_per_move)

/obj/item/engine/proc/rev_engine(atom/movable/M)
	return

/obj/item/engine/proc/putter(atom/movable/M)
	return

/obj/item/engine/thermal
	name = "thermal engine"
	desc = "A fuel-powered engine used to power a small vehicle."
	icon_state = "engine_fuel"
	trail_type = /datum/effect/effect/system/trail/thermal
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	// Reduced consumption: smaller fraction of a mole per move
	cost_per_move = 0.02 // moles of phoron consumed per move

	// Thermal engine consumes fuel from the host vehicle's installed fuel_tank
/obj/item/engine/thermal/consume_fuel(amount)
	if(!amount) amount = cost_per_move
	if(!istype(src.loc, /obj/vehicle/bike))
		return 0
	var/obj/vehicle/bike/B = src.loc
	if(!B.fuel_tank || !B.fuel_tank.air_contents)
		return 0
	var/fuel_available = B.fuel_tank.air_contents.get_by_flag(XGM_GAS_FUEL)
	if(fuel_available && fuel_available >= amount)
		B.fuel_tank.remove_air_by_flag(XGM_GAS_FUEL, amount)
		B.update_icon()
		return 1
	return 0


/obj/item/engine/thermal/rev_engine(atom/movable/M)
	M.audible_message("\The [M] rumbles to life.")

/obj/item/engine/electric/putter(atom/movable/M)
	M.audible_message("\The [M] putters before turning off.")


/////////////////////////////////////////////
//////// Attach an Ion trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////
/datum/effect/effect/system/trail
	var/turf/oldposition
	var/processing = 1
	var/on = 1
	var/max_number = 0
	number = 0
	var/list/specific_turfs = list()
	var/trail_type
	var/duration_of_effect = 10

/datum/effect/effect/system/trail/set_up(atom/atom)
	attach(atom)
	oldposition = get_turf(atom)


/datum/effect/effect/system/trail/start()
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		spawn(0)
			var/turf/T = get_turf(src.holder)
			if(T != src.oldposition)
				if(is_type_in_list(T, specific_turfs) && (!max_number || number < max_number))
					var/obj/effect/effect/trail = new trail_type(oldposition)
					src.oldposition = T
					effect(trail)
					number++
					spawn( duration_of_effect )
						number--
						qdel(trail)
				spawn(2)
					if(src.on)
						src.processing = 1
						src.start()
			else
				spawn(2)
					if(src.on)
						src.processing = 1
						src.start()

/datum/effect/effect/system/trail/proc/stop()
	src.processing = 0
	src.on = 0

/datum/effect/effect/system/trail/proc/effect(obj/effect/effect/T)
	T.set_dir(src.holder.dir)
	return

/obj/effect/effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = TRUE

/datum/effect/effect/system/trail/ion
	trail_type = /obj/effect/effect/ion_trails
	specific_turfs = list(/turf/space)
	duration_of_effect = 20

/datum/effect/effect/system/trail/ion/effect(obj/effect/effect/T)
	..()
	flick("ion_fade", T)
	T.icon_state = "blank"

/obj/effect/effect/thermal_trail
	name = "therman trail"
	icon_state = "explosion_particle"
	anchored = TRUE

/datum/effect/effect/system/trail/thermal
	trail_type = /obj/effect/effect/thermal_trail
	specific_turfs = list(/turf/space)
