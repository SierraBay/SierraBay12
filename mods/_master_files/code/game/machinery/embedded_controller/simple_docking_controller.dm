// The donor frontend has no server handler; retain Sierra's docking program.
/obj/machinery/embedded_controller/radio/simple_docking_controller/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE, datum/nanoui/master_ui = null, datum/topic_state/state = GLOB.default_state)
	return tgui_interact(user)

/obj/machinery/embedded_controller/radio/simple_docking_controller/tgui_interact(mob/user, datum/tgui/ui)
	if(!istype(program, /datum/computer/file/embedded_program/docking/simple))
		return FALSE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SimpleDockingConsole", name)
		ui.open()

/obj/machinery/embedded_controller/radio/simple_docking_controller/tgui_data(mob/user)
	var/datum/computer/file/embedded_program/docking/simple/docking_program = program
	if(!istype(docking_program))
		return list()
	return list("docking_status" = docking_program.get_docking_status(), "override_enabled" = docking_program.override_enabled, "door_state" = docking_program.memory["door_status"]["state"], "door_lock" = docking_program.memory["door_status"]["lock"])

/obj/machinery/embedded_controller/radio/simple_docking_controller/tgui_act(action, list/params)
	if(..())
		return TRUE
	if(!(action in list("force_door", "toggle_override")))
		return FALSE
	Topic(null, list("command" = action), GLOB.default_state)
	return TRUE
