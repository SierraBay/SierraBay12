// TGUI adapts the donor Fabricator contract to Sierra's disk-based RnD fabricator.
/obj/machinery/fabricator/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	return tgui_interact(user)

/obj/machinery/fabricator/tgui_interact(mob/user, datum/tgui/ui)
	if(!check_user(user))
		return FALSE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Fabricator", name)
		ui.open()

/obj/machinery/fabricator/tgui_status(mob/user, datum/tgui_state/state)
	if(!check_user(user))
		return STATUS_CLOSE
	return ..()

/obj/machinery/fabricator/tgui_data(mob/user)
	var/list/data = ui_data(user)
	data["material_efficiency"] = mat_efficiency
	var/list/materials = list()
	for(var/material_id in stored_material)
		var/material/M = SSmaterials.get_material_by_name(material_id)
		if(!M)
			continue
		materials += list(list("name" = material_id, "stored" = stored_material[material_id], "max" = storage_capacity, "refundable" = !!M.stack_type, "units_per_sheet" = M.units_per_sheet, "image" = tgui_product_image(M.stack_type)))
	data["material_storage"] = materials
	data["current_build"] = current_file ? list("name" = current_file.design.name, "multiplier" = 1, "progress" = progress) : null
	var/list/orders = list()
	for(var/i = 1 to length(queue))
		var/datum/computer_file/binary/design/design_file = queue[i]
		orders += list(list("name" = design_file.design.name, "multiplier" = 1, "reference" = "[i]"))
	data["build_queue"] = orders
	var/list/recipes = list()
	var/list/recipe_categories = list()
	var/list/designs = design_list() | design_list_two()
	for(var/datum/computer_file/binary/design/design_file in designs)
		var/datum/design/design = design_file.design
		if(!design)
			continue
		var/list/cost = list()
		for(var/material_id in design.materials)
			var/material/M = SSmaterials.get_material_by_name(material_id)
			cost += list(list("name" = material_id, "amount" = get_design_material_cost(design, material_id), "units_per_sheet" = M?.units_per_sheet))
		recipes += list(list("name" = design.name, "category" = design.category, "reference" = TGUI_REF(design_file), "image" = tgui_product_image(design.build_path), "cost" = cost, "can_build" = check_materials(design) == 0))
		recipe_categories |= design.category
	// Disk insertion and licenses can change between updates, so recipes are dynamic.
	data["recipes"] = recipes
	data["categories"] = recipe_categories
	return data

/obj/machinery/fabricator/tgui_act(action, list/params)
	if(..())
		return TRUE
	switch(action)
		if("make")
			var/list/designs = design_list() | design_list_two()
			var/datum/computer_file/binary/design/design_file = locate(params["make"]) in designs
			var/amount = text2num(params["multiplier"])
			if(!istype(design_file) || !design_file.design || !isnum(amount) || amount < 1)
				return FALSE
			queue_design(design_file, min(round(amount), queue_max))
		if("cancel", "move_up_queue", "move_down_queue")
			var/index = text2num(params["cancel"] || params["index"])
			if(!isnum(index) || index != round(index) || index < 1 || index > length(queue))
				return FALSE
			if(action == "cancel")
				queue.Cut(index, index + 1)
			else if(action == "move_up_queue" && index > 1)
				queue.Swap(index, index - 1)
			else if(action == "move_down_queue" && index < length(queue))
				queue.Swap(index, index + 1)
		if("eject_mat")
			var/material_id = params["eject_mat"]
			var/material/M = SSmaterials.get_material_by_name(material_id)
			if(!M?.stack_type || !(material_id in stored_material) || (current_file && !paused && !error))
				return FALSE
			var/mob/user = usr
			var/amount = tgui_input_number(user, "Enter sheets number to eject.", "Eject", 0, round(stored_material[material_id] / M.units_per_sheet), 0)
			if(isnull(amount) || amount <= 0 || QDELETED(src) || !user?.client || CanUseTopic(user, GLOB.default_state) != STATUS_INTERACTIVE || (current_file && !paused && !error))
				return FALSE
			eject(material_id, min(round(amount), round(stored_material[material_id] / M.units_per_sheet)))
		if("disk", "disk2", "container", "insert", "abort_print", "pause")
			// Topic expects the action name as the href key, not an `action` key.
			Topic(null, list("[action]" = "1"), GLOB.default_state)
		else
			return FALSE
	return TRUE
