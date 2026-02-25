/obj/screen/exosuit/menu_button/hatch
	name = "Кабина меха"
	icon_state = "hatch"
	button_desc = "Опускает кабину меха вниз. <br> -С поднятой кабиной нельзя пользоваться оборудованием. <br> -С поднятой кабиной персонаж получает урон при попадании по меху <br> -С поднятой кабиной можно взаимодействовать с миром."
	switchable = TRUE

/obj/screen/exosuit/menu_button/hatch/switch_on()
	if(owner.power == MECH_POWER_OFF)
		to_chat(usr, SPAN_WARNING("Кабину нельзя закрыть, пока мех незапитан."))
		return
	owner.close_hatch(usr)
	to_chat(usr, SPAN_NOTICE("Кабина закрыта."))
	playsound(src.loc, 'sound/machines/suitstorage_cycledoor.ogg', 50, 1, -6)
	owner.update_icon()
	return TRUE

/obj/screen/exosuit/menu_button/hatch/switch_off()
	if(owner.hatch_locked && owner.hatch_closed)
		to_chat(usr, SPAN_WARNING("Нельзя открыть кабину при активном замке (Смотри в меню меха)."))
		return FALSE
	owner.open_hatch(usr)
	playsound(src.loc, 'sound/machines/suitstorage_cycledoor.ogg', 50, 1, -6)
	owner.update_icon()
	return TRUE


/obj/screen/exosuit/menu_button/hatch/update()
	if(owner.hatch_closed)
		icon_state = "[initial(icon_state)]_activated"
	else
		icon_state = initial(icon_state)


/mob/living/exosuit/proc/open_hatch(mob/living/user)
	hatch_closed = FALSE
	update_icon()
	update_big_buttons()
	need_update_sensor_effects = TRUE
	playsound(src.loc, 'sound/machines/suitstorage_cycledoor.ogg', 50, 1, -6)
	if(user)
		to_chat(user, SPAN_NOTICE("Кабина открыта."))

/mob/living/exosuit/proc/close_hatch(mob/living/user)
	hatch_closed = TRUE
	update_icon()
	update_big_buttons()
	need_update_sensor_effects = TRUE
	playsound(src.loc, 'sound/machines/suitstorage_cycledoor.ogg', 50, 1, -6)
	if(user)
		to_chat(usr, SPAN_NOTICE("Кабина закрыта."))
