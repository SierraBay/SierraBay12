//Рисует УИ верхних кнопок (С выбором подменю)
/datum/category_item/player_setup_item/cybernetics/proc/draw_main_buttons(list/input_list)
	input_list += "<table style='width:100%; text-align:center;'>"
	input_list += "<tr><td colspan='3'>"
	input_list += "<br />\
	[CFBTNU("limbs", "Протезы конечностей", current_tab == "Протезирование")]\
	&nbsp;&nbsp;&nbsp;&nbsp;\
	[CFBTNU("organs", "Внутренние органы", current_tab == "Внутренние органы")]\
	&nbsp;&nbsp;&nbsp;&nbsp;\
	[CFBTNU("augments", "Аугменты", current_tab == "Аугменты")]\
	&nbsp;&nbsp;&nbsp;&nbsp;\
	[CFBTNU("implants", "Импланты тела", current_tab == "Импланты тела")]\
	&nbsp;&nbsp;&nbsp;&nbsp;\
	[CFBTNU("СБРОС", "Полный сброс", FALSE)]"
	input_list += "</td></tr>"
	input_list += "<tr><td colspan='3' style='text-align:center;'>"
