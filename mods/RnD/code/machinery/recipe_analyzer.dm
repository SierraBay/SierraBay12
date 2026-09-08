// Recipe Analyzer
// Standalone machine (no console required).
// Place a food item inside, insert a disk, click "Analyze" — the machine deconstructs
// the food and writes its recipe as a datum/design/food onto the disk.
//
// Recipe cost formula: chemicals[/datum/reagent/nutriment] = round(total_nutriment * 1.5)
// where total_nutriment includes all /datum/reagent/nutriment subtypes.

/obj/machinery/recipe_analyzer
	name = "recipe analyzer"
	desc = "A compact food analysis unit. Place a dish inside and insert a disk to extract its recipe for use in a food replicator."
	icon = 'mods/RnD/icons/destruct_analyzer.dmi'
	icon_state = "d_analyzer"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = POWER_USE_IDLE
	idle_power_usage = 30
	active_power_usage = 1500

	var/obj/item/loaded_food = null
	var/obj/item/stock_parts/computer/hard_drive/portable/disk = null
	var/busy = FALSE

	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = list(
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/matter_bin,
	)

/obj/machinery/recipe_analyzer/Destroy()
	QDEL_NULL(loaded_food)
	disk = null
	return ..()

/obj/machinery/recipe_analyzer/on_update_icon()
	if(panel_open)
		icon_state = "d_analyzer_t"
	else if(loaded_food)
		icon_state = "d_analyzer_l"
	else
		icon_state = "d_analyzer"

// --- Inserting items ---

/obj/machinery/recipe_analyzer/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(busy)
		to_chat(user, SPAN_NOTICE("\The [src] is busy."))
		return TRUE
	if((. = ..()))
		return
	if(panel_open)
		to_chat(user, SPAN_NOTICE("Close the panel first."))
		return TRUE

	// Insert portable disk
	if(istype(I, /obj/item/stock_parts/computer/hard_drive/portable))
		if(disk)
			to_chat(user, SPAN_NOTICE("A disk is already inserted. Eject it first."))
			return TRUE
		if(user.unEquip(I, src))
			disk = I
			to_chat(user, SPAN_NOTICE("You insert [I] into \the [src]."))
			SSnano.update_uis(src)
			return TRUE

	// Insert food item
	if(istype(I, /obj/item/reagent_containers/food))
		if(loaded_food)
			to_chat(user, SPAN_NOTICE("There is already a dish loaded. Eject it first."))
			return TRUE
		if(user.unEquip(I, src))
			loaded_food = I
			to_chat(user, SPAN_NOTICE("You place \the [I] into \the [src]."))
			flick("d_analyzer_la", src)
			SSnano.update_uis(src)
			return TRUE
		return TRUE

	return

// --- NanoUI ---

/obj/machinery/recipe_analyzer/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/recipe_analyzer/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(user.stat)
		return

	var/list/data = list()
	data["busy"] = busy
	data["has_disk"] = !!disk
	data["disk_name"] = disk ? disk.get_disk_name() : null
	data["has_food"] = !!loaded_food
	data["food_name"] = loaded_food ? loaded_food.name : null

	if(loaded_food && loaded_food.reagents)
		var/nutriment_total = round(loaded_food.reagents.get_reagent_amount(/datum/reagent/nutriment, allow_subtypes = TRUE), 0.1)
		data["nutriment_total"] = nutriment_total
		data["nutriment_cost"] = round(nutriment_total * 1.5, 0.5)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-recipe_analyzer.tmpl", "Recipe Analyzer", 380, 260)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/recipe_analyzer/OnTopic(user, href_list, state)
	if(href_list["eject_food"])
		eject_food(user)
		return TOPIC_REFRESH
	if(href_list["eject_disk"])
		eject_disk(user)
		return TOPIC_REFRESH
	if(href_list["analyze"])
		start_analysis(user)
		return TOPIC_HANDLED

// --- Analysis ---

/obj/machinery/recipe_analyzer/proc/start_analysis(mob/user)
	if(busy)
		to_chat(user, SPAN_WARNING("\The [src] is already working."))
		return
	if(!loaded_food)
		to_chat(user, SPAN_WARNING("Load a dish first."))
		return
	if(!disk)
		to_chat(user, SPAN_WARNING("Insert a disk first."))
		return

	busy = TRUE
	update_use_power(POWER_USE_ACTIVE)
	flick("d_analyzer_process", src)
	to_chat(user, SPAN_NOTICE("\The [src] begins analyzing \the [loaded_food]..."))
	addtimer(new Callback(src, PROC_REF(finish_analysis), user), 3 SECONDS)
	SSnano.update_uis(src)

/obj/machinery/recipe_analyzer/proc/finish_analysis(mob/user)
	busy = FALSE
	update_use_power(POWER_USE_IDLE)

	if(!loaded_food || !disk)
		on_update_icon()
		SSnano.update_uis(src)
		return

	// Calculate nutriment cost
	var/nutriment_total = 0
	if(loaded_food.reagents)
		nutriment_total = loaded_food.reagents.get_reagent_amount(/datum/reagent/nutriment, allow_subtypes = TRUE)
	var/nutriment_cost = max(1, round(nutriment_total * 1.5, 0.5))

	// Build a new design datum on the fly
	var/datum/design/food/dynamic/D = new
	D.name = loaded_food.name
	D.desc = "Replicated [loaded_food.name]. Synthesised from raw nutriment."
	D.id = "food_rep_[lowertext(replacetext(loaded_food.name, " ", "_"))]"
	D.build_path = loaded_food.type
	D.chemicals = list(/datum/reagent/nutriment = nutriment_cost)
	D.AssembleDesignUIData()

	// Wrap in a design file and save to disk
	var/datum/computer_file/binary/design/F = new
	F.design = D
	F.set_filename(D.name)

	if(!disk.save_file(F))
		if(user)
			to_chat(user, SPAN_WARNING("The disk is full or read-only. Analysis data lost."))
	else
		if(user)
			to_chat(user, SPAN_NOTICE("Recipe for [loaded_food.name] saved to disk. Required nutriment: [nutriment_cost] units."))

	// Consume the food
	qdel(loaded_food)
	loaded_food = null

	use_power_oneoff(active_power_usage)
	on_update_icon()
	SSnano.update_uis(src)

// --- Eject procs ---

/obj/machinery/recipe_analyzer/proc/eject_food(mob/user)
	if(busy)
		to_chat(user, SPAN_WARNING("\The [src] is busy."))
		return
	if(!loaded_food)
		return
	loaded_food.forceMove(get_turf(src))
	loaded_food = null
	on_update_icon()

/obj/machinery/recipe_analyzer/proc/eject_disk(mob/user)
	if(busy)
		to_chat(user, SPAN_WARNING("\The [src] is busy."))
		return
	if(!disk)
		return
	disk.forceMove(get_turf(src))
	disk = null
	SSnano.update_uis(src)

// --- Dynamic design datum (created at runtime, not a singleton) ---

/datum/design/food/dynamic
	// All fields set at runtime by finish_analysis

/datum/design/food/dynamic/New()
	// Skip AssembleDesignInfo — fields set manually before AssembleDesignUIData is called
	return

// --- Circuit board ---

/obj/item/stock_parts/circuitboard/recipe_analyzer
	name = "circuit board (recipe analyzer)"
	build_path = /obj/machinery/recipe_analyzer
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_BIO = 1)
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/matter_bin = 1,
	)
