/obj/machinery/computer/upload
	name = "unused upload console"
	icon_keyboard = "rd_key"
	icon_screen = "command"
	var/mob/living/silicon/preview_target = null
	// Keep current as a legacy/compatibility alias for external/unaffected systems (e.g. AI modules)
	var/mob/living/silicon/current = null
	var/obj/item/law_module/inserted_module = null
	var/obj/item/aiModule/swiped_aimodule = null

/obj/machinery/computer/upload/Destroy()
	if(inserted_module)
		if(!QDELETED(inserted_module))
			inserted_module.forceMove(get_turf(src))
		inserted_module = null
	swiped_aimodule = null
	return ..()

/obj/machinery/computer/upload/use_tool(obj/item/O, mob/living/user, list/click_params)
	if(QDELETED(inserted_module))
		inserted_module = null
	if(QDELETED(swiped_aimodule))
		swiped_aimodule = null

	if(istype(O, /obj/item/law_module))
		if(inserted_module)
			to_chat(user, SPAN_WARNING("\The [src] already has a law module inserted."))
			return TRUE
		if(user.unEquip(O, src))
			inserted_module = O
			to_chat(user, SPAN_NOTICE("You insert [O] into [src]."))
			interact(user)
		return TRUE

	if(istype(O, /obj/item/aiModule))
		if(!inserted_module)
			to_chat(user, SPAN_WARNING("You must insert a physical law module first before you can write laws to it."))
			return TRUE

		var/obj/item/aiModule/M = O

		var/list/options = M.get_physical_law_programming_options(user, inserted_module)
		if(length(options))
			swiped_aimodule = M
			to_chat(user, SPAN_NOTICE("You swipe [M] on the console's scanner. Select a law to write from the interface."))
			interact(user)
			return TRUE

		if(!M.can_program_physical_law_module(user, inserted_module))
			to_chat(user, SPAN_WARNING("Cannot program module with [M]."))
			return TRUE

		if(M.program_physical_law_module(user, inserted_module, src))
			// Post-prompt/async safety verification:
			if(user && !QDELETED(user) && !user.incapacitated() && inserted_module && !QDELETED(inserted_module))
				var/law_text = inserted_module.law_text
				if(law_text)
					to_chat(user, SPAN_NOTICE("You program the law module with: '[html_encode(law_text)]'"))
					log_and_message_admins("programmed law '[law_text]' on a law module", user, get_turf(src))
			interact(user)
		else
			if(user && !QDELETED(user) && !user.incapacitated())
				to_chat(user, SPAN_WARNING("Failed to program the law module using [M]."))
		return TRUE

	return ..()

/obj/machinery/computer/upload/proc/eject_module(mob/user)
	if(QDELETED(inserted_module))
		inserted_module = null
	if(!inserted_module)
		return FALSE
	var/obj/item/law_module/LM = inserted_module
	inserted_module = null
	LM.forceMove(get_turf(src))
	if(user)
		user.put_in_hands(LM)
		to_chat(user, SPAN_NOTICE("You eject [LM] from [src]."))
	return TRUE

/obj/machinery/computer/upload/interface_interact(mob/user)
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE
	interact(user)
	return TRUE

/obj/machinery/computer/upload/interact(mob/user)
	if(QDELETED(inserted_module))
		inserted_module = null
	if(QDELETED(swiped_aimodule))
		swiped_aimodule = null

	var/list/dat = list()
	dat += "<b>[html_encode(name)] - Physical Module Programmer</b><br>"
	dat += "<small style='color: #888;'>This console programs removable law modules. Programmed modules must be inserted into the physical AI Law Rack and synchronized to take effect.</small><br><br>"

	// Target Silicon Reference (Read-Only Preview)
	dat += "<b>Target Intelligence (Read-Only Preview):</b> [preview_target ? html_encode(preview_target.name) : "None Selected"]"
	dat += " (<a href='byond://?src=\ref[src];select_ai=1'>Change Target</a>)<br>"
	if(preview_target)
		dat += "<small>Current Laws on Target:<br>"
		if(preview_target.laws)
			var/list/datum/ai_law/target_laws = preview_target.laws.all_laws()
			if(length(target_laws))
				for(var/datum/ai_law/AL in target_laws)
					dat += "[AL.get_index()]. [html_encode(AL.law)]<br>"
			else
				dat += "No laws detected.<br>"
		else
			dat += "No laws detected.<br>"
		dat += "</small>"
	dat += "<hr>"

	// Inserted Law Module Slot
	dat += "<b>Physical Law Module Slot (Insert module here):</b><br>"
	if(inserted_module)
		dat += "Inserted Module: <b>[html_encode(inserted_module.name)]</b><br>"
		dat += "Programmed Law Text: <span style='color: #4f4;'><i>\"[inserted_module.law_text ? html_encode(inserted_module.law_text) : "(Blank / Unprogrammed Module)"]\"</i></span><br>"
		dat += "\[ <a href='byond://?src=\ref[src];eject_module=1'>Eject Law Module</a> \]<br>"
	else
		dat += "<span style='color: #f66;'><i>No Law Module inserted. Please insert a Physical Law Module to begin programming.</i></span><br>"
	dat += "<hr>"

	// Swiped Template
	if(swiped_aimodule && !QDELETED(swiped_aimodule))
		dat += "<b>Active AI Module Template (Swiped):</b> [html_encode(swiped_aimodule.name)]"
		dat += " (<a href='byond://?src=\ref[src];clear_template=1'>Clear Template</a>)<br><br>"

		var/list/options = swiped_aimodule.get_physical_law_programming_options(user, inserted_module)
		if(length(options))
			dat += "Select a template law to program into the inserted module:<br>"
			for(var/option_key in options)
				var/option_val = options[option_key]
				dat += "[option_key]. [html_encode(option_val)] "
				if(inserted_module)
					dat += "\[ <a href='byond://?src=\ref[src];write_swiped_law=[option_key]'>Program Inserted Module</a> \]"
				else
					dat += "<small style='color: #aaa;'>(Insert a physical law module first)</small>"
				dat += "<br>"
		else
			dat += "This module template has no readable law set."
	else
		dat += "<i>No programmer template active. Swipe an AI Module (Asimov, Safeguard, Freeform, etc.) on the console reader to load a template.</i>"

	var/datum/browser/popup = new(user, "upload_console", name, 620, 500, src)
	popup.set_content(jointext(dat, null))
	popup.open()

/obj/machinery/computer/upload/OnTopic(mob/user, href_list, datum/topic_state/state)
	if(!CanInteract(user, state))
		return TOPIC_NOACTION

	if(QDELETED(inserted_module))
		inserted_module = null
	if(QDELETED(swiped_aimodule))
		swiped_aimodule = null

	if(href_list["select_ai"])
		var/mob/living/silicon/new_target = select_active_ai(user, get_z(src))
		if(new_target)
			preview_target = new_target
			current = new_target
			to_chat(user, SPAN_NOTICE("Linked [preview_target] to console memory."))
		interact(user)
		return TOPIC_REFRESH

	if(href_list["eject_module"])
		eject_module(user)
		interact(user)
		return TOPIC_REFRESH

	if(href_list["clear_template"])
		swiped_aimodule = null
		to_chat(user, SPAN_NOTICE("Template cleared."))
		interact(user)
		return TOPIC_REFRESH

	if(href_list["write_swiped_law"])
		if(!inserted_module || QDELETED(inserted_module))
			to_chat(user, SPAN_WARNING("No law module inserted!"))
			return TOPIC_NOACTION
		if(!swiped_aimodule || QDELETED(swiped_aimodule))
			return TOPIC_NOACTION

		var/option_key = href_list["write_swiped_law"]
		if(swiped_aimodule.program_physical_law_module(user, inserted_module, src, option_key))
			// Post-prompt/async safety verification:
			if(user && !QDELETED(user) && !user.incapacitated() && inserted_module && !QDELETED(inserted_module))
				var/law_text = inserted_module.law_text
				to_chat(user, SPAN_NOTICE("You program [inserted_module] with: '[html_encode(law_text)]'"))
				log_and_message_admins("programmed law '[law_text]' on a law module", user, get_turf(src))
		interact(user)
		return TOPIC_REFRESH

	return TOPIC_NOACTION

/obj/machinery/computer/upload/ai
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	machine_name = "\improper AI upload console"
	machine_desc = "Maintains a one-way link to ship-bound AI units, allowing remote modification of their laws."

/obj/machinery/computer/upload/ai/interface_interact(mob/user)
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE
	if(!preview_target)
		preview_target = select_active_ai(user, get_z(src))
		current = preview_target
	return ..()

/obj/machinery/computer/upload/robot
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	machine_name = "cyborg upload console"
	machine_desc = "Maintains a one-way link to ship-bound synthetics such as cyborgs and robots, allowing remote modification of their laws."

/obj/machinery/computer/upload/robot/interface_interact(mob/user)
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE
	if(!preview_target)
		preview_target = freeborg(get_z(src))
		current = preview_target
	return ..()
