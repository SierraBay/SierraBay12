/obj/screen/exosuit/menu_button/rename
	name = "rename"
	icon_state = "rename"


/obj/screen/exosuit/menu_button/rename/activated()
	owner.rename(usr)
