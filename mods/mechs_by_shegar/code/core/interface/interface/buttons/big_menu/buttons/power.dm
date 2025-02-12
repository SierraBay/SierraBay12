/obj/screen/exosuit/menu_button/power
	name = "Toggle power"
	icon_state = "power"
	switchable = TRUE

/obj/screen/exosuit/menu_button/power/switch_on()
	if(!owner.toggle_power(usr))
		return FALSE
	else
		return TRUE

/obj/screen/exosuit/menu_button/power/switch_off()
	if(!owner.toggle_power(usr))
		return FALSE
	else
		return TRUE

/obj/screen/exosuit/menu_button/power/update()
	if(owner.power == MECH_POWER_ON)
		icon_state = "[initial(icon_state)]_activated"
	else if(owner.power == MECH_POWER_OFF)
		icon_state = initial(icon_state)
