/obj/screen/exosuit/menu_button/megaspeakers
	name = "Use megaspeakers "
	button_desc = "Позволяет громко и чётко говорить с помощью громкоговорителя меха."
	icon_state = "megaspeakers"

/obj/screen/exosuit/menu_button/megaspeakers/activated()
	if (usr.client)
		if(usr.client.prefs.muted & MUTE_IC)
			to_chat(usr, SPAN_WARNING("You cannot speak in IC (muted)."))
			return
	if(owner.power != MECH_POWER_ON)
		to_chat(usr, SPAN_WARNING("The power indicator flashes briefly."))
		return
	if(!(usr in owner.pilots))
		return
	var/message = sanitize(input(usr, "Shout a message?", "Megaphone", null)  as text)
	if(!message)
		return
	message = capitalize(message)
	owner.audible_message("[FONT_GIANT("\ [owner] integrated megaspeaker speaks: [message]\"")]",10)
	runechat_message("[message]")
	return
