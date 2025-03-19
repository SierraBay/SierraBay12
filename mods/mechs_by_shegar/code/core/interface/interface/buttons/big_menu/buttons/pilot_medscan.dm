/obj/screen/exosuit/menu_button/medscan
	name = "Full scan pilot"
	button_desc = "Анализирует состояние пилота <br> -Выводит результаты медицинского сканера. <br> -Выводит результаты робо сканера."
	icon_state = "pilotscan"

/obj/screen/exosuit/menu_button/medscan/activated()
	owner.medscan.scan(usr,usr)
	roboscan(usr,usr)
