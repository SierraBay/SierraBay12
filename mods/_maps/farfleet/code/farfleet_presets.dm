		////////
		//SMES//
		////////

/obj/machinery/power/smes/buildable/preset/farfleet/engine_main
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil/super_capacity = 1,
									/obj/item/stock_parts/smes_coil = 1)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

/obj/machinery/power/smes/buildable/preset/farfleet/engine_gyrotron
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 1,
									/obj/item/stock_parts/smes_coil/super_io = 1)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

/obj/machinery/power/smes/buildable/preset/farfleet/shuttle
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 1)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

/obj/machinery/power/smes/buildable/preset/farfleet/laser
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 1,
									/obj/item/stock_parts/smes_coil = 1)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE


		// Missile console //

/datum/computer_file/program/munitions/iccg
	filename = "munitionscontrol"
	filedesc = "PC Munitions Control Program"
	nanomodule_path = /datum/nano_module/program/munitions/iccg
	program_icon_state = "munitions"
	program_key_state = "security_key"
	program_menu_icon = "bullet"
	extended_desc = "ICCGN Program for controlling munitions loading and arming systems."
	requires_ntnet = FALSE
	size = 8
	category = PROG_COMMAND
	usage_flags = PROGRAM_CONSOLE
	requires_ntnet_feature = NTNET_SYSTEMCONTROL
	available_on_ntnet = FALSE
	available_on_syndinet = FALSE
	required_access = access_away_iccgn

/datum/nano_module/program/munitions/iccg
	name = "PC Munitions Control Program"
	access_req = list(access_away_iccgn)

// Computer preset

/obj/machinery/computer/modular/preset/munitions/iccg
	default_software = list(
		/datum/computer_file/program/munitions/iccg
	)
