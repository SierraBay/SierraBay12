/obj/machinery/tele_pad
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null

/obj/machinery/tele_projector
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null

/obj/item/stock_parts/circuitboard/tele_pad
	name = "circuit board (teleporter pad)"
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4, TECH_BLUESPACE = 4)
	build_path = /obj/machinery/tele_pad

/obj/item/stock_parts/circuitboard/tele_projector
	name = "circuit board (telepad projector)"
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4, TECH_BLUESPACE = 4)
	build_path = /obj/machinery/tele_projector

/datum/design/circuit/tele_pad
	name = "telepad machine"
	id = "teleporter_pad"
	req_tech = list(TECH_DATA = 4, TECH_BLUESPACE = 4)
	build_path = /obj/item/stock_parts/circuitboard/tele_pad
	sort_string = "MAAAA"

/datum/design/circuit/tele_projector
	name = "telepad projector machine"
	id = "teleprojector"
	req_tech = list(TECH_DATA = 4, TECH_BLUESPACE = 4)
	build_path = /obj/item/stock_parts/circuitboard/tele_projector
	sort_string = "MAAAA"

/obj/item/stock_parts/circuitboard/telepad
	name = "circuit board (telepad)"
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 3, TECH_MATERIAL = 3, TECH_BLUESPACE = 4)
	build_path = /obj/machinery/telepad
	req_components = list(
		/obj/item/bluespace_crystal = 2,
		/obj/item/stock_parts/capacitor = 1
	)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/stock_parts/circuitboard/telesci_console
	name = "circuit board (telescience console)"
	build_path = /obj/machinery/computer/telescience
	origin_tech = list(TECH_DATA = 3, TECH_BLUESPACE = 2)

/datum/design/circuit/telepad
	name = "telepad"
	id = "telepad"
	req_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 3, TECH_MATERIAL = 3, TECH_BLUESPACE = 4)
	build_path = /obj/item/stock_parts/circuitboard/telepad
	sort_string = "HAAAF"

/datum/design/circuit/telesci_console
	name = "telepad control console"
	id = "telesci_console"
	req_tech = list(TECH_DATA = 3, TECH_BLUESPACE = 2)
	build_path = /obj/item/stock_parts/circuitboard/telesci_console
	sort_string = "HAAAD"

/datum/design/item/telesci/artificial/bluespace
	name = "artificial bluespace crystal"
	id = "artificial_bluespace_crystal"
	category = list("Misc")
	req_tech = list(TECH_DATA = 4, TECH_BLUESPACE = 4)
	materials = list(MATERIAL_GOLD = 1500, MATERIAL_DIAMOND = 1500, MATERIAL_PHORON = 1500)
	build_path = /obj/item/bluespace_crystal/artificial
	sort_string = "BOABS"
