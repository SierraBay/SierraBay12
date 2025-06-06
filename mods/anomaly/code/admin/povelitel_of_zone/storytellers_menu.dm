/datum/controller/subsystem/processing/anom/proc/Show_storytellers_UI(list/input_html, mob/living/user)
	draw_main_buttons(input_list = input_html, storytellers_choosed = TRUE)
	//Находиться ли клиент в списке прослушивающих рассказчиков
	var/listener = FALSE
	if(usr.client.ckey in SSanom.debug_storyteller_listeners)
		listener = TRUE
	input_html += CFBTN("toggle_storyteller_listen", "Голос рассказчиков", listener)

	for(var/datum/planet_storyteller/storyteller in all_storytellers)
		input_html += "<br />\
		Рассказчик с планеты [storyteller.my_area]. \
		Уровень агрессии: [storyteller.current_angry_level] \
		<br>\
		Время между активностью: [storyteller.action_delay/10] Секунд \
		[MULTI_BTN("set_storyteller_activity_time", "\ref[storyteller]","", "Выставить время активности")]\
		<br>\
		EVOLV POINTS: [storyteller.current_evolution_points] \
		[MULTI_BTN("change_storyteller_points", "\ref[storyteller]","Эволюция", "Изменить")]\
		<br>\
		ANOM POINTS: [storyteller.current_anomaly_points] \
		[MULTI_BTN("change_storyteller_points", "\ref[storyteller]","Аномалии", "Изменить")]\
		<br>\
		MOBS POINTS: [storyteller.current_mob_points] \
		[MULTI_BTN("change_storyteller_points", "\ref[storyteller]","Мобы", "Изменить")]\
		<br>\
		SCAM POINTS: [storyteller.current_scam_points] \
		[MULTI_BTN("change_storyteller_points", "\ref[storyteller]","Обман", "Изменить")]\
		<br>\
		[MULTI_BTN("delete_object", "\ref[storyteller]","", "Удалить")] "
