//Controls if cameras set the vision flags
/obj/screen/exosuit/menu_button/camera
	name = "toggle camera matrix"
	icon_state = "sensors"
	button_desc = "Управляет дополнительными визорами меха(Мезоны, тактички, ПНВ) <br>-Потребляет энергию <br>-Выключится при потери камеры"
	switchable = TRUE

/obj/screen/exosuit/menu_button/camera/switch_on()
	if(!owner.head)
		to_chat(usr, SPAN_WARNING("I/O Error: Camera systems not found."))
		return FALSE
	if(!owner.head.vision_flags)
		to_chat(usr,  SPAN_WARNING("Alternative sensor configurations not found. Contact manufacturer for more details."))
		return FALSE
	if(!owner.get_cell())
		to_chat(usr,  SPAN_WARNING("The augmented vision systems are offline."))
		return FALSE
	owner.head.active_sensors = TRUE
	to_chat(usr, SPAN_NOTICE("[owner.head.name] advanced sensor mode is activated."))
	return TRUE

/obj/screen/exosuit/menu_button/camera/switch_off()
	owner.head.active_sensors = FALSE
	to_chat(usr, SPAN_NOTICE("[owner.head.name] advanced sensor mode is deactivated."))
	return TRUE

/obj/screen/exosuit/menu_button/camera/update()
	if(owner.head.active_sensors == TRUE)
		icon_state = "[initial(icon_state)]_activated"
	else if(owner.head.active_sensors == FALSE)
		icon_state = initial(icon_state)
