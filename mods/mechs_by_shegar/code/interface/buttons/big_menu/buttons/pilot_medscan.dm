/obj/screen/exosuit/menu_button/medscan
	name = "Full scan pilot"
	icon_state = "pilotscan"

/obj/screen/exosuit/menu_button/medscan/activated()
	owner.medscan.scan(usr,usr)
	roboscan(usr,usr)
