/obj/item/stock_parts/circuitboard/law_rack
	name = "circuit board (AI Law Rack)"
	build_path = /obj/machinery/law_rack
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 3)
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/console_screen = 1
	)
	additional_spawn_components = list(
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/datum/design/circuit/law_rack
	name = "AI Law Rack"
	id = "law_rack_board"
	req_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	build_path = /obj/item/stock_parts/circuitboard/law_rack
	sort_string = "XAAAD"

/datum/design/aimodule/law_module
	name = "AI Law Module"
	id = "law_module"
	req_tech = list(TECH_DATA = 2, TECH_MATERIAL = 2)
	build_path = /obj/item/law_module
	sort_string = "XADAA"

/datum/design/aimodule/law_module/AssembleDesignDesc()
	desc = "Allows for the construction of \a '[name]' physical AI law module."

/datum/design/aimodule/law_module/core
	name = "AI Core Law Module"
	id = "law_module_core"
	build_path = /obj/item/law_module/core
	req_tech = list(TECH_DATA = 3, TECH_MATERIAL = 3)
	sort_string = "XADAB"

/datum/design/aimodule/law_module/supplied
	name = "AI Supplied Law Module"
	id = "law_module_supplied"
	build_path = /obj/item/law_module/supplied
	req_tech = list(TECH_DATA = 3, TECH_MATERIAL = 3)
	sort_string = "XADAC"
