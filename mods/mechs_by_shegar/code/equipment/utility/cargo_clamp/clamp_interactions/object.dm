/obj/mech_clamp_interaction(mob/living/user, obj/item/mech_equipment/clamp/mech_clamp)
	if(buckled_mob)
		to_chat(user, SPAN_WARNING("Someone buckled to this object."))
		return
	if(anchored)
		to_chat(user, SPAN_WARNING("You can't pickup anchored objects."))
		return
	if(length(mech_clamp.carrying) >= mech_clamp.carrying_capacity)
		to_chat(user, SPAN_WARNING("\The [src] is fully loaded!"))
		return
	for(var/atom/picked_atom in contents)
		if(ishuman(picked_atom) || isrobot(contents))
			to_chat(user, SPAN_WARNING("You can't pickup objects with humanoid or borg inside."))
			return
	mech_clamp.owner.visible_message(SPAN_NOTICE("\The [mech_clamp.owner] begins loading \the [src]."))
	if(do_after(mech_clamp.owner, 2 SECONDS, src, DO_PUBLIC_UNIQUE & ~DO_USER_SAME_HAND))
		if(src in mech_clamp.carrying || buckled_mob || anchored) //Repeat checks
			return
		for(var/atom/picked_atom in contents)
			if(isliving(picked_atom) || isrobot(contents))
				to_chat(user, SPAN_WARNING("You can't pickup objects with humanoid or borg inside."))
				return
		if(length(mech_clamp.carrying) >= mech_clamp.carrying_capacity)
			to_chat(user, SPAN_WARNING("\The [mech_clamp] is fully loaded!"))
			return
		forceMove(mech_clamp)
		mech_clamp.carrying += src
		mech_clamp.owner.visible_message(SPAN_NOTICE("\The [mech_clamp.owner] loads \the [src] into its cargo compartment."))
		playsound(src, 'sound/mecha/hydraulic.ogg', 50, 1)
