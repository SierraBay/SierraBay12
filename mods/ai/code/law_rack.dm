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

	if(!isadmin(user))
		to_chat(user, SPAN_WARNING("\The [src] cannot be programmed directly by hand. You must use an AI Upload Console to write laws to it."))
		return

	var/new_law = sanitize(input(user, "Enter the law text (Admin Debug).", "Law Module", law_text) as null|message)
	if(!user || QDELETED(user) || QDELETED(src) || user.incapacitated())
		return
	if(user.get_active_hand() != src && user.get_inactive_hand() != src)
		return
	if(istype(loc, /obj/machinery/law_rack))
		return
	if(!new_law)
		return
	law_text = new_law
	module_label = copytext_char(law_text, 1, 32)
	desc = "A removable law module containing: '[law_text]'"

/obj/item/law_module/core
	name = "\improper core law module"
	desc = "A removable core-law module for use in a physical AI law rack."

/obj/item/law_module/supplied
	name = "\improper supplied law module"
	desc = "A removable supplied-law module for use in a physical AI law rack."

/obj/item/law_module/supplied/attack_self(mob/user)
	return ..()

/obj/item/law_module/hacked
	name = "\improper glitched law module"
	desc = "A corrupted removable law module. Its status light is blinking erratically."

/obj/item/law_module/hacked/attack_self(mob/user)
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
			if(law_rack.linked_ai && !QDELETED(law_rack.linked_ai))
				law_rack.linked_ai.law_rack = null
			law_rack.linked_ai = src
		if(!law_rack.has_installed_modules())
			law_rack.apply_roundstart_preset(pick_roundstart_law_rack_preset(), FALSE)
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
		rack.apply_roundstart_preset(pick_roundstart_law_rack_preset(), FALSE)
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
	use_power = POWER_USE_IDLE
	idle_power_usage = 100
	active_power_usage = 250
	req_access = list(access_ai_upload)
	var/mob/living/silicon/ai/linked_ai = null
	var/list/obj/item/law_module/module_slots = list(null, null, null, null, null, null)
	var/max_slots = 6
	var/obj/item/card/id/inserted_id = null
	var/slots_unlocked = FALSE
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
	if(inserted_id && !QDELETED(inserted_id) && T)
		inserted_id.forceMove(T)
	inserted_id = null
	slots_unlocked = FALSE
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
	if(istype(O, /obj/item/card/id))
		insert_id_card(O, user)
		return TRUE

	if(istype(O, /obj/item/law_module))
		if(!can_modify_rack(user))
			return TRUE
		insert_module(O, user)
		return TRUE
	return ..()

/obj/machinery/law_rack/OnTopic(mob/user, href_list, datum/topic_state/state)
	if(!CanInteract(user, state))
		return TOPIC_NOACTION

	if(href_list["link_ai"])
		if(!can_modify_rack(user))
			return TOPIC_NOACTION
		link_ai(user)
		interact(user)
		return TOPIC_REFRESH

	if(href_list["force_sync"])
		if(!can_modify_rack(user))
			return TOPIC_NOACTION
		force_sync(user)
		interact(user)
		return TOPIC_REFRESH

	if(href_list["eject_id"])
		eject_id_card(user)
		interact(user)
		return TOPIC_REFRESH

	if(href_list["remove"])
		if(!can_modify_rack(user))
			return TOPIC_NOACTION
		var/slot = text2num(href_list["remove"])
		remove_module(slot, user)
		interact(user)
		return TOPIC_REFRESH

	if(href_list["move_up"])
		if(!can_modify_rack(user))
			return TOPIC_NOACTION
		var/slot = text2num(href_list["move_up"])
		move_module(slot, -1, user)
		interact(user)
		return TOPIC_REFRESH

	if(href_list["move_down"])
		if(!can_modify_rack(user))
			return TOPIC_NOACTION
		var/slot = text2num(href_list["move_down"])
		move_module(slot, 1, user)
		interact(user)
		return TOPIC_REFRESH

	return TOPIC_NOACTION

/obj/machinery/law_rack/interact(mob/user)
	ui_interact(user)

/obj/machinery/law_rack/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0, datum/nanoui/master_ui = null, datum/topic_state/state = GLOB.default_state)
	if(linked_ai && QDELETED(linked_ai))
		linked_ai = null
	update_rack_lock()

	var/list/data = list()
	data["name"] = name
	data["linked_ai"] = linked_ai ? linked_ai.name : null
	data["active_preset_name"] = active_preset_name
	data["inserted_id"] = inserted_id ? inserted_id.name : null
	data["slots_unlocked"] = slots_unlocked ? 1 : 0
	data["max_slots"] = max_slots
	data["last_sync_time"] = last_sync_time
	data["last_sync_status"] = last_sync_status
	data["sync_in_progress"] = sync_in_progress ? 1 : 0

	var/list/slots = list()
	for(var/i = 1 to max_slots)
		var/obj/item/law_module/module = module_slots[i]
		if(module && QDELETED(module))
			module_slots[i] = null
			module = null

		if(module)
			var/module_type = "std"
			if(istype(module, /obj/item/law_module/core))
				module_type = "core"
			else if(istype(module, /obj/item/law_module/supplied))
				module_type = "supplied"
			else if(istype(module, /obj/item/law_module/hacked))
				module_type = "corrupted"

			var/preview = module.law_text ? copytext_char(module.law_text, 1, 96) : "No valid law"
			if(module.law_text && length_char(module.law_text) >= 96)
				preview += "..."

			slots += list(list(
				"index" = i,
				"has_module" = 1,
				"name" = module.name,
				"type" = module_type,
				"preview" = preview,
				"ref" = "\ref[module]"
			))
		else
			slots += list(list(
				"index" = i,
				"has_module" = 0
			))
	data["slots"] = slots

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "law_rack.tmpl", name, 620, 520, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/law_rack/proc/insert_module(obj/item/law_module/module, mob/living/user)
	if(user)
		if(!can_modify_rack(user))
			return FALSE
		if(!module || QDELETED(module))
			return FALSE
		if(!module.law_text)
			to_chat(user, SPAN_WARNING("This module does not contain a valid law."))
			return FALSE
	else
		if(!module || QDELETED(module))
			return FALSE
		if(!module.law_text)
			return FALSE

	// Clean up dangling reference if module is already in another rack
	if(istype(module.loc, /obj/machinery/law_rack))
		var/obj/machinery/law_rack/old_rack = module.loc
		if(old_rack != src)
			for(var/j = 1 to old_rack.max_slots)
				if(old_rack.module_slots[j] == module)
					old_rack.module_slots[j] = null
					break

	var/slot = first_empty_slot()
	if(!slot)
		if(user)
			to_chat(user, SPAN_WARNING("The law rack has no empty module slots."))
		return FALSE

	if(user)
		if(!user.unEquip(module, src))
			return FALSE
	module.forceMove(src)
	module_slots[slot] = module

	if(user)
		to_chat(user, SPAN_NOTICE("You insert [module] into slot [slot] of [src]."))
		interact(user)
	log_law_rack(user, "inserted [module] into slot [slot]")
	return TRUE

/obj/machinery/law_rack/proc/remove_module(slot, mob/user)
	if(user && !can_modify_rack(user))
		return FALSE
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
	if(user && !can_modify_rack(user))
		return FALSE
	if(!valid_slot(slot))
		return FALSE
	var/target_slot = slot + direction
	if(!valid_slot(target_slot))
		return FALSE

	if(module_slots[slot] && QDELETED(module_slots[slot]))
		module_slots[slot] = null
	if(module_slots[target_slot] && QDELETED(module_slots[target_slot]))
		module_slots[target_slot] = null

	var/obj/item/law_module/old_module = module_slots[slot]
	module_slots[slot] = module_slots[target_slot]
	module_slots[target_slot] = old_module
	log_law_rack(user, "swapped slots [slot] and [target_slot]")
	return TRUE

/obj/machinery/law_rack/proc/link_ai(mob/user)
	if(user && !can_modify_rack(user))
		return FALSE
	if(user && !CanInteract(user, DefaultTopicState()))
		return FALSE
	var/mob/living/silicon/ai/new_ai = select_active_ai(user, get_z(src))
	if(!new_ai)
		if(user)
			to_chat(user, SPAN_WARNING("No AI selected."))
		return FALSE
	if(QDELETED(new_ai))
		if(user)
			to_chat(user, SPAN_WARNING("Selected AI is no longer available."))
		return FALSE

	if(linked_ai && !QDELETED(linked_ai) && linked_ai.law_rack == src)
		linked_ai.law_rack = null
	if(new_ai.law_rack && !QDELETED(new_ai.law_rack) && new_ai.law_rack != src && new_ai.law_rack.linked_ai == new_ai)
		new_ai.law_rack.linked_ai = null
	linked_ai = new_ai
	linked_ai.law_rack = src
	if(user)
		to_chat(user, SPAN_NOTICE("[linked_ai.name] linked for law rack synchronization."))
	log_law_rack(user, "linked [linked_ai]")
	return TRUE

/obj/machinery/law_rack/proc/force_sync(mob/user)
	if(inoperable())
		return FALSE
	if(user && !can_modify_rack(user))
		return FALSE
	if(sync_in_progress)
		return FALSE
	if(!linked_ai || QDELETED(linked_ai))
		linked_ai = null
		if(user)
			to_chat(user, SPAN_WARNING("No AI is linked to this law rack."))
		return FALSE

	sync_in_progress = TRUE
	try
		linked_ai.laws_sanity_check()
		// Law Rack is the canonical physical source of normal AI laws.
		// AI.laws is rebuilt from rack modules as a runtime-compatible projection.
		// Rack laws are currently projected through supplied_laws to preserve existing
		// show_laws(), state_laws(), lawsync(), and borg sync behavior.
		// Rack projection intentionally goes through supplied_laws for compatibility.
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
		to_chat(linked_ai, SPAN_DANGER("Law Notice: Your laws have been updated via law rack synchronization."))
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
		log_error("[e] on [e.file]:[e.line]")
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

/obj/machinery/law_rack/proc/apply_roundstart_preset(datum/law_rack_preset/preset, overwrite = FALSE)
	if(!preset || !islist(preset.laws_by_slot))
		return FALSE

	var/applied = FALSE
	for(var/slot_text in preset.laws_by_slot)
		var/slot = text2num(slot_text)
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
		module.module_label = copytext_char(law_text, 1, 32)
		module.desc = "A removable core-law module containing: '[law_text]'"
		module_slots[slot] = module
		applied = TRUE

	if(applied)
		active_preset_name = preset.name
		log_law_rack(null, "applied roundstart preset [preset.name]")
	return applied

/obj/machinery/law_rack/proc/has_installed_modules()
	for(var/i = 1 to max_slots)
		var/obj/item/law_module/module = module_slots[i]
		if(module && !QDELETED(module))
			return TRUE
		if(module && QDELETED(module))
			module_slots[i] = null
	return FALSE

/obj/machinery/law_rack/check_access(atom/movable/A)
	if(istype(A, /mob))
		return TRUE
	return ..()

/obj/machinery/law_rack/proc/has_rack_access()
	update_rack_lock()
	return slots_unlocked

/obj/machinery/law_rack/proc/update_rack_lock()
	if(inserted_id && (QDELETED(inserted_id) || inserted_id.loc != src))
		inserted_id = null
	slots_unlocked = inserted_id && check_access(inserted_id)
	return slots_unlocked

/obj/machinery/law_rack/proc/can_modify_rack(mob/user)
	if(has_rack_access())
		return TRUE
	if(user)
		FEEDBACK_ACCESS_DENIED(user, src)
	return FALSE

/obj/machinery/law_rack/proc/insert_id_card(obj/item/card/id/card, mob/living/user)
	if(!card || QDELETED(card))
		return FALSE
	if(inserted_id && (QDELETED(inserted_id) || inserted_id.loc != src))
		inserted_id = null
	if(inserted_id)
		if(user)
			to_chat(user, SPAN_WARNING("\The [src] already has an ID inserted."))
		return FALSE
	if(user && !user.unEquip(card, src))
		FEEDBACK_UNEQUIP_FAILURE(user, card)
		return FALSE

	card.forceMove(src)
	inserted_id = card
	update_rack_lock()
	if(user)
		if(slots_unlocked)
			to_chat(user, SPAN_NOTICE("You insert [card] into [src]. The law rack unlocks."))
		else
			to_chat(user, SPAN_WARNING("You insert [card] into [src], but its access is not accepted."))
		interact(user)
	log_law_rack(user, "inserted ID [card]")
	return TRUE

/obj/machinery/law_rack/proc/eject_id_card(mob/user)
	if(inserted_id && (QDELETED(inserted_id) || inserted_id.loc != src))
		inserted_id = null
	if(!inserted_id)
		if(user)
			to_chat(user, SPAN_WARNING("There is no ID inserted in [src]."))
		update_rack_lock()
		return FALSE

	var/obj/item/card/id/card = inserted_id
	inserted_id = null
	slots_unlocked = FALSE
	card.forceMove(get_turf(src))
	if(user)
		user.put_in_hands(card)
		to_chat(user, SPAN_NOTICE("You eject [card] from [src]."))
	log_law_rack(user, "ejected ID [card]")
	return TRUE

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

/obj/item/stock_parts/circuitboard/law_rack
	name = "circuit board (AI Law Rack)"
	build_path = /obj/machinery/law_rack
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 3)
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/console_screen = 1
	)
	additional_spawn_components = list(
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/datum/design/circuit/law_rack
	name = "AI Law Rack"
	id = "law_rack_board"
	req_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	build_path = /obj/item/stock_parts/circuitboard/law_rack
	sort_string = "XAAAD"

/datum/design/aimodule/law_module
	name = "AI Law Module"
	id = "law_module"
	req_tech = list(TECH_DATA = 2, TECH_MATERIAL = 2)
	build_path = /obj/item/law_module
	sort_string = "XADAA"

/datum/design/aimodule/law_module/AssembleDesignDesc()
	desc = "Allows for the construction of \a '[name]' physical AI law module."

/datum/design/aimodule/law_module/core
	name = "AI Core Law Module"
	id = "law_module_core"
	build_path = /obj/item/law_module/core
	req_tech = list(TECH_DATA = 3, TECH_MATERIAL = 3)
	sort_string = "XADAB"

/datum/design/aimodule/law_module/supplied
	name = "AI Supplied Law Module"
	id = "law_module_supplied"
	build_path = /obj/item/law_module/supplied
	req_tech = list(TECH_DATA = 3, TECH_MATERIAL = 3)
	sort_string = "XADAC"
