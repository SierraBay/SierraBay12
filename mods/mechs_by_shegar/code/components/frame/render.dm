/obj/structure/heavy_vehicle_frame
	var/list/parts_list_images

/obj/structure/heavy_vehicle_frame/Initialize()
	. = ..()
	update_parts_images()

/obj/structure/heavy_vehicle_frame/proc/update_parts_images()
	var/parts_list = list()
	if(head)
		parts_list += head
	if(body)
		parts_list += body
	if(R_arm)
		parts_list += R_arm
	if(L_arm)
		parts_list += L_arm
	if(R_leg)
		parts_list += R_leg
	if(L_leg)
		parts_list += L_leg
	parts_list_images = make_item_radial_menu_choices(parts_list)
