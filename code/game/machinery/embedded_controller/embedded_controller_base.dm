/obj/machinery/embedded_controller
	name = "Embedded Controller"
	anchored = TRUE
	idle_power_usage = 10
	var/datum/computer/file/embedded_program/program	//the currently executing program
	var/on = 1
	var/last_icon_processing // cached for icon update optimization
	var/last_icon_pump_status // cached for icon update optimization
	var/list/outbound_signal_cooldowns = list()

	init_flags = 0

/obj/machinery/embedded_controller/Initialize()
	if(program)
		program = new program(src)
	return ..()

/obj/machinery/embedded_controller/Destroy()
	if(istype(program))
		qdel(program) // the program will clear the ref in its Destroy
	return ..()

/obj/machinery/embedded_controller/proc/post_signal(datum/signal/signal, comm_line, allow_repeat = FALSE)
	return 0

/obj/machinery/embedded_controller/proc/wake_processing()
	if(!(processing_flags & MACHINERY_PROCESS_SELF))
		START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)

/obj/machinery/embedded_controller/proc/should_send_outbound_signal(datum/signal/signal, comm_line, allow_repeat = FALSE)
	if(allow_repeat || !signal)
		return TRUE
	var/key = "[comm_line]|[json_encode(signal.data)]"
	var/last_sent = outbound_signal_cooldowns[key]
	if(last_sent && world.time < last_sent + SecondsToTicks(MESSAGE_RESEND_TIME))
		return FALSE
	outbound_signal_cooldowns[key] = world.time
	return TRUE

/obj/machinery/embedded_controller/receive_signal(datum/signal/signal, receive_method, receive_param)
	if(!signal || signal.encryption) return

	if(program)
		program.receive_signal(signal, receive_method, receive_param)
		wake_processing()
			//spawn(5) program.process() //no, program.process sends some signals and machines respond and we here again and we lag -rastaf0

/obj/machinery/embedded_controller/Topic(href, href_list)
	if(..())
		return
	if(usr)
		usr.set_machine(src)
	if(program)
		. = program.receive_user_command(href_list["command"]) // Any further sanitization should be done in here.
		if(.)
			wake_processing()
		return .

/obj/machinery/embedded_controller/Process()
	var/result = PROCESS_KILL
	if(program)
		result = program.process()
		// Only update icon when displayed state actually changes
		var/current_processing = program.memory["processing"]
		var/current_pump = program.memory["pump_status"]
		if(current_processing != last_icon_processing || current_pump != last_icon_pump_status)
			last_icon_processing = current_processing
			last_icon_pump_status = current_pump
			queue_icon_update()
	return result

/obj/machinery/embedded_controller/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/embedded_controller/radio
	icon = 'icons/obj/doors/airlock_machines.dmi'
	icon_state = "airlock_control_off"
	power_channel = ENVIRON
	density = FALSE
	unacidable = TRUE
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

/obj/machinery/embedded_controller/radio/post_signal(datum/signal/signal, radio_filter = null, allow_repeat = FALSE)
	signal.transmission_method = TRANSMISSION_RADIO
	if(!should_send_outbound_signal(signal, radio_filter, allow_repeat))
		qdel(signal)
		return FALSE
	if(radio_connection)
		return radio_connection.post_signal(src, signal, radio_filter, AIRLOCK_CONTROL_RANGE)
	else
		qdel(signal)

/obj/machinery/embedded_controller/radio/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, radio_filter)
