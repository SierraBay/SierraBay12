//Рисует УИ верхних кнопок (С выбором подменю)
/datum/category_item/player_setup_item/cybernetics/proc/draw_main_buttons(list/input_list)
	input_list += "<table align='center' width='100%'>"
	input_list += "<tr><td colspan=3><center>"
	var/limbs_choosed = FALSE
	var/organs_choosed = FALSE
	var/implats_choosed = FALSE
	if(current_tab == "Протезирование")
		limbs_choosed = TRUE
	else if(current_tab == "Внутренние органы")
		organs_choosed = TRUE
	else if(current_tab == "Импланты тела")
		implats_choosed = TRUE
	input_list += "<br />[CFBTN("limbs", "Протезы конечностей", limbs_choosed)]   [CFBTN("organs", "Внутренние органы", organs_choosed)]   [CFBTN("implants", "Импланты тела", implats_choosed)]"
	input_list += "</center></td></tr>"
	input_list += "<tr><td colspan=3><center><b>"
