/obj/machinery/air_sensor
	icon = 'icons/obj/structures/airfilter.dmi'
	icon_state = "gsensor1"
	name = "gas sensor"

	anchored = TRUE

	uncreated_component_parts = list(
		/obj/item/stock_parts/radio/transmitter/on_event,
		/obj/item/stock_parts/power/apc
	)
	public_variables = list(
		/singleton/public_access/public_variable/input_toggle,
		/singleton/public_access/public_variable/gas,
		/singleton/public_access/public_variable/pressure,
		/singleton/public_access/public_variable/temperature
	)
	stock_part_presets = list(/singleton/stock_part_preset/radio/event_transmitter/air_sensor = 1)
	use_power = POWER_USE_IDLE

	frame_type = /obj/item/machine_chassis/air_sensor
	construct_state = /singleton/machine_construction/default/item_chassis
	base_type = /obj/machinery/air_sensor
	var/last_air_tick = -1
	var/datum/gas_mixture/cached_air_sample
	var/datum/gas_mixture/event_environment_ref

/obj/machinery/air_sensor/Initialize()
	. = ..()
	bind_environment_signal()
	toggle_input_toggle()

/obj/machinery/air_sensor/Destroy()
	if(event_environment_ref)
		UnregisterSignal(event_environment_ref, COMSIG_GASMIX_UPDATED)
	return ..()

/obj/machinery/air_sensor/Move(NewLoc, Dir, step_x, step_y)
	. = ..()
	if(.)
		bind_environment_signal()
		toggle_input_toggle()

/obj/machinery/air_sensor/proc/bind_environment_signal()
	var/datum/gas_mixture/new_environment = return_air()
	if(new_environment == event_environment_ref)
		return
	if(event_environment_ref)
		UnregisterSignal(event_environment_ref, COMSIG_GASMIX_UPDATED)
	event_environment_ref = new_environment
	if(event_environment_ref)
		RegisterSignal(event_environment_ref, COMSIG_GASMIX_UPDATED, PROC_REF(on_environment_gasmix_updated))

/obj/machinery/air_sensor/proc/on_environment_gasmix_updated(datum/gas_mixture/source, reason_flags)
	SIGNAL_HANDLER
	if(source != event_environment_ref)
		return
	toggle_input_toggle()

/obj/machinery/air_sensor/proc/get_air_sample_cached()
	if(last_air_tick != world.time)
		cached_air_sample = return_air()
		last_air_tick = world.time
	return cached_air_sample

/obj/machinery/air_sensor/on_update_icon()
	if(!powered())
		icon_state = "gsensor0"
	else
		icon_state = "gsensor[use_power]"

/singleton/public_access/public_variable/gas
	expected_type = /obj/machinery
	name = "gas data"
	desc = "A list of gas data from the sensor location; the list entries are two-entry lists with \"symbol\" and \"percent\" fields."
	can_write = FALSE
	has_updates = FALSE
	var_type = IC_FORMAT_LIST

/singleton/public_access/public_variable/gas/access_var(obj/machinery/sensor)
	var/datum/gas_mixture/air_sample
	if(istype(sensor, /obj/machinery/air_sensor))
		var/obj/machinery/air_sensor/air_sensor = sensor
		air_sample = air_sensor.get_air_sample_cached()
	else
		air_sample = sensor.return_air()
	if(!air_sample)
		return
	var/total_moles = air_sample.total_moles
	if(total_moles <= 0)
		return

	. = list()
	for(var/gas in air_sample.gas)
		var/gaspercent = round(air_sample.gas["[gas]"]*100/total_moles,0.01)
		var/gas_list = list("symbol" = gas_data.symbol_html["[gas]"], "percent" = gaspercent)
		. += list(gas_list)

/singleton/public_access/public_variable/pressure
	expected_type = /obj/machinery
	name = "pressure data"
	desc = "The pressure of the gas at the sensor."
	can_write = FALSE
	has_updates = FALSE
	var_type = IC_FORMAT_STRING

/singleton/public_access/public_variable/pressure/access_var(obj/machinery/sensor)
	var/datum/gas_mixture/air_sample
	if(istype(sensor, /obj/machinery/air_sensor))
		var/obj/machinery/air_sensor/air_sensor = sensor
		air_sample = air_sensor.get_air_sample_cached()
	else
		air_sample = sensor.return_air()
	return air_sample && num2text(round(air_sample.return_pressure(),0.1))

/singleton/public_access/public_variable/temperature
	expected_type = /obj/machinery
	name = "temperature data"
	desc = "The temperature of the gas at the sensor."
	can_write = FALSE
	has_updates = FALSE
	var_type = IC_FORMAT_NUMBER

/singleton/public_access/public_variable/temperature/access_var(obj/machinery/sensor)
	var/datum/gas_mixture/air_sample
	if(istype(sensor, /obj/machinery/air_sensor))
		var/obj/machinery/air_sensor/air_sensor = sensor
		air_sample = air_sensor.get_air_sample_cached()
	else
		air_sample = sensor.return_air()
	return air_sample && round(air_sample.temperature,0.1)

/singleton/stock_part_preset/radio/event_transmitter/air_sensor
	event = /singleton/public_access/public_variable/input_toggle
	transmit_on_event = list(
		"gas" = /singleton/public_access/public_variable/gas,
		"pressure" = /singleton/public_access/public_variable/pressure,
		"temperature" = /singleton/public_access/public_variable/temperature
	)
	frequency = ATMOS_TANK_FREQ

/obj/machinery/air_sensor/engine
	stock_part_presets = list(/singleton/stock_part_preset/radio/event_transmitter/air_sensor/engine = 1)

/singleton/stock_part_preset/radio/event_transmitter/air_sensor/engine
	frequency = ATMOS_ENGINE_FREQ

/obj/machinery/air_sensor/dist
	stock_part_presets = list(/singleton/stock_part_preset/radio/event_transmitter/air_sensor/dist = 1)

/singleton/stock_part_preset/radio/event_transmitter/air_sensor/dist
	frequency = ATMOS_DIST_FREQ
