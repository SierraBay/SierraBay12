/obj/structure/heavy_vehicle_frame/proc/crowbar_interaction(tool, mob/living/user)
// Remove reinforcement
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
	var/list/options = list(
		"Отсоединить листы" = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', "material"),
		"Отсоединить часть меха" = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', "unconnect_part")
		)
	var/choose = show_radial_menu(user, src, options, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(choose == "Отсоединить листы")
		if (is_reinforced == FRAME_REINFORCED)
			user.visible_message(
				SPAN_NOTICE("\The [user] начал снимать укрепление с  \the [src]."),
				SPAN_NOTICE("Вы начали снимать укрепление с  \the [src].")
			)
		else
			to_chat(user, "[src] have no internal reinforces.")
		if (!user.do_skilled(4 SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
			return TRUE
		material.place_sheet(loc, 10)
		material = null
		is_reinforced = FALSE
		user.visible_message(
			SPAN_NOTICE("\The [user] снял укрепление с \the [src]."),
			SPAN_NOTICE("Вы сняли укрепление с \the [src].")
		)
		return TRUE

	else if(choose == "Отсоединить часть меха")
		var/obj/item/mech_component/choosed_part = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
		if (!choosed_part || !user.use_sanity_check(src, tool) || !uninstall_component(choosed_part, user))
			return TRUE
		if(choosed_part.doubled_owner)
			R_leg.forceMove(choosed_part.doubled_owner)
			R_leg = null
			L_leg.forceMove(choosed_part.doubled_owner)
			L_leg = null
		if (choosed_part == body)
			body = null
		else if (choosed_part == head)
			head = null
		else if (choosed_part == R_arm)
			R_arm = null
		else if (choosed_part == L_arm)
			L_arm = null
		else if (choosed_part == R_leg)
			R_leg = null
		else if (choosed_part == L_leg)
			L_leg = null
		update_icon()
		return TRUE
