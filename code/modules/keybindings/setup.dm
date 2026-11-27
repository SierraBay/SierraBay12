// Set a client's focus to an object and override these procs on that object to let it handle keypresses

/datum/proc/key_down(key, client/user) // Called when a key is pressed down initially
	return


/datum/proc/key_up(key, client/user) // Called when a key is released
	return


/datum/proc/keyLoop(client/user) // Called once every frame
	set waitfor = FALSE
	return


// removes all the existing macros
/client/proc/erase_all_macros()
	var/erase_output = ""
	var/list/macro_set = params2list(winget(src, "default.*", "command")) // The third arg doesnt matter here as we're just removing them all
	for(var/k in 1 to length(macro_set))
		var/list/split_name = splittext(macro_set[k], ".")
		if(split_name[2] in SSinput.protected_macro_ids)
			continue
		var/macro_name = "[split_name[1]].[split_name[2]]" // [3] is "command"
		erase_output = "[erase_output];[macro_name].parent=null"
	winset(src, null, erase_output)


/client/proc/set_macros()
	set waitfor = FALSE
	if(updating_macros)
		macros_update_queued = TRUE
		return
	if(!SSinput.core_macro_set || !prefs?.key_bindings)
		return
	updating_macros = TRUE
	reset_held_keys()
	erase_all_macros()
	install_macro_set(SSinput.core_macro_set, "shared")
	install_macro_set(SSinput.modifier_set, "modifier")
	install_personal_macros()
	update_special_keybinds()
	update_hotkey_mode()
	updating_macros = FALSE
	if(macros_update_queued)
		macros_update_queued = FALSE
		addtimer(new Callback(src, PROC_REF(set_macros)), 1)


/client/proc/install_macro_set(list/macro_set, prefix)
	for(var/key in macro_set)
		install_key_macro("[prefix]-\ref[key]", key, macro_set[key])


/client/proc/install_key_macro(macro_id, key, command)
	winset(src, "default.[macro_id]", list2params(list("parent" = "default", "name" = key, "command" = command)))


/client/proc/install_personal_macros()
	var/list/printables = list()
	for(var/key in prefs.key_bindings)
		if(key == "None" || key == "Unbound")
			continue
		var/keycode = SSinput.get_keycode(key)
		if(!length(keycode) || SSinput.core_macro_set[keycode])
			continue
		if(!prefs.hotkeys && SSinput.is_printable_key(key))
			printables += key
			continue
		install_key_macro("personal-\ref[keycode]", keycode, "KeyDown \"[keycode]\"")
		install_key_macro("personal-\ref[keycode]-UP", "[keycode]+UP", "KeyUp \"[keycode]\"")
	if(length(printables) && prefs.focus_chat_hotkey_nag)
		to_chat(src, SPAN_NOTICE("Focus Chat ignores printable hotkeys: [jointext(printables, ", ")]. You can disable this warning in Controls preferences."))


// byond bug ID:2694120
/client/verb/reset_macros_wrapper()
	set category = "OOC"
	set name = "Fix Keybindings"

	reset_macros()


/client/proc/reset_macros(skip_alert = FALSE)
	var/answer
	if(!skip_alert)
		answer = alert(src, "Change your keyboard language to ENG", "Reset macros")
	if(skip_alert || answer)
		set_macros()
		to_chat(src, SPAN_NOTICE("Keybindings were fixed."))


/**
 * Manually clears any held keys, in case due to lag or other undefined behavior a key gets stuck.
 *
 * Hardcoded to the ESC key.
 */
/client/verb/reset_held_keys()
	set name = "Reset Held Keys"
	set hidden = TRUE

	for(var/key in keys_held)
		keyUp(key)

	//In case one got stuck and the previous loop didn't clean it, somehow.
	for(var/key in key_combos_held)
		keyUp(key_combos_held[key])
