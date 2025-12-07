//У кнопок есть свои шорткаты, - маленькая кнопкушка в меню слева.
//Создаётся при нажатии СКМ по кнопке в меню меха
/mob/living/exosuit
	var/list/shortcut_buttons = list()

/obj/screen/movable/exosuit/shortcut_button
	var/obj/screen/exosuit/menu_button/memored_menu_button
	icon = 'mods/mechs_by_shegar/icons/shortcut_buttons.dmi'

/mob/living/exosuit/proc/try_create_new_shortcut_button(input_button, mob/user)
	for(var/obj/screen/movable/exosuit/shortcut_button/short in shortcut_buttons)
		if(short.memored_menu_button == input_button)
			to_chat(user, SPAN_NOTICE("Такая быстрая кнопка в мехе уже есть."))
			return FALSE
	create_new_shortcut_button(input_button, user)

/mob/living/exosuit/proc/create_new_shortcut_button(obj/screen/exosuit/menu_button/input_button, mob/user)
	var/obj/screen/movable/exosuit/shortcut_button/created_button = new /obj/screen/movable/exosuit/shortcut_button(src)
	close_main_buttons()
	downside_menu_elements -= shortcut_buttons
	LAZYADD(shortcut_buttons, created_button)
	downside_menu_elements += shortcut_buttons
	open_main_buttons()
	created_button.connect_shortcut_to_button(input_button)
	created_button.name = input_button.name
	created_button.icon_state = initial(input_button.icon_state)
	update_shortcut_button_positions()

/mob/living/exosuit/proc/delete_shortcut_button(obj/screen/movable/exosuit/shortcut_button/input_shortcut)
	close_main_buttons()
	downside_menu_elements -= shortcut_buttons
	LAZYREMOVE(shortcut_buttons, input_shortcut)
	downside_menu_elements += shortcut_buttons
	open_main_buttons()
	input_shortcut.disconnect_shortcut_and_button()
	qdel(input_shortcut)
	update_shortcut_button_positions()

/mob/living/exosuit/proc/update_shortcut_button_positions()
	var/y_offset = 0
	var/i = 0
	for(var/obj/screen/movable/exosuit/shortcut_button/picked_button in shortcut_buttons)
		var/offset_x = 0
		var/second_y_offset = 0
		var/main_size = LAZYLEN(downside_menu_elements) - LAZYLEN(shortcut_buttons)
		if(main_size < i)
			offset_x = 0.5
			second_y_offset = 0.5 * main_size + 0.5
		picked_button.screen_loc = "WEST+1.25+[offset_x], CENTER-0.525-[y_offset] + [second_y_offset]"
		y_offset += 0.5
		i++
	//Если мелкое меню меха активно - просим его обновиться вот таким способом


/obj/screen/movable/exosuit/shortcut_button/proc/connect_shortcut_to_button(input_button)
	memored_menu_button = input_button
	memored_menu_button.shortcut_button = src

/obj/screen/movable/exosuit/shortcut_button/proc/disconnect_shortcut_and_button()
	if(memored_menu_button)
		if(memored_menu_button.shortcut_button)
			memored_menu_button.shortcut_button = null
		memored_menu_button = null

/obj/screen/movable/exosuit/shortcut_button/Click(location, control, params)
	var/modifiers = params2list(params)
	if(modifiers["middle"])
		owner.delete_shortcut_button(src)
		return
	if(memored_menu_button)
		memored_menu_button.Click(location, control, params)
