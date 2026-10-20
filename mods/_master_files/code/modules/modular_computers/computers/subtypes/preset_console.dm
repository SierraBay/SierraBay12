// TRADE: replace factory software before the parent preset installs files.
/obj/machinery/computer/modular/preset/dock/Initialize(mapload)
	if(GLOB.using_map.path == "sierra")
		default_software = default_software.Copy()
		default_software -= /datum/computer_file/program/supply
		default_software |= /datum/computer_file/program/trade
	return ..()

/obj/machinery/computer/modular/preset/supply_public/Initialize(mapload)
	if(GLOB.using_map.path == "sierra")
		default_software = list(/datum/computer_file/program/trade_orders)
		autorun_program = /datum/computer_file/program/trade_orders
	return ..()
