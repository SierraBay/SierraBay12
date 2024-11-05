/obj/item/stock_parts/circuitboard/bs_snare_control
	name = "circuit board (bluespace snare manager console)"
	origin_tech = list(TECH_DATA = 4, TECH_BLUESPACE = 6)
	build_path = /obj/machinery/computer/bs_snare_control

/obj/item/stock_parts/circuitboard/bs_snare_hub
	name = "circuit board (bluespace snare hub)"
	origin_tech = list(TECH_DATA = 4, TECH_BLUESPACE = 6)
	build_path = /obj/machinery/bs_snare_hub
	req_components = list(
		/obj/item/bluespace_crystal = 2,
		/obj/item/stock_parts/capacitor/super = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/crystal = 1
	)
	board_type = "machine"
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/datum/design/circuit/bs_silk/bs_snare_control
	name = "circuit board (bluespace snare manager console)"
	id = "bs_snare_control"
	req_tech = list(TECH_DATA = 5, TECH_BLUESPACE = 6)
	build_path = /obj/item/stock_parts/circuitboard/bs_snare_control
	sort_string = "VAZOR"

/datum/design/circuit/bs_silk/bs_snare_hub
	name = "circuit board (bluespace snare hub)"
	id = "bs_snare_hub"
	req_tech = list(TECH_DATA = 5, TECH_BLUESPACE = 6)
	build_path = /obj/item/stock_parts/circuitboard/bs_snare_hub
	sort_string = "BSSNH"

/datum/design/item/clothing/accessory/bs_silk
	name = "bluespace snare control"
	id = "bs_silk"
	category = list("Misc")
	req_tech = list(TECH_BLUESPACE = 2)
	materials = list(MATERIAL_STEEL = 1000)
	build_path = /obj/item/clothing/accessory/bs_silk
	sort_string = "BSSIL"
