/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/

/obj/machinery/r_n_d/destructive_analyzer
	name = "destructive analyzer"
	icon_state = "d_analyzer"
	var/obj/item/loaded_item = null
	var/decon_mod = 0
	var/busy = FALSE

	idle_power_usage = 30
	active_power_usage = 2500
	construct_state = /singleton/machine_construction/default/panel_closed

	machine_name = "destructive analyzer"
	machine_desc = "Breaks down objects into their component parts, gaining new information in the process. Part of an R&D network."

/obj/machinery/r_n_d/destructive_analyzer/Destroy()
	if(linked_console)
		if(linked_console.linked_destroy == src)
			linked_console.linked_destroy = null
		linked_console = null
	return ..()

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in src)
		T += S.rating
	decon_mod = T * 0.1

/obj/machinery/r_n_d/destructive_analyzer/on_update_icon()
	if(panel_open)
		icon_state = "d_analyzer_t"
	else if(loaded_item)
		icon_state = "d_analyzer_l"
	else
		icon_state = "d_analyzer"

/obj/machinery/r_n_d/destructive_analyzer/use_tool(obj/item/I, mob/living/user, list/click_params)
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
	if(!loaded_item && istype(I))
		if(!I.origin_tech)
			to_chat(user, SPAN_NOTICE("This doesn't seem to have a tech origin."))
			return
		if(LAZYLEN(I.origin_tech) == 0)
			to_chat(user, SPAN_NOTICE("You cannot deconstruct this item."))
			return

		if(user.unEquip(I, src))
			busy = TRUE
			loaded_item = I
			to_chat(user, SPAN_NOTICE("You add \the [I] to \the [src]."))
			flick("d_analyzer_la", src)
			addtimer(new Callback(src, PROC_REF(reset_busy)), 1 SECONDS)
			return TRUE
	return

/obj/machinery/r_n_d/destructive_analyzer/proc/reset_busy()
	busy = FALSE
	on_update_icon()
	if(linked_console)
		SSnano.update_uis(linked_console)

// If this returns true, the rdconsole caller will set its screen to SCREEN_WORKING
/obj/machinery/r_n_d/destructive_analyzer/proc/deconstruct_item()
	if(busy)
		to_chat(usr, SPAN_WARNING("The destructive analyzer is busy at the moment."))
		return
	if(!loaded_item)
		return

	busy = TRUE
	flick("d_analyzer_process", src)
	addtimer(new Callback(src, PROC_REF(finish_deconstructing)), 2.4 SECONDS)
	return TRUE

/obj/machinery/r_n_d/destructive_analyzer/proc/finish_deconstructing()
	busy = FALSE
	if(!loaded_item)
		return
	if(linked_console)
		linked_console.handle_item_analysis(loaded_item)
	for(var/mob/living/carbon/human/H in viewers(src))
		SEND_SIGNAL(H, "destructive_analizer", loaded_item)
	if(istype(loaded_item,/obj/item/stack))
		var/obj/item/stack/S = loaded_item
		if(S.amount <= 1)
			qdel(S)
			loaded_item = null
		else
			S.use(1)
	else
		qdel(loaded_item)
		loaded_item = null

	use_power_oneoff(active_power_usage)
	on_update_icon()
	if(linked_console)
		linked_console.reset_screen()

/obj/machinery/r_n_d/destructive_analyzer/proc/eject_item()
	if(busy)
		to_chat(usr, SPAN_WARNING("The destructive analyzer is busy at the moment."))
		return

	if(loaded_item)
		loaded_item.forceMove(loc)
		loaded_item = null
		on_update_icon()
