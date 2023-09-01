/client
	/// Custom movement keys for this client
	var/list/movement_keys = list()
	/// Are we locking our movement input?
	var/movement_locked = FALSE

	/// A buffer of currently held keys.
	var/list/keys_held = list()
	/// A buffer for combinations such of modifiers + keys (ex: CtrlD, AltE, ShiftT). Format: `"key"` -> `"combo"` (ex: `"D"` -> `"CtrlD"`)
	var/list/key_combos_held = list()
	/*
	** These next two vars are to apply movement for keypresses and releases made while move delayed.
	** Because discarding that input makes the game less responsive.
	*/
	/// On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_add
	/// On next move, subtract this dir from the move that would otherwise be done
	var/next_move_dir_sub
	/// Movement dir of the most recently pressed movement key. Used in cardinal-only movement mode.
	var/last_move_dir_pressed




// Я срал, Глист, на читаемость и отладку
// Это уже протестировано и мы просто ждём пока на оффбей зальют эти кейбинды вонючие
// Ну а если не зальют - так уж и быть, в коркод суну

// SIERRA TODO: ПЕРЕНЕСТИ В КОР КОД ЕСЛИ ОФФЫ НЕ ЗАЛЬЮТ
/client/Topic(href, href_list, hsrc)
	//byond bug ID:2694120
	if(href_list["reset_macros"])
		reset_macros(skip_alert = TRUE)
		return

	. = ..()
