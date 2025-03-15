/obj/item/mech_component/control_module
	name = "exosuit control module"
	desc = "A clump of circuitry and software chip docks, used to program exosuits."
	icon_state = "control"
	icon = 'icons/mecha/mech_equipment.dmi'
	gender = NEUTER
	color = COLOR_WHITE
	can_be_pickuped = TRUE
	var/list/installed_software = list()
	var/max_installed_software = 2


/obj/item/mech_component/control_module/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("It has [max_installed_software - LAZYLEN(installed_software)] empty slot\s remaining out of [max_installed_software]."))

/obj/item/mech_component/control_module/use_tool(obj/item/thing, mob/living/user, list/click_params)
	if(istype(thing, /obj/item/circuitboard/exosystem))
		install_software(thing, user)
		return TRUE

	if(isScrewdriver(thing))
		var/result = ..()
		update_software()
		return result
	else
		return ..()

/obj/item/mech_component/control_module/proc/install_software(obj/item/circuitboard/exosystem/software, mob/user)
	if(length(installed_software) >= max_installed_software)
		if(user)
			to_chat(user, SPAN_WARNING("\The [src] can only hold [max_installed_software] software modules."))
		return
	if(user && !user.unEquip(software))
		return

	if(user)
		to_chat(user, SPAN_NOTICE("You load \the [software] into \the [src]'s memory."))

	software.forceMove(src)
	update_software()

/obj/item/mech_component/control_module/proc/update_software()
	installed_software = list()
	for(var/obj/item/circuitboard/exosystem/program in contents)
		installed_software |= program.contains_software

/obj/item/mech_component/sensors/update_parts_images()
	var/list/parts_to_show = list()
	if(radio)
		parts_to_show += radio
	if(camera)
		parts_to_show += camera
	if(computer)
		parts_to_show += computer
	internal_parts_list_images = make_item_radial_menu_choices(parts_to_show)



//Ниже сами платки
/obj/item/circuitboard/exosystem
	name = "exosuit software template"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	var/list/contains_software = list()

/obj/item/circuitboard/exosystem/engineering
	name = "exosuit software (engineering systems)"
	contains_software = list(MECH_SOFTWARE_ENGINEERING)
	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1)

/obj/item/circuitboard/exosystem/utility
	name = "exosuit software (utility systems)"
	contains_software = list(MECH_SOFTWARE_UTILITY)
	icon_state = "mcontroller"
	origin_tech = list(TECH_DATA = 1)

/obj/item/circuitboard/exosystem/medical
	name = "exosuit software (medical systems)"
	contains_software = list(MECH_SOFTWARE_MEDICAL)
	icon_state = "mcontroller"
	origin_tech = list(TECH_DATA = 1,TECH_BIO = 1)

/obj/item/circuitboard/exosystem/weapons
	name = "exosuit software (basic weapon systems)"
	contains_software = list(MECH_SOFTWARE_WEAPONS)
	icon_state = "mainboard"
	origin_tech = list(TECH_DATA = 1, TECH_COMBAT = 3)
