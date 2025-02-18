/obj/structure/heavy_vehicle_frame/proc/crowbar_interaction(tool, mob/living/user)
// Remove reinforcement
	var/input = input(user, "What you wanna do?") as null|anything in list("Отсоединить листы материала", "Отсоединить часть меха")
	if(input == "Отсоединить листы материала")
		if (is_reinforced == FRAME_REINFORCED)
			user.visible_message(
				SPAN_NOTICE("\The [user] начал снимать укрепление с  \the [src]."),
				SPAN_NOTICE("Вы начали снимать укрепление с  \the [src].")
			)
		if (!user.do_skilled(0.5, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
			return TRUE
		material.place_sheet(loc, 10)
		material = null
		is_reinforced = FALSE
		user.visible_message(
			SPAN_NOTICE("\The [user] снял укрепление с \the [src]."),
			SPAN_NOTICE("Вы сняли укрепление с \the [src].")
		)
		return TRUE

	else if(input == "Отсоединить часть меха")
		input = input(user, "Какую часть меха вы хотите отсоединить?", "[src] - Remove Component") as null|anything in list(head, body, L_arm, R_arm, L_leg, R_leg)
		if (!input || !user.use_sanity_check(src, tool) || !uninstall_component(input, user))
			return TRUE
		if (input == body)
			body = null
		else if (input == head)
			head = null
		else if (input == L_arm)
			L_arm = null
		else if (input == R_arm)
			L_arm = null
		else if (input == L_leg)
			L_leg = null
		else if (input == R_leg)
			R_leg = null
		update_icon()
		return TRUE
