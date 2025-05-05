/obj/screen/exosuit/menu_button/radio
	name = "Связь"
	button_desc = "Позволяет использовать внутреннюю систему связи меха."
	icon_state = "radio"

/obj/screen/exosuit/menu_button/radio/activated()
	if(owner.radio)
		owner.radio.attack_self(usr)
	else
		to_chat(usr, SPAN_WARNING("There is no radio installed."))
