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
	icon_state = "bike"
	dir = SOUTH
	layer = LYING_MOB_LAYER

	load_item_visible = 1
	buckle_pixel_shift = list(0, 0, 6)
	health = 100
	maxhealth = 100
	pixel_x = -16
	pixel_y = -2
	locked = 0
	fire_dam_coeff = 0.6
	brute_dam_coeff = 0.5
	var/protection_percent = 40 //0 is no protection, 100 is full protection (afforded to the pilot) from projectiles fired at this vehicle

	var/land_speed = 1 //if 0 it can't go on turf
	var/space_speed = 2
	var/bike_icon = "bike"

	var/datum/effect/effect/system/trail/trail
	var/kickstand = 1
	var/obj/item/engine/engine = null
	var/engine_type
	var/prefilled = 0

/obj/vehicle/bike/New()
	..()
	if(engine_type)
		load_engine(new engine_type(src.loc))
		if(prefilled)
			engine.prefill()
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
		turn_on()
	else
		turn_off()

/obj/vehicle/bike/verb/kickstand()
	set name = "Toggle Kickstand"
	set category = "Object"
	set src in view(0)

	if(usr.incapacitated()) return

	if(kickstand)
		usr.visible_message("\The [usr] puts up \the [src]'s kickstand.")
	else
		if(istype(src.loc,/turf/space))
			to_chat(usr, "<span class='warning'> You don't think kickstands work in space...</span>")
			return
		usr.visible_message("\The [usr] puts down \the [src]'s kickstand.")
		if(pulledby)
			pulledby.stop_pulling()

	kickstand = !kickstand
	anchored = (kickstand || on)

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

/obj/vehicle/bike/load(atom/movable/C)
	var/mob/living/M = C
	if(!istype(M)) return 0
	if(M.buckled || M.restrained() || !Adjacent(M) || !M.Adjacent(src))
		return 0
	return ..(M)

/obj/vehicle/bike/emp_act(severity)
	if(engine)
		engine.emp_act(severity)
	..()

/obj/vehicle/bike/insert_cell(obj/item/cell/C, mob/living/carbon/human/H)
	return

/obj/vehicle/bike/use_tool(obj/item/W as obj, mob/user as mob)
	if(open)
		if(istype(W, /obj/item/engine))
			if(engine)
				to_chat(user, "<span class='warning'>There is already an engine block in \the [src].</span>")
				return 1
			user.visible_message("<span class='warning'>\The [user] installs \the [W] into \the [src].</span>")
			load_engine(W)
			return
		else if(engine && engine.use_tool(W,user))
			return 1
		else if(isCrowbar(W) && engine)
			to_chat(user, "You pop out \the [engine] from \the [src].")
			unload_engine()
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
	if(kickstand || (world.time <= l_move_time + move_delay)) return
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
		if(!engine || !engine.use_power())
			turn_off()
			return 0
	return ..()

/obj/vehicle/bike/turn_on()
	if(!engine || on)
		return

	engine.rev_engine(src)
	if(trail)
		trail.start()
	anchored = TRUE

	update_icon()

	if(pulledby)
		pulledby.stop_pulling()
	..()

/obj/vehicle/bike/turn_off()
	if(!on)
		return
	if(engine)
		engine.putter(src)

	if(trail)
		trail.stop()

	anchored = kickstand

	update_icon()

	..()

/obj/vehicle/bike/bullet_act(obj/item/projectile/Proj)
	if(buckled_mob && prob((100-protection_percent)))
		buckled_mob.bullet_act(Proj)
		return
	..()

/obj/vehicle/bike/on_update_icon()
	overlays.Cut()

	if(on)
		icon_state = "bike"
	else
		icon_state = "bike"
	overlays += image('icons/obj/medium_vehicles.dmi', "[icon_state]_cover", MECH_COCKPIT_LAYER)
	..()


/obj/vehicle/bike/Destroy()
	qdel(trail)
	qdel(engine)
	..()


/obj/vehicle/bike/thermal
	engine_type = /obj/item/engine/thermal
	prefilled = 1

/obj/vehicle/bike/electric
	engine_type = /obj/item/engine/electric
	prefilled = 1

/obj/vehicle/bike/gyroscooter
	name = "gyroscooter"
	desc = "A fancy space scooter."
	icon_state = "gyroscooter_off"

	land_speed = 1.5
	space_speed = 0
	bike_icon = "gyroscooter"

	trail = null
	engine_type = /obj/item/engine/electric
	prefilled = 1
	protection_percent = 5

/obj/item/engine
	name = "engine"
	desc = "An engine used to power a small vehicle."
	//icon = 'icons/obj/objects.dmi'
	w_class = ITEM_SIZE_HUGE
	var/stat = 0
	var/trail_type
	var/cost_per_move = 5

/obj/item/engine/proc/get_trail()
	if(trail_type)
		return new trail_type
	return null

/obj/item/engine/proc/prefill()
	return

/obj/item/engine/proc/use_power()
	return 0

/obj/item/engine/proc/rev_engine(atom/movable/M)
	return

/obj/item/engine/proc/putter(atom/movable/M)
	return

/obj/item/engine/electric
	name = "electric engine"
	desc = "A battery-powered engine used to power a small vehicle."
	icon_state = "engine_electric"
	trail_type = /datum/effect/effect/system/trail/ion
	cost_per_move = 200	// W
	var/obj/item/cell/cell

/obj/item/engine/electric/use_tool(obj/item/I, mob/user)
	if(istype(I,/obj/item/cell))
		if(cell)
			to_chat(user, "<span class='warning'>There is already a cell in \the [src].</span>")
		else
			cell = I
			user.drop_from_inventory(I)
			I.forceMove(src)
		return 1
	else if(isCrowbar(I))
		if(cell)
			to_chat(user, "You pry out \the [cell].")
			cell.dropInto(loc)
			cell = null
			return 1
	..()

/obj/item/engine/electric/prefill()
	cell = new /obj/item/cell/high(src.loc)

/obj/item/engine/electric/use_power()
	if(!cell)
		return 0
	return cell.use(cost_per_move * CELLRATE)

/obj/item/engine/electric/rev_engine(atom/movable/M)
	M.audible_message("\The [M] beeps, spinning up.")

/obj/item/engine/electric/putter(atom/movable/M)
	M.audible_message("\The [M] makes one depressed beep before winding down.")

/obj/item/engine/electric/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	..()

/obj/item/engine/thermal
	name = "thermal engine"
	desc = "A fuel-powered engine used to power a small vehicle."
	icon_state = "engine_fuel"
	trail_type = /datum/effect/effect/system/trail/thermal
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	var/obj/temp_reagents_holder
	var/fuel_points = 0
	//fuel points are determined by differing reagents

/obj/item/engine/thermal/prefill()
	fuel_points = 5000

/obj/item/engine/thermal/New()
	..()
	create_reagents(500)
	temp_reagents_holder = new()
	temp_reagents_holder.create_reagents(15)
	temp_reagents_holder.atom_flags |= ATOM_FLAG_OPEN_CONTAINER

/obj/item/engine/thermal/use_tool(obj/item/I, mob/user)
	if(istype(I,/obj/item/reagent_containers) && I.is_open_container())
		if(istype(I,/obj/item/reagent_containers/food/snacks) || istype(I,/obj/item/reagent_containers/pill))
			return 0
		var/obj/item/reagent_containers/C = I
		C.standard_pour_into(user,src)
		return 1
	..()

/obj/item/engine/thermal/use_power()
	if(fuel_points >= cost_per_move)
		fuel_points -= cost_per_move
		return 1
	if(!reagents || reagents.total_volume <= 0 || stat)
		return 0

	reagents.trans_to(temp_reagents_holder,min(reagents.total_volume,15))
	var/multiplier = 1
	var/actually_flameable = 0
	for(var/datum/reagent/R in temp_reagents_holder.reagents.reagent_list)
		var/new_multiplier = 1
		if(istype(R,/datum/reagent/ethanol))
			var/datum/reagent/ethanol/E = R
			new_multiplier = (10/E.strength)
			actually_flameable = 1
		else if(istype(R,/datum/reagent/hydrazine))
			new_multiplier = 1.25
			actually_flameable = 1
		else if(istype(R,/datum/reagent/fuel))
			actually_flameable = 1
		else if(istype(R,/datum/reagent/toxin/phoron))
			new_multiplier = 2
			actually_flameable = 1
		else if(istype(R,/datum/reagent/frostoil))
			new_multiplier = 0.1
		else if(istype(R,/datum/reagent/water))
			new_multiplier = 0.4
		else if(istype(R,/datum/reagent/sugar)  && R.volume > 1)
			stat = DEAD
			explosion(get_turf(src),-1,0,2,3,0)
			return 0
		multiplier = (multiplier + new_multiplier)/2
	if(!actually_flameable)
		return 0
	fuel_points += 20 * multiplier * temp_reagents_holder.reagents.total_volume
	temp_reagents_holder.reagents.clear_reagents()
	return use_power()

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
