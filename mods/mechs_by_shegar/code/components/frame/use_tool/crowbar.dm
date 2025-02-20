/obj/structure/heavy_vehicle_frame/proc/crowbar_interaction(tool, mob/living/user)
// Remove reinforcement
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
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
		var/obj/item/mech_component/choised_part = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
		if (!choised_part || !user.use_sanity_check(src, tool) || !uninstall_component(choised_part, user))
			return TRUE
		if (choised_part == body)
			body = null
		else if (choised_part == head)
			head = null
		else if (choised_part == L_arm)
			L_arm = null
		else if (choised_part == R_arm)
			R_arm = null
		else if (choised_part == L_leg)
			L_leg = null
		else if (choised_part == R_leg)
			R_leg = null
		update_icon()
		return TRUE
