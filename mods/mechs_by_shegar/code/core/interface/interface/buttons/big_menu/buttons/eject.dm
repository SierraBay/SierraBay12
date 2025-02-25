/obj/screen/exosuit/menu_button/eject
	name = "Leave mech"
	button_desc = "При нажатии, персонаж покидает меха. Требует время на выход из меха."
	icon_state = "eject"

/obj/screen/exosuit/menu_button/eject/activated()
	owner.eject(usr)
	owner.update_big_buttons()
