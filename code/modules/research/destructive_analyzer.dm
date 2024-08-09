/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/

/obj/machinery/r_n_d/destructive_analyzer
	name = "destructive analyzer"
	desc = "Accessed by a connected core fabricator console, it destroys and analyzes items and materials, recycling materials to any connected protolathe, and progressing the learning matrix of the connected core fabricator console."
	icon_state = "d_analyzer"
	icon = 'icons/obj/machines/research/destructive_analyzer.dmi'
	var/obj/item/loaded_item = null
	var/decon_mod = 0

	idle_power_usage = 30
	active_power_usage = 2500
	construct_state = /singleton/machine_construction/default/panel_closed

	machine_name = "destructive analyzer"
	machine_desc = "Breaks down objects into their component parts, gaining new information in the process. Part of an R&D network."

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in src)
		T += S.rating
	decon_mod = min(T * 0.1, 3)
	..()

/obj/machinery/r_n_d/destructive_analyzer/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("d_analyzer_panel")
	if(is_powered())
		if(loaded_item)
			AddOverlays(emissive_appearance(icon, "d_analyzer_lights_item"))
		else
			AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
			//[SIERRA-EDIT] - MODPACK_RND
			icon_state = "d_analyzer"

/obj/machinery/r_n_d/destructive_analyzer/state_transition(singleton/machine_construction/default/new_state)
	. = ..()
	if(istype(new_state) && linked_console)
		linked_console.linked_destroy = null
		linked_console = null

/obj/machinery/r_n_d/destructive_analyzer/components_are_accessible(path)
	return !busy && ..()

/obj/machinery/r_n_d/destructive_analyzer/cannot_transition_to(state_path)
	if(busy)
		return SPAN_NOTICE("\The [src] is busy. Please wait for completion of previous operation.")
	if(loaded_item)
		return SPAN_NOTICE("There is something already loaded into \the [src]. You must remove it first.")
	return ..()

/obj/machinery/r_n_d/destructive_analyzer/use_tool(obj/item/O, mob/living/user, list/click_params)
	if(busy)
		to_chat(user, SPAN_NOTICE("\The [src] is busy right now."))
		return TRUE
	if((. = ..()))
		return
	if(loaded_item)
		to_chat(user, SPAN_NOTICE("There is something already loaded into \the [src]."))
		return TRUE
	if(panel_open)
		to_chat(user, SPAN_NOTICE("You can't load \the [src] while it's opened."))
		return TRUE
	if(!linked_console)
		to_chat(user, SPAN_NOTICE("\The [src] must be linked to an R&D console first."))
		return TRUE
	if(!loaded_item)
		if(isrobot(user)) //Don't put your module items in there!
			return FALSE
		if(!O.origin_tech)
			to_chat(user, SPAN_NOTICE("This doesn't seem to have a tech origin."))
			return TRUE
		if(length(O.origin_tech) == 0 || O.holographic)
			to_chat(user, SPAN_NOTICE("You cannot deconstruct this item."))
			return TRUE
		if(!user.unEquip(O, src))
			return TRUE
		busy = 1
		loaded_item = O
		to_chat(user, SPAN_NOTICE("You add \the [O] to \the [src]."))
		icon_state = "d_analyzer_entry"
		SSnano.update_uis(linked_console)
		spawn(10)
			on_update_icon()
			busy = 0

			if (linked_console.quick_deconstruct)
				deconstruct_item(weakref(user))

		return TRUE


/obj/machinery/r_n_d/destructive_analyzer/proc/eject_item()
	if(busy)
		to_chat(usr, "<span class='warning'>The destructive analyzer is busy at the moment.</span>")
		return

	if(loaded_item)
		loaded_item.forceMove(loc)
		loaded_item = null
		on_update_icon()
	SSnano.update_uis(linked_console)

/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/destructive_analyzer/proc/deconstruct_item()
	if(busy)
		to_chat(usr, "<span class='warning'>The destructive analyzer is busy at the moment.</span>")
		return
	if(!loaded_item)
		return

	busy = TRUE
	flick("d_analyzer_process", src)
	if(linked_console)
		linked_console.screen = "working"
	addtimer(new Callback(src, PROC_REF(finish_deconstructing)), 15)

/obj/machinery/r_n_d/destructive_analyzer/proc/finish_deconstructing()
	busy = FALSE
	if(hacked)
		return

	if(linked_console)
		linked_console.files.check_item_for_tech(loaded_item)
		linked_console.files.research_points += linked_console.files.experiments.get_object_research_value(loaded_item)
		linked_console.files.experiments.do_research_object(loaded_item)

//		if(linked_console.linked_lathe)//Придумать как он будет возвращать ресурсы с предметов
//			linked_console.linked_lathe.loaded_materials[MAT_METAL].amount += round(min((linked_console.linked_lathe.max_material_storage - linked_console.linked_lathe.TotalMaterials()), (loaded_item.m_amt*(decon_mod/10))))
//			linked_console.linked_lathe.loaded_materials[MAT_GLASS].amount += round(min((linked_console.linked_lathe.max_material_storage - linked_console.linked_lathe.TotalMaterials()), (loaded_item.g_amt*(decon_mod/10))))

	if(istype(loaded_item,/obj/item/stack/material))
		var/obj/item/stack/material/S = loaded_item
		if(S.amount == 1)
			qdel(S)
			on_update_icon()
			loaded_item = null
		else
			S.use(1)
	else
		qdel(loaded_item)
		on_update_icon()
		loaded_item = null

	use_power_oneoff(250)
	if(linked_console)
		linked_console.screen = "main"
		SSnano.update_uis(linked_console)


	if(loaded_item)
		loaded_item.forceMove(loc)
		loaded_item = null
	on_update_icon()

/obj/machinery/r_n_d/destructive_analyzer/power_change()
	. = ..()
	eject_item()
//[/SIERRA-EDIT] - MODPACK_RND
