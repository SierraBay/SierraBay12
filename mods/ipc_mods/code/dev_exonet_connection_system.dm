// ── ECS HARDWARE MODULES & STOCK PARTS ───────────────────────────────────────
// The ECS organ IS the computer. These modular_computer/ecs items are hardware
// bundles — inserting one into an open ECS organ swaps its hardware.

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

/obj/item/stock_parts/computer/battery_module/converter
	name = "ECS battery converter"
	desc = "A converter that bridges the IPC's main battery cell to the ECS power bus."
	icon_state = "battery_nano"
	origin_tech = list(TECH_POWER = 1, TECH_ENGINEERING = 1)
	battery_rating = 80
	exonets_ipc_computer_suitable = TRUE

// ── ECS HARDWARE MODULES ─────────────────────────────────────────────────────

/obj/item/modular_computer/ecs
	name = "ECS hardware module"
	desc = "A standard ECS hardware module with storage and a network card."
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "ecs_on"
	icon_state_unpowered = "ecs_off"
	anchored = FALSE
	w_class = ITEM_SIZE_NORMAL
	broken_damage = 60
	max_hardware_size = 2
	hardware_flag = PROGRAM_TABLET

/obj/item/modular_computer/ecs/attack_self(mob/user)
	return  // Cannot be operated standalone; install into an ECS organ

/obj/item/modular_computer/ecs/install_default_hardware()
	..()
	processor_unit = new /obj/item/stock_parts/computer/processor_unit(src)
	hard_drive     = new /obj/item/stock_parts/computer/hard_drive(src)
	network_card   = new /obj/item/stock_parts/computer/network_card(src)

/obj/item/modular_computer/ecs/install_default_programs()
	return  // Programs live on the ECS organ, not the module

// ── CRAFTING RECIPES ─────────────────────────────────────────────────────────

/datum/design/item/modularcomponent/battery/converter
	name = "ECS battery converter"
	id = "ecs_converter"
	req_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 4, TECH_POWER = 3)
	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 800)
	chemicals = list(/datum/reagent/acid = 20)
	build_path = /obj/item/stock_parts/computer/battery_module/converter
	sort_string = "VBABE"

/datum/design/item/modularcomponent/ecs
	name = "ECS hardware module"
	id = "exonet"
	req_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MATERIAL_STEEL = 4000, MATERIAL_GLASS = 3000)
	chemicals = list(/datum/reagent/acid = 50)
	build_path = /obj/item/modular_computer/ecs
	sort_string = "VBAFE"
