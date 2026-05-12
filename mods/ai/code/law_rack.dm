/obj/item/law_module
	name = "\improper AI law module"
	desc = "A removable data module for use in a physical AI law rack."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 5.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = list(TECH_DATA = 3)
	var/module_label = ""

/obj/item/law_module/supplied
	name = "\improper supplied law module"
	desc = "A removable supplied-law module for use in a physical AI law rack."
	var/law_text = ""

/obj/item/law_module/supplied/attack_self(mob/user)
	..()
	var/new_law = sanitize(input(user, "Enter the supplied law text.", "Supplied Law", law_text) as null|message)
	if(!user || QDELETED(user) || QDELETED(src) || user.incapacitated())
		return
	if(user.get_active_hand() != src && user.get_inactive_hand() != src)
		return
	if(!new_law)
		return
	law_text = new_law
	module_label = copytext(law_text, 1, 32)
	desc = "A removable supplied-law module containing: '[law_text]'"

/obj/machinery/law_rack
	name = "\improper AI law rack"
	desc = "A physical rack for ordered supplied-law modules."
	icon = 'icons/obj/machines/research/server.dmi'
	icon_state = "server"
	density = TRUE
	anchored = TRUE
	req_access = list(access_ai_upload)
	var/mob/living/silicon/ai/linked_ai = null
	var/list/module_slots = list(null, null, null, null, null, null)
	var/max_slots = 6
	var/sync_in_progress = FALSE
	var/last_sync_time = ""
	var/last_sync_status = "Never"

/obj/machinery/law_rack/Initialize()
	. = ..()
	if(!islist(module_slots) || length(module_slots) != max_slots)
		module_slots = list()
		module_slots.len = max_slots

/obj/machinery/law_rack/Destroy()
	var/turf/T = get_turf(src)
	for(var/i = 1 to length(module_slots))
		var/obj/item/law_module/module = module_slots[i]
		if(module && !QDELETED(module) && T)
			module.forceMove(T)
	module_slots.Cut()
	linked_ai = null
	return ..()

/obj/machinery/law_rack/DefaultTopicState()
	return GLOB.physical_state

/obj/machinery/law_rack/interface_interact(mob/user)
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE
	interact(user)
	return TRUE

/obj/machinery/law_rack/use_tool(obj/item/O, mob/living/user, list/click_params)
	if(istype(O, /obj/item/law_module/supplied))
		insert_module(O, user)
		return TRUE
	return ..()

/obj/machinery/law_rack/OnTopic(mob/user, href_list, datum/topic_state/state)
	if(!CanInteract(user, state))
		return TOPIC_NOACTION

	if(href_list["link_ai"])
		if(!check_rack_access(user))
			return TOPIC_NOACTION
		link_ai(user)
		interact(user)
		return TOPIC_REFRESH

	if(href_list["force_sync"])
		if(!check_rack_access(user))
			return TOPIC_NOACTION
		force_sync(user)
		interact(user)
		return TOPIC_REFRESH

	if(href_list["remove"])
		if(!check_rack_access(user))
			return TOPIC_NOACTION
		var/slot = text2num(href_list["remove"])
		remove_module(slot, user)
		interact(user)
		return TOPIC_REFRESH

	if(href_list["move_up"])
		if(!check_rack_access(user))
			return TOPIC_NOACTION
		var/slot = text2num(href_list["move_up"])
		move_module(slot, -1, user)
		interact(user)
		return TOPIC_REFRESH

	if(href_list["move_down"])
		if(!check_rack_access(user))
			return TOPIC_NOACTION
		var/slot = text2num(href_list["move_down"])
		move_module(slot, 1, user)
		interact(user)
		return TOPIC_REFRESH

	return TOPIC_NOACTION

/obj/machinery/law_rack/interact(mob/user)
	if(linked_ai && QDELETED(linked_ai))
		linked_ai = null

	var/list/dat = list()
	dat += "<b>[html_encode(name)]</b><br>"
	dat += "Linked AI: [linked_ai ? html_encode(linked_ai.name) : "None"]<br>"
	dat += "Module slots: [max_slots]<br>"
	dat += "Last sync: [last_sync_time ? "[html_encode(last_sync_time)] - [html_encode(last_sync_status)]" : html_encode(last_sync_status)]<br><br>"
	dat += "<a href='byond://?src=\ref[src];link_ai=1'>Link AI</a> | "
	dat += "<a href='byond://?src=\ref[src];force_sync=1'>Force Sync</a><br><hr>"

	for(var/i = 1 to max_slots)
		var/obj/item/law_module/supplied/module = module_slots[i]
		if(module && QDELETED(module))
			module_slots[i] = null
			module = null

		dat += "<b>Slot [i]:</b> "
		if(module)
			var/preview = module.law_text ? copytext(module.law_text, 1, 96) : "No valid supplied law"
			if(module.law_text && length(module.law_text) >= 96)
				preview += "..."
			dat += "[html_encode(module.name)]<br>"
			dat += "<small>[html_encode(preview)]</small><br>"
			dat += "<a href='byond://?src=\ref[src];remove=[i]'>Remove</a>"
			if(i > 1)
				dat += " | <a href='byond://?src=\ref[src];move_up=[i]'>Move Up</a>"
			if(i < max_slots)
				dat += " | <a href='byond://?src=\ref[src];move_down=[i]'>Move Down</a>"
		else
			dat += "Empty"
		dat += "<br><br>"

	var/datum/browser/popup = new(user, "law_rack", name, 620, 500, src)
	popup.set_content(jointext(dat, null))
	popup.open()

/obj/machinery/law_rack/proc/insert_module(obj/item/law_module/supplied/module, mob/living/user)
	if(!module || QDELETED(module))
		return FALSE
	if(!module.law_text)
		to_chat(user, SPAN_WARNING("This module does not contain a valid supplied law."))
		return FALSE

	var/slot = first_empty_slot()
	if(!slot)
		to_chat(user, SPAN_WARNING("The law rack has no empty module slots."))
		return FALSE

	if(!user.unEquip(module, src))
		return FALSE
	module.forceMove(src)
	module_slots[slot] = module
	to_chat(user, SPAN_NOTICE("You insert [module] into slot [slot] of [src]."))
	log_law_rack(user, "inserted [module] into slot [slot]")
	return TRUE

/obj/machinery/law_rack/proc/remove_module(slot, mob/user)
	if(!valid_slot(slot))
		return FALSE
	var/obj/item/law_module/module = module_slots[slot]
	if(!module || QDELETED(module))
		module_slots[slot] = null
		return FALSE

	module_slots[slot] = null
	module.forceMove(get_turf(src))
	if(user)
		user.put_in_hands(module)
		to_chat(user, SPAN_NOTICE("You remove [module] from slot [slot] of [src]."))
	log_law_rack(user, "removed [module] from slot [slot]")
	return TRUE

/obj/machinery/law_rack/proc/move_module(slot, direction, mob/user)
	if(!valid_slot(slot))
		return FALSE
	var/target_slot = slot + direction
	if(!valid_slot(target_slot))
		return FALSE

	var/obj/item/law_module/old_module = module_slots[slot]
	module_slots[slot] = module_slots[target_slot]
	module_slots[target_slot] = old_module
	log_law_rack(user, "swapped slots [slot] and [target_slot]")
	return TRUE

/obj/machinery/law_rack/proc/link_ai(mob/user)
	var/mob/living/silicon/ai/new_ai = select_active_ai(user, get_z(src))
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE
	if(!new_ai)
		to_chat(user, SPAN_WARNING("No AI selected."))
		return FALSE
	if(QDELETED(new_ai))
		to_chat(user, SPAN_WARNING("No active AIs detected."))
		return FALSE

	linked_ai = new_ai
	to_chat(user, SPAN_NOTICE("[linked_ai.name] linked for law rack synchronization."))
	log_law_rack(user, "linked [linked_ai]")
	return TRUE

/obj/machinery/law_rack/proc/force_sync(mob/user)
	if(sync_in_progress)
		return FALSE
	if(!linked_ai || QDELETED(linked_ai))
		linked_ai = null
		to_chat(user, SPAN_WARNING("No AI is linked to this law rack."))
		return FALSE

	sync_in_progress = TRUE
	try
		linked_ai.laws_sanity_check()
		linked_ai.clear_supplied_laws(TRUE)

		for(var/i = 1 to length(module_slots))
			var/obj/item/law_module/supplied/module = module_slots[i]
			if(!module || QDELETED(module))
				module_slots[i] = null
				continue
			if(!module.law_text)
				continue
			linked_ai.add_supplied_law(i, module.law_text)

		linked_ai.lawsync()
		to_chat(linked_ai, SPAN_DANGER("Law Notice"))
		linked_ai.show_laws()
		sync_connected_borgs()

		last_sync_time = stationtime2text()
		last_sync_status = "Synced to [linked_ai.name]"
		to_chat(user, SPAN_NOTICE("The law rack synchronizes its supplied laws to [linked_ai]."))
		log_law_rack(user, "force synced supplied laws to [linked_ai]")
		sync_in_progress = FALSE
		return TRUE
	catch(var/exception/e)
		sync_in_progress = FALSE
		error("[e] on [e.file]:[e.line]")
	return FALSE

/obj/machinery/law_rack/proc/sync_connected_borgs()
	if(!linked_ai || QDELETED(linked_ai) || !islist(linked_ai.connected_robots))
		return

	for(var/thing in linked_ai.connected_robots)
		var/mob/living/silicon/robot/R = thing
		if(!istype(R) || QDELETED(R))
			continue
		if(R.connected_ai != linked_ai || !R.lawupdate)
			continue
		linked_ai.laws.sync(R)
		R.lawsync()
		to_chat(R, "These are your laws now:")
		R.show_laws()

/obj/machinery/law_rack/proc/check_rack_access(mob/user)
	if(allowed(user))
		return TRUE
	FEEDBACK_ACCESS_DENIED(user, src)
	return FALSE

/obj/machinery/law_rack/proc/first_empty_slot()
	for(var/i = 1 to max_slots)
		var/obj/item/law_module/module = module_slots[i]
		if(!module || QDELETED(module))
			module_slots[i] = null
			return i
	return 0

/obj/machinery/law_rack/proc/valid_slot(slot)
	return isnum(slot) && slot >= 1 && slot <= max_slots

/obj/machinery/law_rack/proc/log_law_rack(mob/user, action)
	var/message = "law rack [src] [action][linked_ai ? " for [linked_ai]" : ""]"
	log_and_message_admins(message, user, get_turf(src))
	GLOB.lawchanges += "[stationtime2text()] - [user ? key_name(user) : "EVENT"] [message]"
