/datum/controller/subsystem/processing/anom/proc/Show_anomalies_UI(list/input_html, mob/living/user, input_x, input_y)
	input_x = 1000
	input_y = 1500
	draw_main_buttons(input_list = input_html, anoms_choosed = TRUE)

	for(var/obj/anomaly/anom in all_anomalies_cores)
		input_html += "<br />[anom.admin_name], cords: [get_x(anom)], [get_y(anom)], [get_z(anom)] ||| [MULTI_BTN("delete_object", "\ref[anom]","Аномалии", "Удалить")]  [MULTI_BTN("teleport_to_object", "\ref[anom]", "Аномалии", "Телепортироваться")]"
