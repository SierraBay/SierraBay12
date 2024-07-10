/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulphuric acid).
*/

/obj/machinery/r_n_d/circuit_imprinter
	name = "circuit imprinter"
	desc = "Accessed by a connected core fabricator console, it produces circuits from various materials and sulphuric acid."
	icon_state = "circuit_imprinter"
	icon = 'icons/obj/machines/research/circuit_imprinter.dmi'
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	base_type = /obj/machinery/r_n_d/circuit_imprinter
	construct_state = /singleton/machine_construction/default/panel_closed

	var/progress = 0

	var/max_material_storage = 100000
	var/mat_efficiency = 1
	var/speed = 1

	idle_power_usage = 30
	active_power_usage = 2500
	machine_name = "circuit imprinter"
	machine_desc = "Creates circuit boards by etching raw sheets of material with sulphuric acid. Part of an R&D network."
	//[SIERRA-EDIT] - MODPACK_RND
	var/list/queue = list()

/obj/machinery/r_n_d/circuit_imprinter/New()
	..()
	materials = default_material_composition.Copy()

/obj/machinery/r_n_d/circuit_imprinter/Process()
	..()
	if(inoperable())
		update_icon()
		return
	if(LAZYLEN(queue) == 0)
		busy = FALSE
		update_icon()
		return
	var/datum/rnd_queue_design/RNDD = queue[1]
	var/datum/design/D = RNDD.design
	if(canBuild(RNDD))
		if(progress == 0)
			print_pre(D)
		busy = TRUE
		progress += speed
		if(progress >= D.time * RNDD.amount)
			build(RNDD)
			progress = 0
			queue -= RNDD
			if(linked_console)
				SSnano.update_uis(linked_console)
			print_post(D)
		update_icon()
	else
		if(busy)
			visible_message(SPAN_NOTICE("\icon[src]\The [src] flashes: insufficient materials."))
			busy = FALSE
			progress = 0
			update_icon()



/obj/machinery/r_n_d/circuit_imprinter/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	var/t = 0
	for(var/f in materials)
		t += materials[f]
	return t


/obj/machinery/r_n_d/circuit_imprinter/RefreshParts()
	var/T = 0
	var/obj/item/stock_parts/building_material/mat = get_component_of_type(/obj/item/stock_parts/building_material)
	if(mat)
		for(var/obj/item/reagent_containers/glass/G in mat.materials)
			T += G.volume
		if(!reagents)
			create_reagents(T)
		else
			reagents.maximum_volume = T

	max_material_storage = 75000 * clamp(total_component_rating_of_type(/obj/item/stock_parts/matter_bin), 0, 10)

	T = clamp(total_component_rating_of_type(/obj/item/stock_parts/manipulator), 0, 3)
	mat_efficiency = 1 - (T - 1) / 4
	speed = T
	..()

/obj/machinery/r_n_d/circuit_imprinter/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("[icon_state]_panel")
	if(is_powered())
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
		AddOverlays("[icon_state]_lights")
	if(busy)
		AddOverlays("[icon_state]_working")

/obj/machinery/r_n_d/circuit_imprinter/state_transition(singleton/machine_construction/default/new_state)
	. = ..()
	if(istype(new_state) && linked_console)
		linked_console.linked_imprinter = null
		linked_console = null

/obj/machinery/r_n_d/circuit_imprinter/components_are_accessible(path)
	return !busy && ..()

/obj/machinery/r_n_d/circuit_imprinter/cannot_transition_to(state_path)
	if(busy)
		return SPAN_NOTICE("\The [src] is busy. Please wait for completion of previous operation.")
	return ..()

/obj/machinery/r_n_d/circuit_imprinter/use_tool(obj/item/O, mob/living/user, list/click_params)
	if(busy)
		to_chat(user, SPAN_NOTICE("\The [src] is busy. Please wait for completion of previous operation."))
		return TRUE
	if ((. = ..()))
		return
	if(panel_open)
		to_chat(user, SPAN_NOTICE("You can't load \the [src] while it's opened."))
		return TRUE
	if(!linked_console)
		to_chat(user, "\The [src] must be linked to an R&D console first.")
		return TRUE
	if(O.is_open_container())
		return FALSE
	if(is_robot_module(O))
		return FALSE
	if(!istype(O, /obj/item/stack/material))
		to_chat(user, SPAN_WARNING("You cannot insert this item into \the [src]!"))
		return TRUE
	if(inoperable())
		to_chat(user, SPAN_WARNING("\The [src] is not working properly."))
		return TRUE

	if(TotalMaterials() + SHEET_MATERIAL_AMOUNT > max_material_storage)
		to_chat(user, SPAN_WARNING("\The [src]'s material bin is full. Please remove material before adding more."))
		return TRUE

	var/obj/item/stack/material/stack = O
	var/amount = min(stack.get_amount(), round((max_material_storage - TotalMaterials()) / SHEET_MATERIAL_AMOUNT))

	busy = 1
	use_power_oneoff(max(1000, (SHEET_MATERIAL_AMOUNT * amount / 10)))

	var/t = stack.material.name
	if(t)
		if(do_after(usr, 1.6 SECONDS, src, DO_PUBLIC_UNIQUE))
			if(stack.use(amount))
				to_chat(user, SPAN_NOTICE("You add [amount] sheet\s to \the [src]."))
				materials[t] += amount * SHEET_MATERIAL_AMOUNT
	busy = 0
	updateUsrDialog()
	return TRUE

/obj/machinery/r_n_d/circuit_imprinter/proc/queue_design(datum/design/D, amount = 1)
	var/datum/rnd_queue_design/RNDD = new /datum/rnd_queue_design(D, amount)
	queue += RNDD

/obj/machinery/r_n_d/circuit_imprinter/proc/removeFromQueue(index)
	if(!is_valid_index(index, queue))
		return
	queue.Cut(index, index + 1)

/obj/machinery/r_n_d/circuit_imprinter/proc/canBuild(datum/rnd_queue_design/RNDD)
	var/datum/design/D = RNDD.design
	for(var/M in D.materials)
		if(materials[M] < (D.materials[M] * RNDD.amount)*mat_efficiency)
			return FALSE
	for(var/C in D.chemicals)
		if(!reagents.has_reagent(C, (D.chemicals[C] * RNDD.amount)*mat_efficiency))
			return FALSE
	return TRUE

/obj/machinery/r_n_d/circuit_imprinter/proc/build(datum/rnd_queue_design/RNDD)
	var/datum/design/D = RNDD.design
	var/power = active_power_usage
	for(var/M in D.materials)
		power += round(D.materials[M] / 5) * RNDD.amount
	power = max(active_power_usage, power)
	use_power_oneoff(power)
	for(var/M in D.materials)
		materials[M] = max(0, materials[M] - ((D.materials[M] * RNDD.amount)*mat_efficiency))
	for(var/C in D.chemicals)
		reagents.remove_reagent(C, ((D.chemicals[C] * RNDD.amount)*mat_efficiency))
	for(var/i in 1 to RNDD.amount)
		D.Fabricate(get_turf(src), 1, src)

/obj/machinery/r_n_d/circuit_imprinter/proc/clear_queue()
	queue = list()

/obj/machinery/r_n_d/circuit_imprinter/proc/eject(material, amount)
	if(!(material in materials))
		return
	var/material/mat = SSmaterials.get_material_by_name(material)
	var/eject = clamp(round(materials[material] / mat.units_per_sheet), 0, amount)
	if(eject > 0)
		mat.place_sheet(loc, eject)
		materials[material] -= eject * mat.units_per_sheet

/obj/machinery/r_n_d/circuit_imprinter/proc/print_pre(datum/design/D)
	return

/obj/machinery/r_n_d/circuit_imprinter/proc/print_post(datum/design/D)
	visible_message("\icon[src]\The [src] flashes, indicating that \the [D] is complete.", range = 3)
	if(!LAZYLEN(queue))
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 1 -3)
		visible_message("\icon[src]\The [src] pings indicating that queue is complete.")
	return
//[/SIERRA-EDIT] - MODPACK_RND
