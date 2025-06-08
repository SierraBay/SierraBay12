/datum/controller/subsystem/processing/anom/proc/Show_artefacts_UI(list/input_html, mob/living/user)
	draw_main_buttons(input_list = input_html, artefacts_choosed = TRUE)
	for(var/obj/item/artefact/artefact in artefacts_list_in_world)
		input_html += "<br />\
		[artefact.admin_name],\
		координаты: [get_x(artefact)], [get_y(artefact)], [get_z(artefact)] |||\
		[MULTI_BTN("delete_object", "\ref[artefact]","Артефакты", "Удалить")]\
		[MULTI_BTN("teleport_to_object", "\ref[artefact]", "Артефакты", "Телепортироваться")]"
