/mob/living/exosuit
	///Статус меню вооружения. По умолчанию включено
	var/hardpoints_menu_status = TRUE
	var/list/hardpoints_menu_elements = list() //Список всех кнопачек хардпоинтов
	var/obj/screen/exosuit/hardpoints_menu/hardpoints_menu

//Далеко не всегда игроку нужно смотреть на свои орудия, а места они занимают много, и важное
//В активном состоянии все орудия будут показаны, в скрытом - скрыты. Всё просто.
/obj/screen/exosuit/hardpoints_menu
	name = "hardpoints menu"
	icon_state = "context_menu_open"
	var/open_position
	var/closed_position

/obj/screen/exosuit/hardpoints_menu/Click()
	owner.toggle_hardpoints_menu()

//Данная кнопочка покажет на экране игрька большоое меню
/mob/living/exosuit/proc/toggle_hardpoints_menu()
	if(hardpoints_menu_status) //Закрыть меню
		hardpoints_menu_status = FALSE
		hardpoints_menu.icon_state = "context_menu_closed"
		hardpoints_menu.screen_loc = hardpoints_menu.closed_position
	else
		hardpoints_menu_status = TRUE
		hardpoints_menu.icon_state = "context_menu_open"
		hardpoints_menu.screen_loc = hardpoints_menu.open_position
	refresh_hardpoints_menu_hud()

/mob/living/exosuit/proc/refresh_hardpoints_menu_hud()
	if(LAZYLEN(pilots))
		for(var/thing in pilots)
			var/mob/pilot = thing
			if(pilot.client)
				if(hardpoints_menu_status)
					for(var/picked_hardpoint in hardpoint_hud_elements)
						var/obj/screen/movable/exosuit/hardpoint/hardpoint_screen_obj = hardpoint_hud_elements[picked_hardpoint]
						pilot.client.screen |= hardpoint_screen_obj
						if(hardpoint_screen_obj.holding)
							pilot.client.screen |= hardpoint_screen_obj.holding
				else
					for(var/picked_hardpoint in hardpoint_hud_elements)
						var/obj/screen/movable/exosuit/hardpoint/hardpoint_screen_obj = hardpoint_hud_elements[picked_hardpoint]
						pilot.client.screen -= hardpoint_screen_obj
						if(hardpoint_screen_obj.holding)
							pilot.client.screen -= hardpoint_screen_obj.holding
