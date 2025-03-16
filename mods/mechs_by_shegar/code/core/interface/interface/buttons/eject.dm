/obj/screen/movable/exosuit/eject
	name = "eject"
	maptext = MECH_UI_STYLE("EJECT")
	maptext_x = 5
	maptext_y = 12

/obj/screen/movable/exosuit/eject/Click()
	owner.eject(usr)

