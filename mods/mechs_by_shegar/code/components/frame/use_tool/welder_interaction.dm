/obj/structure/heavy_vehicle_frame/proc/welder_interaction(obj/item/weldingtool/welder, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
	if (!is_reinforced)
		USE_FEEDBACK_FAILURE("\The [src] has no reinforcements to weld.")
		return TRUE
	if (is_reinforced == FRAME_REINFORCED)
		USE_FEEDBACK_FAILURE("\The [src]'s reinforcements need to be secured before you can weld them.")
		return TRUE
	if (!welder.can_use(1, user, "to weld \the [src]'s internal reinforcements"))
		return TRUE
	var/current_state = is_reinforced
	playsound(src, 'sound/items/Welder.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts [is_reinforced == FRAME_REINFORCED_WELDED ? "un" : null]welding \the [src]'s internal reinforcements with \a [welder]."),
		SPAN_NOTICE("You start [is_reinforced == FRAME_REINFORCED_WELDED ? "un" : null]welding \the [src]'s internal reinforcements with \the [welder]."),
		SPAN_ITALIC("You hear welding.")
		)
	if (!user.do_skilled((welder.toolspeed * 2) SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, welder))
		return TRUE
	if (!is_reinforced)
		USE_FEEDBACK_FAILURE("\The [src] has no reinforcements to weld.")
		return TRUE
	if (is_reinforced == FRAME_REINFORCED)
		USE_FEEDBACK_FAILURE("\The [src]'s reinforcements need to be secured before you can weld them.")
		return TRUE
	if (current_state != is_reinforced)
		USE_FEEDBACK_FAILURE("\The [src]'s state has changed.")
		return TRUE
	if (!welder.remove_fuel(1, user))
		return TRUE
	is_reinforced = is_reinforced == FRAME_REINFORCED_WELDED ? FRAME_REINFORCED_SECURE : FRAME_REINFORCED_WELDED
	update_icon()
	playsound(src, 'sound/items/Welder.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("\The [user] [is_reinforced == FRAME_REINFORCED_WELDED ? "un" : null]welds \the [src]'s internal reinforcements with \a [welder]."),
		SPAN_NOTICE("You [is_reinforced == FRAME_REINFORCED_WELDED ? "un" : null]weld \the [src]'s internal reinforcements with \the [welder]."),
	)
	return TRUE
