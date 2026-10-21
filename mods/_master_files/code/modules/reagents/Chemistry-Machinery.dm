/obj/machinery/chem_master/tgui_state(mob/user)
	return GLOB.tgui_default_state


/obj/machinery/chem_master/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", name)
		ui.set_autoupdate(TRUE)
		ui.open()


/obj/machinery/chem_master/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/chem_master))


/obj/machinery/chem_master/tgui_data(mob/user)
	var/list/data = list()

	data["pillSprite"] = pillsprite
	data["bottleSprite"] = bottlesprite
	data["isSloppy"] = sloppy
	data["container"] = !!beaker
	data["pillBottle"] = !!loaded_pill_bottle
	data["toBeaker"] = to_beaker
	data["productionOptions"] = production_options
	data["pillDosage"] = pill_dosage
	data["pillDosageMax"] = initial(pill_dosage)
	data["pillCount"] = pillamount
	data["pillCountMax"] = max_pill_count
	data["bottleDosage"] = bottle_dosage
	data["bottleDosageMax"] = initial(bottle_dosage)
	data["isAnalyzedBlood"] = FALSE
	data["blisterDosage"] = blister_dosage
	data["blisterDosageMax"] = initial(blister_dosage)
	data["blisterType"] = blister_type
	data["containerChemicals"] = list()
	data["bufferChemicals"] = list()

	if(analyzed_reagent)
		data["analyzedReagent"] = analyzed_reagent.name
		data["analyzedDesc"] = analyzed_reagent.description
		if(istype(analyzed_reagent, /datum/reagent/blood))
			data["isAnalyzedBlood"] = TRUE
			data["analyzedBloodSpecies"] = "Species of Origin: [analyzed_reagent.data["species"]]"
			data["analyzedBloodType"] = "Blood Type: [analyzed_reagent.data["blood_type"]]"
			data["analyzedBloodDNA"] = "DNA Hash: [analyzed_reagent.data["blood_DNA"]]"

	if(loaded_pill_bottle)
		data["pillBottleContent"] = length(loaded_pill_bottle.contents)
		data["pillBottleMaxContent"] = loaded_pill_bottle.max_storage_space

	var/container_data = list()
	if(beaker && beaker.reagents && beaker.reagents.reagent_list)
		for(var/datum/reagent/reagent in beaker.reagents.reagent_list)
			container_data += list(list(
				"name" = reagent.name,
				"desc" = reagent.description,
				"volume" = reagent.volume,
				"ref" = "[TGUI_REF(reagent)]"
			))
		data["containerChemicals"] = container_data

	var/buffer_data = list()
	if(reagents && reagents.reagent_list)
		for(var/datum/reagent/reagent in reagents.reagent_list)
			buffer_data += list(list(
				"name" = reagent.name,
				"desc" = reagent.description,
				"volume" = reagent.volume,
				"ref" = "[TGUI_REF(reagent)]"
			))
		data["bufferChemicals"] = buffer_data

	return data


/obj/machinery/chem_master/tgui_static_data(mob/user)
	var/list/static_data = list()

	var/pill_styles = list()
	for(var/i in 1 to 25)
		pill_styles += list(list(
			"id" = i,
			"sprite" = "pill[i]",
		))
	static_data["pillSprites"] = pill_styles

	var/bottle_styles = list()
	for(var/style in list("bottle-1", "bottle-2", "bottle-3", "bottle-4"))
		bottle_styles += list(list(
			"id" = style,
			"sprite" = "[style]",
		))
	static_data["bottleSprites"] = bottle_styles

	return static_data


/obj/machinery/chem_master/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	user.set_machine(src)
	return tgui_interact(user)

/obj/machinery/chem_master/tgui_act(action, list/params)
	if(..())
		return TRUE
	var/list/topic_params
	switch(action)
		if("ejectPillBottle")
			topic_params = list("ejectp" = "1")
		if("analyze")
			topic_params = list("analyze" = params["name"])
		if("add", "remove")
			var/amount = text2num("[params["amount"]]")
			if(!isnum(amount) || amount <= 0 || !beaker)
				return FALSE
			topic_params = list("amount" = "[amount]")
			topic_params[action] = params["reagent"]
		if("eject", "toggle", "dissolve_pill", "dissolve_until_full")
			topic_params = list()
			topic_params[action] = "1"
		if("toggleSloppy")
			topic_params = list("toggle_sloppy" = "1")
		if("pillCount")
			var/count = text2num("[params["pillCount"]]")
			if(!isnum(count))
				return FALSE
			pillamount = clamp(round(count), 1, max_pill_count)
			return TRUE
		if("pillDosage", "bottleDosage", "blisterDosage")
			var/dosage = text2num("[params["newDosage"]]")
			if(!isnum(dosage) || dosage <= 0)
				return FALSE
			switch(action)
				if("pillDosage")
					pill_dosage = clamp(dosage, 0.1, initial(pill_dosage))
				if("bottleDosage")
					bottle_dosage = clamp(dosage, 1, initial(bottle_dosage))
				if("blisterDosage")
					blister_dosage = clamp(dosage, 0.1, initial(blister_dosage))
			return TRUE
		if("blisterType")
			var/slots = text2num("[params["slots"]]")
			if(!(slots in list(2, 4, 6)))
				return FALSE
			blister_type = slots
			return TRUE
		if("createPill", "createBlister")
			if(production_options == "CONDIMENTS" || !beaker)
				return FALSE
			return tgui_create_pills(usr, action == "createBlister")
		if("createBottle")
			if(!beaker)
				return FALSE
			create_bottle(usr)
			return TRUE
		if("changePillStyle")
			var/style = text2num("[params["style"]]")
			if(!isnum(style) || style != round(style) || style < 1 || style > 25)
				return FALSE
			pillsprite = "[style]"
			return TRUE
		if("changeBottleStyle")
			if(!(params["style"] in list("bottle-1", "bottle-2", "bottle-3", "bottle-4")))
				return FALSE
			bottlesprite = params["style"]
			return TRUE
		else
			return FALSE
	// Sierra owns transfer loss, contaminants, disposal mode and pill dissolution.
	Topic(null, topic_params, GLOB.default_state)
	return TRUE

/obj/machinery/chem_master/proc/tgui_create_pills(mob/user, make_blister = FALSE)
	var/count = make_blister ? blister_type : pillamount
	if(reagents.total_volume / count < 1)
		return FALSE
	var/amount_per_pill = min(reagents.total_volume / count, make_blister ? blister_dosage : pill_dosage)
	var/pill_name = tgui_input_text(user, "Name:", "Name your pill!", "[reagents.get_master_reagent_name()] ([amount_per_pill]u)", MAX_NAME_LEN)
	pill_name = sanitizeSafe(pill_name, MAX_NAME_LEN)
	if(!pill_name || QDELETED(src) || !user?.client || !beaker || CanUseTopic(user, GLOB.default_state) != STATUS_INTERACTIVE || reagents.total_volume / count < 1)
		return FALSE
	var/obj/item/storage/pill_bottle/blister/blister
	if(make_blister)
		switch(count)
			if(2)
				blister = new /obj/item/storage/pill_bottle/blister/two(loc)
			if(4)
				blister = new /obj/item/storage/pill_bottle/blister/four(loc)
			if(6)
				blister = new /obj/item/storage/pill_bottle/blister(loc)
	while(count-- && count >= 0)
		var/obj/item/reagent_containers/pill/P = new /obj/item/reagent_containers/pill(loc)
		P.SetName("[pill_name] pill")
		P.icon_state = "pill" + pillsprite
		if(P.icon_state in list("pill1", "pill2", "pill3", "pill4", "pill5")) // if using greyscale, take colour from reagent
			P.color = reagents.get_color()
		reagents.trans_to_obj(P, amount_per_pill)
		if(blister)
			P.forceMove(blister)
		else if(loaded_pill_bottle && length(loaded_pill_bottle.contents) < loaded_pill_bottle.max_storage_space)
			P.forceMove(loaded_pill_bottle)
	if(blister)
		blister.update_icon()
	return TRUE

/obj/machinery/chem_master/create_bottle(mob/user)
	var/bottle_name = reagents.total_volume ? reagents.get_master_reagent_name() : "glass"
	var/product_name = sanitizeSafe(tgui_input_text(user, "Name:", "Name your bottle!", bottle_name, MAX_NAME_LEN), MAX_NAME_LEN)
	if(!product_name || QDELETED(src) || !user?.client || !beaker || CanUseTopic(user, GLOB.default_state) != STATUS_INTERACTIVE)
		return
	var/obj/item/reagent_containers/glass/bottle/P = new /obj/item/reagent_containers/glass/bottle(loc)
	P.SetName("[product_name] bottle")
	P.icon_state = bottlesprite
	reagents.trans_to_obj(P, bottle_dosage)
	P.update_icon()
