/obj/screen/exosuit/menu_button/power
	name = "Энергия"
	button_desc = "Кнопка запускает питание меха. <br> В случае перегрева и при нажатии Alt + ЛКМ, мех аварийно запускается <br> WARNING: Мех начинает греться сильнее от разных источников, а при повторном перегреве взорвётся."
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


/obj/screen/exosuit/menu_button/power/Click(location, control, params)
	press_animation()
	var/mod_modifiers = params2list(params)
	if(mod_modifiers["alt"])
		owner.emergency_toggle_power(usr)
		owner.update_icon()
		return
	if(owner.overheat && owner.power != MECH_POWER_ON)
		to_chat(usr, "Overheat detected, safe protocol active.")
		return
	.=..()
