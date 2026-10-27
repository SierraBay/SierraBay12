// TGUI
/obj/machinery/smartfridge/tgui_state(mob/user)
	return GLOB.tgui_default_state


/obj/machinery/smartfridge/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmartFridge", name)
		ui.set_autoupdate(TRUE)
		ui.open()


/obj/machinery/smartfridge/tgui_data(mob/user)
	var/list/data = list()

	data["contents"] = list()
	data["secure"] = is_secure
	// Sierra drying racks dry automatically while powered.
	data["can_dry"] = FALSE
	data["drying"] = istype(src, /obj/machinery/smartfridge/drying_rack) && operable()

	var/list/items = list()
	for(var/i=1 to length(item_records))
		var/datum/stored_items/I = item_records[i]
		var/count = I.get_amount()
		if(count > 0)
			items += list(list(
				"display_name" = I.item_name,
				"vend" = i,
				"quantity" = count
				))

	if(length(items) > 0)
		data["contents"] = items

	return data


/obj/machinery/smartfridge/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	user.set_machine(src)
	return tgui_interact(user)


/obj/machinery/smartfridge/tgui_act(action, list/params)
	if(..())
		return TRUE
	if(action != "vend")
		return FALSE
	var/index = text2num("[params["vend"]]")
	var/amount = text2num("[params["amount"]]")
	if(!isnum(index) || index != round(index) || index < 1 || index > length(item_records) || !isnum(amount) || amount < 1)
		return FALSE
	var/datum/stored_items/record = item_records[index]
	amount = min(round(amount), record.get_amount())
	if(amount < 1)
		return FALSE
	// The existing Topic applies the secure fridge's access check to these parameters.
	Topic(null, list("vend" = "[index]", "amount" = "[amount]"), GLOB.default_state)
	return TRUE
