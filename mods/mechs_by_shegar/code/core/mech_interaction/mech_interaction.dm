/mob/living/exosuit/MouseDrop_T(atom/dropping, mob/user)
	var/obj/machinery/portable_atmospherics/canister/C = dropping
	if(istype(C))
		body.MouseDrop_T(dropping, user)
	else . = ..()

/mob/living/exosuit/MouseDrop(mob/living/carbon/human/over_object) //going from assumption none of previous options are relevant to exosuit
	if(body)
		if(!body.MouseDrop(over_object))
			return ..()

/mob/living/exosuit/RelayMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, mob/user)
	if(user && (user in pilots) && user.loc == src)
		return OnMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, user)
	return ..()

/mob/living/exosuit/OnMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, mob/user)
	if(!user || incapacitated() || user.incapacitated())
		return FALSE

	if(!(user in pilots) && user != src)
		return FALSE

	//This is handled at active module level really, it is the one who has to know if it's supposed to act
	if(selected_system)
		return selected_system.MouseDragInteraction(src_object, over_object, src_location, over_location, src_control, over_control, params, user)



/datum/click_handler/default/mech/OnDblClick(atom/A, params)
	OnClick(A, params)

/mob/living/exosuit/allow_click_through(atom/A, params, mob/user)
	if(LAZYISIN(pilots, user) && !hatch_closed)
		return TRUE
	. = ..()

//UI distance checks
/mob/living/exosuit/contents_nano_distance(src_object, mob/living/user)
	. = ..()
	if(!hatch_closed)
		return max(shared_living_nano_distance(src_object), .) //Either visible to mech(outside) or visible to user (inside)

/mob/living/exosuit/proc/check_enter(mob/user, silent = FALSE, check_incap = TRUE)
	if(!user || (check_incap && user.incapacitated()))
		return FALSE
	if (user.buckled)
		if (!silent)
			to_chat(user, SPAN_WARNING("You are currently buckled to \the [user.buckled]."))
		return FALSE
	if(!(user.mob_size >= body.min_pilot_size && user.mob_size <= body.max_pilot_size))
		if(!silent)
			to_chat(user, SPAN_WARNING("You cannot pilot an exosuit of this size."))
		return FALSE
	if(!user.Adjacent(src))
		return FALSE
	if(hatch_locked)
		if(!silent)
			to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is locked."))
		return FALSE
	if(hatch_closed)
		if(!silent)
			to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is closed."))
		return FALSE
	if(LAZYLEN(pilots) >= LAZYLEN(body.pilot_positions))
		if(!silent)
			to_chat(user, SPAN_WARNING("\The [src] is occupied to capacity."))
		return FALSE
	return TRUE

/mob/living/exosuit/proc/enter(mob/user, silent = FALSE, check_incap = TRUE, instant = FALSE)
	if(!check_enter(user, silent, check_incap))
		return FALSE
	to_chat(user, SPAN_NOTICE("You start climbing into \the [src]..."))
	if(!body)
		return FALSE
	if(!instant && !do_after(user, body.climb_time, src, DO_PUBLIC_UNIQUE))
		return FALSE
	if(!check_enter(user, silent, check_incap))
		return FALSE
	if(!silent)
		to_chat(user, SPAN_NOTICE("You climb into \the [src]."))
		playsound(src, 'sound/machines/airlock_heavy.ogg', 60, 1)
	add_pilot(user)
	return TRUE




/mob/living/exosuit/proc/sync_access()
	access_card.access = saved_access.Copy()
	if(sync_access)
		for(var/mob/pilot in pilots)
			access_card.access |= pilot.GetAccess()
			to_chat(pilot, SPAN_NOTICE("Security access permissions synchronized."))



/mob/living/exosuit/attack_generic(mob/user, damage, attack_message = "smashes into")
	..()
	if(damage)
		playsound(loc, body.damage_sound, 40, 1)

/mob/living/exosuit/proc/attack_self(mob/user)
	return visible_message("\The [src] pokes itself.")
