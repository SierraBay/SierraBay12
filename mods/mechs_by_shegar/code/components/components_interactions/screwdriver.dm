/obj/item/mech_component/proc/screwdriver_interaction(mob/living/user)
	if(LAZYLEN(contents))
		//Filter non movables
		var/list/valid_contents = list()
		for(var/atom/movable/A in contents)
			if(!A.anchored)
				valid_contents += A
		if(!LAZYLEN(valid_contents))
			return TRUE
		var/obj/item/robot_parts/removed
		if(LAZYLEN(valid_contents) == 1)
			removed = pick(valid_contents)
		else
			removed = show_radial_menu(user, src, internal_parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
		if(!(removed in contents))
			return TRUE
		user.visible_message(SPAN_NOTICE("\The [user] removes \the [removed] from \the [src]."))
		removed.forceMove(user.loc)
		playsound(user.loc, 'sound/effects/pop.ogg', 50, 0)
		update_components()
	else
		to_chat(user, SPAN_WARNING("There is nothing to remove."))
	return TRUE
