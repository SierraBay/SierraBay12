/obj/screen/exosuit/menu_button
	icon = 'mods/mechs_by_shegar/icons/menu_buttons.dmi'
	//Кнопка переключаемая, а не просто нажимаемая
	var/switchable = FALSE
	var/toggled = FALSE
	maptext_x = 9
	maptext_y = 13
	height = 32


/obj/screen/exosuit/menu_button/proc/update()
	return

/obj/screen/exosuit/menu_button/Click(location, control, params)
	var/modifiers = params2list(params)
	if(modifiers["shift"])
		shift_press()
		return
	else if(modifiers["alt"])
		alt_press()
		return
	else if(modifiers["ctrl"])
		ctrl_press()
		return
	toggle_button()

/obj/screen/exosuit/menu_button/proc/activated()
	return

/obj/screen/exosuit/menu_button/proc/toggle_button()
	press_animation()//Нажмём кнопку
	if(switchable)
		if(!toggled)
			if(!switch_on())
				return
		else
			if(!switch_off())
				return
	change_icon_state()
	activated()

/obj/screen/exosuit/menu_button/proc/switch_off()
	return

/obj/screen/exosuit/menu_button/proc/switch_on()
	return

/obj/screen/exosuit/menu_button/proc/shift_press()
	press_animation(modificator_press = FALSE)

/obj/screen/exosuit/menu_button/proc/alt_press()
	press_animation(modificator_press = FALSE)

/obj/screen/exosuit/menu_button/proc/ctrl_press()
	press_animation(modificator_press = FALSE)

///Кнопку нажали, как рисовать - пусть думает функция
/obj/screen/exosuit/menu_button/proc/press_animation(modificator_press = FALSE)
	flick("[initial(icon_state)]_press", src)

	//Здесь звук нажатия. Работает для всех нажатий


/obj/screen/exosuit/menu_button/proc/change_icon_state()
	if(switchable)
		if(!toggled)
			icon_state = "[icon_state]_activated"
			toggled = TRUE
		else
			icon_state = initial(icon_state)
			toggled = FALSE
