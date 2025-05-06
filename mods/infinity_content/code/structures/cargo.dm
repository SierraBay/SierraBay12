/obj/structure/cart
	name = "Cargo cart"
	desc = "Brand-new cart for heavy things. you can see little logo of NT on the back side."
	icon = 'mods/infinity_content/icons/obj/cart.dmi'
	icon_state = "cart"
	layer = STRUCTURE_LAYER
	density = FALSE
	w_class = ITEM_SIZE_LARGE
	var/cargoweight = 0
	var/atom/movable/load = null

/obj/structure/cart/Move()
	. = ..()
	if(load && !istype(load, /datum/vehicle_dummy_load))
		load.set_glide_size(src.glide_size)
		load.forceMove(src.loc)
		var/todir = src.dir
		if(istype(load, /obj/structure/closet/crate))
			todir = turn(src.dir, 90)
		load.set_dir(todir)

	var/sound
	sound = pick(list(
		'mods/infinity_content/sound/effects/cart1.ogg',
		'mods/infinity_content/sound/effects/cart2.ogg',
		'mods/infinity_content/sound/effects/cart3.ogg'
		))

	playsound(src, sound, 50, 1, 10)


/obj/structure/cart/MouseDrop_T(atom/movable/cargo, mob/user)
	if (!istype(user))
		return

	if(!CanPhysicallyInteract(user) || !user.Adjacent(cargo) || !istype(cargo) || (user == cargo))
		return

	if(do_after(user, 2 SECONDS, src, DO_DEFAULT | DO_TARGET_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
		if(!load(cargo))
			USE_FEEDBACK_FAILURE("You are unable to load [cargo] on [src]")
			return
		density = TRUE


/obj/structure/cart/attack_hand(mob/user)
	if (!istype(user))
		return FALSE

	if(user.stat || user.restrained() || !Adjacent(user))
		return FALSE

	if(!load)
		return FALSE

	if(do_after(user, 2 SECONDS, src, DO_DEFAULT | DO_TARGET_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
		unload(user)

	return ..()

/obj/structure/cart/proc/load(atom/movable/cargo)
	if(ismob(cargo))
		return FALSE
	if(!(istype(cargo, /obj/machinery) || istype(cargo, /obj/structure/closet) || istype(cargo, /obj/structure/largecrate) || istype(cargo, /obj/structure/ore_box) || istype(cargo, /obj/item/mech_component) || istype(cargo, /obj/item/mech_equipment)))
		return FALSE

	//if there are any items you don't want to be able to interact with, add them to this check
	// ~no more shielded, emitter armed death trains
	if(!isturf(cargo.loc)) //To prevent loading things from someone's inventory, which wouldn't get handled properly.
		return FALSE
	if(load)
		return FALSE

	if(cargo.anchored && !(istype(cargo, /obj/item/mech_component) || istype(cargo, /obj/item/mech_equipment)))
		return FALSE

	if(istype(cargo, /obj/machinery))
		load_object(cargo)
	else
		// if a create/closet, close before loading
		var/obj/structure/closet/crate = cargo
		if(istype(crate) && crate.opened && !crate.close())
			return FALSE

		cargo.forceMove(loc)
		cargo.anchored = TRUE

		load = cargo

		cargo.plane = plane
		cargo.layer = OBJ_LAYER

		if(!istype(cargo, /obj/structure/closet/crate))
			cargo.pixel_y += 6
			cargo.set_dir(dir)
		else
			cargo.set_dir(turn(dir, 90))

	if(load)
		var/obj/object_on_cart = load
		if(istype(load, /datum/vehicle_dummy_load))
			var/datum/vehicle_dummy_load/dummy = load
			object_on_cart = dummy.actual_load
		cargoweight = clamp(object_on_cart.w_class, 0, ITEM_SIZE_GARGANTUAN)
		return TRUE
	return FALSE

/obj/structure/cart/proc/load_object(atom/movable/cargo)
	var/datum/vehicle_dummy_load/dummy_load = new()
	load = dummy_load

	if(!load)
		return

	dummy_load.actual_load = cargo
	cargo.forceMove(src)

	// SIERRA TODO: Мне не нравится эта херня.
	// Надо посмотреть можно ли сделать через appearance или подобное.
	// То есть у объекта меняются значения, создаётся оверлей и значения возвращаются на место.
	// Кринж.
	cargo.pixel_y += 6
	cargo.plane = plane
	cargo.layer = OBJ_LAYER

	AddOverlays(cargo)

	//we can set these back now since we have already cloned the icon into the overlay
	cargo.pixel_y = initial(cargo.pixel_y)
	cargo.reset_plane_and_layer()

/obj/structure/cart/proc/unload(mob/user, direction)
	if(istype(load, /datum/vehicle_dummy_load))
		var/datum/vehicle_dummy_load/dummy_load = load
		load = dummy_load.actual_load
		dummy_load.actual_load = null
		qdel(dummy_load)
		ClearOverlays()

	if(!load)
		return

	var/turf/dest = null

	//find a turf to unload to
	if(direction)	//if direction specified, unload in that direction
		dest = get_step(src, direction)
	else if(user)	//if a user has unloaded the vehicle, unload at their feet
		dest = get_turf(user)

	if(!dest)
		dest = get_step_to(src, get_step(src, turn(dir, 90))) //try unloading to the side of the vehicle first if neither of the above are present

	//if these all result in the same turf as the vehicle or nullspace, pick a new turf with open space
	if(!dest || dest == get_turf(src))
		var/list/options = list()
		for(var/test_dir in GLOB.alldirs)
			var/possible_turf = get_step_to(src, get_step(src, test_dir))
			if(!possible_turf)
				continue
			options += possible_turf
		if(length(options))
			dest = pick(options)
		else
			dest = get_turf(src)	//otherwise just dump it on the same turf as the vehicle

	if(!isturf(dest))	//if there still is nowhere to unload, cancel out since the vehicle is probably in nullspace
		return FALSE

	load.forceMove(dest)
	load.set_dir(get_dir(loc, dest))
	load.pixel_y = initial(load.pixel_y)
	load.reset_plane_and_layer()

	cargoweight = 0
	load = null

	density = FALSE

	update_icon()

	return TRUE
