/obj/item/stock_parts/circuitboard/trade_beacon
	origin_tech = list(TECH_BLUESPACE = 2)
	board_type = "machine"
	req_components = list(
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/subspace/crystal = 2
	)

/obj/item/stock_parts/circuitboard/trade_beacon/receiving
	name = "circuit board (receiving trade beacon)"
	build_path = /obj/machinery/trade_beacon/receiving

/obj/item/stock_parts/circuitboard/trade_beacon/sending
	name = "circuit board (sending trade beacon)"
	build_path = /obj/machinery/trade_beacon/sending
