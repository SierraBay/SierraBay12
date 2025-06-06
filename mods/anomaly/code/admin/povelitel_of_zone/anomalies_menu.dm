/datum/controller/subsystem/processing/anom/proc/Show_anomalies_UI(list/input_html, mob/living/user)
	draw_main_buttons(input_list = input_html, anoms_choosed = TRUE)
	for(var/obj/anomaly/anom in all_anomalies_cores)
		input_html += "<br />[anom.admin_name],\
		координаты: [get_x(anom)], [get_y(anom)], [get_z(anom)] |||\
		[MULTI_BTN("delete_object", "\ref[anom]","Аномалии", "Удалить")]\
		[MULTI_BTN("teleport_to_object", "\ref[anom]", "Аномалии", "Телепортироваться")]\
		[MULTI_BTN("born_artefact", "\ref[anom]", "Аномалии", "Создать артефакт")]\
		[MULTI_BTN("activate_anomaly", "\ref[anom]", "Аномалии", "Активировать аномалию")]"
