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
