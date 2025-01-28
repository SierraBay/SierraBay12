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
	have_recycling = FALSE
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



/obj/machinery/fabricator/rnd/imprinter
	name = "circuit imprinter"
	desc = "A machine used for printing advanced circuit boards. Operated from an R\&D console."
	icon_state = "imprinter"

	build_type = IMPRINTER


/obj/machinery/fabricator/rnd/imprinter/loaded/Initialize()
	. = ..()
	container = new /obj/item/reagent_containers/glass/beaker(src)
