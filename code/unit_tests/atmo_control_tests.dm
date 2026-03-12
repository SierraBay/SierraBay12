/datum/radio_frequency/unit_test_capture
	var/post_count = 0
	var/list/last_signal_data

/datum/radio_frequency/unit_test_capture/post_signal(obj/source as obj|null, datum/signal/signal, radio_filter = null as text|null, range = null as num|null)
	post_count++
	last_signal_data = signal?.data?.Copy()
	return TRUE

/datum/unit_test/atmo_control
	name = "template - atmo control"
	template = /datum/unit_test/atmo_control

/datum/unit_test/atmo_control/proc/create_console(typepath = /obj/machinery/computer/air_control)
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for atmo control tests.")
		return
	return new typepath(T)

/datum/unit_test/atmo_control/signal_routing
	name = "MACHINE: Air control consoles route signals only to matching tags"

/datum/unit_test/atmo_control/signal_routing/start_test()
	var/obj/machinery/computer/air_control/console = create_console()
	if(!console)
		return 1

	console.sensor_tag = "sensor"
	console.input_tag = "input"
	console.output_tag = "output"
	console.sensor_info = list("state" = "old_sensor")
	console.input_info = list("state" = "old_input")
	console.output_info = list("state" = "old_output")

	var/datum/signal/signal = new
	signal.data = list("tag" = "sensor", "pressure" = 101.3)
	console.receive_signal(signal)
	if(console.sensor_info["pressure"] != 101.3)
		fail("Expected matching sensor tag to update only sensor_info.")
		qdel(console)
		return 1
	if(console.input_info["state"] != "old_input" || console.output_info["state"] != "old_output")
		fail("Matching sensor tag should not mutate input_info or output_info.")
		qdel(console)
		return 1

	signal = new
	signal.data = list("tag" = "input", "power" = 1)
	console.receive_signal(signal)
	if(console.input_info["power"] != 1)
		fail("Expected matching input tag to update input_info.")
		qdel(console)
		return 1

	signal = new
	signal.data = list("tag" = "output", "external" = 500)
	console.receive_signal(signal)
	if(console.output_info["external"] != 500)
		fail("Expected matching output tag to update output_info.")
		qdel(console)
		return 1

	signal = new
	signal.data = list("tag" = "irrelevant", "pressure" = 999)
	console.receive_signal(signal)
	if(console.sensor_info["pressure"] != 101.3 || console.input_info["power"] != 1 || console.output_info["external"] != 500)
		fail("Irrelevant tags should not mutate cached console info.")
		qdel(console)
		return 1

	pass("Air control consoles update only the matching cached signal payload.")
	qdel(console)
	return 1

/datum/unit_test/atmo_control/fuel_injection_routing_and_wakeup
	name = "MACHINE: Fuel injection consoles route device signals and wake on sensor updates"

/datum/unit_test/atmo_control/fuel_injection_routing_and_wakeup/start_test()
	var/obj/machinery/computer/air_control/fuel_injection/console = create_console(/obj/machinery/computer/air_control/fuel_injection)
	if(!console)
		return 1

	console.sensor_tag = "sensor"
	console.device_tag = "injector"
	console.automation = TRUE
	console.device_info = list("state" = "old_device")

	var/datum/signal/signal = new
	signal.data = list("tag" = "injector", "power" = 1)
	console.receive_signal(signal)
	if(console.device_info["power"] != 1)
		fail("Expected matching device tag to update device_info.")
		qdel(console)
		return 1

	signal = new
	signal.data = list("tag" = "sensor", "temperature" = 1000)
	console.receive_signal(signal)
	if(console.sensor_info["temperature"] != 1000)
		fail("Expected matching sensor tag to update inherited sensor_info.")
		qdel(console)
		return 1
	if(!(console.processing_flags & MACHINERY_PROCESS_SELF))
		fail("Fuel injection console should wake self-processing when automation receives a sensor update.")
		qdel(console)
		return 1

	pass("Fuel injection consoles route both device and shared sensor signals correctly.")
	qdel(console)
	return 1

/datum/unit_test/atmo_control/process_behavior_and_dedupe
	name = "MACHINE: Air control processing is killed when idle and fuel automation deduplicates commands"

/datum/unit_test/atmo_control/process_behavior_and_dedupe/start_test()
	var/obj/machinery/computer/air_control/base_console = create_console()
	if(!base_console)
		return 1
	if(base_console.Process() != PROCESS_KILL)
		fail("Base air control console should not self-process while idle.")
		qdel(base_console)
		return 1
	qdel(base_console)

	var/obj/machinery/computer/air_control/fuel_injection/console = create_console(/obj/machinery/computer/air_control/fuel_injection)
	if(!console)
		return 1
	if(console.Process() != PROCESS_KILL)
		fail("Fuel injection console with automation disabled should return PROCESS_KILL.")
		qdel(console)
		return 1

	console.device_tag = "injector"
	console.sensor_tag = "sensor"
	console.automation = TRUE
	console.last_automation_state = null
	console.radio_connection = new /datum/radio_frequency/unit_test_capture
	console.sensor_info = list("temperature" = 1000)

	if(console.Process() != PROCESS_KILL)
		fail("Fuel injection console should complete automation work in a single wakeup tick.")
		qdel(console)
		return 1

	var/datum/radio_frequency/unit_test_capture/radio = console.radio_connection
	if(radio.post_count != 1)
		fail("Expected the first automation tick to emit exactly one command.")
		qdel(console)
		return 1
	if(radio.last_signal_data["set_power"] != 1)
		fail("Expected low temperature automation to request injector power on.")
		qdel(console)
		return 1

	console.Process()
	if(radio.post_count != 1)
		fail("Repeated automation ticks with the same desired state should not emit duplicate commands.")
		qdel(console)
		return 1

	console.sensor_info = list("temperature" = 2500)
	console.Process()
	if(radio.post_count != 2)
		fail("Expected temperature threshold transition to emit exactly one additional command.")
		qdel(console)
		return 1
	if(radio.last_signal_data["set_power"] != 0)
		fail("Expected high temperature automation to request injector power off.")
		qdel(console)
		return 1

	pass("Atmo control processing idles correctly and fuel automation sends commands only on state transitions.")
	qdel(console)
	return 1
