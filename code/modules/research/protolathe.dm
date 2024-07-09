//[SIERRA-EDIT] - MODPACK_RND
/datum/rnd_material
	var/name
	var/amount
	var/sheet_size
	var/sheet_type

/datum/rnd_material/New(Name, obj/item/stack/material/Sheet_type)
	name = Name
	amount = 0
	sheet_type = Sheet_type
	sheet_size = initial(Sheet_type.perunit)

/datum/rnd_queue_design
	var/name
	var/datum/design/design
	var/amount

/datum/rnd_queue_design/New(datum/design/D, Amount)
	name = D.name
	if(Amount > 1)
		name = "[name] x[Amount]"

	design = D
	amount = Amount

/obj/machinery/r_n_d/protolathe
	name = "protolathe"
	desc = "Accessed by a connected core fabricator console, it produces items from various materials."
	icon_state = "protolathe"
	icon = 'icons/obj/machines/research/protolathe.dmi'
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_OPEN_CONTAINER

	idle_power_usage = 30
	active_power_usage = 5000
	base_type = /obj/machinery/r_n_d/protolathe
	construct_state = /singleton/machine_construction/default/panel_closed

	machine_name = "protolathe"
	machine_desc = "Uses raw materials to produce prototypes. Part of an R&D network."

	var/max_material_storage = 250000

	var/progress = 0

	var/mat_efficiency = 1
	var/speed = 1
	var/list/queue = list()

/obj/machinery/r_n_d/protolathe/New()
	..()
	materials = default_material_composition.Copy()

/obj/machinery/r_n_d/protolathe/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	var/t = 0
	for(var/f in materials)
		t += materials[f]
	return t

/obj/machinery/r_n_d/protolathe/Process()
	..()
	if(inoperable())
		update_icon()
		return
	if(length(queue) == 0)
		busy = 0
		update_icon()
		return
	var/datum/rnd_queue_design/RNDD = queue[1]
	var/datum/design/D = RNDD.design
	if(canBuild(RNDD))
		busy = 1
		progress += speed
		if(progress >= D.time * RNDD.amount)
			build(RNDD)
			progress = 0
			queue -= RNDD
			if(linked_console)
				SSnano.update_uis(linked_console)
		update_icon()
	else
		if(busy)
			visible_message(SPAN_NOTICE("\icon[src]\The [src] flashes: insufficient materials."))
			busy = 0
			progress = 0
			update_icon()

/obj/machinery/r_n_d/protolathe/RefreshParts()
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

	T = clamp(total_component_rating_of_type(/obj/item/stock_parts/manipulator), 0, 6)
	mat_efficiency = 1 - (T - 2) / 8
	speed = T / 2
	..()

/obj/machinery/r_n_d/protolathe/proc/queue_design(datum/design/D, amount = 1)
	var/datum/rnd_queue_design/RNDD = new /datum/rnd_queue_design(D, amount)
	queue += RNDD

/obj/machinery/r_n_d/protolathe/proc/clear_queue()
	queue = list()
	progress = 0

/obj/machinery/r_n_d/protolathe/proc/canBuild(datum/rnd_queue_design/RNDD)
	var/datum/design/D = RNDD.design
	for(var/M in D.materials)
		if(materials[M] < D.materials[M]*RNDD.amount)
			return FALSE
	for(var/C in D.chemicals)
		if(!reagents.has_reagent(C, D.chemicals[C] * RNDD.amount))
			return FALSE
	return TRUE

/obj/machinery/r_n_d/protolathe/proc/build(datum/rnd_queue_design/RNDD)
	var/power = active_power_usage
	var/datum/design/D = RNDD.design
	for(var/M in D.materials)
		power += round(D.materials[M] / 5, 0.01) * RNDD.amount
	power = max(active_power_usage, power)
	use_power_oneoff(power)
	for(var/M in D.materials)
		materials[M] = max(0, materials[M] - ((D.materials[M] * RNDD.amount)*mat_efficiency))
	for(var/C in D.chemicals)
		reagents.remove_reagent(C, ((D.chemicals[C] * RNDD.amount)*mat_efficiency))
	for(var/i in 1 to RNDD.amount)
		D.Fabricate(get_turf(src), 1, src)


/obj/machinery/r_n_d/protolathe/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("[icon_state]_panel")
	if(is_powered())
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
		AddOverlays("[icon_state]_lights")
	if(busy)
		AddOverlays("[icon_state]_working")
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights_working"))
		AddOverlays("[icon_state]_lights_working")

/obj/machinery/r_n_d/protolathe/state_transition(singleton/machine_construction/default/new_state)
	. = ..()
	if(istype(new_state) && linked_console)
		linked_console.linked_lathe = null
		linked_console = null

/obj/machinery/r_n_d/protolathe/components_are_accessible(path)
	return !busy && ..()

/obj/machinery/r_n_d/protolathe/cannot_transition_to(state_path)
	if(busy)
		return SPAN_NOTICE("\The [src] is busy. Please wait for completion of previous operation.")
	return ..()

/obj/machinery/r_n_d/protolathe/use_tool(obj/item/O, mob/living/user, list/click_params)
	if(busy)
		to_chat(user, SPAN_NOTICE("\The [src] is busy. Please wait for completion of previous operation."))
		return TRUE
	if((. = ..()))
		return
	if(O.is_open_container())
		return FALSE
	if(panel_open)
		to_chat(user, SPAN_NOTICE("You can't load \the [src] while it's opened."))
		return TRUE
	if(!linked_console)
		to_chat(user, SPAN_NOTICE("\The [src] must be linked to an R&D console first!"))
		return TRUE
	if(is_robot_module(O))
		return FALSE
	if(!istype(O, /obj/item/stack/material))
		to_chat(user, SPAN_NOTICE("You cannot insert this item into \the [src]!"))
		return TRUE
	if(inoperable())
		return TRUE

	if(TotalMaterials() + SHEET_MATERIAL_AMOUNT > max_material_storage)
		to_chat(user, SPAN_NOTICE("\The [src]'s material bin is full. Please remove material before adding more."))
		return TRUE

	var/obj/item/stack/material/stack = O

	var/amount = min(stack.get_amount(), round((max_material_storage - TotalMaterials()) / SHEET_MATERIAL_AMOUNT))

	var/image/I = image(icon, "protolathe_stack")
	I.color = stack.material.icon_colour
	AddOverlays(I)
	spawn(10)
		CutOverlays(I)

	busy = 1
	use_power_oneoff(max(1000, (SHEET_MATERIAL_AMOUNT * amount / 10)))
	if(do_after(user, 1.6 SECONDS, src, DO_PUBLIC_UNIQUE))
		if(stack.get_amount() >= amount)
			if(stack.use(amount))
				to_chat(user, SPAN_NOTICE("You add [amount] sheet\s to \the [src]."))
				materials[stack.material.name] += amount * SHEET_MATERIAL_AMOUNT

	busy = 0
	SSnano.update_uis()
	return TRUE


/obj/machinery/r_n_d/protolathe/proc/removeFromQueue(index)
	if(!is_valid_index(index, queue))
		return
	queue.Cut(index, index + 1)

/obj/machinery/r_n_d/protolathe/proc/eject(material, amount)
	if(!(material in materials))
		return
	var/material/mat = SSmaterials.get_material_by_name(material)
	var/eject = clamp(round(materials[material] / mat.units_per_sheet), 0, amount)
	if(eject > 0)
		mat.place_sheet(loc, eject)
		materials[material] -= eject * mat.units_per_sheet
//[/SIERRA-EDIT] - MODPACK_RND
