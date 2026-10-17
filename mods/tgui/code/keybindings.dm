/client/reset_macros(skip_alert = FALSE)
	var/answer
	if(!skip_alert)
		answer = tgui_alert(src, "Change your keyboard language to ENG", "Reset macros")
	if(skip_alert || answer)
		set_macros()
		to_chat(src, SPAN_NOTICE("Keybindings were fixed."))
