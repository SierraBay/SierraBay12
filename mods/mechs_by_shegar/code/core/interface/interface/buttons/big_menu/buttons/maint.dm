/obj/screen/exosuit/menu_button/maint
	name = "Режим обслуживания"
	button_desc = "Режим технического обслуживания меха. <br> -Требуется для внешнего снятия оборудоваиня <br> -Требуется для установки оборудования <br> -Требуется для разборки ключом меха. <br> -Требуется для доставания отвёртой батареи."
	icon_state = "maint"
	switchable = TRUE

/obj/screen/exosuit/menu_button/maint/switch_on()
	owner.maintenance_protocols = TRUE
	to_chat(usr, SPAN_NOTICE("Maintenance protocols enabled."))
	playsound(src.loc, 'sound/machines/suitstorage_lockdoor.ogg', 50, 1, -6)
	return TRUE

/obj/screen/exosuit/menu_button/maint/switch_off()
	owner.maintenance_protocols = FALSE
	to_chat(usr, SPAN_NOTICE("Maintenance protocols disabled."))
	playsound(src.loc, 'sound/machines/suitstorage_lockdoor.ogg', 50, 1, -6)
	return TRUE
