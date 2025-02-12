/mob/living/exosuit
	///Статус меню вооружения
	var/hardpoints_menu_status = FALSE
	var/list/hardpoints_menu_elements = list() //Список всех кнопачек хардпоинтов

//Далеко не всегда игроку нужно смотреть на свои орудия, а места они занимают много, и важное
//В активном состоянии все орудия будут показаны, в скрытом - скрыты. Всё просто.
/obj/screen/exosuit/hardpoints_menu
	name = "hardpoints menu"
	icon_state = "hardpoints_menu_closed"
	var/open_position

/obj/screen/exosuit/hardpoints_menu/Click()
	owner.toggle_hardpoints_menu()

//Данная кнопочка покажет на экране игрька большоое меню
/mob/living/exosuit/proc/toggle_hardpoints_menu()
	if(hardpoints_menu_status) //Закрыть меню
		hardpoints_menu_status = FALSE
		hardpoints_menu.icon_state = "hardpoints_menu_closed"
		hardpoints_menu.screen_loc = "1:6,14.5"
	else
		hardpoints_menu_status = TRUE
		hardpoints_menu.icon_state = "hardpoints_menu_open"
		hardpoints_menu.screen_loc = hardpoints_menu.open_position
	refresh_hardpoints_menu_hud()

/mob/living/exosuit/proc/refresh_hardpoints_menu_hud()
	if(LAZYLEN(pilots))
		for(var/thing in pilots)
			var/mob/pilot = thing
			if(pilot.client)
				if(hardpoints_menu_status == TRUE)
					pilot.client.screen |= hardpoints_menu_elements
				else
					pilot.client.screen -= hardpoints_menu_elements
