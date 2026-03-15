/obj/item/stock_parts/radio/transmitter
	name = "radio transmitter"
	desc = "A radio transmitter designed for use with machines."
	icon_state = "subspace_transmitter"
	var/range = 60  // Limits transmit range
	var/latency = 2 // Delay between event and transmission; doesn't apply to transmit on tick
	var/buffer

/obj/item/stock_parts/radio/transmitter/proc/queue_transmit(list/data)
	if(!length(data))
		return
	if(!buffer)
		buffer = data
		addtimer(new Callback(src, PROC_REF(transmit)), latency)
	else
		buffer |= data

/obj/item/stock_parts/radio/transmitter/proc/transmit()
	if(!LAZYLEN(buffer))
		return
	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = TRANSMISSION_RADIO
	signal.encryption = encryption
	signal.data = buffer
	signal.data["tag"] = id_tag
	radio.post_signal(src, signal, filter, range)
	buffer = null

// Standard variant can either transmit on var change or transmit every tick. Latter is not encouraged for premade variants.
/obj/item/stock_parts/radio/transmitter/basic
	multitool_extension = /datum/extension/interactive/multitool/radio/transmitter
	var/list/transmit_on_change
	var/list/transmit_on_tick
	var/transmit_interval = 2 SECONDS
	var/list/last_transmitted_data
	var/telemetry_timer_scheduled = FALSE

/obj/item/stock_parts/radio/transmitter/basic/proc/var_changed(singleton/public_access/public_variable/variable, obj/machinery/machine, old_value, new_value)
	var/list/L = list()
	for(var/thing in transmit_on_change)
		if(transmit_on_change[thing] == variable)
			L[thing] = new_value
	queue_transmit(L)

/obj/item/stock_parts/radio/transmitter/basic/proc/can_periodically_transmit(obj/machinery/machine)
	return istype(machine) && loc == machine && (status & PART_STAT_INSTALLED) && LAZYLEN(transmit_on_tick)

/obj/item/stock_parts/radio/transmitter/basic/proc/start_periodic_transmit(obj/machinery/machine)
	last_transmitted_data = null
	schedule_next_periodic_transmit(machine, 0)

/obj/item/stock_parts/radio/transmitter/basic/proc/stop_periodic_transmit(obj/machinery/machine)
	telemetry_timer_scheduled = FALSE
	last_transmitted_data = null

/obj/item/stock_parts/radio/transmitter/basic/proc/schedule_next_periodic_transmit(obj/machinery/machine, delay = transmit_interval)
	if(!can_periodically_transmit(machine))
		return
	telemetry_timer_scheduled = TRUE
	addtimer(new Callback(src, PROC_REF(periodic_transmit), machine), delay, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/stock_parts/radio/transmitter/basic/proc/build_tick_payload(obj/machinery/machine)
	var/list/L = list()
	for(var/thing in transmit_on_tick)
		var/singleton/public_access/public_variable/variable = transmit_on_tick[thing]
		L[thing] = variable.access_var(machine)
	return L

/obj/item/stock_parts/radio/transmitter/basic/proc/periodic_transmit(obj/machinery/machine)
	telemetry_timer_scheduled = FALSE
	if(!can_periodically_transmit(machine))
		return

	var/list/payload = build_tick_payload(machine)
	if(LAZYLEN(payload))
		var/payload_signature = json_encode(payload)
		var/last_payload_signature = LAZYLEN(last_transmitted_data) ? json_encode(last_transmitted_data) : null
		if(payload_signature != last_payload_signature)
			queue_transmit(payload)
			last_transmitted_data = payload.Copy()
	else
		last_transmitted_data = null

	if(can_periodically_transmit(machine))
		schedule_next_periodic_transmit(machine)

/obj/item/stock_parts/radio/transmitter/basic/on_install(obj/machinery/machine)
	..()
	sanitize_events(machine, transmit_on_change)
	sanitize_events(machine, transmit_on_tick)
	if(LAZYLEN(transmit_on_tick))
		start_periodic_transmit(machine)
	for(var/thing in transmit_on_change)
		var/singleton/public_access/public_variable/variable = transmit_on_change[thing]
		variable.register_listener(src, machine, PROC_REF(var_changed))

/obj/item/stock_parts/radio/transmitter/basic/on_uninstall(obj/machinery/machine)
	stop_periodic_transmit(machine)
	for(var/thing in transmit_on_change)
		var/singleton/public_access/public_variable/variable = transmit_on_change[thing]
		variable.unregister_listener(src, machine)
	..()

/obj/item/stock_parts/radio/transmitter/basic/Destroy()
	stop_periodic_transmit(loc)
	if(istype(loc, /obj/machinery))
		for(var/thing in transmit_on_change)
			var/singleton/public_access/public_variable/variable = transmit_on_change[thing]
			variable.unregister_listener(src, loc)
	. = ..()

/obj/item/stock_parts/radio/transmitter/basic/machine_process(obj/machinery/machine)
	return PROCESS_KILL

// This is a variant that waits for an event (a public var set), and then transmits everything in the list.

/obj/item/stock_parts/radio/transmitter/on_event
	multitool_extension = /datum/extension/interactive/multitool/radio/event_transmitter
	var/singleton/public_access/public_variable/event
	var/list/transmit_on_event

/obj/item/stock_parts/radio/transmitter/on_event/is_valid_event(obj/machinery/machine, singleton/public_access/variable)
	if(istype(variable, /singleton/public_access/public_method))
		return LAZYACCESS(machine.public_methods, variable.type)
	return ..()

/obj/item/stock_parts/radio/transmitter/on_event/on_install(obj/machinery/machine)
	..()
	sanitize_events(machine, transmit_on_event)
	if(!is_valid_event(machine, event))
		event = null
	if(event)
		event.register_listener(src, machine, PROC_REF(trigger_event))

/obj/item/stock_parts/radio/transmitter/on_event/on_uninstall(obj/machinery/machine)
	if(event)
		event.unregister_listener(src, machine)
	..()

/obj/item/stock_parts/radio/transmitter/on_event/Destroy()
	if(event && istype(loc, /obj/machinery))
		event.unregister_listener(src, loc)
	. = ..()

/obj/item/stock_parts/radio/transmitter/on_event/proc/trigger_event(singleton/public_access/public_variable/variable, obj/machinery/machine, old_value, new_value)
	var/list/dat = list()
	for(var/thing in transmit_on_event)
		var/singleton/public_access/public_variable/check_variable = transmit_on_event[thing]
		dat[thing] = check_variable.access_var(machine)
	queue_transmit(dat)

/obj/item/stock_parts/radio/transmitter/basic/buildable
	part_flags = PART_FLAG_HAND_REMOVE
	name = "basic radio transmitter"
	desc = "A stock radio transmitter machine component. Can transmit updates regularly or on change."
	color = COLOR_RED
	matter = list(MATERIAL_STEEL = 400)

/obj/item/stock_parts/radio/transmitter/on_event/buildable
	part_flags = PART_FLAG_HAND_REMOVE
	name = "event radio transmitter"
	desc = "A radio transmitter machine component which transmits when activated by an event."
	color = COLOR_ORANGE
	matter = list(MATERIAL_STEEL = 400)
