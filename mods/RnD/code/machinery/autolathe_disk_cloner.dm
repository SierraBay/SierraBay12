/obj/machinery/disk_cloner
	name = "Disk cloner"
	desc = "Machine used for copying files from one disk to another disk."
	icon = 'mods/RnD/icons/disk_cloner.dmi'
	icon_state = "disk_cloner"
	density = TRUE
	anchored = TRUE
	use_power = POWER_USE_IDLE
	idle_power_usage = 5
	active_power_usage = 500

	var/copying_delay = 0
	var/hack_fail_chance = 0

	var/obj/item/stock_parts/computer/hard_drive/portable/original = null
	var/obj/item/stock_parts/computer/hard_drive/portable/copy = null
	base_type = /obj/machinery/disk_cloner
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = list(
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/micro_laser,

	)

	var/copying = FALSE


/obj/machinery/disk_cloner/Initialize()
	. = ..()
	update_icon()

/obj/machinery/disk_cloner/RefreshParts()
	..()
	var/laser_rating = 0
	var/scanner_rating = 0
	for(var/obj/item/stock_parts/scanning_module/SM in component_parts)
		scanner_rating += SM.rating
	for(var/obj/item/stock_parts/micro_laser/ML in component_parts)
		laser_rating += ML.rating

	if(scanner_rating+laser_rating >= 9)
		copying_delay = 15
	else if(scanner_rating+laser_rating >= 6)
		copying_delay = 30
	else
		copying_delay = 80

	hack_fail_chance = ((scanner_rating+laser_rating) >= 9) ? 20 : 40

/obj/machinery/disk_cloner/use_tool(obj/item/I, mob/user)
	if ((. = ..()))
		return
	if(panel_open)
		return

	if(istype(I, /obj/item/stock_parts/computer/hard_drive/portable))
		if(!original)
			original = put_disk(I, user)
			to_chat(user, SPAN_NOTICE("You put \the [I] into the first slot of [src]."))
		else if(!copy)
			copy = put_disk(I, user)
			to_chat(user, SPAN_NOTICE("You put \the [I] into the second slot of [src]."))
		else
			to_chat(user, SPAN_NOTICE("[src]'s slots is full."))

	user.set_machine(src)
	ui_interact(user)
	update_icon()


/obj/machinery/disk_cloner/Destroy()
	if(original)
		original.forceMove(src.loc)
		original = null
	if(copy)
		copy.forceMove(src.loc)
		copy = null
	. = ..()

/obj/machinery/disk_cloner/proc/put_disk(obj/item/stock_parts/computer/hard_drive/portable/AD, mob/user)
	ASSERT(istype(AD))

	user.unEquip(AD,src)
	return AD


/obj/machinery/disk_cloner/attack_hand(mob/user as mob)
	if(..())
		return TRUE

	user.set_machine(src)
	ui_interact(user)
	update_icon()


/obj/machinery/disk_cloner/ui_data()
	var/list/data = list(
		"copying" = copying,
	)

	if(original)
		data["disk1"] = original.ui_data()
		data["copyingtotal"] = LAZYLEN(original.stored_files)

	if(copy)
		data["disk2"] = copy.ui_data()
		data["copyingnow"] = LAZYLEN(copy.stored_files)

	return data


/obj/machinery/disk_cloner/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = ui_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "mods-autolathe_disk_cloner.tmpl", "Disk cloner", 480, 555)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/disk_cloner/Topic(href, href_list)
	if(..())
		return 1

	usr.set_machine(src)

	if(href_list["start"])
		if(copying)
			copying = FALSE
		else
			copy()
		return

	if(href_list["eject"])
		var/mob/living/H = null
		var/obj/item/stock_parts/computer/hard_drive/portable/D = null
		if(ishuman(usr))
			H = usr
			D = H.get_active_hand()

		if(href_list["eject"] == "f")
			if(original)
				original.forceMove(src.loc)
				if(H)
					H.put_in_active_hand(original)
				original = null
			else
				if(istype(D))
					H.drop_item()
					D.forceMove(src)
					original = D
		else
			if(copy)
				copy.forceMove(src.loc)
				if(H)
					H.put_in_active_hand(copy)
				copy = null
			else
				if(istype(D))
					H.drop_item()
					D.forceMove(src)
					copy = D

	SSnano.update_uis(src)
	update_icon()


/obj/machinery/disk_cloner/proc/copy()
	copying = TRUE
	update_use_power(POWER_USE_ACTIVE)
	SSnano.update_uis(src)
	update_icon()
	if(original && copy && !copy.used_capacity)
		copy.name = original.name

		for(var/f in original.stored_files)
			if(!(original && copy) || !copying || !f)
				break

			var/datum/computer_file/original_file = f
			var/datum/computer_file/copying_file

			// Design files with copy protection require special treatment
			if(istype(original_file, /datum/computer_file))
				var/datum/computer_file/file = original_file
				var/datum/computer_file/copy

				if(prob(hack_fail_chance))
					// Make a corrupted design with same filename as the original
					if(istype(original_file, /datum/computer_file/binary/design))
						var/datum/computer_file/binary/design/design_copy
						design_copy = new

						design_copy.set_design_type(/datum/computer_file/binary/design/corrupted)
						design_copy.filetype = "CCD"
						design_copy.filename = original_file.filename
				else
					// Copy the original design, remove DRM
					copy = new
					copy = file.clone()

					copying_file = copy
			else
				break

			// Any other files can be simply cloned
			if(!copying_file)
				copying_file = original_file.clone()

			// Store the copied file. If the disc is corrupted, faulty, out of space - stop the copying process.
			if(!copy.create_file(copying_file))
				break

			SSnano.update_uis(src)
			update_icon()
			sleep(copying_delay)

	copying = FALSE
	update_use_power(POWER_USE_IDLE)
	SSnano.update_uis(src)
	update_icon()


/obj/machinery/disk_cloner/on_update_icon()
	ClearOverlays()

	if(panel_open)
		overlays.Add(image(icon, icon_state = "disk_cloner_panel"))

	if(!stat)
		overlays.Add(image(icon, icon_state = "disk_cloner_screen"))
		overlays.Add(image(icon, icon_state = "disk_cloner_keyboard"))

		if(original)
			overlays.Add(image(icon, icon_state = "disk_cloner_screen_disk1"))

			if(LAZYLEN(original.stored_files))
				overlays.Add(image(icon, icon_state = "disk_cloner_screen_list1"))

		if(copy)
			overlays.Add(image(icon, icon_state = "disk_cloner_screen_disk2"))

			if(LAZYLEN(copy.stored_files))
				overlays.Add(image(icon, icon_state = "disk_cloner_screen_list2"))

		if(copying)
			overlays.Add(image(icon, icon_state = "disk_cloner_cloning"))

/obj/machinery/disk_cloner/attack_ai(mob/user)
	return ui_interact(user)


/obj/item/stock_parts/circuitboard/disk_cloner
	name = "circuit board (disk cloner)"
	build_path = /obj/machinery/disk_cloner
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4)
	req_components = list(
							/obj/item/stock_parts/scanning_module = 2,
							/obj/item/stock_parts/micro_laser = 2
	)
	additional_spawn_components = list(
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/keyboard = 1,
							/obj/item/stock_parts/power/apc/buildable = 1
	)

/datum/design/circuit/disk_cloner
	name = "disk cloner board"
	id = "disk_cloner"
	req_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 3)
	build_path = /obj/item/stock_parts/circuitboard/disk_cloner
	sort_string = "HABZZ"
