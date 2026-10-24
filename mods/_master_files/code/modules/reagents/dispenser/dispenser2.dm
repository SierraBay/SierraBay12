// TGUI
/obj/machinery/chemical_dispenser/tgui_state(mob/user)
	return GLOB.tgui_default_state


/obj/machinery/chemical_dispenser/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDispenser", name)
		ui.set_autoupdate(TRUE)
		ui.open()


/obj/machinery/chemical_dispenser/tgui_data(mob/user)
	var/list/data = list()

	data["amount"] = amount
	data["isBeakerLoaded"] = !!container
	data["drinkingGlass"] = accept_drinking

	var/list/beakerContents = list()
	if(length(container?.reagents?.reagent_list))
		for(var/datum/reagent/reagent in container.reagents.reagent_list)
			beakerContents += list(list(
				"name" = reagent.name,
				"volume" = reagent.volume
			))
	data["beakerContents"] = beakerContents

	if(container?.reagents)
		data["beakerCurrentVolume"] = container.reagents.total_volume
		data["beakerMaxVolume"] = container.reagents.maximum_volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var/list/chemicals = list()
	for(var/label in cartridges)
		var/obj/item/reagent_containers/chem_disp_cartridge/cartridge = cartridges[label]
		chemicals += list(list(
			"label" = label,
			"amount" = cartridge.reagents.total_volume,
			"capacity" = cartridge.reagents.maximum_volume
		))
	data["chemicals"] = chemicals

	return data


/obj/machinery/chemical_dispenser/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	user.set_machine(src)
	return tgui_interact(user)


/obj/machinery/chemical_dispenser/tgui_act(action, list/params)
	if(..())
		return TRUE
	var/list/topic_params
	switch(action)
		if("amount")
			var/new_amount = text2num("[params["amount"]]")
			if(!isnum(new_amount))
				return FALSE
			topic_params = list("amount" = "[new_amount]")
		if("dispense")
			if(!(params["dispense"] in cartridges))
				return FALSE
			topic_params = list("dispense" = params["dispense"])
		if("flush")
			topic_params = list("ejectBeaker" = "1")
		else
			return FALSE
	// Preserve Sierra's skill errors, contamination and cartridge consumption.
	Topic(null, topic_params, GLOB.default_state)
	return TRUE
