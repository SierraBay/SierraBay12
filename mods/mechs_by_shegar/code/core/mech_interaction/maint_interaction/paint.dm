/mob/living/exosuit/proc/paint_spray_interaction(mob/living/user, color)
	var/obj/item/mech_component/choice = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(choice)
		choice.set_color(color)
		update_icon()
		generate_icons()
		return TRUE
	return FALSE

/obj/structure/heavy_vehicle_frame/set_color(new_colour)
	return
