/mob/living/exosuit/proc/Initialize_big_menu_buttons()
	var/list/big_buttons = list(
		/obj/screen/exosuit/menu_button/power,
		/obj/screen/exosuit/menu_button/eject,
		/obj/screen/exosuit/menu_button/hatch,
		/obj/screen/exosuit/menu_button/rename,
		/obj/screen/exosuit/menu_button/radio,
		/obj/screen/exosuit/menu_button/maint,
		/obj/screen/exosuit/menu_button/megaspeakers,
		/obj/screen/exosuit/menu_button/gps,
		/obj/screen/exosuit/menu_button/medscan,
		/obj/screen/exosuit/menu_button/id,
		/obj/screen/exosuit/menu_button/air,
		/obj/screen/exosuit/menu_button/hatch_bolts,
		/obj/screen/exosuit/menu_button/camera
	)
	var/x_step = 0.8 //как сильно мы сдвигаемся
	var/y_step = 0.8
	var/current_x_cord = 0
	var/current_y_cord = 1.2
	for(var/button_type in big_buttons)
		var/obj/screen/exosuit/menu_button/menu_button = new button_type(src)
		if(current_x_cord >= 6) //Все кнопки после каждой 10-ки будут находится ниже остальных, а счётчик обнулится
			current_x_cord = 0
			current_y_cord += y_step

		menu_button.screen_loc = "CENTER-2+[current_x_cord], CENTER-[current_y_cord]" //Высставляем положение кнопачки
		menu_hud_elements |= menu_button //Размещаем кнопушку в меню
		current_x_cord += x_step //Делаем шаг правее
