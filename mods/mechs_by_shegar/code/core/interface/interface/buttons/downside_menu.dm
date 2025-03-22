/mob/living/exosuit
	///Статус основного меню. По умолчанию открыт.
	var/downside_menu_status = TRUE
	//Список кнопок в основном меню смотреть в инициализации
	var/list/downside_menu_elements = list()
	var/list/downside_menu_types = list(
		/obj/screen/exosuit/menu_button/power,
		/obj/screen/exosuit/menu_button/eject,
		/obj/screen/exosuit/menu_button/hatch,
		/obj/screen/exosuit/menu_button/air
	)
	var/obj/screen/exosuit/downside_menu/downside_menu

//В активном состоянии все орудия будут показаны, в скрытом - скрыты. Всё просто.
/obj/screen/exosuit/downside_menu
	name = "buttons menu"
	icon_state = "context_menu_open"
	var/open_position
	var/closed_position

/obj/screen/exosuit/downside_menu/Click()
	owner.toggle_main_buttons()


/mob/living/exosuit/proc/toggle_main_buttons()
	if(downside_menu_status) //Закрыть меню
		close_main_buttons()
	else
		open_main_buttons()

/mob/living/exosuit/proc/close_main_buttons()
	downside_menu_status = FALSE
	downside_menu.icon_state = "context_menu_closed"
	downside_menu.screen_loc = downside_menu.closed_position
	refresh_main_buttons_hud()

/mob/living/exosuit/proc/open_main_buttons()
	downside_menu_status = TRUE
	downside_menu.icon_state = "context_menu_open"
	downside_menu.screen_loc = downside_menu.open_position
	refresh_main_buttons_hud()

/mob/living/exosuit/proc/refresh_main_buttons_hud()
	if(LAZYLEN(pilots))
		for(var/thing in pilots)
			var/mob/pilot = thing
			if(pilot.client)
				if(downside_menu_status)
					pilot.client.screen |= downside_menu_elements
				else
					pilot.client.screen -= downside_menu_elements
