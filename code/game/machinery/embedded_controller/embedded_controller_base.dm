/obj/machinery/embedded_controller
	name = "Embedded Controller"
	anchored = TRUE
	idle_power_usage = 10
	var/datum/computer/file/embedded_program/program	//the currently executing program
	var/on = 1
	/// If TRUE, icon updates are emitted only when a compact state signature changes.
	var/optimize_icon_tick = FALSE
	/// If TRUE, controller can stop processing while idle and wake up on events.
	var/optimize_event_processing = FALSE
	var/tmp/last_icon_state_signature

/obj/machinery/embedded_controller/Initialize()
	if(program)
		program = new program(src)
	. = ..()
	refresh_processing_registration()

/obj/machinery/embedded_controller/Destroy()
	if(istype(program))
		qdel(program) // the program will clear the ref in its Destroy
	return ..()

/obj/machinery/embedded_controller/proc/post_signal(datum/signal/signal, comm_line)
	return 0

/obj/machinery/embedded_controller/receive_signal(datum/signal/signal, receive_method, receive_param)
	if(!signal || signal.encryption) return

	if(program)
		program.receive_signal(signal, receive_method, receive_param)
		if(event_processing_optimization_enabled())
			// Wake on explicit commands or when a signal moved us into an active state.
			if(signal.data["command"] || controller_requires_active_processing())
				START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
			//spawn(5) program.process() //no, program.process sends some signals and machines respond and we here again and we lag -rastaf0

/obj/machinery/embedded_controller/Topic(href, href_list)
	if(..())
		return
	if(usr)
		usr.set_machine(src)
	if(program)
		var/command_result = program.receive_user_command(href_list["command"]) // Any further sanitization should be done in here.
		if(event_processing_optimization_enabled() && command_result)
			START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		return command_result

/obj/machinery/embedded_controller/Process()
	if(program)
		program.process()

	if(optimize_icon_tick)
		var/icon_state_signature = get_icon_state_signature()
		if(icon_state_signature != last_icon_state_signature)
			last_icon_state_signature = icon_state_signature
			update_icon()
	else
		update_icon()

	if(event_processing_optimization_enabled() && !controller_requires_active_processing())
		return PROCESS_KILL

/obj/machinery/embedded_controller/proc/event_processing_optimization_enabled()
	if(!optimize_event_processing)
		return FALSE
	var/datum/computer/file/embedded_program/docking/docking_program = program
	if(istype(docking_program))
		return SSmachines.optimize_embedded_docking_event
	var/datum/computer/file/embedded_program/airlock/multi_docking/multi_docking_program = program
	if(istype(multi_docking_program))
		return SSmachines.optimize_embedded_docking_event
	return TRUE

/obj/machinery/embedded_controller/proc/controller_requires_active_processing()
	if(!event_processing_optimization_enabled())
		return TRUE
	if(!on || !istype(program))
		return FALSE

	var/datum/computer/file/embedded_program/airlock/airlock_program = program
	if(istype(airlock_program))
		var/datum/computer/file/embedded_program/airlock/multi_docking/multi_docking_program = airlock_program
		if(istype(multi_docking_program) && multi_docking_program.docking_enabled && !multi_docking_program.response_sent)
			return TRUE
		return !!airlock_program.memory["processing"]

	var/datum/computer/file/embedded_program/docking/docking_program = program
	if(istype(docking_program))
		var/docking_status = docking_program.get_docking_status()
		if(docking_status == "docking" || docking_status == "undocking")
			return TRUE
		var/datum/computer/file/embedded_program/docking/airlock/airlock_docking_program = docking_program
		if(istype(airlock_docking_program))
			airlock_program = airlock_docking_program.airlock_program
			if(istype(airlock_program))
				return !!airlock_program.memory["processing"]
		return FALSE

	return TRUE

/obj/machinery/embedded_controller/proc/refresh_processing_registration()
	if(!event_processing_optimization_enabled())
		START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		return
	if(controller_requires_active_processing())
		START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
	else
		STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)

/obj/machinery/embedded_controller/proc/get_icon_state_signature()
	var/signature = 0
	if(on)
		signature |= 1
	if(!istype(program))
		return signature
	signature |= (1 << 1)
	var/processing = !!program.memory["processing"]
	var/override_enabled = FALSE
	var/airlock_processing = FALSE
	var/pump_is_siphon = FALSE

	var/datum/computer/file/embedded_program/docking/airlock/docking_program = program
	if(istype(docking_program))
		override_enabled = !!docking_program.override_enabled
		var/datum/computer/file/embedded_program/airlock/airlock_program = docking_program.airlock_program
		if(istype(airlock_program))
			airlock_processing = !!airlock_program.memory["processing"]
			if(airlock_processing)
				pump_is_siphon = (airlock_program.memory["pump_status"] == "siphon")
	else
		var/datum/computer/file/embedded_program/airlock/airlock_program = program
		if(istype(airlock_program))
			airlock_processing = !!airlock_program.memory["processing"]
			if(airlock_processing)
				pump_is_siphon = (airlock_program.memory["pump_status"] == "siphon")

	if(processing)
		signature |= (1 << 2)
	if(override_enabled)
		signature |= (1 << 3)
	if(airlock_processing)
		signature |= (1 << 4)
	if(pump_is_siphon)
		signature |= (1 << 5)
	return signature

/obj/machinery/embedded_controller/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/embedded_controller/radio
	icon = 'icons/obj/doors/airlock_machines.dmi'
	icon_state = "airlock_control_off"
	power_channel = ENVIRON
	density = FALSE
	unacidable = TRUE
	optimize_icon_tick = TRUE
	var/frequency = 1379
	var/radio_filter = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/embedded_controller/radio/Initialize()
	set_frequency(frequency)
	. = ..()

/obj/machinery/embedded_controller/radio/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	..()

/obj/machinery/embedded_controller/radio/on_update_icon()
	ClearOverlays()
	if(!on || !istype(program))
		return
	if(!program.memory["processing"])
		AddOverlays(image(icon, "screen_standby"))
		AddOverlays(image(icon, "indicator_done"))
	else
		AddOverlays(image(icon, "indicator_active"))
	var/datum/computer/file/embedded_program/docking/airlock/docking_program = program
	var/datum/computer/file/embedded_program/airlock/airlock_program = program
	if(istype(docking_program))
		if(docking_program.override_enabled)
			AddOverlays(image(icon, "indicator_forced"))
		airlock_program = docking_program.airlock_program

	if(istype(airlock_program) && airlock_program.memory["processing"])
		if(airlock_program.memory["pump_status"] == "siphon")
			AddOverlays(image(icon, "screen_drain"))
		else
			AddOverlays(image(icon, "screen_fill"))

/obj/machinery/embedded_controller/radio/post_signal(datum/signal/signal, radio_filter = null)
	signal.transmission_method = TRANSMISSION_RADIO
	if(radio_connection)
		return radio_connection.post_signal(src, signal, radio_filter, AIRLOCK_CONTROL_RANGE)
	else
		qdel(signal)

/obj/machinery/embedded_controller/radio/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, radio_filter)
