// TGUI
/obj/machinery/power/apc/tgui_state(mob/user)
	return GLOB.tgui_always_state


/obj/machinery/power/apc/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "APC", "[area.name] - APC")
		ui.open()


/obj/machinery/power/apc/tgui_data(mob/user)
	var/list/data = list()
	var/obj/item/cell/cell = get_cell()

	data["hasAccess"] = (has_access(req_access, user.GetAccess()) && !isWireCut(APC_WIRE_IDSCAN))
	data["locked"] = (locked && !emagged) ? 1 : 0
	data["isOperating"] = operating
	data["externalPower"] = main_status
	data["powerCellStatus"] = cell ? cell.percent() : null
	data["chargeMode"] = chargemode
	data["chargingStatus"] = charging
	data["totalLoad"] = round(lastused_total)
	data["totalCharging"] = round(lastused_charging)
	data["coverLocked"] = coverlocked
	data["failTime"] = failure_timer * 2
	data["siliconUser"] = (istype(user, /mob/living/silicon) || (isghost(user) && isadmin(user)))

	var/list/power_channels = list()
	power_channels += list(list(
		"title" = "Equipment",
		"powerLoad" = round(lastused_equip),
		"status" = equipment,
		"topicParams" = list(
			"auto" = list("eqp" = 2),
			"on"   = list("eqp" = 1),
			"off"  = list("eqp" = 0)
		)
	))
	power_channels += list(list(
		"title" = "Lighting",
		"powerLoad" = round(lastused_light),
		"status" = lighting,
		"topicParams" = list(
			"auto" = list("lgt" = 2),
			"on"   = list("lgt" = 1),
			"off"  = list("lgt" = 0)
		)
	))
	power_channels += list(list(
		"title" = "Environment",
		"powerLoad" = round(lastused_environ),
		"status" = environ,
		"topicParams" = list(
			"auto" = list("env" = 2),
			"on"   = list("env" = 1),
			"off"  = list("env" = 0)
		)
	))

	data["powerChannels"] = power_channels

	return data


/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE, datum/nanoui/master_ui = null, datum/topic_state/state = GLOB.default_state)
	user.set_machine(src)
	return tgui_interact(user)

/obj/machinery/power/apc/tgui_act(action, list/params)
	if(..())
		return
	var/list/href_list = list()
	switch(action)
		if("set")
			var/list/channels = list("Equipment" = "eqp", "Lighting" = "lgt", "Environment" = "env")
			var/channel = channels[params["chan"]]
			var/value = text2num("[params["set"]]")
			if(!channel || !(value in list(0, 1, 2)))
				return FALSE
			href_list[channel] = "[value]"
		if("lock", "reboot", "breaker", "cmode", "overload", "toggleaccess")
			href_list[action] = "1"
		else
			return FALSE
	// Topic retains locked-panel, silicon, wire and malfunction rules.
	Topic("", href_list)
	return TRUE
