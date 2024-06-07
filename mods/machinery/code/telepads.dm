/obj/machinery/tele_pad
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null

/obj/machinery/tele_projector
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null

/obj/item/stock_parts/circuitboard/tele_pad
	name = "circuit board (telepad)"
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
	id = "telepad"
	req_tech = list(TECH_DATA = 4, TECH_BLUESPACE = 4)
	build_path = /obj/item/stock_parts/circuitboard/tele_pad
	sort_string = "MAAAA"

/datum/design/circuit/tele_projector
	name = "telepad projector machine"
	id = "teleprojector"
	req_tech = list(TECH_DATA = 4, TECH_BLUESPACE = 4)
	build_path = /obj/item/stock_parts/circuitboard/tele_projector
	sort_string = "MAAAA"
