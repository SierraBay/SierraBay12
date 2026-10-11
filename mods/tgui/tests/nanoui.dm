/datum/unit_test/tgui_nanoui
	name = "TGUI: NanoUI adapter payload, transfer and source cleanup"

/datum/unit_test/tgui_nanoui/start_test()
	var/old_stage = SSatoms.atom_init_stage
	SSatoms.atom_init_stage = INITIALIZATION_INNEW_REGULAR
	var/mob/old_user = new
	var/mob/new_user = new
	SSatoms.atom_init_stage = old_stage
	var/datum/tgui_test_host/host = new
	var/initial_count = length(SStgui.open_uis)
	var/list/windows = list()
	for(var/i = 1 to 3)
		var/datum/nanoui/nano = new(old_user, host, "test-[i]", "layout_default.tmpl", "Test", 600, 500)
		nano.set_initial_data(list("count" = i))
		var/list/data = nano.tgui_data(old_user)
		var/list/payload = data["nanoData"]
		var/list/nano_data = payload["data"]
		var/list/html = nano.tgui_static_data(old_user)
		if(length(nano.ui_assets(old_user)))
			fail("NanoUI libraries must not auto-load into the parent TGUI page.")
		if(nano_data["count"] != i || !findtext(html["html"], "receiveUpdateData") || !findtext(html["html"], TGUI_REF(nano)))
			fail("NanoUI payload or its original Topic reference was lost.")
		nano.tgui_ui = new(old_user, nano, "NanoUI")
		nano.tgui_ui.window = new /datum/tgui_window/tgui_test
		nano.tgui_ui.window.acquire_lock(nano.tgui_ui)
		windows += nano.tgui_ui.window
		SStgui.on_open(nano.tgui_ui)
		SSnano.ui_opened(nano)
	SSnano.user_transferred(old_user, new_user)
	if(length(old_user.open_uis) || length(old_user.tgui_open_uis) || length(new_user.open_uis) != 3 || length(new_user.tgui_open_uis) != 3)
		fail("NanoUI and TGUI ownership diverged on mob transfer.")
	qdel(host)
	if(length(new_user.open_uis) || length(new_user.tgui_open_uis) || length(SStgui.open_uis) != initial_count)
		fail("Deleting a NanoUI source left a registered interface.")
	for(var/datum/tgui_window/window in windows)
		if(window.locked || window.locked_by)
			fail("Closing a NanoUI adapter left its TGUI window locked.")
		qdel(window)
	qdel(old_user)
	qdel(new_user)
	if(!reported)
		pass("Legacy payloads and both UI registries remain consistent.")
	return TRUE
