/datum/unit_test/tgui_lifecycle
	name = "TGUI: close, logout, transfer and deleted source cleanup"

/datum/tgui_test_host
	var/closed = 0
	var/access_status = STATUS_INTERACTIVE

/datum/tgui_test_host/tgui_status(mob/user, datum/tgui_state/state)
	return access_status

/datum/tgui_test_host/tgui_close(mob/user)
	closed++

// A headless browser boundary: production UI ownership and cleanup still run.
/datum/tgui_window/tgui_test/New()
	status = TGUI_WINDOW_READY

/datum/tgui_window/tgui_test/close(can_be_suspended = TRUE, logout = FALSE)
	release_lock()
	status = TGUI_WINDOW_CLOSED
	message_queue = null

/datum/tgui_window/tgui_refresh_test
	parent_type = /datum/tgui_window/tgui_test
	var/refresh_count = 0

/datum/tgui_window/tgui_refresh_test/reinitialize()
	refresh_count++

/datum/unit_test/tgui_lifecycle/proc/check_manual_refresh()
	var/datum/tgui_test_host/host = new
	var/datum/tgui/ui = new(null, host, "AlertModal")
	var/datum/tgui_window/tgui_refresh_test/window = new
	if(window.refresh_ui() || window.locked || window.refresh_count)
		fail("Manual refresh opened or locked an idle pooled window.")
	window.acquire_lock(ui)
	window.status = TGUI_WINDOW_LOADING
	if(!window.refresh_ui() || window.refresh_count != 1 || window.locked_by != ui)
		fail("Manual refresh did not recover a loading interface with its original owner.")
	ui.closing = TRUE
	if(window.refresh_ui() || window.refresh_count != 1)
		fail("Manual refresh reopened an interface that was closing.")
	qdel(ui)
	if(window.refresh_ui() || window.refresh_count != 1)
		fail("Manual refresh reopened an interface with a deleted owner.")
	window.release_lock()
	qdel(window)
	qdel(host)

/datum/unit_test/tgui_lifecycle/start_test()
	check_manual_refresh()
	var/initial_count = length(SStgui.open_uis)
	var/old_stage = SSatoms.atom_init_stage
	SSatoms.atom_init_stage = INITIALIZATION_INNEW_REGULAR
	var/mob/old_user = new
	var/mob/new_user = new
	SSatoms.atom_init_stage = old_stage
	var/datum/tgui_test_host/host = new
	var/datum/tgui/parent = new(old_user, host, "AlertModal")
	var/list/windows = list()
	parent.window = new /datum/tgui_window/tgui_test
	parent.window.acquire_lock(parent)
	windows += parent.window
	SStgui.on_open(parent)
	for(var/i = 1 to 3)
		var/datum/tgui/child = new(old_user, host, "AlertModal", parent_ui = parent)
		child.window = new /datum/tgui_window/tgui_test
		child.window.acquire_lock(child)
		windows += child.window
		SStgui.on_open(child)
	parent.process_status()
	if(parent.status != STATUS_INTERACTIVE)
		fail("An allowed UI did not become interactive.")
	host.access_status = STATUS_UPDATE
	parent.process_status()
	for(var/datum/tgui/child in parent.children)
		child.process_status()
		if(child.status != STATUS_UPDATE)
			fail("A child retained interaction after the parent lost access.")
	host.access_status = STATUS_CLOSE
	parent.process_status()
	if(parent.status != STATUS_CLOSE)
		fail("Losing access did not mark the UI for closure.")
	if(!SStgui.on_transfer(old_user, new_user) || length(old_user.tgui_open_uis) || length(new_user.tgui_open_uis) != 4)
		fail("Transfer lost or duplicated a UI.")
	SStgui.on_logout(new_user)
	if(length(new_user.tgui_open_uis) || length(SStgui.open_uis) != initial_count || host.closed != 4 || SStgui.open_uis_by_src[TGUI_REF(host)])
		fail("Closing parent and children left a UI registered.")
	for(var/datum/tgui_window/window in windows)
		if(window.locked || window.locked_by)
			fail("A closed UI kept its pooled window locked.")
		qdel(window)
	var/datum/tgui_test_host/deleted_host = new
	var/datum/tgui/deleted_ui = new(new_user, deleted_host, "AlertModal")
	deleted_ui.window = new /datum/tgui_window/tgui_test
	var/datum/tgui_window/deleted_window = deleted_ui.window
	deleted_window.acquire_lock(deleted_ui)
	SStgui.on_open(deleted_ui)
	qdel(deleted_host)
	if(length(new_user.tgui_open_uis) || length(SStgui.open_uis) != initial_count || deleted_window.locked)
		fail("Deleting a source did not release its UI and window.")
	qdel(deleted_window)
	var/datum/tgui/mob_ui = new(old_user, host, "AlertModal")
	mob_ui.window = new /datum/tgui_window/tgui_test
	var/datum/tgui_window/mob_window = mob_ui.window
	mob_window.acquire_lock(mob_ui)
	SStgui.on_open(mob_ui)
	qdel(old_user)
	if(length(SStgui.open_uis) != initial_count || mob_window.locked)
		fail("Deleting the user left its UI registered or locked.")
	qdel(mob_window)
	qdel(host)
	qdel(new_user)
	if(!reported)
		pass("All registrations and window locks released.")
	return TRUE

/datum/unit_test/tgui_inputs
	name = "TGUI: zero, empty text, clipping and duplicate list entries"

/datum/unit_test/tgui_inputs/start_test()
	var/datum/tgui_input_number/number = new(null, "Test", "Test", 0, 100, 0, 0, TRUE, GLOB.tgui_always_state)
	number.set_entry(0)
	if(isnull(number.entry) || number.entry != 0)
		fail("Zero was treated as cancellation.")
	var/datum/tgui_input_text/text = new(null, "Test", "Test", "", 4, FALSE, FALSE, 0, GLOB.tgui_always_state)
	text.set_entry("abcde")
	if(text.entry != "abcd")
		fail("Text length limit lost the final allowed character.")
	text.set_entry("")
	if(isnull(text.entry) || text.entry != "")
		fail("Empty submitted text was treated as cancellation.")
	var/datum/tgui_list_input/choices = new(null, "Test", "Test", list("same", "same", "other"), null, 0, GLOB.tgui_always_state)
	if(length(choices.items) != 3 || length(choices.items_map) != 3)
		fail("Duplicate display names lost a selectable entry.")
	qdel(number)
	qdel(text)
	qdel(choices)
	if(!reported)
		pass("Input edge cases preserved.")
	return TRUE

/datum/unit_test/tgui_message
	name = "TGUI: BYOND message encoding"

/datum/unit_test/tgui_message/start_test()
	var/list/payload = list("quote" = "\"", "unicode" = "тест", "zero" = 0)
	var/message = TGUI_CREATE_MESSAGE("update", payload)
	var/list/decoded = json_decode(url_decode(message))
	if(decoded["type"] != "update" || decoded["payload"]["quote"] != "\"" || decoded["payload"]["unicode"] != "тест" || decoded["payload"]["zero"] != 0)
		fail("Message encoding changed payload content.")
	else
		pass("Encoded messages round trip.")
	return TRUE
