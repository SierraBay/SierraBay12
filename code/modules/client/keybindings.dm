/**
 * Updates the keybinds for special keys
 *
 * Handles adding macros for the keys that need it
 * And adding movement keys to the clients movement_keys list
 * At the time of writing this, communication(OOC, Say, IC) require macros
 * Arguments:
 * * direct_prefs - the preference we're going to get keybinds from
 */
/client/proc/update_special_keybinds(datum/preferences/direct_prefs)
	var/datum/preferences/D = prefs || direct_prefs
	if(!D?.key_bindings)
		return
	movement_keys = list()
	for(var/key in D.key_bindings)
		if(key == "None" || key == "Unbound" || (!D.hotkeys && SSinput.is_printable_key(key)))
			continue
		if(SSinput.core_macro_set[SSinput.get_keycode(key)])
			continue
		for(var/kb_name in D.key_bindings[key])
			switch(kb_name)
				if("North")
					movement_keys[key] = NORTH
				if("East")
					movement_keys[key] = EAST
				if("West")
					movement_keys[key] = WEST
				if("South")
					movement_keys[key] = SOUTH
				if("Say")
					install_key_macro("personal-\ref[key]", key, "say")
				if("OOC")
					install_key_macro("personal-\ref[key]", key, "ooc")
				if("Me")
					install_key_macro("personal-\ref[key]", key, "me")


/client/verb/ToggleHotkeyMode()
	set hidden = TRUE
	if(!prefs)
		return
	prefs.hotkeys = !prefs.hotkeys
	set_macros()


/client/proc/update_hotkey_mode()
	if(!prefs)
		return
	winset(src, "mainwindow.mainwindow", "macro=default")
	if (prefs.hotkeys)
		// If hotkey mode is enabled, then clicking the map will automatically
		// unfocus the text bar. This removes the red color from the text bar
		// so that the visual focus indicator matches reality.
		winset(src, "mapwindow.map", "focus=true")
		winset(src, "outputwindow.hotkeytoggle", "is-checked=true")
		if (prefs.dark_theme)
			winset(src, "outputwindow.input", "background-color = #ffffff; background-color = [COLOR_DARKMODE_BACKGROUND]")
			winset(src, "outputwindow.input", "text-color = #000000; text-color = [COLOR_DARKMODE_TEXT]")
		else
			winset(src, "outputwindow.input", "background-color = [COLOR_DARKMODE_BACKGROUND]; background-color = #ffffff")
			winset(src, "outputwindow.input", "text-color = [COLOR_DARKMODE_TEXT]; text-color = #000000")
	else
		winset(src, "outputwindow.hotkeytoggle", "is-checked=false")
		winset(src, "outputwindow.input", "focus=true")
		winset(src, "outputwindow.input", "text-color = #000000; background-color = #d3b5b5")
