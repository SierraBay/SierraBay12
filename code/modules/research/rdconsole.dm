/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter. It also contains the /datum/research holder with all the known/possible technology paths and device designs.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
doesn't have toxins access.

When a R&D console is destroyed or even partially disassembled, you lose all research data on it. However, there are two ways around
this dire fate:
- The easiest way is to go to the settings menu and select "Sync Database with Network." That causes it to upload (but not download)
it's data to every other device in the game. Each console has a "disconnect from network" option that'll will cause data base sync
operations to skip that console. This is useful if you want to make a "public" R&D console or, for example, give the engineers
a circuit imprinter with certain designs on it and don't want it accidentally updating. The downside of this method is that you have
to have physical access to the other console to send data back. Note: An R&D console is on CentCom so if a random griffan happens to
cause a ton of data to be lost, an admin can go send it back.
- The second method is with Technology Disks and Design Disks. Each of these disks can hold a single technology or design datum in
it's entirety. You can then take the disk to any R&D console and upload it's data to it. This method is a lot more secure (since it
won't update every console in existence) but it's more of a hassle to do. Also, the disks can be stolen.
*/
//[/SIERRA-EDIT] - MODPACK_RND
/obj/machinery/computer/rdconsole
	name = "fabrication control console"
	desc = "Console controlling the various fabrication devices. Uses self-learning matrix to hold and optimize blueprints. Prone to corrupting said matrix, so back up often."
	icon_keyboard = "rd_key"
	icon_screen = "rdcomp"
	light_color = "#a97faa"
	base_type = /obj/machinery/computer/rdconsole/core
	machine_name = "\improper R&D control console"
	machine_desc = "Used to operate an R&D setup, including protolathes, circuit imprinters, and destructive analyzers. Can be configured with a screwdriver."
	var/datum/research/files							//Stores all the collected research data.
	var/obj/item/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/stock_parts/computer/hard_drive/portable/disk = null	//Stores the data disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/r_n_d/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/r_n_d/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	var/screen = "main"       //Which screen is currently showing.
	var/id = 0			//ID of the computer (for server restrictions).
	var/sync = 1		//If sync = 0, it doesn't show up on Server Control Console
	var/can_analyze = TRUE //If the console is allowed to use destructive analyzers

	var/can_research = TRUE   //Is this console capable of researching

	var/selected_tech_tree
	var/selected_technology
	var/show_settings = FALSE
	var/show_link_menu = FALSE
	var/selected_protolathe_category
	var/selected_imprinter_category
	var/search_text

	var/list/saved_origins = list()
	var/protolathe_show_tech = TRUE
	var/protolathe_search = ""
	var/imprinter_show_tech = TRUE
	var/imprinter_search = ""
	var/quick_deconstruct = FALSE
	var/list/diskstored = list()

	req_access = list(access_research)	//Data and setting manipulation requires scientist access.

/obj/machinery/computer/rdconsole/proc/CallMaterialName(ID)
	var/return_name = ID
	var/datum/reagent/temp_reagent
	switch(return_name)
		if(MATERIAL_STEEL)
			return_name = "Steel"
		if(MATERIAL_ALUMINIUM)
			return_name = "Aluminium"
		if(MATERIAL_GLASS)
			return_name = "Glass"
		if(MATERIAL_PLASTIC)
			return_name = "Plastic"
		if(MATERIAL_GOLD)
			return_name = "Gold"
		if(MATERIAL_SILVER)
			return_name = "Silver"
		if(MATERIAL_PHORON)
			return_name = "Solid Phoron"
		if(MATERIAL_URANIUM)
			return_name = "Uranium"
		if(MATERIAL_DIAMOND)
			return_name = "Diamond"
	if(!return_name)
		for(var/R in subtypesof(/datum/reagent))
			temp_reagent = null
			temp_reagent = new R()
			if(temp_reagent == ID)
				return_name = temp_reagent.name
				qdel(temp_reagent)
				temp_reagent = null
				break
	return return_name

/obj/machinery/computer/rdconsole/proc/CallReagentName(reagent_type)
	var/datum/reagent/R = reagent_type
	return ispath(reagent_type, /datum/reagent) ? initial(R.name) : "Unknown"

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/r_n_d/D in range(4, src))
		if(D.linked_console != null || D.panel_open)
			continue
		if(istype(D, /obj/machinery/r_n_d/destructive_analyzer) && can_analyze == TRUE) // Only science R&D consoles can do research
			if(isnull(linked_destroy))
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/protolathe))
			if(isnull(linked_lathe))
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/circuit_imprinter))
			if(isnull(linked_imprinter))
				linked_imprinter = D
				D.linked_console = src
	return

/obj/machinery/computer/rdconsole/New()
	..()
	files = new
	if(!id)
		for(var/obj/machinery/r_n_d/server/centcom/S as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server/centcom))
			S.update_connections()
			break

/obj/machinery/computer/rdconsole/Initialize()
	SyncRDevices()
	RDcomputer_list += src
	. = ..()

/obj/machinery/computer/rdconsole/Destroy()
	RDcomputer_list -= src
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_destroy = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_destroy = null
	return ..()

/obj/machinery/computer/rdconsole/use_tool(obj/item/D, mob/living/user, list/click_params)
	if(!user.canUnEquip(D))
		return TRUE
	if(istype(D, /obj/item/disk/secret_project))
		var/obj/item/disk/secret_project/disk = D
		to_chat(user, "<span class='notice'>[name] received [disk.stored_points] research points from [disk.name]</span>")
		files.research_points += disk.stored_points
		user.remove_from_mob(disk)
		qdel(disk)
		return

	if(istype(D, /obj/item/disk/tech_disk))
		var/obj/item/disk/tech_disk/disk = D
		if(disk.stored)
			if(disk.stored.id in diskstored)
				to_chat(user, "<span class='notice'>[name] has already have same data as at the [disk]</span>")
				return
			var/science_value = disk.stored.level * 1000
			files.research_points += science_value
			to_chat(user, "<span class='notice'>[name] received [science_value] research points from [disk]</span>")
			diskstored += disk.stored.id
			user.remove_from_mob(disk)
			qdel(disk)

	if(istype(D, /obj/item/stock_parts/computer/hard_drive/portable))
		if(disk)
			to_chat(user, SPAN_NOTICE("A disk is already loaded into the machine."))
			return

		user.drop_item()
		D.forceMove(src)
		disk = D
		to_chat(user, SPAN_NOTICE("You add \the [D] to the machine."))
		SSnano.update_uis(src)
	else if(istype(D, /obj/item/device/science_tool))
		var/research_points = files.experiments.read_science_tool(D)
		if(research_points > 0)
			to_chat(user, "<span class='notice'>[name] received [research_points] research points from uploaded data.</span>")
			files.research_points += research_points
		else
			to_chat(user, "<span class='notice'>There was no usefull data inside [D.name]'s buffer.</span>")
	updateUsrDialog()

	return ..()

/obj/machinery/computer/rdconsole/emag_act(remaining_charges, mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = TRUE
		req_access.Cut()
		to_chat(user, SPAN_NOTICE("You disable the security protocols."))
		return 1

/obj/machinery/computer/rdconsole/proc/sync_tech()
	for(var/obj/machinery/r_n_d/server/S in rnd_server_list)
		var/server_processed = 0
		if(GLOB.using_map.use_overmap && !(src.z in GetConnectedZlevels(S.z)))
			break
		if(S.disabled)
			continue
		if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
			S.files.download_from(files)
			server_processed = 1
		if(((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom)) || S.hacked)
			files.download_from(S.files)
			server_processed = 1
		if(!istype(S, /obj/machinery/r_n_d/server/centcom) && server_processed)
			S.produce_heat(100)

	screen = "main"
	SSnano.update_uis(src)

/obj/machinery/computer/rdconsole/proc/find_devices()
	SyncRDevices()
	screen = "main"
	SSnano.update_uis(src)


/obj/machinery/computer/rdconsole/proc/get_protolathe_data()
	var/list/protolathe_list = list(
		"max_material_storage" =             linked_lathe.max_material_storage,
		"total_materials" =                  linked_lathe.TotalMaterials(),
	)
	var/list/material_list = list()
	for(var/M in linked_lathe.materials)
		var/material/material = SSmaterials.get_material_by_name(M)
		material_list += list(list(
			"id" =             M,
			"name" =           material.display_name,
			"ammount" =        linked_lathe.materials[M],
			"can_eject_one" =  linked_lathe.materials[M] >= 1,
			"can_eject_five" = linked_lathe.materials[M] >= 5,
		))
	protolathe_list["materials"] = material_list
	return protolathe_list

/obj/machinery/computer/rdconsole/proc/get_imprinter_data()
	var/list/imprinter_list = list(
		"max_material_storage" =             linked_imprinter.max_material_storage,
		"total_materials" =                  linked_imprinter.TotalMaterials(),
		"total_volume" =                     linked_imprinter.reagents.total_volume,
		"maximum_volume" =                   linked_imprinter.reagents.maximum_volume,
	)
	var/list/printer_reagent_list = list()
	for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
		printer_reagent_list += list(list(
			"id" =             R,
			"name" =           R.name,
			"volume" =         R.volume,
		))
	imprinter_list["reagents"] = printer_reagent_list
	var/list/material_list = list()
	for(var/M in linked_imprinter.materials)
		var/material/material = SSmaterials.get_material_by_name(M)
		material_list += list(list(
			"id" =             M,
			"name" =           material.display_name,
			"ammount" =        linked_imprinter.materials[M],
			"can_eject_one" =  linked_imprinter.materials[M] >= 1,
			"can_eject_five" = linked_imprinter.materials[M] >= 5,
		))
	imprinter_list["materials"] = material_list
	return imprinter_list



/obj/machinery/computer/rdconsole/proc/get_possible_designs_data(build_type, category)
	var/list/designs_list = list()
	var/coeff = 1
	if(build_type == PROTOLATHE)
		coeff = linked_lathe.mat_efficiency
	if(build_type == IMPRINTER)
		coeff = linked_imprinter.mat_efficiency
	for(var/datum/design/D in files.known_designs)
		if(D.build_type & build_type)
			var/cat = "Unspecified"
			if(D.category)
				cat = D.category
			if((category in cat) || (category == "Search Results" && findtext(D.name, search_text)))
				var/temp_material
				var/temp_chemical
				var/maximum = 50
				var/can_build
				var/can_build_chem
				for(var/M in D.materials)
					if(build_type == PROTOLATHE)
						can_build = linked_lathe.check_craftable_amount_by_material(D, M)
					if(build_type == IMPRINTER)
						can_build = linked_imprinter.check_craftable_amount_by_material(D, M)
					var/material/mat = SSmaterials.get_material_by_name(M)
					if(can_build < 1)
						temp_material += " <span style=\"color:red\">[D.materials[M]*coeff] [mat.display_name]</span>"
					else
						temp_material += " [D.materials[M]*coeff] [mat.display_name]"
					can_build = min(can_build,maximum)
				for(var/C in D.chemicals)
					if(build_type == IMPRINTER)
						can_build_chem = linked_imprinter.check_craftable_amount_by_chemical(D, C)
					if(can_build_chem < 1)
						temp_chemical += " <span style=\"color:red\">[D.chemicals[C]*coeff] [CallReagentName(C)]</span>"
					else
						temp_chemical += " [D.chemicals[C]*coeff] [CallReagentName(C)]"
					can_build = min(can_build, can_build_chem)
				designs_list += list(list(
					"id" =             D.id,
					"name" =           D.shortname,
					"desc" =           D.desc,
					"can_create" =     can_build,
					"temp_material" =  temp_material,
					"temp_chemical" =  temp_chemical
				))
	return designs_list

/obj/machinery/computer/rdconsole/Topic(href, href_list) // Oh boy here we go.
	if(..())
		return 1

	if(href_list["select_tech_tree"])
		var/new_select_tech_tree = href_list["select_tech_tree"]
		if(files.all_technologies[new_select_tech_tree])
			selected_tech_tree = new_select_tech_tree
			selected_technology = null
	if(href_list["select_technology"])
		var/new_selected_technology = href_list["select_technology"]
		if(files.all_technologies[selected_tech_tree][new_selected_technology])
			selected_technology = new_selected_technology
	if(href_list["unlock_technology"])
		var/unlock = href_list["unlock_technology"]
		files.UnlockTechology(files.all_technologies[selected_tech_tree][unlock])
	if(href_list["go_screen"])
		var/where = href_list["go_screen"]
		if(href_list["need_access"])
			if(!allowed(usr) && !emagged)
				to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")
				return
		screen = where
		if(screen == "protolathe" || screen == "circuit_imprinter")
			search_text = ""
	if(href_list["eject_disk"]) // User is ejecting the disk.
		if(disk)
			disk.forceMove(get_turf(src))
			disk = null
	if(href_list["delete_disk_file"]) // User is attempting to delete a file from the loaded disk.
		if(disk)
			var/datum/computer_file/file = locate(href_list["delete_disk_file"]) in disk.stored_files
			disk.remove_file(file)

	if(href_list["download_disk_design"]) // User is attempting to download (disk->rdconsole) a design from the disk.
		if(disk)
			var/datum/computer_file/binary/design/file = locate(href_list["download_disk_design"]) in disk.stored_files
			files.AddDesign2Known(file.design)

	if(href_list["download_disk_science"]) // User is attempting to download (disk->rdconsole) a science from the disk.
		if(disk)
			var/datum/computer_file/binary/sci/file = locate(href_list["download_disk_science"]) in disk.stored_files
			var/savedpionts = files.AddSciPoints(file)
			files.research_points += savedpionts
			to_chat(usr, "<span class='notice'>[savedpionts] new science points downloaded from the [file.filename].</span>")

	if(href_list["upload_disk_design"]) // User is attempting to upload (rdconsole->disk) a design to the disk.
		if(disk)
			var/datum/design/D = locate(href_list["upload_disk_design"]) in files.known_designs
			if(D)
				disk.save_file(D.file.clone())
	if(href_list["toggle_settings"])
		if(allowed(usr) || emagged)
			show_settings = !show_settings
		else
			to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")
	if(href_list["toggle_link_menu"])
		if(allowed(usr) || emagged)
			show_link_menu = !show_link_menu
		else
			to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")
	if(href_list["sync"]) //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
		if(!sync)
			to_chat(usr, "<span class='warning'>You must connect to the network first!</span>")
		else
			screen = "working"
			addtimer(new Callback(src, .proc/sync_tech), 3 SECONDS)
	if(href_list["togglesync"]) //Prevents the console from being synced by other consoles. Can still send data.
		sync = !sync
	if(href_list["select_category"])
		var/what_cat = href_list["select_category"]
		if(screen == "protolathe")
			selected_protolathe_category = what_cat
		if(screen == "circuit_imprinter")
			selected_imprinter_category = what_cat
	if(href_list["build"] && screen == "protolathe" && linked_lathe) //Causes the Protolathe to build something.
		var/amount=text2num(href_list["amount"])
		var/datum/design/being_built = null
		for(var/datum/design/D in files.known_designs)
			if(D.id == href_list["build"])
				being_built = D
				break
		if(being_built && amount)
			linked_lathe.queue_design(being_built, amount)
	if(href_list["build"] && screen == "circuit_imprinter" && linked_imprinter)
		var/datum/design/being_built = null
		for(var/datum/design/D in files.known_designs)
			if(D.id == href_list["build"])
				being_built = D
				break
		if(being_built)
			linked_imprinter.queue_design(being_built)
	if(href_list["search"])
		var/input = sanitizeSafe(input(usr, "Enter text to search", "Searching") as null|text, MAX_LNAME_LEN)
		search_text = input
		if(screen == "protolathe")
			if(!search_text)
				selected_protolathe_category = null
			else
				selected_protolathe_category = "Search Results"
		if(screen == "circuit_imprinter")
			if(!search_text)
				selected_imprinter_category = null
			else
				selected_imprinter_category = "Search Results"
	if(href_list["clear_queue"])
		if(screen == "protolathe" && linked_lathe)
			linked_lathe.clear_queue()
		if(screen == "circuit_imprinter" && linked_imprinter)
			linked_imprinter.clear_queue()
	if(href_list["deconstruct"])
		if(linked_destroy)
			linked_destroy.deconstruct_item()
	if(href_list["eject_item"])
		if(linked_destroy)
			linked_destroy.eject_item()
	if(href_list["imprinter_purgeall"] && linked_imprinter)
		linked_imprinter.reagents.clear_reagents()
	if(href_list["imprinter_purge"] && linked_imprinter)
		linked_imprinter.reagents.del_reagent(href_list["imprinter_purge"])
	if(href_list["lathe_ejectsheet"] && linked_lathe) // Ejecting sheets from the protolathe
		var/desired_num_sheets = text2num(href_list["lathe_ejectsheet_amt"])
		linked_lathe.eject(href_list["lathe_ejectsheet"], desired_num_sheets)
	if(href_list["imprinter_ejectsheet"] && linked_imprinter) // Ejecting sheets from the imprinter
		var/desired_num_sheets = text2num(href_list["imprinter_ejectsheet_amt"])
		linked_imprinter.eject(href_list["imprinter_ejectsheet"], desired_num_sheets)
	if(href_list["find_device"])
		screen = "working"
		addtimer(new Callback(src, PROC_REF(find_devices)), 2 SECONDS)
	if(href_list["disconnect"]) //The R&D console disconnects with a specific device.
		switch(href_list["disconnect"])
			if("destroy")
				linked_destroy.linked_console = null
				linked_destroy = null
			if("lathe")
				linked_lathe.linked_console = null
				linked_lathe = null
			if("imprinter")
				linked_imprinter.linked_console = null
				linked_imprinter = null
	if(href_list["reset"]) //Reset the R&D console's database.
		var/choice = alert("R&D Console Database Reset", "Are you sure you want to reset the R&D console's database? Data lost cannot be recovered.", "Continue", "Cancel")
		if(choice == "Continue")
			screen = "working"
			qdel(files)
			files = new /datum/research(src)
			spawn(20)
				screen = "main"
				SSnano.update_uis(src)
	if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(allowed(usr) || emagged)
			screen = "locked"
		else
			to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")
	if(href_list["unlock"])
		if(allowed(usr) || emagged)
			screen = "main"
		else
			to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")

	return TRUE


/obj/machinery/computer/rdconsole/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/computer/rdconsole/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if((screen == "protolathe" && !linked_lathe) || (screen == "circuit_imprinter" && !linked_imprinter))
		screen = "main" // Kick us from protolathe or imprinter screen if they were destroyed
	var/list/data = list()
	data["screen"] = screen
	data["sync"] = sync
	data["has_disk"] = !!disk
	if(disk)
		data["disk_size"] = disk.max_capacity
		data["disk_used"] = disk.used_capacity

	// Main screen needs info about tech levels
	if(!screen || screen == "main")
		data["show_settings"] = show_settings
		data["show_link_menu"] = show_link_menu
		data["has_dest_analyzer"] = !!linked_destroy
		data["has_protolathe"] = !!linked_lathe
		data["has_circuit_imprinter"] = !!linked_imprinter
		data["can_research"] = can_research

		var/list/tech_tree_list = list()
		for(var/tech_tree_id in files.tech_trees)
			var/datum/tech/Tech_Tree = files.tech_trees[tech_tree_id]
			if(!Tech_Tree.shown)
				continue
			var/list/tech_tree_data = list(
				"id" =             Tech_Tree.id,
				"name" =           "[Tech_Tree.name]",
				"shortname" =      "[Tech_Tree.shortname]",
				"level" =          Tech_Tree.level,
				"maxlevel" =       Tech_Tree.maxlevel,
			)
			tech_tree_list += list(tech_tree_data)
		data["tech_trees"] = tech_tree_list

		if(linked_lathe)
			data["protolathe_data"] = get_protolathe_data()

		if(linked_imprinter)
			data["imprinter_data"] = get_imprinter_data()

		if(linked_destroy)
			if(linked_destroy.loaded_item)
				var/list/tech_names = list(TECH_MATERIAL = "Materials", TECH_ENGINEERING = "Engineering", TECH_PHORON = "Phoron", TECH_POWER = "Powerstorage", TECH_BLUESPACE = "Blue-space", TECH_BIO = "Biotech", TECH_COMBAT = "Combat", TECH_MAGNET = "Electromagnetic", TECH_DATA = "Programming", TECH_ESOTERIC = "Illegal")

				var/list/temp_tech = linked_destroy.loaded_item.origin_tech
				var/list/item_data = list()

				for(var/T in temp_tech)
					var/tech_name = tech_names[T]
					if(!tech_name)
						tech_name = T

					item_data += list(list(
						"id" =             T,
						"name" =           tech_name,
						"level" =          temp_tech[T],
					))

				// This calculates how much research points we missed because we already researched items with such orig_tech levels
				var/research_value = files.experiments.get_object_research_value(linked_destroy.loaded_item, ignoreRepeat = TRUE)
				var/tech_points_mod = research_value
				if(research_value)
					tech_points_mod = files.experiments.get_object_research_value(linked_destroy.loaded_item) / research_value

				var/list/destroy_list = list(
					"has_item" =              TRUE,
					"item_name" =             linked_destroy.loaded_item.name,
					"item_tech_points" =      files.experiments.get_object_research_value(linked_destroy.loaded_item),
					"item_tech_mod" =         round(tech_points_mod*100),
				)
				destroy_list["tech_data"] = item_data

				data["destroy_data"] = destroy_list
			else
				var/list/destroy_list = list(
					"has_item" =             FALSE,
				)
				data["destroy_data"] = destroy_list

	if(screen == "protolathe")
		if(linked_lathe)
			data["search_text"] = search_text
			data["protolathe_data"] = get_protolathe_data()
			data["all_categories"] = files.design_categories_protolathe
			if(search_text)
				data["all_categories"] = list("Search Results") + data["all_categories"]

			if((!selected_protolathe_category || !(selected_protolathe_category in data["all_categories"])) && LAZYLEN(files.design_categories_protolathe))
				selected_protolathe_category = files.design_categories_protolathe[1]

			if(selected_protolathe_category)
				data["selected_category"] = selected_protolathe_category
				data["possible_designs"] = get_possible_designs_data(PROTOLATHE, selected_protolathe_category)

			var/list/queue_list = list()
			queue_list["can_restart"] = (LAZYLEN(linked_lathe.queue) && !linked_lathe.busy)
			queue_list["queue"] = list()
			for(var/datum/rnd_queue_design/RNDD in linked_lathe.queue)
				queue_list["queue"] += RNDD.name
			data["queue_data"] = queue_list

	if(screen == "circuit_imprinter")
		if(linked_imprinter)
			data["search_text"] = search_text
			data["imprinter_data"] = get_imprinter_data()
			data["all_categories"] = files.design_categories_imprinter
			if(search_text)
				data["all_categories"] = list("Search Results") + data["all_categories"]

			if((!selected_imprinter_category || !(selected_imprinter_category in data["all_categories"])) && LAZYLEN(files.design_categories_imprinter))
				selected_imprinter_category = files.design_categories_imprinter[1]

			if(selected_imprinter_category)
				data["selected_category"] = selected_imprinter_category
				data["possible_designs"] = get_possible_designs_data(IMPRINTER, selected_imprinter_category)


			var/list/queue_list = list()
			queue_list["can_restart"] = (LAZYLEN(linked_imprinter.queue) && !linked_imprinter.busy)
			queue_list["queue"] = list()
			for(var/datum/rnd_queue_design/RNDD in linked_imprinter.queue)
				queue_list["queue"] += RNDD.name
			data["queue_data"] = queue_list

	if(screen == "disk_management_designs")
		if(disk)
			var/list/disk_designs = list()
			var/list/disk_design_files = disk.find_files_by_type(/datum/computer_file/binary/design)
			for(var/f in disk_design_files)
				var/datum/computer_file/binary/design/d_file = f
				disk_designs += list(list("name" = d_file.design.shortname, "id" = "\ref[d_file]"))
			data["disk_designs"] = disk_designs
			var/list/known_designs = list()
			for(var/i in files.known_designs)
				var/datum/design/D = i
				known_designs += list(list("name" = D.shortname, "id" = "\ref[D]"))
			data["known_designs"] = known_designs

			var/list/disk_science = list()
			var/list/disk_sciecne_files = disk.find_files_by_type(/datum/computer_file/binary/sci)
			for(var/f in disk_sciecne_files)
				var/datum/computer_file/binary/sci/s_file = f
				disk_science += list(list("name" = s_file.filename, "id" = "\ref[s_file]"))
			data["disk_science"] = disk_science

	// All the info needed for displaying tech trees
	if(screen == "tech_trees")
		var/list/line_list = list()

		var/list/tech_tree_list = list()
		for(var/tech_tree_id in files.tech_trees)
			var/datum/tech/Tech_Tree = files.tech_trees[tech_tree_id]
			if(!Tech_Tree.shown)
				continue
			var/list/tech_tree_data = list(
				"id" =             Tech_Tree.id,
				"name" =           "[Tech_Tree.name]",
				"shortname" =      "[Tech_Tree.shortname]",
			)
			tech_tree_list += list(tech_tree_data)

		data["tech_trees"] = tech_tree_list

		if(!selected_tech_tree)
			selected_tech_tree = files.all_technologies[1]

		var/list/tech_list = list()
		if(selected_tech_tree && files.all_technologies[selected_tech_tree])
			var/datum/tech/Tech_Tree = files.tech_trees[selected_tech_tree]
			data["tech_tree_name"] = Tech_Tree.name
			data["tech_tree_desc"] = Tech_Tree.desc
			data["tech_tree_level"] = Tech_Tree.level

			for(var/tech_id in files.all_technologies[selected_tech_tree])
				var/datum/technology/Tech = files.all_technologies[selected_tech_tree][tech_id]
				var/list/tech_data = list(
					"id" =             Tech.id,
					"name" =           "[Tech.name]",
					"x" =              round(Tech.x*100),
					"y" =              round(Tech.y*100),
					"icon" =           "[Tech.icon]",
					"isresearched" =   "[files.IsResearched(Tech)]",
					"canresearch" =    "[files.CanResearch(Tech)]",
				)
				tech_list += list(tech_data)

				for(var/req_tech_id in Tech.required_technologies)
					if(files.all_technologies[selected_tech_tree][req_tech_id])
						var/datum/technology/OTech = files.all_technologies[selected_tech_tree][req_tech_id]
						if(OTech.tech_type == Tech.tech_type)
							var/line_x = (min(round(OTech.x*100), round(Tech.x*100)))
							var/line_y = (min(round(OTech.y*100), round(Tech.y*100)))
							var/width = (abs(round(OTech.x*100) - round(Tech.x*100)))
							var/height = (abs(round(OTech.y*100) - round(Tech.y*100)))

							var/istop = FALSE
							if(OTech.y > Tech.y)
								istop = TRUE
							var/isright = FALSE
							if(OTech.x < Tech.x)
								isright = TRUE

							var/list/line_data = list(
								"line_x" =           line_x,
								"line_y" =           line_y,
								"width" =            width,
								"height" =           height,
								"istop" =            istop,
								"isright" =          isright,
							)
							line_list += list(line_data)

		data["techs"] = tech_list
		data["lines"] = line_list
		data["selected_tech_tree"] = selected_tech_tree
		data["research_points"] = files.research_points

		data["selected_technology_id"] = ""
		if(selected_technology)
			var/datum/technology/Tech = files.all_technologies[selected_tech_tree][selected_technology]
			var/list/technology_data = list(
				"name" =           Tech.name,
				"desc" =           Tech.desc,
				"id" =             Tech.id,
				"tech_type" =      Tech.tech_type,
				"cost" =           Tech.cost,
				"isresearched" =   files.IsResearched(Tech),
			)
			data["selected_technology_id"] = Tech.id

			var/list/requirement_list = list()
			for(var/t in Tech.required_tech_levels)
				var/datum/tech/Tech_Tree = files.tech_trees[t]

				var/level = Tech.required_tech_levels[t]
				var/list/req_data = list(
					"text" =           "[Tech_Tree.shortname] level [level]",
					"isgood" =         (Tech_Tree.level >= level)
				)
				requirement_list += list(req_data)
			for(var/t in Tech.required_technologies)
				var/datum/technology/OTech = files.all_technologies[selected_tech_tree][t]

				var/list/req_data = list(
					"text" =           "[OTech.name]",
					"isgood" =         files.IsResearched(OTech)
				)
				requirement_list += list(req_data)
			technology_data["requirements"] = requirement_list

			var/list/unlock_list = list()
			for(var/T in Tech.unlocks_designs)
				var/datum/design/D = files.design_by_id[T]
				var/list/unlock_data = list(
					"text" = "[D.shortname]"
				)
				unlock_list += list(unlock_data)
			technology_data["unlocks"] = unlock_list

			data["selected_technology"] = technology_data

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "rdconsole.tmpl", "R&D Console", 1000, 700)

		ui.set_initial_data(data)
		ui.open()
//[/SIERRA-EDIT] - MODPACK_RND

/obj/machinery/computer/rdconsole/robotics
	name = "robotics fabrication console"
	id = 2
	req_access = list(access_robotics)
	can_analyze = FALSE

/obj/machinery/computer/rdconsole/core
	name = "core fabricator console"
	id = 1
/obj/machinery/computer/rdconsole/attack_ai(mob/user)
	. = ..()
	ui_interact(user)
