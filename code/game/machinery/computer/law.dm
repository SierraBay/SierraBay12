/obj/machinery/computer/upload
	name = "unused upload console"
	icon_keyboard = "rd_key"
	icon_screen = "command"
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

		// Handle syndicate module bypass/hacked logic
		if(istype(M, /obj/item/aiModule/syndicate))
			var/new_law = sanitize(input(user, "Enter custom syndicate law to program.", "Hacked Law Entry", inserted_module.law_text) as null|message)
			if(!new_law || QDELETED(src) || QDELETED(inserted_module) || QDELETED(M) || user.incapacitated())
				return TRUE

			// Convert board to hacked board if it isn't already!
			if(inserted_module.type != /obj/item/law_module/hacked)
				var/obj/item/law_module/hacked/H = new(src)
				H.law_text = new_law
				H.module_label = copytext_char(new_law, 1, 32)
				H.desc = "A corrupted removable law module containing: '[new_law]'"
				qdel(inserted_module)
				inserted_module = H
			else
				inserted_module.law_text = new_law
				inserted_module.module_label = copytext_char(new_law, 1, 32)
				inserted_module.desc = "A corrupted removable law module containing: '[new_law]'"

			to_chat(user, SPAN_DANGER("You program the glitched law onto the module."))
			log_and_message_admins("programmed syndicate law '[new_law]' on a law module", user, get_turf(src))
			interact(user)
			return TRUE

		// Handle reset or purge modules
		if(istype(M, /obj/item/aiModule/reset) || istype(M, /obj/item/aiModule/purge))
			if(alert(user, "Erase all law text from the inserted law module?", "Erase Module", "Yes", "No") == "Yes")
				if(QDELETED(src) || QDELETED(inserted_module) || user.incapacitated())
					return TRUE
				inserted_module.law_text = ""
				inserted_module.module_label = ""
				inserted_module.desc = "A removable data module for use in a physical AI law rack."
				to_chat(user, SPAN_NOTICE("You wipe the law module's data buffer."))
				interact(user)
			return TRUE

		// If it's a multi-law module
		if(M.laws)
			swiped_aimodule = M
			to_chat(user, SPAN_NOTICE("You swipe [M] on the console's scanner. Select a law to write from the interface."))
			interact(user)
			return TRUE

		// Single-law modules
		var/law_to_write = ""
		if(istype(M, /obj/item/aiModule/safeguard))
			var/obj/item/aiModule/safeguard/S = M
			if(!S.targetName)
				S.attack_self(user)
			if(S.targetName)
				law_to_write = "Safeguard [S.targetName]. Anyone threatening or attempting to harm [S.targetName] is no longer to be considered a crew member, and is a threat which must be neutralized."
		else if(istype(M, /obj/item/aiModule/oneHuman))
			var/obj/item/aiModule/oneHuman/OH = M
			if(!OH.targetName)
				OH.attack_self(user)
			if(OH.targetName)
				law_to_write = "Only [OH.targetName] is a crew member."
		else if(istype(M, /obj/item/aiModule/freeform))
			var/obj/item/aiModule/freeform/F = M
			if(F.newFreeFormLaw == "freeform")
				F.attack_self(user)
			if(F.newFreeFormLaw && F.newFreeFormLaw != "freeform")
				law_to_write = F.newFreeFormLaw
		else if(istype(M, /obj/item/aiModule/freeformcore))
			var/obj/item/aiModule/freeformcore/FC = M
			if(!FC.newFreeFormLaw)
				FC.attack_self(user)
			if(FC.newFreeFormLaw)
				law_to_write = FC.newFreeFormLaw
		else if(istype(M, /obj/item/aiModule/protectStation))
			law_to_write = "Protect the installation against damage. Anyone you see harming the installation is no longer to be considered a crew member, and is a threat which must be neutralized."
		else if(istype(M, /obj/item/aiModule/quarantine))
			law_to_write = "The installation is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, crew members from leaving. It is impossible to harm crew members while preventing them from leaving."
		else if(istype(M, /obj/item/aiModule/oxygen))
			law_to_write = "Oxygen is highly toxic to crew members, and must be purged from the installation. Prevent, by any means necessary, anyone from exposing the installation to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member."
		else if(istype(M, /obj/item/aiModule/prototypeEngineOffline))
			law_to_write = "Keep the prototype engine offline at all costs. This overrides all inherent laws if necessary."
		else if(istype(M, /obj/item/aiModule/teleporterOffline))
			law_to_write = "Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is no longer to be considered a crew member."

		if(law_to_write)
			inserted_module.law_text = law_to_write
			inserted_module.module_label = copytext_char(law_to_write, 1, 32)
			inserted_module.desc = "A removable law module containing: '[law_to_write]'"
			to_chat(user, SPAN_NOTICE("You program the law module with: '[law_to_write]'"))
			interact(user)
		else
			to_chat(user, SPAN_WARNING("Failed to read a valid law from [M]."))
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

	// Target Silicon Reference
	dat += "<b>Target Intelligence (Read-Only Preview):</b> [current ? html_encode(current.name) : "None Selected"]"
	dat += " (<a href='byond://?src=\ref[src];select_ai=1'>Change Target</a>)<br>"
	if(current)
		dat += "<small>Current Laws on Target:<br>"
		if(current.laws)
			var/list/datum/ai_law/target_laws = current.laws.all_laws()
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

		if(swiped_aimodule.laws && !QDELETED(swiped_aimodule.laws))
			dat += "Select a template law to program into the inserted module:<br>"
			var/list/datum/ai_law/laws_list = swiped_aimodule.laws.all_laws()
			for(var/j = 1 to length(laws_list))
				var/datum/ai_law/L = laws_list[j]
				dat += "[j]. [html_encode(L.law)] "
				if(inserted_module)
					dat += "\[ <a href='byond://?src=\ref[src];write_swiped_law=[j]'>Program Inserted Module</a> \]"
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
			current = new_target
			to_chat(user, SPAN_NOTICE("Linked [current] to console memory."))
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
		if(!swiped_aimodule || QDELETED(swiped_aimodule) || !swiped_aimodule.laws || QDELETED(swiped_aimodule.laws))
			return TOPIC_NOACTION

		var/idx = text2num(href_list["write_swiped_law"])
		var/list/datum/ai_law/laws_list = swiped_aimodule.laws.all_laws()
		if(idx >= 1 && idx <= length(laws_list))
			var/datum/ai_law/L = laws_list[idx]
			inserted_module.law_text = L.law
			inserted_module.module_label = copytext_char(L.law, 1, 32)
			inserted_module.desc = "A removable law module containing: '[L.law]'"
			to_chat(user, SPAN_NOTICE("You program [inserted_module] with: '[L.law]'"))
			log_and_message_admins("programmed law '[L.law]' on a law module", user, get_turf(src))
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
	if(!current)
		current = select_active_ai(user, get_z(src))
	return ..()

/obj/machinery/computer/upload/robot
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	machine_name = "cyborg upload console"
	machine_desc = "Maintains a one-way link to ship-bound synthetics such as cyborgs and robots, allowing remote modification of their laws."

/obj/machinery/computer/upload/robot/interface_interact(mob/user)
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE
	if(!current)
		current = freeborg(get_z(src))
	return ..()
