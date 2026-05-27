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
	set_law_text(new_law)

/obj/item/law_module/proc/set_law_text(new_law, new_label = null, corrupted = FALSE)
	law_text = sanitize(new_law)
	module_label = new_label ? new_label : copytext_char(law_text, 1, 32)
	if(corrupted)
		desc = "A corrupted removable law module containing: '[law_text]'"
	else if(law_text)
		desc = "A removable law module containing: '[law_text]'"
	else
		desc = initial(desc)

/obj/item/law_module/proc/clear_law_text()
	law_text = ""
	module_label = ""
	desc = initial(desc)

/obj/item/law_module/proc/has_valid_law()
	return !!law_text

/obj/item/law_module/proc/get_law_preview(max_len = 96)
	if(!law_text)
		return "No valid law"
	var/preview = copytext_char(law_text, 1, max_len)
	if(length_char(law_text) >= max_len)
		preview += "..."
	return preview

/obj/item/law_module/proc/apply_to_ai_laws(datum/ai_laws/laws, slot)
	// Module subtype is currently physical/display metadata.
	// Rack projection writes all normal rack laws through supplied_laws for compatibility
	// with existing AI law display/sync systems.
	if(!laws || !law_text)
		return FALSE
	laws.add_supplied_law(slot, law_text)
	return TRUE

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
