/obj/screen/exosuit/menu_button/hatch
	name = "Кабина меха"
	icon_state = "hatch"
	button_desc = "Опускает кабину меха вниз. <br> -С поднятой кабиной нельзя пользоваться оборудованием. <br> -С поднятой кабиной персонаж получает урон при попадании по меху <br> -С поднятой кабиной можно взаимодействовать с миром."

/obj/screen/exosuit/menu_button/hatch/activated()
	if(owner.power == MECH_POWER_OFF && !owner.hatch_closed)
		to_chat(usr, SPAN_WARNING("Кабину нельзя закрыть, пока мех не запитан."))
		return
	if(owner.hatch_locked && owner.hatch_closed)
		to_chat(usr, SPAN_WARNING("Нельзя открыть кабину при активном замке (Смотри в меню меха)."))
		return
	if(owner.hatch_closed)
		owner.open_hatch(usr)
	else
		owner.close_hatch(usr)


/obj/screen/exosuit/menu_button/hatch/update()
	if(owner.hatch_closed)
		icon_state = "[initial(icon_state)]_activated"
		toggled = FALSE
	else
		icon_state = initial(icon_state)
		toggled = TRUE


/mob/living/exosuit/proc/open_hatch(mob/living/user)
	hatch_closed = FALSE
	update_big_buttons()
	update_icon()
	need_update_sensor_effects = TRUE
	playsound(src.loc, 'sound/machines/suitstorage_cycledoor.ogg', 50, 1, -6)
	if(user)
		to_chat(user, SPAN_NOTICE("Кабина открыта."))
	if(head && LAZYLEN(pilots))
		for(var/mob/living/carbon/human/thing in pilots)
			SEND_SIGNAL(head, COMSIG_CABINE_OPEN, thing)
			thing.update_inv_head(thing)


/mob/living/exosuit/proc/close_hatch(mob/living/user)
	hatch_closed = TRUE
	update_big_buttons()
	update_icon()
	need_update_sensor_effects = TRUE
	playsound(src.loc, 'sound/machines/suitstorage_cycledoor.ogg', 50, 1, -6)
	if(user)
		to_chat(usr, SPAN_NOTICE("Кабина закрыта."))
	if(head && LAZYLEN(pilots))
		for(var/mob/living/carbon/human/thing in pilots)
			SEND_SIGNAL(head, COMSIG_CABINE_CLOSED, thing)
			thing.update_inv_head(thing)
