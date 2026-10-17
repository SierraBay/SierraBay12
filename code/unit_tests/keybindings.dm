// Ported from Nebula #5446: Focus Chat defaults must leave text input usable.
/datum/unit_test/default_focus_chat_keys_shall_be_unprintable
	name = "INPUT: Focus Chat defaults shall be unprintable"


/datum/unit_test/default_focus_chat_keys_shall_be_unprintable/start_test()
	var/list/failures = list()
	for(var/binding_name in global.keybindings_by_name)
		var/datum/keybinding/binding = global.keybindings_by_name[binding_name]
		for(var/key in binding.classic_keys)
			if(key != "None" && key != "Unbound" && SSinput.is_printable_key(key))
				failures += "[binding.type]: [key]"
	if(length(failures))
		fail("Printable Focus Chat defaults: [jointext(failures, ", ")]")
	else
		pass("All Focus Chat default keys leave printable input available.")
	return TRUE


/datum/unit_test/legacy_shift_keybindings_shall_be_preserved
	name = "INPUT: Legacy Shift bindings shall be preserved"


/datum/unit_test/legacy_shift_keybindings_shall_be_preserved/start_test()
	var/list/bindings = sanitize_keybindings(list(
		"shift" = list("moving_quickly"),
		"Shift" = list("moving_quickly"),
		"W" = list("North")
	))
	if(bindings["shift"] || !(bindings["Shift"] ~= list("moving_quickly")) || !(bindings["W"] ~= list("North")))
		fail("Normalizing legacy Shift lost or duplicated a saved keybinding.")
	else
		pass("Legacy Shift and custom movement bindings were preserved.")
	return TRUE


// [SIERRA-ADD] Preserve bindings captured under different browser key names.
/datum/unit_test/space_keybindings_shall_be_normalized
	name = "INPUT: Space bindings shall be normalized"


/datum/unit_test/space_keybindings_shall_be_normalized/start_test()
	var/list/bindings = sanitize_keybindings(list(
		" " = list("North"),
		"Spacebar" = list("North"),
		"Space" = list("North")
	))
	if(length(bindings) != 1 || !(bindings["Space"] ~= list("North")))
		fail("Space aliases lost or duplicated a saved keybinding.")
	else
		pass("Space aliases were normalized without losing bindings.")
	return TRUE
// [SIERRA-ADD] End.
