//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.
//[/SIERRA-EDIT] - MODPACK_RND
var/global/list/default_material_composition = list(MATERIAL_STEEL = 0, MATERIAL_ALUMINIUM = 0, MATERIAL_PLASTIC = 0, MATERIAL_GLASS = 0, MATERIAL_GOLD = 0, MATERIAL_SILVER = 0, MATERIAL_PHORON = 0, MATERIAL_URANIUM = 0, MATERIAL_DIAMOND = 0)
/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research/protolathe.dmi'
	density = TRUE
	anchored = TRUE
	uncreated_component_parts = null
	stat_immune = 0
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/obj/machinery/computer/rdconsole/linked_console

	var/list/materials = list()

/obj/machinery/r_n_d/dismantle()
	for(var/obj/I in src)
		if(istype(I, /obj/item/reagent_containers/glass/beaker))
			reagents.trans_to_obj(I, reagents.total_volume)
	for(var/f in materials)
		if(materials[f] >= SHEET_MATERIAL_AMOUNT)
			new /obj/item/stack/material(loc, round(materials[f] / SHEET_MATERIAL_AMOUNT), f)
	return ..()

/obj/machinery/r_n_d/proc/check_craftable_amount_by_material(datum/design/D, mat)
	var/A = materials[mat]
	A = A / max(1 , (D.materials[mat])) // loaded material / required material
	return A

/obj/machinery/r_n_d/circuit_imprinter/proc/check_craftable_amount_by_chemical(datum/design/design, reagent)
	var/A = design.chemicals[reagent]
	A = A / max(1, (design.chemicals[reagent]))

	return A
//[/SIERRA-EDIT] - MODPACK_RND
