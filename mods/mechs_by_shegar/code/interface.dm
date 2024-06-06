#define MECH_UI_STYLE(X) "<span style=\"font-family: 'Small Fonts'; -dm-text-outline: 1 black; font-size: 5px;\">" + X + "</span>"

/obj/screen/movable/exosuit/toggle/menu
	name = "toggle mech menu "
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("MENU")
	maptext_x = 6
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/menu/toggled()
	owner.menu_status = !owner.menu_status
	owner.refresh_menu_hud()

/obj/screen/movable/exosuit/toggle/megaspeakers
	name = "Use megaspeakers "
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("SPEAK")
	maptext_x = 4
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/megaspeakers/toggled()
	if (usr.client)
		if(usr.client.prefs.muted & MUTE_IC)
			to_chat(usr, SPAN_WARNING("You cannot speak in IC (muted)."))
			return

	var/message = sanitize(input(usr, "Shout a message?", "Megaphone", null)  as text)
	if(!message)
		return
	message = capitalize(message)
	owner.visible_message("[FONT_GIANT("\"[]\"")]",10)
	owner.visible_message("[FONT_GIANT("\"[owner] integrated megaspeaker speaks: [message]\"")]",10)
	owner.visible_message("[FONT_GIANT("\"[]\"")]",10)
	return

/obj/screen/movable/exosuit/toggle/gps
	name = "Use integrated GPS"
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("GPS")
	maptext_x = 6
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/gps/toggled()
	owner.GPS.attack_self(usr)

/obj/screen/movable/exosuit/toggle/medscan
	name = "Full scan pilot"
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("PLTSCN")
	maptext_x = 2
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/medscan/toggled()
	owner.medscan.scan(usr,usr)
	roboscan(usr,usr)



/mob/living/exosuit/proc/get_main_data(mob/user)
	to_chat(user, SPAN_NOTICE("Main mech integrity: <b> [health]/[maxHealth]([((health/maxHealth)*100)]%) </b>"))
