/// Legacy map/path: formerly mission contract pad. Behaves as a normal transport pad.
/obj/machinery/drone_pad/rd_mission
	name = "R&D transport drone pad"
	desc = "A transport drone landing pad for Research. Corporate mission delivery is no longer supported."
	initial_id_tag = "rd_transport"

/obj/item/stock_parts/circuitboard/rd_mission_drone_pad
	name = "circuit board (R&D transport drone pad)"
	build_path = /obj/machinery/drone_pad/rd_mission
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stock_parts/scanning_module = 4,
		/obj/item/bluespace_crystal = 1
	)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/datum/design/circuit/rd_mission_drone_pad
	name = "R&D transport drone pad"
	id = "rd_mission_drone_pad"
	req_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3, TECH_BLUESPACE = 2)
	build_path = /obj/item/stock_parts/circuitboard/rd_mission_drone_pad
	sort_string = "MAAAN"
