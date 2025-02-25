/mob/living/exosuit
	var/list/menu_hud_elements = list()
	///Статус большого меню (На большую часть экрана игрока)
	var/menu_status = FALSE

//Данная кнопочка покажет на экране игрька большоое меню
/mob/living/exosuit/proc/open_big_menu()
	menu_status = !menu_status
	refresh_menu_hud()


//Обновляет тепло, ХП и энергию меха
/mob/living/exosuit/proc/update_big_menu_status()
	return

//Задача - обновить состояние больших кнопочек
/mob/living/exosuit/proc/update_big_buttons()
	for(var/obj/screen/exosuit/menu_button/picked_menu_button in menu_hud_elements)
		picked_menu_button.update()
	for(var/obj/screen/exosuit/menu_button/picked_menu_button in downside_menu_elements)
		picked_menu_button.update()
