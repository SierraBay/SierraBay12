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

/obj/machinery/smartfridge/disks/New()
	. = ..()
	on_update_icon()

/obj/machinery/smartfridge/disks/accept_check(obj/item/O as obj)
	if(istype(O, /obj/item/stock_parts/computer/hard_drive/portable))
		return 1
	return 0

/obj/machinery/smartfridge/disks/on_update_icon()
	ClearOverlays()
	if(MACHINE_IS_BROKEN(src))
		icon_state = "[icon_state]-broken"
	else
		icon_state = icon_base

	if(panel_open)
		AddOverlays(image(icon, "[icon_base]-panel"))

	var/image/I
	var/is_off = ""
	if(stat & MACHINE_STAT_NOPOWER)
		is_off = "-off"

	// Fridge contents
	switch(length(contents))
		if(0)
			I = image(icon, "empty[is_off]")
		if(1 to 2)
			I = image(icon, "[icon_contents]-1[is_off]")
		if(3 to 5)
			I = image(icon, "[icon_contents]-2[is_off]")
		else
			I = image(icon, "[icon_contents]-3[is_off]")
	AddOverlays(I)
