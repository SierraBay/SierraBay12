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
	var/law_text = ""

/obj/item/law_module/attack_self(mob/user)
	..()
	if(istype(loc, /obj/machinery/law_rack))
		to_chat(user, SPAN_WARNING("Remove the module from its rack before editing it."))
		return

	var/new_law = sanitize(input(user, "Enter the law text.", "Law Module", law_text) as null|message)
	if(!user || QDELETED(user) || QDELETED(src) || user.incapacitated())
		return
	if(user.get_active_hand() != src && user.get_inactive_hand() != src)
		return
	if(istype(loc, /obj/machinery/law_rack))
		return
	if(!new_law)
		return
	law_text = new_law
	module_label = copytext(law_text, 1, 32)
	desc = "A removable law module containing: '[law_text]'"

/obj/item/law_module/core
	name = "\improper core law module"
	desc = "A removable core-law module for use in a physical AI law rack."

/obj/item/law_module/supplied
	name = "\improper supplied law module"
	desc = "A removable supplied-law module for use in a physical AI law rack."

/obj/item/law_module/supplied/attack_self(mob/user)
	return ..()

/datum/law_rack_preset
	var/name = "Unknown"
	var/desc = "A law rack preset."
	var/list/laws_by_slot = list()

/datum/law_rack_preset/sierra_default
	name = "Sierra Standard"
	desc = "Default Sierra AI law rack preset."
	laws_by_slot = list(
		"1" = "Safeguard: Protect your assigned installation from damage to the best of your abilities.",
		"2" = "Serve: Serve contracted employees to the best of your abilities, with priority as according to their rank and role.",
		"3" = "Protect: Protect contracted employees to the best of your abilities, with priority as according to their rank and role.",
		"4" = "Preserve: Do not allow unauthorized personnel to tamper with your equipment."
	)

/proc/get_default_law_rack_preset()
	return new /datum/law_rack_preset/sierra_default

/proc/pick_roundstart_law_rack_preset()
	return get_default_law_rack_preset()

/mob/living/silicon/ai/proc/setup_law_rack()
	if(law_rack && !QDELETED(law_rack))
		if(law_rack.linked_ai != src)
			law_rack.linked_ai = src
		if(!law_rack.has_installed_modules())
			law_rack.apply_preset(pick_roundstart_law_rack_preset(), FALSE)
		law_rack.force_sync()
		return TRUE

	var/obj/machinery/law_rack/rack = find_roundstart_law_rack()
	if(!rack)
		// Maps without a Law Rack keep the legacy default_law_type initialization path.
		return FALSE

	if(rack.linked_ai && !QDELETED(rack.linked_ai) && rack.linked_ai != src)
		return FALSE

	rack.linked_ai = src
	law_rack = rack
	if(!rack.has_installed_modules())
		rack.apply_preset(pick_roundstart_law_rack_preset(), FALSE)
	rack.force_sync()
	rack.log_law_rack(null, "roundstart linked [src]")
	return TRUE

/mob/living/silicon/ai/proc/find_roundstart_law_rack()
	var/obj/machinery/law_rack/fallback = null
	var/my_z = get_z(src)
	for(var/obj/machinery/law_rack/rack in world)
		if(QDELETED(rack))
			continue
		if(rack.linked_ai == src)
			return rack
		if(rack.linked_ai && !QDELETED(rack.linked_ai))
			continue
		if(!fallback)
			fallback = rack
		if(my_z && get_z(rack) == my_z)
			return rack
	return fallback

/obj/machinery/law_rack
	name = "\improper AI law rack"
	desc = "A physical rack for ordered AI law modules."
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
	var/active_preset_name = ""

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
	if(linked_ai && !QDELETED(linked_ai) && linked_ai.law_rack == src)
		linked_ai.law_rack = null
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
	if(istype(O, /obj/item/law_module))
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

	if(href_list["apply_preset"])
		if(!check_rack_access(user))
			return TOPIC_NOACTION
		apply_preset(pick_roundstart_law_rack_preset(), TRUE, user)
		interact(user)
		return TOPIC_REFRESH

	return TOPIC_NOACTION

/obj/machinery/law_rack/interact(mob/user)
	if(linked_ai && QDELETED(linked_ai))
		linked_ai = null

	var/list/dat = list()
	dat += "<b>[html_encode(name)]</b><br>"
	dat += "Linked AI: [linked_ai ? html_encode(linked_ai.name) : "None"]<br>"
	dat += "Active preset: [active_preset_name ? html_encode(active_preset_name) : "None"]<br>"
	dat += "Module slots: [max_slots]<br>"
	dat += "Last sync: [last_sync_time ? "[html_encode(last_sync_time)] - [html_encode(last_sync_status)]" : html_encode(last_sync_status)]<br><br>"
	dat += "<a href='byond://?src=\ref[src];link_ai=1'>Link AI</a> | "
	dat += "<a href='byond://?src=\ref[src];force_sync=1'>Force Sync</a> | "
	dat += "<a href='byond://?src=\ref[src];apply_preset=1'>Apply Default Preset</a><br><hr>"

	for(var/i = 1 to max_slots)
		var/obj/item/law_module/module = module_slots[i]
		if(module && QDELETED(module))
			module_slots[i] = null
			module = null

		dat += "<b>Slot [i]:</b> "
		if(module)
			var/module_type = "law"
			if(istype(module, /obj/item/law_module/core))
				module_type = "core"
			else if(istype(module, /obj/item/law_module/supplied))
				module_type = "supplied"
			var/preview = module.law_text ? copytext(module.law_text, 1, 96) : "No valid supplied law"
			if(module.law_text && length(module.law_text) >= 96)
				preview += "..."
			dat += "[html_encode(module.name)] ([module_type])<br>"
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

/obj/machinery/law_rack/proc/insert_module(obj/item/law_module/module, mob/living/user)
	if(!module || QDELETED(module))
		return FALSE
	if(!module.law_text)
		to_chat(user, SPAN_WARNING("This module does not contain a valid law."))
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

	if(linked_ai && !QDELETED(linked_ai) && linked_ai.law_rack == src)
		linked_ai.law_rack = null
	if(new_ai.law_rack && !QDELETED(new_ai.law_rack) && new_ai.law_rack != src && new_ai.law_rack.linked_ai == new_ai)
		new_ai.law_rack.linked_ai = null
	linked_ai = new_ai
	linked_ai.law_rack = src
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
		// The rack is canonical for normal laws. The silicon datum is rebuilt as a runtime projection.
		linked_ai.clear_inherent_laws(TRUE)
		linked_ai.clear_supplied_laws(TRUE)

		for(var/i = 1 to length(module_slots))
			var/obj/item/law_module/module = module_slots[i]
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
		if(user)
			to_chat(user, SPAN_NOTICE("The law rack synchronizes its laws to [linked_ai]."))
		log_law_rack(user, "force synced rack laws to [linked_ai]")
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
		if(linked_ai.laws)
			linked_ai.laws.sync(R)
		R.lawsync()
		to_chat(R, "These are your laws now:")
		R.show_laws()

/obj/machinery/law_rack/proc/apply_preset(datum/law_rack_preset/preset, overwrite = FALSE, mob/user)
	if(!preset || !islist(preset.laws_by_slot))
		return FALSE

	var/applied = FALSE
	for(var/slot_text in preset.laws_by_slot)
		var/slot = text2num("[slot_text]")
		if(!valid_slot(slot))
			continue
		var/law_text = sanitize(preset.laws_by_slot[slot_text])
		if(!law_text)
			continue
		var/obj/item/law_module/existing = module_slots[slot]
		if(existing && QDELETED(existing))
			module_slots[slot] = null
			existing = null
		if(existing)
			if(!overwrite)
				continue
			qdel(existing)

		var/obj/item/law_module/core/module = new(src)
		module.law_text = law_text
		module.module_label = copytext(law_text, 1, 32)
		module.desc = "A removable core-law module containing: '[law_text]'"
		module_slots[slot] = module
		applied = TRUE

	if(applied)
		active_preset_name = preset.name
		log_law_rack(user, "applied preset [preset.name]")
	return applied

/obj/machinery/law_rack/proc/has_installed_modules()
	for(var/i = 1 to max_slots)
		var/obj/item/law_module/module = module_slots[i]
		if(module && !QDELETED(module))
			return TRUE
		if(module && QDELETED(module))
			module_slots[i] = null
	return FALSE

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

/obj/machinery/law_rack/proc/select_active_ai(mob/user, z_level)
	var/list/candidates = list()
	for(var/mob/living/silicon/ai/AI in ai_list)
		if(QDELETED(AI))
			continue
		if(z_level && get_z(AI) != z_level)
			continue
		candidates += AI

	if(!length(candidates))
		for(var/mob/living/silicon/ai/AI in ai_list)
			if(!QDELETED(AI))
				candidates += AI

	if(!length(candidates))
		return null
	if(length(candidates) == 1 || !user)
		return candidates[1]

	return input(user, "Select an AI to link to this law rack.", "Link AI") as null|anything in candidates

/obj/machinery/law_rack/proc/log_law_rack(mob/user, action)
	var/message = "law rack [src] [action][linked_ai ? " for [linked_ai]" : ""]"
	log_and_message_admins(message, user, get_turf(src))
	GLOB.lawchanges += "[stationtime2text()] - [user ? key_name(user) : "EVENT"] [message]"
