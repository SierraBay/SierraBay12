/obj/structure/heavy_vehicle_frame/proc/wrench_interaction(obj/item/tool, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
	if (!is_reinforced)
		USE_FEEDBACK_FAILURE("\The [src] has no reinforcements to secure or remove.")
		return TRUE
	if (is_reinforced == FRAME_REINFORCED_WELDED)
		USE_FEEDBACK_FAILURE("\The [src]'s internal reinforcements are welded in place and can't be removed.")
		return TRUE
	var/current_state = is_reinforced
	var/input
	if (is_reinforced == FRAME_REINFORCED_SECURE)
		input = "Remove Reinforcements"
	else
		input = input(user, "What would you like to do with the reinforcements?", "[src] - Reinforcements") as null|anything in list("Secure Reinforcements", "Remove Reinforcements")
		if (!input || !user.use_sanity_check(src, tool))
			return TRUE
		if (current_state != is_reinforced)
			USE_FEEDBACK_FAILURE("\The [src]'s state has changed.")
			return TRUE
	playsound(src, 'sound/items/Ratchet.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts [input == "Secure Reinforcements" ? "securing" : "removing"] \the [src]'s internal reinforcements with \a [tool]."),
		SPAN_NOTICE("You start [input == "Secure Reinforcements" ? "securing" : "removing"] \the [src]'s internal reinforcements with \the [tool].")
		)
	if (!user.do_skilled((tool.toolspeed * 4) SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
		return TRUE
	if (current_state != is_reinforced)
		USE_FEEDBACK_FAILURE("\The [src]'s state has changed.")
		return TRUE
	playsound(src, 'sound/items/Ratchet.ogg', 50, TRUE)
	is_reinforced = input == "Secure Reinforcements" ? FRAME_REINFORCED_SECURE : FALSE
	if (input == "Remove Reinforcements")
		material.place_sheet(loc, 10)
		material = null
		update_icon()
		user.visible_message(
			SPAN_NOTICE("\The [user] [input == "Secure Reinforcements" ? "secures" : "removes"] \the [src]'s internal reinforcements with \a [tool]."),
			SPAN_NOTICE("You [input == "Secure Reinforcements" ? "secure" : "remove"] \the [src]'s internal reinforcements with \the [tool].")
		)
		return TRUE
