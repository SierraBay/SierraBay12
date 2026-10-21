// TGUI
/obj/machinery/biogenerator/tgui_state(mob/user)
	return GLOB.tgui_default_state


/obj/machinery/biogenerator/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Biogenerator")
		ui.set_autoupdate(TRUE)
		ui.open()


/obj/machinery/biogenerator/tgui_data(mob/user)
	var/list/data = list()

	data["processing"] = state == 1
	data["biomass"] = points
	data["storedPlants"] = ingredients ? TRUE : FALSE

	if(beaker)
		data["container"] = TRUE
		data["containerContent"] = beaker.reagents.total_volume
		data["containerMaxContent"] = beaker.reagents.maximum_volume
	else
		data["container"] = FALSE

	return data


/obj/machinery/biogenerator/tgui_static_data(mob/user)
	var/list/static_data = list()

	var/list/listed_types = list()
	for(var/c_type = 1 to length(products))
		var/list/current_content = products[products[c_type]]
		var/list/listed_products = list()
		for(var/c_product = 1 to length(current_content))
			var/atom/thing = current_content[c_product]
			listed_products += list(list(
				"product_index" = c_product,
				"name" = initial(thing.name),
				"cost" = round(current_content[current_content[c_product]] / build_eff)
				))
		listed_types += list(list(
			"type_name" = products[c_type],
			"products" = listed_products
			))
	static_data["types"] = listed_types

	return static_data


/obj/machinery/biogenerator/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	user.set_machine(src)
	return tgui_interact(user)


/obj/machinery/biogenerator/tgui_act(action, list/params)
	if(..())
		return TRUE
	if(state == 1) // BG_PROCESSING is local to the original file.
		return FALSE
	switch(action)
		if("activate", "detach")
			Topic(null, list("action" = action), GLOB.default_state)
		if("eject_plants")
			for(var/obj/item/reagent_containers/food/snacks/grown/plant in contents)
				plant.dropInto(loc)
			ingredients = 0
			update_icon()
		if("create")
			var/category = params["type"]
			var/list/sub_products = products[category]
			var/index = text2num("[params["product_index"]]")
			var/amount = text2num("[params["amount"]]")
			if(!islist(sub_products) || !isnum(index) || index != round(index) || index < 1 || index > length(sub_products) || !isnum(amount) || amount < 1)
				return FALSE
			amount = min(round(amount), 100)
			var/product_path = sub_products[index]
			var/mob/user = usr
			// Each item retains Sierra's production delay, price and output placement.
			for(var/i = 1 to amount)
				if(QDELETED(src) || !user?.client || state == 1 || CanUseTopic(user, GLOB.default_state) != STATUS_INTERACTIVE || points < round(sub_products[product_path] / build_eff))
					break
				create_product(category, product_path)
		else
			return FALSE
	return TRUE
