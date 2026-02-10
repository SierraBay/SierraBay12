//Autolathe defines
#define ERR_OK 0
#define ERR_NOTFOUND "not found"
#define ERR_NOMATERIAL "no material"
#define ERR_NOREAGENT "no reagent"
#define ERR_NOCOMPAT "not copmatible"
#define ERR_PAUSED "paused"
#define ERR_DISTANT "no users"
#define ERR_STOPPED "lazy user"
#define ERR_SKILL_ISSUE "unskilled user"
//AUTOLATHE
#define SANITIZE_LATHE_COST(n) round((n), 0.01)

/obj/machinery/fabricator
	name = "autolathe"
	desc = "A general purpose fabricator capable of producing nearly any item you need, provided you have the necessary materials and design disks."
	icon = 'mods/RnD/icons/autolathe.dmi'
	icon_state = "autolathe"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = POWER_USE_IDLE
	idle_power_usage = 20
	active_power_usage = 2000
	var/base_icon_state
	var/build_type = PROTOLATHE

	var/obj/item/stock_parts/computer/hard_drive/portable/disk
	var/obj/item/stock_parts/computer/hard_drive/portable/disk2

	var/list/stored_material = list()
	var/obj/item/reagent_containers/glass/container

	var/unfolded
	var/show_category
	var/list/categories

	var/list/special_actions

	// Used by wires - unused for now
	var/disabled = FALSE
	var/shocked = FALSE

	var/working = FALSE
	var/paused = FALSE
	var/error
	var/progress = 0

	var/datum/computer_file/binary/design/current_file
	var/list/queue = list()
	var/queue_max = 24

	var/storage_capacity = 0
	var/speed = 1
	var/mat_efficiency = 1
	var/max_quality = 0
	var/fab_status_flags = 0
	var/default_disk = null // The disk that spawns in autolathe by default
	var/additional_disk = null // Secondary disk

	// Various autolathe functions that can be disabled in subtypes
	var/have_disk = TRUE
	var/have_disk2 = TRUE
	var/have_reagents = TRUE
	var/have_materials = TRUE
	var/have_recycling = TRUE
	var/have_design_selector = TRUE

	var/list/unsuitable_materials = list()
	var/list/suitable_materials //List that limits autolathes to eating mats only in that list.

	var/global/list/error_messages = list(
		ERR_NOLICENSE = "Not enough license points left.",
		ERR_NOTFOUND = "Design data not found.",
		ERR_NOMATERIAL = "Not enough materials.",
		ERR_NOREAGENT = "Not enough reagents.",
		ERR_PAUSED = "**Construction Paused**",
		ERR_NOCOMPAT = "Design is not copmatible.",
		ERR_NOODDITY = "Catalyst not found.",
		ERR_DISTANT = "User too far to operate machine.",
		ERR_STOPPED = "User stopped operating machine.",
		ERR_SKILL_ISSUE = "User cannot produce this design."
	)

	var/list/saved_designs = list()

	wires = /datum/wires/fabricator
	base_type = /obj/machinery/fabricator
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = list(
		/obj/item/stock_parts/matter_bin,
		/obj/item/stock_parts/matter_bin,
		/obj/item/stock_parts/matter_bin,
		/obj/item/stock_parts/manipulator,

	)

/obj/machinery/fabricator/Initialize()
	. = ..()
	if(have_disk && default_disk)
		disk = new default_disk(src)
	if(have_disk2 && additional_disk)
		disk2 = new additional_disk(src)

	RefreshParts()
	update_icon()

/obj/machinery/fabricator/Destroy()
	for(var/material in stored_material)
		var/material/M = SSmaterials.get_material_by_name(material)
		if(stored_material[material] > M.units_per_sheet)
			M.place_sheet(get_turf(src), round(stored_material[material] / M.units_per_sheet), M.name)
	QDEL_NULL(wires)
	return ..()

/obj/machinery/fabricator/proc/materials_data()
	var/list/data = list()

	data["mat_efficiency"] = mat_efficiency
	data["mat_capacity"] = storage_capacity

	data["container"] = !!container
	if(container && container.reagents)
		var/list/L = list()
		for(var/datum/reagent/R in container.reagents.reagent_list)
			var/list/LE = list("name" = R.name, "amount" = R.volume)
			L.Add(list(LE))

		data["reagents"] = L

	var/list/M = list()
	for(var/mtype in stored_material)
		if(stored_material[mtype] <= 0)
			continue

		var/material/MAT = SSmaterials.get_material_by_name(mtype)
		var/list/ME = list("name" = MAT.display_name, "id" = mtype, "amount" = stored_material[mtype], "ejectable" = !!MAT.stack_type)

		M.Add(list(ME))

	data["materials"] = M

	return data


/obj/machinery/fabricator/ui_data(mob/user)
	var/list/data = list()

	data["have_disk"] = have_disk
	data["have_disk2"] = have_disk2
	data["have_reagents"] = have_reagents
	data["have_materials"] = have_materials
	data["have_design_selector"] = have_design_selector

	data["error"] = error
	data["paused"] = paused

	data["unfolded"] = unfolded

	data["speed"] = speed

	if(disk)
		data["disk"] = list(
			"name" = disk.get_disk_name(),
			"read_only" = disk.read_only
		)

	if(disk2 && have_disk2)
		data["disk2"] = list(
			"name" = disk2.get_disk_name(),
			"read_only" = disk2.read_only
		)


	if(categories)
		data["categories"] = categories
		data["show_category"] = show_category

	data["special_actions"] = special_actions

	data |= materials_data()

	var/list/L = list()
	for(var/d in design_list())
		var/datum/computer_file/binary/design/design_file = d
		if(!show_category || design_file.design.category == show_category)
			L.Add(list(design_file.ui_data()))

	var/list/O = list()
	for(var/f in design_list_two())
		var/datum/computer_file/binary/design/design_file = f
		if(!show_category || design_file.design.category == show_category)
			O.Add(list(design_file.ui_data()))

	L |= O

	data["designs"] = L


	if(current_file)
		data["current"] = current_file.ui_data()
		data["progress"] = progress

	var/list/Q = list()

	var/list/qmats = stored_material.Copy()

	for(var/i = 1; i <= LAZYLEN(queue); i++)
		var/datum/computer_file/binary/design/design_file = queue[i]
		var/list/QR = design_file.ui_data()

		QR["ind"] = i

		QR["error"] = 0

		for(var/rmat in design_file.design.materials)
			if(!(rmat in qmats))
				qmats[rmat] = 0

			qmats[rmat] -= design_file.design.materials[rmat]
			if(qmats[rmat] < 0)
				QR["error"] = 1

		if(can_print(design_file) != ERR_OK)
			QR["error"] = 2

		Q.Add(list(QR))

	data["queue"] = Q
	data["queue_max"] = queue_max


	return data


/obj/machinery/fabricator/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = ui_data(user, ui_key)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "mods-autolathe.tmpl", capitalize(name), 600, 700)

		// template keys starting with _ are not appended to the UI automatically and have to be called manually
		ui.add_template("_materials", "mods-autolathe_materials.tmpl")
		ui.add_template("_reagents", "mods-autolathe_reagents.tmpl")
		ui.add_template("_designs", "mods-autolathe_designs.tmpl")
		ui.add_template("_queue", "mods-autolathe_queue.tmpl")

		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/fabricator/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(fab_status_flags & FAB_SHOCKED)
		shock(user, 50)

	if((fab_status_flags & FAB_DISABLED) && !panel_open)
		to_chat(user, SPAN_WARNING("\The [src] is disabled!"))
		return TRUE

	if(panel_open && (isMultitool(I) || isWirecutter(I)))
		attack_hand(user)
		return TRUE
	if ((. = ..()))
		return
	if(stat)
		to_chat(user, SPAN_WARNING("\The [src] is not operating."))
		return TRUE
	if(istype(I, /obj/item/stock_parts/computer/hard_drive/portable))
		if(!disk)
			insert_disk(user, I)
			return
		else
			insert_disk2(user, I)
			return

	// Some item types are consumed by default
	if(istype(I, /obj/item/stack) || istype(I, /obj/item/trash) || istype(I, /obj/item/material/shard))
		eat(user, I)
		return

	if(istype(I, /obj/item/reagent_containers/glass))
		insert_beaker(user, I)
		return

	if(!check_user(user))
		return

	user.set_machine(src)
	ui_interact(user)

/obj/machinery/fabricator/proc/check_user(mob/user)
	return TRUE

/obj/machinery/fabricator/attack_hand(mob/user)
	if(..())
		return TRUE

	if(!check_user(user))
		return TRUE

	if(fab_status_flags & FAB_SHOCKED)
		shock(user, 50)
		return TRUE

	user.set_machine(src)
	ui_interact(user)
	wires.Interact(user)

/obj/machinery/fabricator/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)

	if(href_list["insert"])
		eat(usr)
		return TRUE

	if(href_list["disk"])
		if(disk)
			eject_disk(usr)
		else
			insert_disk(usr)
		return TRUE

	if(href_list["disk2"])
		if(disk2)
			eject_disk2(usr)
		else
			insert_disk2(usr)
		return TRUE

	if(href_list["container"])
		if(container)
			eject_beaker(usr)
		else
			insert_beaker(usr)
		return TRUE

	if(href_list["category"] && categories)
		var/new_category = text2num(href_list["category"])

		if(new_category && new_category <= length(categories))
			show_category = categories[new_category]
		return TRUE

	if(href_list["eject_material"] && (!current_file || paused || error))
		var/material = href_list["eject_material"]
		var/material/M = SSmaterials.get_material_by_name(material)

		if(!M.stack_type)
			return

		var/num = input("Enter sheets number to eject. 0-[round(stored_material[material]/2000)]","Eject",0) as num
		if(!CanUseTopic(usr))
			return

		num = min(max(num,0), stored_material[material])

		eject(material, num)
		return TRUE


	if(href_list["add_to_queue"])
		var/recipe_filename = href_list["add_to_queue"]
		var/datum/computer_file/binary/design/design_file

		var/list/DL = list()

		DL |= design_list()
		DL |= design_list_two()

		for(var/f in DL)
			var/datum/computer_file/temp_file = f
			if(temp_file.filename == recipe_filename)
				design_file = temp_file
				break

		if(design_file)
			var/amount = 1

			if(href_list["several"])
				amount = input("How many \"[design_file.design.name]\" you want to print ?", "Print several") as null|num
				if(!CanUseTopic(usr) || !(design_file in DL))
					return

			queue_design(design_file, amount)

		return TRUE

	if(href_list["remove_from_queue"])
		var/ind = text2num(href_list["remove_from_queue"])
		if(ind >= 1 && ind <= LAZYLEN(queue))
			queue.Cut(ind, ind + 1)
		return TRUE

	if(href_list["move_up_queue"])
		var/ind = text2num(href_list["move_up_queue"])
		if(ind >= 2 && ind <= LAZYLEN(queue))
			queue.Swap(ind, ind - 1)
		return TRUE

	if(href_list["move_down_queue"])
		var/ind = text2num(href_list["move_down_queue"])
		if(ind >= 1 && ind <= LAZYLEN(queue)-1)
			queue.Swap(ind, ind + 1)
		return TRUE


	if(href_list["abort_print"])
		abort()
		return TRUE

	if(href_list["pause"])
		paused = !paused
		return TRUE

	if(href_list["unfold"])
		if(unfolded == href_list["unfold"])
			unfolded = null
		else
			unfolded = href_list["unfold"]
		return TRUE

/obj/machinery/fabricator/proc/insert_disk(mob/living/user, obj/item/stock_parts/computer/hard_drive/portable/inserted_disk)
	if(!inserted_disk && istype(user))
		inserted_disk = user.get_active_hand()

	if(!istype(inserted_disk))
		return

	if(!Adjacent(user) && !Adjacent(inserted_disk))
		return

	if(!have_disk)
		to_chat(user, SPAN_WARNING("[src] has no slot for a data disk."))
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

/obj/machinery/fabricator/proc/insert_disk2(mob/living/user, obj/item/stock_parts/computer/hard_drive/portable/inserted_disk2)
	if(!inserted_disk2 && istype(user))
		inserted_disk2 = user.get_active_hand()

	if(!istype(inserted_disk2))
		return

	if(!Adjacent(user) && !Adjacent(inserted_disk2))
		return

	if(!have_disk2)
		to_chat(user, SPAN_WARNING("[src] has no slot B for a data disk."))
		return

	if(disk2)
		to_chat(user, SPAN_NOTICE("There's already \a [disk2] inside slot B of [src]."))
		return

	if(istype(user) && (inserted_disk2 in user))
		user.unEquip(inserted_disk2, src)

	inserted_disk2.forceMove(src)
	disk2 = inserted_disk2
	to_chat(user, SPAN_NOTICE("You insert \the [inserted_disk2] into slot B of [src]."))
	SSnano.update_uis(src)

/obj/machinery/fabricator/proc/insert_beaker(mob/living/user, obj/item/reagent_containers/glass/beaker)
	if(!beaker && istype(user))
		beaker = user.get_active_hand()

	if(!istype(beaker))
		return

	if(!Adjacent(user) && !Adjacent(beaker))
		return

	if(!have_reagents)
		to_chat(user, SPAN_WARNING("[src] has no slot for a beaker."))
		return

	if(container)
		to_chat(user, SPAN_WARNING("There's already \a [container] inside [src]."))
		return

	if(istype(user) && (beaker in user))
		user.unEquip(beaker, src)

	beaker.forceMove(src)
	container = beaker
	to_chat(user, SPAN_NOTICE("You put \the [beaker] into [src]."))
	SSnano.update_uis(src)


/obj/machinery/fabricator/proc/eject_beaker(mob/living/user)
	if(!container)
		return

	if(current_file && !paused && !error)
		return

	container.forceMove(dropInto(loc))
	to_chat(usr, SPAN_NOTICE("You remove \the [container] from \the [src]."))

	if(istype(user) && Adjacent(user))
		user.put_in_hands(container)

	container = null


//This proc ejects the autolathe disk, but it also does some DRM fuckery to prevent exploits
/obj/machinery/fabricator/proc/eject_disk(mob/living/user)
	if(!disk)
		return

	var/list/design_list = design_list()

	// Go through the queue and remove any recipes we find which came from this disk
	for(var/design in queue)
		if(design in design_list)
			queue -= design

	//Check the current too
	if(current_file in design_list)
		//And abort it if it came from this disk
		abort()


	//Digital Rights have been successfully managed. The corporations win again.
	//Now they will graciously allow you to eject the disk
	disk.forceMove(get_turf(src))
	to_chat(usr, SPAN_NOTICE("You remove \the [disk] from slot A of \the [src]."))
	disk = null

//This proc ejects the autolathe disk, but it also does some DRM fuckery to prevent exploits
/obj/machinery/fabricator/proc/eject_disk2(mob/living/user)
	if(!disk2)
		return

	var/list/design_list_two = design_list_two()

	// Go through the queue and remove any recipes we find which came from this disk
	for(var/design in queue)
		if(design in design_list_two)
			queue -= design

	//Check the current too
	if(current_file in design_list_two)
		//And abort it if it came from this disk
		abort()


	//Digital Rights have been successfully managed. The corporations win again.
	//Now they will graciously allow you to eject the disk
	disk2.forceMove(get_turf(src))
	to_chat(usr, SPAN_NOTICE("You remove \the [disk2] from slot B of \the [src]."))
	disk2 = null

/obj/machinery/fabricator/AltClick(mob/living/user)
	if(user.incapacitated())
		to_chat(user, SPAN_WARNING("You can't do that right now!"))
		return
	if(!in_range(src, user))
		return
	if(disk2)
		src.eject_disk2(user)
	src.eject_disk(user)

/obj/machinery/fabricator/proc/eat(mob/living/user, obj/item/eating)
	if(!eating && istype(user))
		eating = user.get_active_hand()

	if(!istype(eating))
		return FALSE

	if(stat)
		return FALSE

	if(!Adjacent(user) && !Adjacent(eating))
		return FALSE

	if(is_robot_module(eating))
		return FALSE

	if(!have_recycling)
		to_chat(user, SPAN_WARNING("[src] does not support material recycling."))
		return FALSE

	if(istype(eating, /obj/item/stack))
		var/obj/item/stack/material/stack = eating
		var/material = stack.material.name
		var/stack_singular = "[stack.material.use_name] [stack.material.sheet_singular_name]" // eg "steel sheet", "wood plank"
		var/stack_plural = "[stack.material.use_name] [stack.material.sheet_plural_name]" // eg "steel sheets", "wood planks"
		var/amnt = 0
		var/list/_matter = stack.matter
		if(_matter)
			for(var/mat in _matter)
				if(istype(eating, /obj/item/stack/material/rods))
					var/amount_material_in_one = _matter[mat]/stack.amount
					amnt = amount_material_in_one
				else
					amnt = stack.perunit


		if(stack.uses_charge)
			return

		if(stored_material[material] + amnt <= storage_capacity)
			if(stack && stack.can_use(1))
				var/count = 0
				while(stored_material[material] + amnt <= storage_capacity && stack.amount >= 1)
					stored_material[material] += amnt
					stack.use(1)
					count++
				to_chat(user, "You insert [count] [count==1 ? stack_singular : stack_plural] into the [src].")// 0 steel sheets, 1 steel sheet, 2 steel sheets, etc
				res_load(SSmaterials.get_material_by_name(material))


		else
			to_chat(user, "The [src] cannot hold more [stack_plural].")// use the plural form even if the given sheet is singular

		return TRUE

	else
		var/isdesignnotexist = TRUE
		var/datum/design/D = SSresearch.fabricator_recycle(eating)
		if(D)
			isdesignnotexist = FALSE
			for(var/material in D.materials)
				if(stored_material[material] < storage_capacity)
					stored_material[material] += ((D.materials[material]/4)/mat_efficiency)
		if(isdesignnotexist)
			for(var/obj/O in eating.GetAllContents())
				var/list/_matter = O.matter
				if(_matter)
					for(var/material in _matter)
						if(material in unsuitable_materials)
							continue
						if(stored_material[material] < storage_capacity)
							stored_material[material] += ((_matter[material]/4)/mat_efficiency)
		qdel(eating)
		return TRUE


/obj/machinery/fabricator/state_transition(singleton/machine_construction/default/new_state)
	. = ..()
	if(istype(new_state))
		updateUsrDialog()

/obj/machinery/fabricator/proc/queue_design(datum/computer_file/binary/design/design_file, amount=1)
	if(!design_file || !amount)
		return

	if(design_file)
		design_file = design_file.clone()

	while(amount && LAZYLEN(queue) < queue_max)
		queue.Add(design_file)
		amount--

	if(!current_file)
		next_file()

/obj/machinery/fabricator/proc/clear_queue()
	queue.Cut()

/obj/machinery/fabricator/proc/check_craftable_amount_by_material(datum/design/design, material)
	return stored_material[material] / max(1, SANITIZE_LATHE_COST(design.materials[material])) // loaded material / required material

/obj/machinery/fabricator/proc/check_craftable_amount_by_chemical(datum/design/design, reagent)
	if(!container || !container.reagents)
		return 0

	return container.reagents.get_reagent_amount(reagent) / max(1, design.chemicals[reagent])


//////////////////////////////////////////
//Helper procs for derive possibility
//////////////////////////////////////////
/obj/machinery/fabricator/proc/design_list()
	if(!disk)
		return saved_designs

	return disk.find_files_by_type(/datum/computer_file/binary/design)

/obj/machinery/fabricator/proc/design_list_two()
	if(!disk2)
		return saved_designs

	return disk2.find_files_by_type(/datum/computer_file/binary/design)

/obj/machinery/fabricator/proc/icon_off()
	if(stat & MACHINE_STAT_NOPOWER)
		return TRUE
	return FALSE

/obj/machinery/fabricator/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("[icon_state]_panel")

	icon_state = initial(icon_state)

	if(icon_off())
		return

	if(working) // if paused, work animation looks awkward.
		if(paused || error)
			icon_state = "[icon_state]_pause"
		else
			icon_state = "[icon_state]_work"

//Procs for handling print animation
/obj/machinery/fabricator/proc/print_pre()
	flick("[initial(icon_state)]_start", src)

/obj/machinery/fabricator/proc/print_post()
	flick("[initial(icon_state)]_finish", src)
	if(!current_file && !LAZYLEN(queue))
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 1, -3)
		visible_message("\The [src] pings, indicating that queue is complete.")


/obj/machinery/fabricator/proc/res_load(material/material)
	var/list/viewing = list()
	for (var/mob/M in view(6,src))
		if (M.client)
			viewing |= M.client
	var/image/orderimage = image('mods/RnD/icons/autolathe.dmi', src, "[icon_state]_load_m")
	orderimage.color = material.icon_colour
	flick_overlay(orderimage, viewing, 8)

/obj/machinery/fabricator/components_are_accessible(path)
	return !(fab_status_flags & FAB_BUSY) && ..()

/obj/machinery/fabricator/proc/check_materials(datum/design/design)

	if(design.build_type != build_type)
		var/second_check = build_type | MECHFAB
		if(design.build_type != second_check)
			return ERR_NOCOMPAT

	for(var/rmat in design.materials)
		if(!(rmat in stored_material))
			return ERR_NOMATERIAL

		if(stored_material[rmat] < SANITIZE_LATHE_COST(design.materials[rmat]))
			return ERR_NOMATERIAL

	if(LAZYLEN(design.chemicals))
		if(!container)
			return ERR_NOREAGENT

		for(var/rgn in design.chemicals)
			if(!container.reagents.has_reagent(rgn, design.chemicals[rgn]))
				return ERR_NOREAGENT

	return ERR_OK

/obj/machinery/fabricator/proc/can_print(datum/computer_file/binary/design/design_file)

	if(paused)
		return ERR_PAUSED

	if(progress <= 0)
		if(!design_file || !design_file.design)
			return ERR_NOTFOUND

		var/datum/design/design = design_file.design
		var/error_mat = check_materials(design)
		if(error_mat != ERR_OK)
			return error_mat

	return ERR_OK


/obj/machinery/fabricator/power_change()
	..()
	if(stat & MACHINE_STAT_NOPOWER)
		working = FALSE
	update_icon()
	SSnano.update_uis(src)

/obj/machinery/fabricator/Process()
	if(stat & MACHINE_STAT_NOPOWER)
		return

	if(current_file)
		var/err = can_print(current_file)

		if(err == ERR_OK)
			error = null

			working = TRUE
			progress += speed

		else if(err in error_messages)
			error = error_messages[err]
		else
			error = "Unknown error."

		if(current_file.design && progress >= current_file.design.time)
			finish_construction()

	else
		error = null
		working = FALSE
		next_file()

	update_use_power(working ? POWER_USE_ACTIVE : POWER_USE_IDLE)

	special_process()
	update_icon()
	SSnano.update_uis(src)


/obj/machinery/fabricator/proc/consume_materials(datum/design/design)
	for(var/material in design.materials)
		var/material_cost = design.adjust_materials ? SANITIZE_LATHE_COST(design.materials[material]) : design.materials[material]
		stored_material[material] = max(0, stored_material[material] - material_cost * mat_efficiency)

	for(var/reagent in design.chemicals)
		container.reagents.remove_reagent(reagent, design.chemicals[reagent])

	return TRUE


/obj/machinery/fabricator/proc/next_file()
	current_file = null
	progress = 0
	if(LAZYLEN(queue))
		current_file = queue[1]
		print_pre()
		working = TRUE
		queue.Cut(1, 2) // Cut queue[1]
	else
		working = FALSE
	update_icon()

/obj/machinery/fabricator/proc/special_process()
	return

/obj/machinery/fabricator/proc/eject(material, amount)
	var/recursive = amount == -1 ? 1 : 0
	material = lowertext(material)
	var/mattype
	switch(material)
		if(MATERIAL_STEEL)
			mattype = /obj/item/stack/material/steel
		if(MATERIAL_PLASTEEL)
			mattype = /obj/item/stack/material/plasteel
		if(MATERIAL_GLASS)
			mattype = /obj/item/stack/material/glass
		if(MATERIAL_ALUMINIUM)
			mattype = /obj/item/stack/material/aluminium
		if(MATERIAL_PLASTIC)
			mattype = /obj/item/stack/material/plastic
		if(MATERIAL_GOLD)
			mattype = /obj/item/stack/material/gold
		if(MATERIAL_SILVER)
			mattype = /obj/item/stack/material/silver
		if(MATERIAL_DIAMOND)
			mattype = /obj/item/stack/material/diamond
		if(MATERIAL_PHORON)
			mattype = /obj/item/stack/material/phoron
		if(MATERIAL_URANIUM)
			mattype = /obj/item/stack/material/uranium
		else
			return
	var/obj/item/stack/material/S = new mattype(loc)
	if(amount <= 0)
		amount = S.max_amount
	var/ejected = min(round(stored_material[material] / S.perunit), amount)
	S.amount = min(ejected, amount)
	if(S.amount <= 0)
		qdel(S)
		return
	stored_material[material] -= ejected * S.perunit
	if(recursive && stored_material[material] >= S.perunit)
		eject(material, -1)
		S.update_materials()


/obj/machinery/fabricator/dismantle()
	eject_disk()
	for(var/mat in stored_material)
		if(ispath(mat, /material))
			var/mat_name = stored_material[mat]
			var/material/M = SSmaterials.get_material_by_name(mat_name)
			if(stored_material[mat] > M.units_per_sheet)
				M.place_sheet(get_turf(src), round(stored_material[mat] / M.units_per_sheet), M.name)
	..()
	return TRUE

//Updates lathe material storage size, production speed and material efficiency.
/obj/machinery/fabricator/RefreshParts()
	for(var/a in uncreated_component_parts)
		get_component_of_type(a)
	var/mb_rating = 0
	var/mb_amount = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		mb_rating += MB.rating
		mb_amount++

	if(mb_amount == 0)
		return

	var/man_rating = 0
	var/man_amount = 0
	man_rating = total_component_rating_of_type(/obj/item/stock_parts/manipulator)
	man_amount = number_of_components(/obj/item/stock_parts/manipulator)
	man_rating -= man_amount
	max_quality = man_rating

	var/las_rating = 0
	las_rating = total_component_rating_of_type(/obj/item/stock_parts/micro_laser)

	speed = initial(speed) + man_rating + las_rating
	mat_efficiency = max(0.4, 1 - (man_rating * 0.1))

	storage_capacity = 30000 * clamp(total_component_rating_of_type(/obj/item/stock_parts/matter_bin), 0, 20)
	..()

//Cancels the current construction
/obj/machinery/fabricator/proc/abort()
	if(working)
		print_post()
	current_file = null
	paused = TRUE
	working = FALSE
	update_icon()

//Finishing current construction
/obj/machinery/fabricator/proc/finish_construction()
	fabricate_design(current_file.design)


/obj/machinery/fabricator/proc/fabricate_design(datum/design/design)
	consume_materials(design)
	design.Fabricate(get_turf(loc), mat_efficiency, src)
	working = FALSE
	current_file = null
	print_post()
	next_file()


/obj/machinery/fabricator/micro
	name = "microlathe"
	desc = "It produces small items from common resources."
	icon = 'icons/obj/machines/fabricators/microlathe.dmi'
	icon_state = "minilathe"
	base_icon_state = "minilathe"

	idle_power_usage = 10
	active_power_usage = 1000
	machine_name = "microlathe"
	machine_desc = "A smaller-sized autolathe, typically used for cutlery, dinnerware, and drinking glasses."


/obj/machinery/fabricator/micro/check_materials(datum/design/design)
	. = ..()
	var/cat = design.category[1]
	if(!(cat == "Cutlery" || cat == "Drinking Glasses" || cat == "Medical"))
		return ERR_NOCOMPAT


/obj/machinery/fabricator/micro/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("[icon_state]_panel")
	if(working)
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights_working"))
		AddOverlays("[icon_state]_lights_working")
	else if(!disabled)
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
		AddOverlays("[icon_state]_lights")


// You (still) can't flick_light overlays in BYOND, and this is a vis_contents hack to provide the same functionality.
// Used for materials loading animation.
/obj/effect/flick_light_overlay
	name = ""
	icon_state = ""
	// Acts like a part of the object it's created for when in vis_contents
	// Inherits everything but the icon_state
	vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_DIR | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID

/obj/effect/flick_light_overlay/New(atom/movable/loc)
	..()
	// Just VIS_INHERIT_ICON isn't enough: flick_light() needs an actual icon to be set
	icon = loc.icon
	loc.add_vis_contents(src)

/obj/effect/flick_light_overlay/Destroy()
	if(istype(loc, /atom/movable))
		var/atom/movable/A = loc
		A.remove_vis_contents(src)
	return ..()

/obj/machinery/fabricator/hacked
	fab_status_flags = FAB_HACKED

	var/disk_box = /obj/item/storage/box/autolathe_designs

/obj/machinery/fabricator/hacked/Initialize()
	. = ..()
	new disk_box(loc)

/obj/machinery/fabricator/micro/loaded
	default_disk = /obj/item/stock_parts/computer/hard_drive/portable/design/glass
	additional_disk = /obj/item/stock_parts/computer/hard_drive/portable/design/cuttery

/obj/machinery/fabricator/micro/loaded/Initialize()
	. = ..()
	stored_material = list(
	MATERIAL_STEEL = 40000,
	MATERIAL_ALUMINIUM = 40000,
	MATERIAL_PLASTIC = 40000,
	MATERIAL_GLASS = 90000,
	)


/obj/machinery/fabricator/micro/bartender
	name = "Bartender Microlathe"
	default_disk = /obj/item/stock_parts/computer/hard_drive/portable/design/drinking
	have_disk2 = FALSE

#undef ERR_OK
#undef ERR_NOTFOUND
#undef ERR_NOMATERIAL
#undef ERR_NOREAGENT
#undef ERR_NOCOMPAT
#undef ERR_PAUSED
