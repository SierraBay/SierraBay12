/obj/screen/exosuit/menu_button/maint
	name = "toggle maintenance protocol"
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
