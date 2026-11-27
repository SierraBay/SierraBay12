SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	init_order = SS_INIT_INPUT
	flags = SS_TICKER
	priority = SS_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	/// Fixed commands and modifier macros, independent of personal bindings.
	var/list/core_macro_set
	var/list/modifier_set
	var/list/protected_macro_ids = list("PROTECTED-Shift", "PROTECTED-ShiftUp")
	var/list/unprintables_cache
	var/list/warn_keys = list(
		"C" = "Can interfere with copying text from the chatbox.",
		"V" = "Can interfere with pasting text into the chatbox."
	)
	var/list/blacklisted_keys = list(
		"Back" = "Reserved for clearing the command input.",
		"Tab" = "Reserved for toggling hotkey mode.",
		"Escape" = "Reserved for releasing held keys."
	)


/datum/controller/subsystem/input/Initialize()
	setup_default_macro_sets()
	refresh_client_macro_sets()
	return ..()


// This is for when macro sets are eventualy datumized
/datum/controller/subsystem/input/proc/setup_default_macro_sets()
	// Ported from Nebula #5446: capture only bound keys, never Any/Any+UP.
	core_macro_set = list(
		"Back" = ".winset \"outputwindow.input.text=\"\"\"",
		"Tab" = "ToggleHotkeyMode",
		"Escape" = "Reset-Held-Keys"
	)
	modifier_set = list(
		"Alt" = "KeyDown Alt",
		"Alt+UP" = "KeyUp Alt",
		"Ctrl" = "KeyDown Ctrl",
		"Ctrl+UP" = "KeyUp Ctrl"
	)
	setup_unprintable_keys()


/datum/controller/subsystem/input/proc/setup_unprintable_keys()
	unprintables_cache = list(
		"Shift", "Ctrl", "Alt", "North", "West", "East", "South",
		"Northwest", "Northeast", "Center", "Southwest", "Southeast",
		"Return", "Escape", "Delete", "Select", "Execute", "Snapshot",
		"Attn", "CrSel", "ExSel", "ErEOF", "Zoom", "PA1", "OEMClear",
		"Pause", "Play", "Insert", "Help", "LWin", "RWin", "Apps",
		"Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4",
		"Numpad5", "Numpad6", "Numpad7", "Numpad8", "Numpad9",
		"Multiply", "Add", "Separator", "Subtract", "Decimal", "Divide"
	)
	for(var/key in unprintables_cache)
		unprintables_cache[key] = TRUE
	for(var/index in 1 to 24)
		unprintables_cache["F[index]"] = TRUE


/datum/controller/subsystem/input/proc/get_keycode(key)
	var/static/regex/modifiers = regex("^(Alt)?(Ctrl)?(Shift)?")
	return replacetext(key, modifiers, "")


/datum/controller/subsystem/input/proc/is_printable_key(key)
	var/keycode = get_keycode(key)
	return length(keycode) && !unprintables_cache[keycode]


// Badmins just wanna have fun ♪
/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	for(var/client/C in GLOB.clients)
		C.set_macros()


/datum/controller/subsystem/input/fire()
	for(var/client/C in GLOB.clients)
		C.keyLoop()
