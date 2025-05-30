//Pile of garbage for when a clam is uninstalled or destroyed with +1 dense items inside
/obj/structure/cargopile
	name = "spilled cargo"
	desc = "The jetsam of some unfortunate power loader."
	icon = 'icons/obj/structures/rubble.dmi'
	icon_state = "base"
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | PIXEL_SCALE
	atom_flags = ATOM_FLAG_CLIMBABLE
	opacity = 1
	density = TRUE
	anchored = TRUE


/obj/structure/cargopile/on_update_icon()
	ClearOverlays()
	for(var/obj/thing in contents)
		var/image/I = new
		I.appearance = thing.appearance
		I.appearance_flags = DEFAULT_APPEARANCE_FLAGS | PIXEL_SCALE
		I.pixel_x = rand(-16,16)
		I.pixel_y = rand(-16,16)
		I.SetTransform(rotation = rand(0, 360))
		AddOverlays(I)

/obj/structure/cargopile/attack_hand(mob/user)
	. = ..()
	if(Adjacent(user))
		var/obj/chosen_obj = input(user, "Choose an object to grab.", "Cargo pile") as null|anything in contents
		if(!chosen_obj)
			return
		if(chosen_obj.density)
			for(var/atom/A in get_turf(src))
				if(!istype(A, /obj/structure/cargopile) && A.density && !(A.atom_flags & ATOM_FLAG_CHECKS_BORDER))
					to_chat(user, SPAN_WARNING("\The [A] blocks you from pulling out \the [chosen_obj]."))
					return
		if(!do_after(user, 0.5 SECONDS, src, DO_PUBLIC_UNIQUE)) return
		if(!chosen_obj) return
		if(chosen_obj.density)
			for(var/atom/A in get_turf(src))
				if(A != src && A.density && !(A.atom_flags & ATOM_FLAG_CHECKS_BORDER))
					to_chat(user, SPAN_WARNING("\The [A] blocks you from pulling out \the [chosen_obj]."))
					return
		if(user.put_in_active_hand(chosen_obj))
			src.visible_message(SPAN_NOTICE("\The [user] carefully grabs \the [chosen_obj] from \the [src]."))
		else if(chosen_obj.dropInto(get_turf(src)))
			src.visible_message(SPAN_NOTICE("\The [user] pulls \the [chosen_obj] from \the [src]."))

		if(!length(contents))
			qdel_self()
		else update_icon()

/obj/item/mech_equipment/clamp
	name = "mounted clamp"
	desc = "A large, heavy industrial cargo loading clamp."
	icon_state = "mech_clamp"
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_UTILITY)
	origin_tech = list(TECH_MATERIAL = 2, TECH_ENGINEERING = 2)
	var/carrying_capacity = 5
	var/list/obj/carrying = list()
	heat_generation = 25

/obj/item/mech_equipment/clamp/resolve_attackby(atom/A, mob/user, click_params)
	if(owner)
		return 0
	return ..()

/obj/item/mech_equipment/clamp/attack_hand(mob/user)
	if(owner && LAZYISIN(owner.pilots, user))
		if(!owner.hatch_closed && length(carrying))
			var/obj/chosen_obj = input(user, "Choose an object to grab.", "Clamp Claw") as null|anything in carrying
			if(!chosen_obj)
				return
			if(!do_after(user, 2 SECONDS, owner, DO_PUBLIC_UNIQUE)) return
			if(owner.hatch_closed || !chosen_obj) return
			if(user.put_in_active_hand(chosen_obj))
				owner.visible_message(SPAN_NOTICE("\The [user] carefully grabs \the [chosen_obj] from \the [src]."))
				playsound(src, 'sound/mecha/hydraulic.ogg', 50, 1)
				carrying -= chosen_obj
	. = ..()

/obj/item/mech_equipment/clamp/afterattack(atom/target, mob/living/user, inrange, params)
	if(!module_can_be_used(target, user, inrange))
		return
	target.mech_clamp_interaction(user, src)

/obj/item/mech_equipment/clamp/attack_self(mob/user)
	. = ..()
	if(.)
		drop_carrying(user, TRUE)

/obj/item/mech_equipment/clamp/CtrlClick(mob/user)
	if(owner)
		drop_carrying(user, FALSE)
		return TRUE
	return ..()

/obj/item/mech_equipment/clamp/proc/drop_carrying(mob/user, choose_object)
	if(!length(carrying))
		to_chat(user, SPAN_WARNING("You are not carrying anything in \the [src]."))
		return
	var/obj/chosen_obj = carrying[1]
	if(choose_object)
		chosen_obj = input(user, "Choose an object to set down.", "Clamp Claw") as null|anything in carrying
	if(!chosen_obj)
		return
	if(chosen_obj.density)
		for(var/atom/A in get_turf(src))
			if(A != owner && A.density && !(A.atom_flags & ATOM_FLAG_CHECKS_BORDER))
				to_chat(user, SPAN_WARNING("\The [A] blocks you from putting down \the [chosen_obj]."))
				return

	owner.visible_message(SPAN_NOTICE("\The [owner] unloads \the [chosen_obj]."))
	playsound(src, 'sound/mecha/hydraulic.ogg', 50, 1)
	chosen_obj.forceMove(get_turf(src))
	carrying -= chosen_obj

/obj/item/mech_equipment/clamp/get_hardpoint_status_value()
	if(length(carrying) > 1)
		return length(carrying)/carrying_capacity
	return null

/obj/item/mech_equipment/clamp/get_hardpoint_maptext()
	if(length(carrying) == 1)
		return carrying[1].name
	else if(length(carrying) > 1)
		return "Multiple"
	. = ..()

/obj/item/mech_equipment/clamp/proc/create_spill()
	if(length(carrying))
		var/denseCount = 0
		for(var/obj/load in carrying)
			if(load.density)
				denseCount += 1
			if(denseCount > 1)
				break

		if(denseCount > 1)
			var/obj/structure/cargopile/pile = new(get_turf(src))
			for(var/obj/load in carrying)
				load.forceMove(pile)
				carrying -= load
			pile.update_icon()
		else
			for(var/obj/load in carrying)
				var/turf/location = get_turf(src)
				var/list/turfs = location.AdjacentTurfsSpace()
				if(load.density)
					if(length(turfs) > 0)
						location = pick(turfs)
						turfs -= location
					else
						load.dropInto(location)
						load.throw_at_random(FALSE, rand(2,4), 4)
						location = null
				if(location)
					load.dropInto(location)
				carrying -= load

/obj/item/mech_equipment/clamp/uninstalled()
	create_spill()
	. = ..()

/obj/item/mech_equipment/clamp/wreck()
	create_spill()
