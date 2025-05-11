/mob/living/exosuit
	//TRUE - Не перехватывается и меню открывается как раньше
	//FALSE при нажатии правой кнопкой мыши, мех это перехватывает и меню не открывается
	var/show_right_click_menu = FALSE

/obj/screen/exosuit/menu_button/right_click
	name = "Правая кнопка"
	button_desc = "Переключает видимость меню возникаемого при нажатии ПКМ по игровому полю. <br> Без этой активной кнопки, многие возможности управления меха работать не будут."
	icon_state = "right"

/obj/screen/exosuit/menu_button/right_click/activated()
	if(owner.show_right_click_menu)
		owner.show_right_click_menu = FALSE
		for(var/mob/living/smbd in owner.pilots)
			smbd.client.show_popup_menus = FALSE
	else
		owner.show_right_click_menu = TRUE
		for(var/mob/living/smbd in owner.pilots)
			smbd.client.show_popup_menus = TRUE

/obj/screen/exosuit/menu_button/right_click/update()
	if(owner.show_right_click_menu)
		icon_state = "[initial(icon_state)]_activated"
	else
		icon_state = initial(icon_state)
