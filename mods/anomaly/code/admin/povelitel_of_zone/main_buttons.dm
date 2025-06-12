///Здесь происходит отрисовка основных кнопачек, с помощью которых мы и будем выбирать категорию над
/datum/controller/subsystem/processing/anom/proc/draw_main_buttons(list/input_list, anoms_choosed = FALSE, artefacts_choosed = FALSE, weather_choosed = FALSE, storytellers_choosed = FALSE)
	/*Будут такие кнопки как:
	-Аномалии
	-Артефакты
	-Рассказчики
	-Погоды
	-
	*/
	input_list += "<table align='center' width='100%'>"
	input_list += "<tr><td colspan=3><center>"
	input_list += "<br />[FCFBTN(SSanom, "Аномалии", "Аномалии", anoms_choosed)]   [FCFBTN(SSanom, "Артефакты", "Артефакты", artefacts_choosed)]   [FCFBTN(SSanom, "Погода", "Погода", weather_choosed)] [FCFBTN(SSanom, "Рассказчики", "Рассказчики", storytellers_choosed)]"
	input_list += "</center></td></tr>"
	input_list += "<tr><td colspan=3>"
