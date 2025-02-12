/obj/screen/exosuit/menu_button/eject
	name = "Leave mech"
	icon_state = "eject"

/obj/screen/exosuit/menu_button/eject/activated()
	owner.eject(usr)
	owner.update_big_buttons()
