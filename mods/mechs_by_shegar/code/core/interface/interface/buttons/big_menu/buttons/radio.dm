/obj/screen/exosuit/menu_button/radio
	name = "Связь"
	button_desc = "Кнопка запускает питание меха. <br> В случае перегрева и при нажатии Alt + ЛКМ, мех аварийно запускается <br> WARNING: Мех начинает греться сильнее от разных источников, а при повторном перегреве взорвётся."
	icon_state = "radio"

/obj/screen/exosuit/menu_button/radio/activated()
	if(owner.radio)
		owner.radio.attack_self(usr)
	else
		to_chat(usr, SPAN_WARNING("There is no radio installed."))
