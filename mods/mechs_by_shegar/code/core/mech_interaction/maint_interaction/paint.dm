/mob/living/exosuit/proc/paint_spray_interaction(mob/living/user, color)
	var/obj/item/mech_component/choice = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	choice.set_color(color)
	update_icon()
	return TRUE

/obj/structure/heavy_vehicle_frame/set_color(new_colour)
	return

/obj/structure/heavy_vehicle_frame/proc/paint_spray_interaction(mob/living/user, color)
	var/obj/item/mech_component/choice = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	choice.set_color(color)
	update_icon()
	return TRUE

/obj/structure/heavy_vehicle_frame
	var/list/parts_list_images

/obj/structure/heavy_vehicle_frame/proc/generate_parts_images()
	parts_list_images = make_item_radial_menu_choices(list(head, body, arms, legs))

/obj/structure/heavy_vehicle_frame/Initialize()
	. = ..()
	generate_parts_images()

/obj/structure/heavy_vehicle_frame/on_update_icon()
	.=..()
	generate_parts_images()
