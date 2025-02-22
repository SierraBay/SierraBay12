/obj/machinery/robotics_fabricator
	var/fab_status_flags
	wires = /datum/wires/fabricator/robotics_fabricator
	var/obj/item/stock_parts/computer/hard_drive/portable/disk

/obj/machinery/robotics_fabricator/Initialize()
	files = new /datum/research(src) //Setup the research data holder.
	manufacturer = basic_robolimb.company
	. = ..()


/obj/machinery/robotics_fabricator/attack_hand(mob/user)
	if(!(fab_status_flags & FAB_HACKED))
		req_access = list(access_robotics)

	if(fab_status_flags & FAB_SHOCKED)
		shock(user, 50)

	if((fab_status_flags & FAB_HACKED) && !panel_open)
		req_access.Cut()

	if(..())
		return TRUE

	user.set_machine(src)
	ui_interact(user)
	wires.Interact(user)

/obj/machinery/robotics_fabricator/proc/insert_disk(mob/living/user, obj/item/stock_parts/computer/hard_drive/portable/inserted_disk)
	if(!inserted_disk && istype(user))
		inserted_disk = user.get_active_hand()

	if(!istype(inserted_disk))
		return

	if(!Adjacent(user) && !Adjacent(inserted_disk))
		return

	if(disk)
		to_chat(user, SPAN_NOTICE("There's already \a [disk] inside [src]."))
		return

	if(istype(user) && (inserted_disk in user))
		user.unEquip(inserted_disk, src)

	inserted_disk.forceMove(src)
	disk = inserted_disk
	to_chat(user, SPAN_NOTICE("You insert \the [inserted_disk] into [src]."))
	SSnano.update_uis(src)


/obj/machinery/robotics_fabricator/proc/design_list()
	if(!disk)
		return

	return disk.find_files_by_type(/datum/computer_file/binary/design)

/obj/machinery/robotics_fabricator/get_build_options()
	. = list()
	for(var/i in files.known_designs)
		var/datum/design/D = i
		if(!(D.build_type & MECHFAB))
			continue
		. += list(list("name" = D.name, "id" = "\ref[D]", "category" = D.category, "resourses" = get_design_resourses(D), "time" = get_design_time(D)))
	if(disk)
		for(var/i in design_list(disk))
			var/datum/computer_file/binary/design/file = i
			if(!(file.design.build_type == MECHFAB))
				continue
			. += list(list("name" = file.design.name, "id" = "\ref[file.design]", "category" = "Disk", "resourses" = get_design_resourses(file.design), "time" = get_design_time(file.design)))


/obj/machinery/robotics_fabricator/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/data[0]

	var/datum/design/current = length(queue) ? queue[1] : null
	if(current)
		data["current"] = current.name
	data["queue"] = get_queue_names()
	data["buildable"] = get_build_options()
	data["category"] = category
	data["categories"] = categories
	if(all_robolimbs)
		var/list/T = list()
		for(var/A in all_robolimbs)
			var/datum/robolimb/R = all_robolimbs[A]
			if(R.unavailable_at_fab || length(R.applies_to_part))
				continue
			T += list(list("id" = A, "company" = R.company))
		data["manufacturers"] = T
		data["manufacturer"] = manufacturer
	data["materials"] = get_materials()
	data["maxres"] = res_max_amount
	data["sync"] = sync_message
	if(current)
		data["builtperc"] = round((progress / current.time) * 100)
	data["disk"] = disk

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-mechfab.tmpl", "Exosuit Fabricator UI", 800, 600)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/robotics_fabricator/Topic(href, href_list)
	if(..())
		return
	if(href_list["build"])
		var/datum/design/D = locate(href_list["build"]) in files.known_designs
		if(D)
			add_to_queue(D)
			return TOPIC_HANDLED

	if(href_list["remove"])
		var/num = text2num(href_list["remove"])
		if(num)
			num = clamp(num, 1,LAZYLEN(queue))
			remove_from_queue(num)
			return TOPIC_HANDLED

	if(href_list["category"])
		if(href_list["category"] in categories)
			category = href_list["category"]
			return TOPIC_HANDLED

	if(href_list["manufacturer"])
		if(href_list["manufacturer"] in all_robolimbs)
			manufacturer = href_list["manufacturer"]
			return TOPIC_HANDLED

	if(href_list["eject"])
		eject_materials(href_list["eject"], text2num(href_list["amount"]))
		return TOPIC_HANDLED

	if(href_list["sync"])
		sync()
		return TOPIC_HANDLED
	else
		sync_message = ""

	if(href_list["eject_disk"])
		if(disk)
			disk.forceMove(get_turf(src))
			to_chat(usr, SPAN_NOTICE("You remove \the [disk] from \the [src]."))
			disk = null
			sync()
			return TOPIC_HANDLED


	return 1

/obj/machinery/robotics_fabricator/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(panel_open && (isMultitool(I) || isWirecutter(I)))
		attack_hand(user)
		return TRUE
	if(fab_status_flags & FAB_SHOCKED)
		shock(user, 50)
	if((fab_status_flags & FAB_DISABLED) && !panel_open)
		to_chat(user, SPAN_WARNING("\The [src] is disabled!"))
		return TRUE

	if ((. = ..()))
		return

	if(busy)
		to_chat(user, SPAN_NOTICE("\The [src] is busy. Please wait for completion of previous operation."))
		return TRUE

	if(istype(I, /obj/item/stock_parts/computer/hard_drive/portable))
		insert_disk(user, I)
		sync()
		return TRUE

	if(!istype(I, /obj/item/stack/material))
		return ..()

	var/obj/item/stack/material/stack = I
	var/material = stack.material.name
	var/stack_singular = "[stack.material.use_name] [stack.material.sheet_singular_name]" // eg "steel sheet", "wood plank"
	var/stack_plural = "[stack.material.use_name] [stack.material.sheet_plural_name]" // eg "steel sheets", "wood planks"
	var/amnt = stack.perunit

	if(stack.uses_charge)
		return

	if(!(material in materials))
		to_chat(user, SPAN_WARNING("\The [src] does not accept [stack_plural]!"))
		return TRUE

	if(materials[material] + amnt <= res_max_amount)
		if(stack && stack.can_use(1))
			var/count = 0
			var/viewing
			for (var/mob/M in view(6,src))
				if (M.client)
					viewing += M.client
			var/image/orderimage = image('icons/obj/machines/fabricators/robotics_fabricator.dmi', src, "fab-load-metal")
			flick_overlay(orderimage, viewing, 8)
			while(materials[material] + amnt <= res_max_amount && stack.amount >= 1)
				materials[material] += amnt
				stack.use(1)
				count++
			to_chat(user, "You insert [count] [count==1 ? stack_singular : stack_plural] into the fabricator.")// 0 steel sheets, 1 steel sheet, 2 steel sheets, etc

			update_busy()
	else
		to_chat(user, "The fabricator cannot hold more [stack_plural].")// use the plural form even if the given sheet is singular

	return TRUE

/obj/machinery/robotics_fabricator/update_categories()
	categories = list()
	for(var/datum/design/D in files.known_designs)
		if(!D.build_path || !(D.build_type & MECHFAB))
			continue
		categories |= D.category

/obj/machinery/robotics_fabricator/sync()
	for(var/obj/machinery/computer/rdconsole/RDC in view(11, src))
		if(!RDC.sync)
			sync_message = "Error: no console found."
			return
		files = RDC.files
		sync_message = "Sync complete."
		update_categories()
	if(disk)
		categories |= "Disk"
	else if(!disk)
		categories -= "Disk"
