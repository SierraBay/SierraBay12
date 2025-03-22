/mob/living/exosuit/proc/Initialize_downside_menu()
	var/i = 0
	for(var/main_button in downside_menu_types)
		var/obj/screen/exosuit/menu_button/spawned = new main_button(src)
		i += 0.5
		spawned.layer = 3.2
		spawned.screen_loc = "WEST+0.2, CENTER-[0.25 - i]"
		downside_menu_elements |= spawned
	//Размещаем кнопку управления меню основных кнопок
	downside_menu = new /obj/screen/exosuit/downside_menu(src)
	downside_menu.screen_loc = "WEST+0.2,CENTER-0.25"
	downside_menu.open_position = "WEST+0.2,CENTER-0.25"
	downside_menu.closed_position = "WEST+0.2,CENTER-0.25"
	downside_menu.layer = 3.1
	hud_elements |= downside_menu
