//// INTERNAL IPCs COMPUTER
/obj/item/modular_computer
	var/exonets_ipc_computer = FALSE

/obj/item/stock_parts/computer
	var/exonets_ipc_computer_suitable = FALSE

/obj/item/stock_parts/computer/hard_drive
	exonets_ipc_computer_suitable = TRUE
/obj/item/stock_parts/computer/network_card
	exonets_ipc_computer_suitable = TRUE
/obj/item/stock_parts/computer/network_card/wired
	exonets_ipc_computer_suitable = FALSE
/obj/item/stock_parts/computer/processor_unit
	exonets_ipc_computer_suitable = TRUE




/mob/living/carbon/human/default_can_use_topic(src_object)
	.=..()
	var/dist = get_dist(src_object, src)
	var/obj/item/modular_computer/ecs/computer = src_object
	if(computer.parent_type == /obj/item/modular_computer/ecs)
		if(is_species(SPECIES_IPC) && dist == 0)
			return STATUS_INTERACTIVE
		else if (dist <= 3)
			return STATUS_UPDATE
		else
			return STATUS_CLOSE

/obj/item/stock_parts/computer/battery_module/converter
	name = "Converter battery"
	desc = "A tiny device with sole purpose to connect main IPC battery"
	icon_state = "battery_nano"
	origin_tech = list(TECH_POWER = 1, TECH_ENGINEERING = 1)
	battery_rating = 80
	exonets_ipc_computer_suitable = TRUE

/obj/item/modular_computer/ecs
	name = "exonet connection system"
	desc = "A cirquit with some ports and wires."
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "ecs_on"
	icon_state_unpowered = "ecs_off"
	anchored = FALSE
	w_class = ITEM_SIZE_NORMAL
	base_idle_power_usage = 5
	base_active_power_usage = 50
	light_strength = 0
	broken_damage = 60
	max_hardware_size = 2
	hardware_flag = PROGRAM_LAPTOP
	exonets_ipc_computer = TRUE

/obj/item/modular_computer/ecs/first
	name = "exonet connection system."
	hardware_flag = PROGRAM_TABLET
	desc = "A simple circuit with some ports and wires."

/obj/item/modular_computer/ecs/second
	name = "exonet connection system."
	hardware_flag = PROGRAM_TABLET
	desc = "A complex circuit with some ports and wires."

/obj/item/modular_computer/ecs/third
	name = "exonet connection system."
	hardware_flag = PROGRAM_LAPTOP
	desc = "An extremely complex circuit with some ports and wires."

/obj/item/modular_computer/ecs/first/install_default_hardware()
	..()
	processor_unit = new/obj/item/stock_parts/computer/processor_unit(src)
	hard_drive = new/obj/item/stock_parts/computer/hard_drive/small(src)
	network_card = new/obj/item/stock_parts/computer/network_card(src)
	battery_module = new/obj/item/stock_parts/computer/battery_module/converter(src)

/obj/item/modular_computer/ecs/second/install_default_hardware()
	..()
	processor_unit = new/obj/item/stock_parts/computer/processor_unit(src)
	hard_drive = new/obj/item/stock_parts/computer/hard_drive(src)
	network_card = new/obj/item/stock_parts/computer/network_card/advanced(src)
	battery_module = new/obj/item/stock_parts/computer/battery_module/converter(src)


/obj/item/modular_computer/ecs/third/install_default_hardware()
	..()
	processor_unit = new/obj/item/stock_parts/computer/processor_unit(src)
	hard_drive = new/obj/item/stock_parts/computer/hard_drive/advanced(src)
	network_card = new/obj/item/stock_parts/computer/network_card/advanced(src)
	battery_module = new/obj/item/stock_parts/computer/battery_module/converter(src)

/obj/item/modular_computer/ecs/install_default_programs()
	..()
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(os)
		os.create_file(new/datum/computer_file/program/email_client())
		os.create_file(new/datum/computer_file/program/wordprocessor())
		os.create_file(new/datum/computer_file/program/crew_manifest())


/obj/item/modular_computer/ecs/attack_self(mob/user) // Оставляем возможность вызывать окно только через абилку ИПСа
	return


/obj/item/modular_computer/ecs/proc/open_terminal_ecs(mob/user)
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	return  os.open_terminal(user)


/obj/item/modular_computer/ecs/emag_act(remaining_charges, mob/user)
	to_chat(user, "\The [src] cannot be emagged.")
	return NO_EMAG_ACT

/obj/item/modular_computer/ecs/turn_on(mob/user)
	if(bsod)
		return
	if(tesla_link)
		tesla_link.enabled = TRUE
	if (get_damage_value() > broken_damage)
		to_chat(user, "You send an activation signal to \the [src], but it responds with an error code. It must be damaged.")
		return
	if(processor_unit && (apc_power(0) || battery_power(0))) // Battery-run and charged or non-battery but powered by APC.
		to_chat(user, "You send an activation signal to \the [src], turning it on.")
		enable_computer(user)
	else // Unpowered
		to_chat(user, "You send an activation signal to \the [src] but it does not respond.")


/obj/item/modular_computer/use_tool(obj/item/W, mob/living/user, list/click_params)
	. = ..()
	if(istype(W, /obj/item/stock_parts/computer))
		var/obj/item/stock_parts/computer/C = W
		if(exonets_ipc_computer && C.exonets_ipc_computer_suitable)
			if(C.hardware_size <= max_hardware_size)
				try_install_component(user, C)
			else
				to_chat(user, "This component is not suitable for \the [src].")

/datum/design/item/modularcomponent/battery/converter
	name = "exonet battery converter"
	id = "ecs_converter"
	req_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 4, TECH_POWER = 3)
	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 800)
	chemicals = list(/datum/reagent/acid = 20)
	build_path = /obj/item/stock_parts/computer/battery_module/converter
	sort_string = "VBABE"

/datum/design/item/modularcomponent/ecs
	name = "exonet connection system"
	id = "exonet"
	req_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 4000, glass = 3000)
	chemicals = list(/datum/reagent/acid = 50)
	build_path = /obj/item/modular_computer/ecs/second
	sort_string = "VBAFE"
