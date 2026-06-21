//Devices that link into the R&D console fall into thise type for easy identification and some shared procs.
/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'mods/RnD/icons/destruct_analyzer.dmi'
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = POWER_USE_IDLE
	var/obj/machinery/computer/rdconsole/linked_console

/obj/machinery/r_n_d/attack_hand(mob/user)
	return


//All lathe-type devices that link into the R&D console fall into thise type for easy identification and some shared procs
/obj/machinery/fabricator/rnd
	queue_max = 16

	have_disk = FALSE
	have_disk2 = FALSE
	have_recycling = TRUE
	have_design_selector = FALSE

	var/obj/machinery/computer/rdconsole/linked_console

/obj/machinery/fabricator/rnd/Destroy()
	if(linked_console)
		if(linked_console.linked_lathe == src)
			linked_console.linked_lathe = null
		if(linked_console.linked_imprinter == src)
			linked_console.linked_imprinter = null
		linked_console = null
	return ..()


/obj/machinery/fabricator/rnd/protolathe
	name = "protolathe"
	desc = "A machine used for construction of advanced prototypes. Operated from an R\&D console."
	icon_state = "protolathe"

	build_type = PROTOLATHE
	base_type = /obj/machinery/fabricator/rnd/protolathe



/obj/machinery/fabricator/rnd/imprinter
	name = "circuit imprinter"
	desc = "A machine used for printing advanced circuit boards. Operated from an R\&D console."
	icon_state = "imprinter"

	build_type = IMPRINTER
	base_type = /obj/machinery/fabricator/rnd/imprinter


/obj/machinery/fabricator/rnd/imprinter/loaded/Initialize()
	. = ..()
	container = new /obj/item/reagent_containers/glass/beaker(src)

/obj/machinery/fabricator/rnd/robotics
	name = "robotics fabricator"
	desc = "A heavy-duty fabricator for robotics parts and compact modules."
	icon = 'mods/RnD/icons/autolathe.dmi'
	icon_state = "robofab"
	base_icon_state = "robofab"
	req_access = list(access_robotics)
	build_type = ROBOTFAB
	have_disk = TRUE
	have_design_selector = TRUE
	have_reagents = FALSE
	have_disk2 = FALSE
	base_type = /obj/machinery/fabricator/rnd/robotics

	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null

	var/manufacturer = null

/obj/machinery/fabricator/rnd/robotics/Initialize()
	stored_material = list(
		MATERIAL_STEEL = 0,
		MATERIAL_PLASTEEL = 0,
		MATERIAL_TITANIUM = 0,
		MATERIAL_ALUMINIUM = 0,
		MATERIAL_PLASTIC = 0,
		MATERIAL_GLASS = 0,
		MATERIAL_GOLD = 0,
		MATERIAL_SILVER = 0,
		MATERIAL_PHORON = 0,
		MATERIAL_URANIUM = 0,
		MATERIAL_DIAMOND = 0
	)
	. = ..()

/obj/machinery/fabricator/rnd/robotics/mech
	name = "exosuit fabricator"
	desc = "A heavy-duty fabricator dedicated to large exosuit and mech components."
	build_type = MECHFAB
	base_type = /obj/machinery/fabricator/rnd/robotics/mech
	icon = 'mods/RnD/icons/mech_fab.dmi'
	icon_state = "mechfab"
	base_icon_state = "mechfab"

// mech_fab.dmi uses overlay/body state names _lights / _work / _pause (no mechfab_ prefix).
/obj/machinery/fabricator/rnd/robotics/mech/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("[icon_state]_panel")

	icon_state = initial(icon_state)

	if(icon_off())
		icon_state = "[icon_state]_off"
		return

	if(working) // if paused, work animation looks awkward.
		if(paused || error)
			icon_state = "[icon_state]_pause"
		else
			icon_state = "[icon_state]_work"

/// Tall sprite sits on one turf; spawn printed parts on the tile to the machine's right (see computer.dm left/right vs dir).
/obj/machinery/fabricator/rnd/robotics/mech/proc/get_output_turf_for_build()
	var/turf/left_step = get_step(src, turn(dir, 90))
	if(isturf(left_step) && !left_step.density)
		return left_step
	return get_turf(loc)

/obj/machinery/fabricator/rnd/robotics/mech/fabricate_design(datum/design/design)
	consume_materials(design)
	var/turf/output_turf = get_output_turf_for_build()
	var/obj/new_item = design.Fabricate(output_turf, mat_efficiency, src)
	if(design.reverse_engineered && istype(new_item, /obj/item/storage) && length(new_item.contents))
		for(var/atom/movable/A in new_item.contents)
			qdel(A)
	working = FALSE
	current_file = null
	print_post()
	next_file()


/obj/item/stock_parts/circuitboard/robotics_fabricator
	name = "circuit board (robotics fabricator)"
	build_path = /obj/machinery/fabricator/rnd/robotics
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/datum/design/circuit/robotics_fabricator
	name = "robotech fabricator"
	id = "robofab"
	req_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	build_path = /obj/item/stock_parts/circuitboard/robotics_fabricator
	sort_string = "HABAE"

/obj/item/stock_parts/circuitboard/robotics_fabricator/mech
	name = "circuit board (exosuit fabricator)"
	build_path = /obj/machinery/fabricator/rnd/robotics/mech

/datum/design/circuit/robotics_fabricator/mech
	name = "exosuit fabricator"
	id = "mechfab"
	build_path = /obj/item/stock_parts/circuitboard/robotics_fabricator/mech
	sort_string = "HABAF"

/obj/item/stock_parts/circuitboard/protolathe
	name = "circuit board (protolathe)"
	build_path = /obj/machinery/fabricator/rnd/protolathe
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/reagent_containers/glass/beaker = 2)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/stock_parts/circuitboard/circuit_imprinter
	name = "circuit board (circuit imprinter)"
	build_path = /obj/machinery/fabricator/rnd/imprinter
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/reagent_containers/glass/beaker = 2)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/machinery/smartfridge/disks
	name = "\improper Disks Storage"
	desc = "When you need disks fast!"
	icon_state = "smartfridge"
	icon_base = "smartfridge"
	icon_contents = "disk"
	icon = 'mods/RnD/icons/vending.dmi'
	accepted_types = list(
		/obj/item/stock_parts/computer/hard_drive/portable)

/obj/machinery/smartfridge/disks/permitted
	startswith = list(
		/obj/item/stock_parts/computer/hard_drive/portable/design/components = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/cuttery = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/drinking = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/exploration = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/engineering = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/general = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/medical = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/tool = 1
	)

/obj/machinery/smartfridge/disks/full
	startswith = list(
		/obj/item/stock_parts/computer/hard_drive/portable/design/components = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/cuttery = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/drinking = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/arms = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/engineering = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/general = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/medical = 1,
		/obj/item/stock_parts/computer/hard_drive/portable/design/tool = 1
	)
