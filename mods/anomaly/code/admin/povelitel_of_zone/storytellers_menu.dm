/datum/controller/subsystem/processing/anom/proc/Show_storytellers_UI(list/input_html, mob/living/user, input_x, input_y)
	input_x = 1000
	input_y = 1500
	draw_main_buttons(input_list = input_html, storytellers_choosed = TRUE)

	for(var/datum/planet_storyteller/storyteller in all_storytellers)
		input_html += "<br />Рассказчик с планеты [storyteller.my_area]. LEVEL: [storyteller.current_angry_level]|EVOLV POINTS: [storyteller.current_evolution_points]|ANOM POINTS: [storyteller.current_anomaly_points]|MOBS POINTS: [storyteller.current_mob_points]|SCAM POINTS: [storyteller.current_scam_points] ||| [MULTI_BTN("delete_object", "\ref[storyteller]","Рассказчики", "Удалить")] "
