/mob/living/exosuit
	var/list/menu_hud_elements = list()
	///Статус большого меню (На большую часть экрана игрока)
	var/menu_status = FALSE

//Данная кнопочка покажет на экране игрька большоое меню
/mob/living/exosuit/proc/open_big_menu()
	menu_status = !menu_status
	refresh_big_menu_hud()

//Убирает с экрана/Суёт на экран большое меню
/mob/living/exosuit/proc/refresh_big_menu_hud()
	if(LAZYLEN(pilots))
		for(var/thing in pilots)
			var/mob/pilot = thing
			if(pilot.client)
				update_big_menu_status()
				if(menu_status == TRUE)
					pilot.client.screen |= menu_hud_elements//Врубаем меню худ
				else
					pilot.client.screen -= menu_hud_elements //Вырубаем меню худ

//Обновляет тепло, ХП и энергию меха
/mob/living/exosuit/proc/update_big_menu_status()
	mech_hp.update_hp()
	return

//Задача - обновить состояние больших кнопочек
/mob/living/exosuit/proc/update_big_buttons()
	for(var/obj/screen/exosuit/menu_button/picked_menu_button in menu_hud_elements)
		picked_menu_button.update()
