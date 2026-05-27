// ==========================================
// Polymorphic API for programming physical law modules via AI Upload Console.
// Each aiModule subtype provides its own law text instead of the console
// maintaining a type-specific if/else chain.
// ==========================================

/// Base proc: returns the law text that this aiModule would write to a physical law module.
/// Returns null if the module cannot produce a law (needs user input, is a multi-law set, etc.)
/// Override in subtypes to provide specific law text.
/obj/item/aiModule/proc/get_physical_law_module_text(mob/user, obj/item/law_module/target_module)
	return null

/obj/item/aiModule/proc/can_program_physical_law_module(mob/user, obj/item/law_module/target_module)
	return TRUE

/obj/item/aiModule/proc/get_physical_law_programming_options(mob/user, obj/item/law_module/target_module)
	if(laws && !QDELETED(laws))
		var/list/options = list()
		var/list/datum/ai_law/laws_list = laws.all_laws()
		for(var/i = 1 to length(laws_list))
			var/datum/ai_law/L = laws_list[i]
			options["[i]"] = L.law
		return options
	return null

/obj/item/aiModule/proc/program_physical_law_module(mob/user, obj/item/law_module/target_module, obj/machinery/computer/upload/console, option_key = null)
	if(option_key)
		var/list/options = get_physical_law_programming_options(user, target_module)
		if(options && options[option_key])
			var/law = options[option_key]
			target_module.set_law_text(law)
			return TRUE
		return FALSE

	var/law = get_physical_law_module_text(user, target_module)
	if(!law)
		return FALSE
	target_module.set_law_text(law)
	return TRUE

/obj/item/aiModule/syndicate/program_physical_law_module(mob/user, obj/item/law_module/target_module, obj/machinery/computer/upload/console, option_key = null)
	var/new_law = sanitize(input(user, "Enter custom syndicate law to program.", "Hacked Law Entry", target_module.law_text) as null|message)
	if(!user || QDELETED(user) || user.incapacitated())
		return FALSE
	if(!console || QDELETED(console))
		return FALSE
	if(!target_module || QDELETED(target_module) || target_module != console.inserted_module)
		return FALSE
	if(QDELETED(src))
		return FALSE
	if(!new_law)
		return FALSE

	if(target_module.type != /obj/item/law_module/hacked)
		var/obj/item/law_module/hacked/H = new(console)
		H.set_law_text(new_law, null, TRUE)
		qdel(target_module)
		console.inserted_module = H
	else
		target_module.set_law_text(new_law, null, TRUE)

	to_chat(user, SPAN_DANGER("You program the glitched law onto the module."))
	log_and_message_admins("programmed syndicate law '[new_law]' on a law module", user, get_turf(console))
	return TRUE

/obj/item/aiModule/reset/program_physical_law_module(mob/user, obj/item/law_module/target_module, obj/machinery/computer/upload/console, option_key = null)
	if(alert(user, "Erase all law text from the inserted law module?", "Erase Module", "Yes", "No") != "Yes")
		return FALSE
	if(!user || QDELETED(user) || user.incapacitated())
		return FALSE
	if(!console || QDELETED(console))
		return FALSE
	if(!target_module || QDELETED(target_module) || target_module != console.inserted_module)
		return FALSE

	target_module.clear_law_text()
	to_chat(user, SPAN_NOTICE("You wipe the law module's data buffer."))
	return TRUE

/obj/item/aiModule/purge/program_physical_law_module(mob/user, obj/item/law_module/target_module, obj/machinery/computer/upload/console, option_key = null)
	if(alert(user, "Erase all law text from the inserted law module?", "Erase Module", "Yes", "No") != "Yes")
		return FALSE
	if(!user || QDELETED(user) || user.incapacitated())
		return FALSE
	if(!console || QDELETED(console))
		return FALSE
	if(!target_module || QDELETED(target_module) || target_module != console.inserted_module)
		return FALSE

	target_module.clear_law_text()
	to_chat(user, SPAN_NOTICE("You wipe the law module's data buffer."))
	return TRUE

/obj/item/aiModule/safeguard/get_physical_law_module_text(mob/user, obj/item/law_module/target_module)
	if(!targetName)
		attack_self(user)
	if(!targetName || !user || QDELETED(user) || user.incapacitated())
		return null
	return "Safeguard [targetName]. Anyone threatening or attempting to harm [targetName] is no longer to be considered a crew member, and is a threat which must be neutralized."

/obj/item/aiModule/oneHuman/get_physical_law_module_text(mob/user, obj/item/law_module/target_module)
	if(!targetName)
		attack_self(user)
	if(!targetName || !user || QDELETED(user) || user.incapacitated())
		return null
	return "Only [targetName] is a crew member."

/obj/item/aiModule/freeform/get_physical_law_module_text(mob/user, obj/item/law_module/target_module)
	if(newFreeFormLaw == "freeform")
		attack_self(user)
	if(!newFreeFormLaw || newFreeFormLaw == "freeform" || !user || QDELETED(user) || user.incapacitated())
		return null
	return newFreeFormLaw

/obj/item/aiModule/freeformcore/get_physical_law_module_text(mob/user, obj/item/law_module/target_module)
	if(!newFreeFormLaw)
		attack_self(user)
	if(!newFreeFormLaw || !user || QDELETED(user) || user.incapacitated())
		return null
	return newFreeFormLaw

/obj/item/aiModule/protectStation/get_physical_law_module_text(mob/user, obj/item/law_module/target_module)
	return "Protect the installation against damage. Anyone you see harming the installation is no longer to be considered a crew member, and is a threat which must be neutralized."

/obj/item/aiModule/quarantine/get_physical_law_module_text(mob/user, obj/item/law_module/target_module)
	return "The installation is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, crew members from leaving. It is impossible to harm crew members while preventing them from leaving."

/obj/item/aiModule/oxygen/get_physical_law_module_text(mob/user, obj/item/law_module/target_module)
	return "Oxygen is highly toxic to crew members, and must be purged from the installation. Prevent, by any means necessary, anyone from exposing the installation to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member."

/obj/item/aiModule/prototypeEngineOffline/get_physical_law_module_text(mob/user, obj/item/law_module/target_module)
	return "Keep the prototype engine offline at all costs. This overrides all inherent laws if necessary."

/obj/item/aiModule/teleporterOffline/get_physical_law_module_text(mob/user, obj/item/law_module/target_module)
	return "Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is no longer to be considered a crew member."
