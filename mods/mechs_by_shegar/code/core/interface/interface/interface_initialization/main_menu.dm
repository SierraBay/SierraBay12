/mob/living/exosuit/proc/Initialize_big_menu()
	var/obj/screen/exosuit/menu_background = new /obj/screen/exosuit/menu_background(src)
	menu_background.layer = 2.1
	menu_background.screen_loc = "CENTER-2.85,CENTER-2.5"
	menu_background.mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	menu_hud_elements |= menu_background
	var/list/big_buttons = list(
		/obj/screen/exosuit/menu_button/rename,
		/obj/screen/exosuit/menu_button/radio,
		/obj/screen/exosuit/menu_button/maint,
		/obj/screen/exosuit/menu_button/megaspeakers,
		/obj/screen/exosuit/menu_button/gps,
		/obj/screen/exosuit/menu_button/medscan,
		/obj/screen/exosuit/menu_button/id,
		/obj/screen/exosuit/menu_button/hatch_bolts,
		/obj/screen/exosuit/menu_button/camera
	)
	var/x_step = 0 //как сильно мы сдвигаемся
	var/y_step = 0.5
	var/current_x_cord = 2.3
	var/current_y_cord = 0
	for(var/button_type in big_buttons)
		var/obj/screen/exosuit/menu_button/menu_button = new button_type(src)
		menu_button.layer = 2.2
		menu_button.screen_loc = "CENTER-[current_x_cord], CENTER+1.5-[current_y_cord]" //Высставляем положение кнопачки
		menu_hud_elements |= menu_button //Размещаем кнопушку в меню
		current_y_cord += y_step //Делаем шаг ниже
		current_x_cord += x_step
