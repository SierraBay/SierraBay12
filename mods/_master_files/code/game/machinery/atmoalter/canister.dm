// TGUI
/obj/machinery/portable_atmospherics/canister/tgui_state(mob/user)
	return GLOB.tgui_default_state


/obj/machinery/portable_atmospherics/canister/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canister", name)
		ui.open()


/obj/machinery/portable_atmospherics/canister/tgui_data(mob/user)
	var/list/data = list()

	data["name"] = name
	data["portConnected"] = !!connected_port
	data["canLabel"] = can_label
	data["valveOpen"] = valve_open
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["hasHoldingTank"] = holding ? TRUE : FALSE
	if(holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure()))

	return data


/obj/machinery/portable_atmospherics/canister/tgui_static_data(mob/user)
	var/list/static_data = list()

	static_data["canLabel"] = can_label
	static_data["maximumPressure"] = round(maximum_pressure)
	static_data["minReleasePressure"] = round(ONE_ATMOSPHERE / 10)
	static_data["maxReleasePressure"] = round(10 * ONE_ATMOSPHERE)
	static_data["portConnected"] = connected_port ? TRUE : FALSE

	return static_data


/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	user.set_machine(src)
	return tgui_interact(user)


/obj/machinery/portable_atmospherics/canister/tgui_act(action, list/params)
	if(..())
		return TRUE
	switch(action)
		if("toggle", "remove_tank")
			Topic(null, list(action = "1"), GLOB.default_state)
		if("pressure")
			var/pressure = params["pressure"] == "reset" ? ONE_ATMOSPHERE : text2num(params["pressure"])
			if(!isnum(pressure))
				return FALSE
			release_pressure = clamp(round(pressure), ONE_ATMOSPHERE / 10, ONE_ATMOSPHERE * 10)
		if("relabel")
			if(!can_label)
				return FALSE
			var/static/list/colors = list("\[N2O\]" = "redws", "\[N2\]" = "red", "\[O2\]" = "blue", "\[Phoron\]" = "orange", "\[CO2\]" = "black", "\[H2\]" = "purple", "\[Air\]" = "grey", "\[CAUTION\]" = "yellow")
			var/mob/user = usr
			var/label = tgui_input_list(user, "Choose canister label", "Gas canister", colors)
			if(QDELETED(src) || !user?.client || !can_label || !(label in colors) || CanUseTopic(user, GLOB.default_state) != STATUS_INTERACTIVE)
				return FALSE
			canister_color = colors[label]
			icon_state = colors[label]
			SetName("\improper Canister: [label]")
			update_icon()
		else
			return FALSE
	return TRUE
