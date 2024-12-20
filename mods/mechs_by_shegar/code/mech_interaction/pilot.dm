/mob/living/exosuit/add_pilot(mob/user)
	if (LAZYISIN(pilots, user))
		return
	user.forceMove(src)
	user.PushClickHandler(/datum/click_handler/default/mech)
	LAZYADD(pilots, user)
	if (user.client)
		user.client.screen |= hud_elements
	LAZYDISTINCTADD(user.additional_vision_handlers, src)
	GLOB.destroyed_event.register(user, src, .proc/remove_pilot)
	sync_access()
	update_pilots()
	need_update_sensor_effects = TRUE
	to_chat(user,SPAN_NOTICE("<b><font color = green> Press Middle mouse button for fast swap current hardpoint. </font></b>"))
	to_chat(user,SPAN_NOTICE("<b><font color = green> Press SPACE mouse for toggle strafe mod. </font></b>"))


/// Removes a mob from the pilots list and destroyed event handlers. Called by the destroyed event.
/mob/living/exosuit/remove_pilot(mob/user)
	if (!LAZYISIN(pilots, user))
		return
	user.RemoveClickHandler(/datum/click_handler/default/mech)
	if (!QDELETED(user))
		user.dropInto(loc)
	if (user.client)
		user.client.screen -= hud_elements
		user.client.screen -= menu_hud_elements
		user.client.screen -= hardpoint_hud_elements
		user.client.screen -= hardpoints_menu_elements
		user.client.eye = user
	LAZYREMOVE(user.additional_vision_handlers, src)
	LAZYREMOVE(pilots, user)
	GLOB.destroyed_event.unregister(user, src, PROC_REF(remove_pilot))
	sync_access()
	update_pilots()
	clear_sensors_effects(user)

/mob/living/exosuit/eject(mob/user, silent)
	if(!user || !(user in src.contents))
		return
	if(hatch_closed)
		if(hatch_locked)
			if(!silent)
				to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is locked."))
			return
		open_hatch()
		update_icon()

	//Начинаем вылезать
	visible_message("\the [user] starts climbing out from [src].")
	if(!do_after(user, 7 SECONDS, src, DO_PUBLIC_UNIQUE))
		return FALSE

	if(hatch_locked)
		return

	hatch_closed = FALSE
	update_icon()
	if(!silent)
		to_chat(user, SPAN_NOTICE("You climb out of \the [src]."))

	remove_pilot(user)
	return TRUE
