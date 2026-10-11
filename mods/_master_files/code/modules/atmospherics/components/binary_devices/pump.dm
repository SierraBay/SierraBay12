// TGUI
/obj/machinery/atmospherics/binary/pump/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Pump", name)
		ui.open()


/obj/machinery/atmospherics/binary/pump/tgui_data(mob/user)
	var/list/data = list()

	data["on"] = use_power
	data["pressure_set"] = round(target_pressure)
	data["max_pressure"] = max_pressure_setting
	data["last_flow_rate"] = round(last_flow_rate)
	data["last_power_draw"] = round(last_power_draw)
	data["max_power_draw"] = power_rating

	return data


/obj/machinery/atmospherics/binary/pump/tgui_state(mob/user)
	return GLOB.tgui_default_state


/obj/machinery/atmospherics/binary/pump/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE, datum/nanoui/master_ui = null, datum/topic_state/state = GLOB.default_state)
	user.set_machine(src)
	return tgui_interact(user)

/obj/machinery/atmospherics/binary/pump/tgui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("power")
			update_use_power(!use_power)
		if("min")
			target_pressure = 0
		if("max")
			target_pressure = max_pressure_setting
		if("set")
			var/new_pressure = text2num(params["rate"])
			if(isnull(new_pressure))
				return FALSE
			target_pressure = clamp(new_pressure, 0, max_pressure_setting)
		else
			return FALSE
	update_icon()
	return TRUE
