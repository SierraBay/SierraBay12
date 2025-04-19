/obj/structure/heavy_vehicle_frame/proc/wirecutter_interaction(obj/item/tool, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
	if (!is_wired)
		USE_FEEDBACK_FAILURE("\The [src] has no wiring to adjust or remove.")
		return TRUE
	var/input
	var/current_state = is_wired
	if (is_wired == FRAME_WIRED_ADJUSTED)
		input = "Remove Wiring"
	else
		input = input(user, "What would you like to do with the wiring?", "[src] - Wiring") as null|anything in list("Adjust Wiring", "Remove Wiring")
		if (!input || !user.use_sanity_check(src, tool))
			return TRUE
		if (is_wired != current_state)
			USE_FEEDBACK_FAILURE("\The [src]'s state has changed.")
			return TRUE
	playsound(src, 'sound/items/Wirecutter.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts [input == "Adjust Wiring" ? "adjusting" : "removing"] the wiring in \the [src] with \a [tool]."),
		SPAN_NOTICE("You start [input == "Adjust Wiring" ? "adjusting" : "removing"] the wiring in \the [src] with \the [tool].")
		)
	if (!user.do_skilled((tool.toolspeed * 3) SECONDS, SKILL_ELECTRICAL, src) || !user.use_sanity_check(src, tool))
		return TRUE
	if (is_wired != current_state)
		USE_FEEDBACK_FAILURE("\The [src]'s state has changed.")
		return TRUE
	playsound(src, 'sound/items/Wirecutter.ogg', 50, TRUE)
	is_wired = input == "Adjust Wiring" ? FRAME_WIRED_ADJUSTED : FALSE
	update_icon()
	if (input == "Remove Wiring")
		new /obj/item/stack/cable_coil(loc, 10)
		user.visible_message(
			SPAN_NOTICE("\The [user] [input == "Adjust Wiring" ? "adjusts" : "removes"] the wiring in \the [src] with \a [tool]."),
			SPAN_NOTICE("You [input == "Adjust Wiring" ? "adjust" : "remove"] the wiring in \the [src] with \the [tool].")
			)
		return TRUE
