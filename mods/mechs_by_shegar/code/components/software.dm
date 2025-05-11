/obj/item/robot_parts/robot_component/control_module
	name = "exosuit board computer"
	desc = "A clump of circuitry and software chip docks, used to program exosuits."
	icon_state = "control"
	icon = 'icons/mecha/mech_equipment.dmi'
	gender = NEUTER
	color = COLOR_WHITE
	//Картиночки плат внутри
	var/list/internal_parts_list_images = list()
	//Список программ установленных в общей сумме
	var/list/installed_software = list()
	//Список плат вставленных в компьютер
	var/list/installed_circuits = list()
	var/max_installed_software = 2


/obj/item/robot_parts/robot_component/control_module/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("It has [max_installed_software - LAZYLEN(installed_software)] empty slot\s remaining out of [max_installed_software]."))

/obj/item/robot_parts/robot_component/control_module/Initialize()
	. = ..()
	update_software()

/obj/item/robot_parts/robot_component/control_module/use_tool(obj/item/thing, mob/living/user, list/click_params)
	if(istype(thing, /obj/item/circuitboard/exosystem))
		install_software(thing, user)
		return TRUE

	if(isScrewdriver(thing))
		screwdriver_interaction(user)
		return
	else
		return ..()

/obj/item/robot_parts/robot_component/control_module/proc/screwdriver_interaction(mob/living/user)
	if(!LAZYLEN(contents))
		to_chat(user, "Внутри нет комплектующих.")
		return
	//Filter non movables
	var/list/valid_contents = list()
	for(var/atom/movable/A in contents)
		if(!A.anchored)
			valid_contents += A
	if(!LAZYLEN(valid_contents))
		return FALSE
	var/obj/item/circuitboard/exosystem/removed
	if(LAZYLEN(valid_contents) == 1)
		removed = pick(valid_contents)
	else
		removed = show_radial_menu(user, src, internal_parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(!(removed in contents))
		return TRUE
	user.visible_message(SPAN_NOTICE("\The [user] removes \the [removed] from \the [src]."))
	removed.forceMove(user.loc)
	playsound(user.loc, 'sound/effects/pop.ogg', 50, 0)
	update_software()

/obj/item/robot_parts/robot_component/control_module/proc/install_software(obj/item/circuitboard/exosystem/software, mob/user)
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

/obj/item/robot_parts/robot_component/control_module/proc/update_software()
	installed_software = list()
	installed_circuits = list()
	for(var/obj/item/circuitboard/exosystem/program in contents)
		installed_software |= program.contains_software
		installed_circuits |= program
	update_parts_images()

/obj/item/robot_parts/robot_component/control_module/proc/update_parts_images()
	internal_parts_list_images = make_item_radial_menu_choices(installed_circuits)

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
	name = "mech software template"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	var/list/contains_software = list()

/obj/item/circuitboard/exosystem/engineering
	name = "mech software (engineering systems)"
	contains_software = list(MECH_SOFTWARE_ENGINEERING)
	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1)

/obj/item/circuitboard/exosystem/utility
	name = "mech software (utility systems)"
	contains_software = list(MECH_SOFTWARE_UTILITY)
	icon_state = "mcontroller"
	origin_tech = list(TECH_DATA = 1)

/obj/item/circuitboard/exosystem/medical
	name = "mech software (medical systems)"
	contains_software = list(MECH_SOFTWARE_MEDICAL)
	icon_state = "mcontroller"
	origin_tech = list(TECH_DATA = 1,TECH_BIO = 1)

/obj/item/circuitboard/exosystem/weapons
	name = "mech software (basic weapon systems)"
	contains_software = list(MECH_SOFTWARE_WEAPONS)
	icon_state = "mainboard"
	origin_tech = list(TECH_DATA = 1, TECH_COMBAT = 3)
