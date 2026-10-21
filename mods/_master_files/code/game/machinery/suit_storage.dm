// TGUI
/obj/machinery/suit_storage_unit/tgui_state(mob/user)
	return GLOB.tgui_default_state


/obj/machinery/suit_storage_unit/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SuitStorage", name)
		ui.set_autoupdate(TRUE)
		ui.open()


/obj/machinery/suit_storage_unit/tgui_data(mob/user)
	var/list/data = list()

	data["panel_open"] = panelopen
	data["door_open"] = isopen
	data["locked"] = islocked
	data["uv"] = isUV
	data["super_uv"] = issuperUV
	data["safeties"] = safetieson
	data["helmet"] = helmet?.name
	data["suit"] = suit?.name
	data["boots"] = boots?.name
	data["tank"] = tank?.name
	data["mask"] = mask?.name
	data["occupied"] = !!occupant

	return data


/obj/machinery/suit_storage_unit/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	user.set_machine(src)
	return tgui_interact(user)


/obj/machinery/suit_storage_unit/tgui_act(action, list/params)
	if(..())
		return TRUE
	if(!(action in list("dispense_helmet", "dispense_suit", "dispense_boots", "dispense_tank", "dispense_mask", "toggle_open", "toggle_lock", "start_UV", "toggleUV", "togglesafeties", "eject_guy")))
		return FALSE
	var/list/href_list = list()
	href_list[action] = "1"
	Topic(null, href_list, GLOB.default_state)
	return TRUE
