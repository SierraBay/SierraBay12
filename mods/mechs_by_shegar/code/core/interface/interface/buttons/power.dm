/obj/screen/movable/exosuit/power
	name = "power"
	icon_state = null
	maptext_width = 64

/obj/screen/movable/exosuit/toggle/power_control
	name = "Power control"
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("POWER")
	maptext_x = 3
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/power_control/toggled()
	. = ..()
	owner.toggle_power(usr)

/obj/screen/movable/exosuit/toggle/power_control/on_update_icon()
	toggled = (owner.power == MECH_POWER_ON)
	. = ..()



/obj/screen/movable/exosuit/toggle/power_control/Click(location, control, params)
	var/mod_modifiers = params2list(params)
	if(mod_modifiers["alt"])
		//owner.fast_toggle_power(usr)
		owner.update_icon()
		return
	if(owner.overheat && owner.power != MECH_POWER_ON)
		to_chat(usr, "Overheat detected, safe protocol active.")
		return
	.=..()
