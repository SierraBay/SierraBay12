// TGUI
/obj/machinery/disposal/tgui_state(mob/user)
	return GLOB.tgui_default_state


/obj/machinery/disposal/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DisposalBin", name)
		ui.open()


/obj/machinery/disposal/tgui_data(mob/user)
	var/list/data = list()

	data["isAI"] = isAI(user)
	data["flushing"] = flush
	data["mode"] = mode
	data["pressure"] = round(clamp(100* air_contents.return_pressure() / (SEND_PRESSURE), 0, 100),1)

	return data


/obj/machinery/disposal/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE, datum/nanoui/master_ui = null, datum/topic_state/state = GLOB.default_state)
	user.set_machine(src)
	return tgui_interact(user)

/obj/machinery/disposal/interact(mob/user)
	return ui_interact(user)

/obj/machinery/disposal/tgui_act(action, list/params)
	if(..())
		return
	var/list/href_list = list()
	switch(action)
		if("eject")
			href_list["eject"] = "1"
		if("mode")
			href_list["pump"] = mode >= 1 ? "0" : "1"
		if("flush")
			href_list["handle"] = flush ? "0" : "1"
		else
			return FALSE
	// Sierra checks flushing, disabled pumps, AI reach and users inside the bin.
	Topic("", href_list)
	return TRUE
