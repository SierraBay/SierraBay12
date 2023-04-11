	//////////
	//TCOMMS//
	//////////

/obj/machinery/telecomms/hub/preseticcgn
	id = "Pioneer Corps Hub"
	network = "iccgntcommsat"
	autolinkers = list("iccgnHub", "iccgnrelay", "albrelay", "iccgndroptroops", "iccgnmedical", "iccgncommon", "iccgncommand",
	 "receiverIccgn", "broadcasterIccgn")

/obj/machinery/telecomms/relay/preset/iccgn
	id = "Pioneer Corps Relay"
	network = "iccgntcommsat"
	autolinkers = list("iccgnrelay")

/obj/machinery/telecomms/relay/preset/iccgnalb
	id = "Albatross Relay"
	network = "iccgntcommsat"
	autolinkers = list("albrelay")

/obj/machinery/telecomms/receiver/preset_iccgn
	id = "Pioneer Corps Receiver"
	network = "iccgntcommsat"
	autolinkers = list("receiverIccgn")
	freq_listening = list(ERT_FREQ, MED_FREQ, COMM_FREQ, PUB_FREQ)

/obj/machinery/telecomms/bus/preset_iccgn1
	id = "Pioneer Corps Bus 1"
	network = "iccgntcommsat"
	freq_listening = list(ERT_FREQ, COMM_FREQ)
	autolinkers = list("processoriccgn1", "iccgndroptroops", "iccgncommand")

/obj/machinery/telecomms/bus/preset_iccgn2
	id = "Pioneer Corps Bus 2"
	network = "iccgntcommsat"
	freq_listening = list(MED_FREQ, PUB_FREQ)
	autolinkers = list("processoriccgn2", "iccgnmedical", "iccgncommon")

/obj/machinery/telecomms/bus/preset_iccgn2/New()
	for(var/i = PUBLIC_LOW_FREQ, i < PUBLIC_HIGH_FREQ, i += 2)
		if(i == PUB_FREQ)
			continue
		freq_listening |= i
	..()

/obj/machinery/telecomms/processor/preset_iccgn1
	id = "Pioneer Corps Processor 1"
	network = "iccgntcommsat"
	autolinkers = list("processorIccgn1")

/obj/machinery/telecomms/processor/preset_iccgn2
	id = "Patrol Processor 2"
	network = "senttcommsat"
	autolinkers = list("processorIent2")

/obj/machinery/telecomms/broadcaster/preset_iccgn
	id = "Farfleet Broadcaster"
	network = "iccgntcommsat"
	autolinkers = list("broadcasterIccgn")

/obj/machinery/telecomms/server/presets/farfleet/common
	id = "Pioneer Corps Common Server"
	freq_listening = list(PUB_FREQ) // AI Private and Common
	network = "iccgntcommsat"
	autolinkers = list("iccgncommon")

/obj/machinery/telecomms/server/presets/farfleet/command
	id = "Pioneer Corps Command Server"
	freq_listening = list(COMM_FREQ)
	network = "iccgntcommsat"
	autolinkers = list("iccgncommand")

/obj/machinery/telecomms/server/presets/farfleet/droptroops
	id = "Pioneer Corps Droptroops Server"
	freq_listening = list(ERT_FREQ)
	network = "iccgntcommsat"
	autolinkers = list("iccgntroops")

/obj/machinery/telecomms/server/presets/farfleet/medical
	id = "Pioneer Corps Medical Server"
	freq_listening = list(MED_FREQ)
	network = "iccgntcommsat"
	autolinkers = list("iccgnmedical")

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
