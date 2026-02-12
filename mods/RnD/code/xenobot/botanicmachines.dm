/obj/machinery/botany
	icon = 'icons/obj/machines/hydroponics_machines.dmi'
	icon_state = "hydrotray"
	density = TRUE
	anchored = TRUE

	use_power = POWER_USE_IDLE
	idle_power_usage = 10
	active_power_usage = 2000

	var/obj/item/seeds/seed // Currently loaded seed packet
	var/obj/item/stock_parts/computer/hard_drive/portable/disk //Currently loaded data disk
	var/datum/computer_file/binary/plantgene/loaded_gene //Currently loaded plant gene

	var/action_time = 5 SECONDS
	var/failed_task = FALSE
	var/open = 0

/obj/machinery/botany/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/botany/proc/start_task()
	// UI is updated by "return TRUE" in Topic()
	use_power = POWER_USE_ACTIVE

	addtimer(new Callback(src, .proc/finish_task), action_time)

/obj/machinery/botany/proc/finish_task()
	use_power = POWER_USE_IDLE
	SSnano.update_uis(src)
	if(failed_task)
		failed_task = FALSE
		visible_message("[src] pings unhappily, flashing a red warning light.")
	else
		visible_message("[src] pings happily.")

/obj/machinery/botany/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W,/obj/item/seeds))
		if(seed)
			to_chat(user, "There is already a seed loaded.")
			return TRUE
		var/obj/item/seeds/S =W
		if(S.seed && S.seed.get_trait(TRAIT_IMMUTABLE) > 0)
			to_chat(user, "That seed is not compatible with our genetics technology.")
		else if(user.unEquip(W, src))
			seed = W
			to_chat(user, "You load [W] into [src].")
			ui_interact(user)
		return TRUE

	if(isScrewdriver(W))
		open = !open
		to_chat(user, SPAN_NOTICE("You [open ? "open" : "close"] the maintenance panel."))
		return TRUE

	if(open && isCrowbar(W))
		dismantle()
		return TRUE

	if(istype(W, /obj/item/stock_parts/computer/hard_drive/portable))
		if(disk)
			to_chat(user, SPAN_WARNING("There is already a data disk loaded."))
		else
			user.drop_from_inventory(W)
			W.forceMove(src)
			disk = W
			SSnano.update_uis(src)
			to_chat(user, SPAN_NOTICE("You load [W] into [src]."))
			ui_interact(user)
		return
	..()

/obj/machinery/botany/ui_data()
	var/list/data = list()
	data["active"] = (use_power == POWER_USE_ACTIVE)

	data["loaded_gene"] = loaded_gene?.ui_data()

	if(disk)
		var/list/disk_genes = list()
		for(var/f in disk.find_files_by_type(/datum/computer_file/binary/plantgene))
			var/datum/computer_file/gene = f
			disk_genes.Add(list(gene.ui_data()))

		data["disk"] = list(
			"max_capacity" = disk.max_capacity,
			"used_capacity" = disk.used_capacity,
			"stored_genes" = disk_genes
		)

	if(seed)
		data["seed"] = list(
			"name" = seed.name,
			"degradation" = seed.modified
		)

	return data

/obj/machinery/botany/Topic(href, href_list)
	if(..())
		return TRUE

	if(href_list["eject_seed"])
		if(!seed)
			return TRUE

		if(seed.seed.name == "new line" || isnull(SSplants.seeds[seed.seed.name]))
			seed.seed.uid = LAZYLEN(SSplants.seeds) + 1
			seed.seed.name = "[seed.seed.uid]"
			SSplants.seeds[seed.seed.name] = seed.seed

		seed.update_seed()

		to_chat(usr, SPAN_NOTICE("You remove \the [seed] from \the [src]."))

		seed.dropInto(loc)
		if(Adjacent(usr))
			usr.put_in_active_hand(seed)

		seed = null
		return TRUE

	if(href_list["eject_disk"])
		if(!disk)
			return TRUE

		to_chat(usr, SPAN_NOTICE("You remove \the [disk] from \the [src]."))

		disk.dropInto(loc)
		if(Adjacent(usr))
			usr.put_in_active_hand(disk)

		disk = null
		return TRUE

	if(href_list["clear_gene"])
		loaded_gene = null
		return TRUE

	if(href_list["load_gene"])
		if(!disk)
			return TRUE

		var/datum/computer_file/binary/plantgene/gene = disk.find_file_by_name(href_list["load_gene"])
		if(istype(gene))
			loaded_gene = gene.clone()
		return TRUE

	if(href_list["delete_gene"])
		if(!disk)
			return TRUE

		disk.remove_file(disk.find_file_by_name(href_list["delete_gene"]))
		return TRUE

	if(href_list["save_gene"])
		if(!loaded_gene || !disk)
			return TRUE

		disk.save_file(loaded_gene.clone())
		return TRUE



// Allows for a trait to be extracted from a seed packet, destroying that seed.
/obj/machinery/botany/extractor
	name = "lysis-isolation centrifuge"
	icon = 'icons/obj/machines/research/virology.dmi'
	icon_state = "centrifuge"
	var/genes_processed = FALSE

/obj/machinery/botany/extractor/ui_data()
	var/list/data = ..()

	var/list/geneMasks = list()
	for(var/gene_tag in SSplants.gene_tag_masks)
		geneMasks.Add(list(list("tag" = gene_tag, "mask" = SSplants.gene_tag_masks[gene_tag])))
	data["geneMasks"] = geneMasks

	if(seed && genes_processed)
		data["hasGenetics"] = TRUE
		data["sourceName"] = seed.seed.display_name
		if(!seed.seed.roundstart)
			data["sourceName"] += " (variety #[seed.seed.uid])"
	else
		data["hasGenetics"] = FALSE

	return data

/obj/machinery/botany/extractor/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	var/list/data = ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mods-botany_isolator.tmpl", "Lysis-isolation Centrifuge", 800, 750)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/botany/extractor/Topic(href, href_list)
	var/mob/user = usr
	if(..())
		return TRUE

	if(href_list["scan_genome"])
		if(!seed || genes_processed)
			return TRUE

		genes_processed = TRUE

		start_task()
		return TRUE

	if(href_list["get_gene"])
		if(!seed || !genes_processed)
			return TRUE

		var/datum/computer_file/binary/plantgene/P = seed.seed.get_gene(href_list["get_gene"])
		if(!P)
			return TRUE
		loaded_gene = P

		if(user)
			seed.modified += rand(20,60) + user.skill_fail_chance(SKILL_BOTANY, 100, SKILL_TRAINED)
			var/expertise = max(0, user.get_skill_value(SKILL_BOTANY) - SKILL_TRAINED)
			seed.modified = max(0, seed.modified - 10*expertise)

		if(seed.modified >= 100)
			failed_task = TRUE
			QDEL_NULL(seed)
			genes_processed = FALSE

		start_task()
		return 1

	if(href_list["clear_buffer"])
		QDEL_NULL(seed)
		genes_processed = FALSE
		return TRUE

	if(href_list["eject_seed"] && genes_processed)
		return TRUE


// Fires an extracted trait into another packet of seeds.
/obj/machinery/botany/editor
	name = "bioballistic delivery system"
	icon = 'icons/obj/machines/research/virology.dmi'
	icon_state = "incubator"

/obj/machinery/botany/editor/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	var/list/data = ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mods-botany_editor.tmpl", "Bioballistic Delivery System", 600, 650)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/botany/editor/Topic(href, href_list)
	if(..())
		return TRUE

	var/mob/user = usr

	if(href_list["apply_gene"])
		if(!loaded_gene || !seed)
			return TRUE


		var/expertise = 0
		if(user)
			expertise = user.get_skill_value(SKILL_BOTANY)

		// Calculate damage based on expertise level
		// No skill: 50-100 damage | Max skill: 5-20 damage
		var/damage_min
		var/damage_max

		if(expertise >= 4)
			damage_min = 10
			damage_max = 25
		else if(expertise == 3)
			damage_min = 15
			damage_max = 35
		else if(expertise == 2)
			damage_min = 25
			damage_max = 55
		else if(expertise == 1)
			damage_min = 37
			damage_max = 77
		else
			damage_min = 60
			damage_max = 100

		// Add calculated damage
		seed.modified += rand(damage_min, damage_max)
		if(seed.modified >= 100)
			seed.modified = 100
			failed_task = TRUE

		if(!isnull(SSplants.seeds[seed.seed.name]))
			seed.seed = seed.seed.diverge(1)
			seed.seed_type = seed.seed.name
			seed.update_seed()

		if(!failed_task)
			seed.seed.apply_gene(loaded_gene)

		start_task()
		return TRUE
