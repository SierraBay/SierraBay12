/datum/asset/simple/design_icons/register()
	for(var/D in SSresearch.all_designs)
		var/datum/design/design = D

		var/filename = sanitizeFileName("[design.build_path].png")

		var/atom/item = design.build_path
		var/icon_file = initial(item.icon)
		var/icon_state
		if(item in typesof(/obj/item/reagent_containers/food/drinks/glass2))
			var/obj/item/reagent_containers/food/drinks/glass2/glass = item
			icon_state = initial(glass.base_icon)
		else
			icon_state = initial(item.icon_state)

		// eugh
		if (!icon_file)
			icon_file = ""

		#ifdef UNIT_TESTS
		if(!(icon_state in icon_states(icon_file)))
			// stack_trace("design [D] with icon '[icon_file]' missing state '[icon_state]'")
			continue
		#endif
		var/icon/I = icon(icon_file, icon_state, SOUTH)

		assets[filename] = I
	..()

	for(var/D in SSresearch.all_designs)
		var/datum/design/design = D
		design.ui_data["icon"] = (sanitizeFileName("[design.build_path].png"))


/obj/item/stock_parts/computer/hard_drive/ui_data()
	var/list/data = list(
		"disk_name" = get_disk_name(),
		"max_capacity" = max_capacity,
		"used_capacity" = used_capacity
	)

	var/list/files = list()
	for(var/datum/computer_file/F in stored_files)
		files.Add(list(list(
			"filename" = F.filename,
			"filetype" = F.filetype,
			"size" = F.size,
			"undeletable" = F.undeletable
		)))
	data["files"] = files
	return data
