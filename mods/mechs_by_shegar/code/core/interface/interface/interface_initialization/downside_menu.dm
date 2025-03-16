/mob/living/exosuit/proc/Initialize_downside_menu()
	var/obj/screen/exosuit/menu_background = new /obj/screen/exosuit/menu_background(src)
	menu_background.icon = 'mods/mechs_by_shegar/icons/main_buttons_back.dmi'
	menu_background.icon_state = "mech_background"
	menu_background.screen_loc = "CENTER-3.25,CENTER-7"
	menu_background.layer = 3.1
	menu_background.mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	downside_menu_elements |= menu_background
	var/i = 0
	for(var/main_button in downside_menu_types)
		var/obj/screen/exosuit/menu_button/spawned = new main_button(src)
		spawned.layer = 3.2
		spawned.screen_loc = "CENTER-[3.25 - i]:16,SOUTH:7" //temp
		downside_menu_elements |= spawned
		i += 0.85
	//Размещаем кнопку управления меню основных кнопок
	downside_menu = new /obj/screen/exosuit/downside_menu(src)
	downside_menu.screen_loc = "CENTER+0.25,SOUTH+0.85"
	downside_menu.open_position = "CENTER+0.25,SOUTH+0.85"
	downside_menu.closed_position = "CENTER:2,SOUTH+0:-10"
	downside_menu.layer = 3.1
	hud_elements |= downside_menu
