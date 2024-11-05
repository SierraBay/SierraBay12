/obj/item/stock_parts/circuitboard/cell_charger
	name = "circuit board (cell_charger)"
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 3)
	build_path = /obj/machinery/cell_charger
	req_components = list(
		/obj/item/stock_parts/capacitor = 2)

/obj/item/stock_parts/circuitboard/recharger
	name = "circuit board (recharger)"
	board_type = "machine"
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 4)
	build_path = /obj/machinery/recharger
	req_components = list(
		/obj/item/stock_parts/capacitor = 2)

/obj/item/stock_parts/circuitboard/wallcharger
	name = "circuit board (wall recharger)"
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 5)
	build_path = /obj/machinery/recharger/wallcharger
	req_components = list(
		/obj/item/stock_parts/capacitor = 2)

/datum/design/circuit/cell_charger
	name = "cell charger"
	id = "cellcharger"
	req_tech = list(TECH_DATA = 5, TECH_ENGINEERING = 3)
	build_path = /obj/item/stock_parts/circuitboard/cell_charger
	sort_string = "BOOOB"

/datum/design/circuit/recharger
	name = "recharger"
	id = "recharger"
	req_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 5)
	build_path = /obj/item/stock_parts/circuitboard/recharger
	sort_string = "BOBOB"

/datum/design/circuit/wallcharger
	name = "wall recharger"
	id = "wallrecharger"
	req_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 6)
	build_path = /obj/item/stock_parts/circuitboard/wallcharger
	sort_string = "BBOBO"
