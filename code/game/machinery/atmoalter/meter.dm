/obj/machinery/meter
	name = "meter"
	desc = "A gas flow meter."
	icon = 'icons/obj/atmospherics/meter.dmi'
	icon_state = "meterX"
	var/atom/target = null //A pipe for the base type
	anchored = TRUE
	init_flags = 0
	power_channel = ENVIRON
	idle_power_usage = 15
	var/next_display_sample_at = 0
	var/display_sample_phase_offset = 0
	var/display_sample_interval = 2 SECONDS
	var/last_meter_icon_state
	var/display_sample_alignment_timer
	var/display_sample_loop_timer

	uncreated_component_parts = list(
		/obj/item/stock_parts/power/apc
	)
	public_variables = list(
		/singleton/public_access/public_variable/gas,
		/singleton/public_access/public_variable/pressure,
		/singleton/public_access/public_variable/temperature
	)
	stock_part_presets = list(/singleton/stock_part_preset/radio/basic_transmitter/meter = 1)

	frame_type = /obj/item/machine_chassis/pipe_meter
	construct_state = /singleton/machine_construction/default/item_chassis
	base_type = /obj/machinery/meter

/obj/machinery/meter/Initialize()
	. = ..()
	if(!target)
		set_target(locate(/obj/machinery/atmospherics/pipe) in loc, FALSE)
	if(!target)
		set_target(loc, FALSE)
	display_sample_phase_offset = rand(0, max(0, display_sample_interval - 1))
	next_display_sample_at = world.time + display_sample_phase_offset
	last_meter_icon_state = icon_state
	sync_processing_state()

/obj/machinery/meter/proc/set_target(atom/new_target, sync = TRUE)
	clear_target(FALSE)
	target = new_target
	GLOB.destroyed_event.register(target, src, PROC_REF(clear_target))
	if(sync)
		next_display_sample_at = world.time
		sync_processing_state(TRUE)

/obj/machinery/meter/proc/clear_target(sync = TRUE)
	if(target)
		GLOB.destroyed_event.unregister(target, src)
		target = null
	if(sync)
		next_display_sample_at = world.time
		sync_processing_state(TRUE)

/obj/machinery/meter/proc/can_sample_display()
	return is_powered() && !inoperable()

/obj/machinery/meter/proc/needs_processing()
	return FALSE

/obj/machinery/meter/proc/sync_processing_state(immediate = FALSE)
	STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
	if(!can_sample_display())
		stop_display_sample_timers()
		return
	if(immediate)
		if(display_sample_alignment_timer)
			deltimer(display_sample_alignment_timer)
			display_sample_alignment_timer = null
		if(!display_sample_loop_timer)
			display_sample_loop_timer = addtimer(new Callback(src, PROC_REF(display_sample_tick)), display_sample_interval, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_LOOP)
		display_sample_tick()
		return
	if(display_sample_loop_timer || display_sample_alignment_timer || display_sample_interval <= 0)
		return
	var/delay = max(1, next_display_sample_at - world.time)
	display_sample_alignment_timer = addtimer(new Callback(src, PROC_REF(begin_display_sample_loop)), delay, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/machinery/meter/proc/stop_display_sample_timers()
	if(display_sample_alignment_timer)
		deltimer(display_sample_alignment_timer)
		display_sample_alignment_timer = null
	if(display_sample_loop_timer)
		deltimer(display_sample_loop_timer)
		display_sample_loop_timer = null

/obj/machinery/meter/proc/schedule_next_display_sample()
	sync_processing_state()

/obj/machinery/meter/proc/begin_display_sample_loop()
	display_sample_alignment_timer = null
	if(QDELETED(src) || !can_sample_display())
		return
	if(!display_sample_loop_timer)
		display_sample_loop_timer = addtimer(new Callback(src, PROC_REF(display_sample_tick)), display_sample_interval, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_LOOP)
	display_sample_tick()

/obj/machinery/meter/proc/set_next_display_sample_time()
	var/delay = display_sample_interval - ((world.time - display_sample_phase_offset) % display_sample_interval)
	if(delay <= 0)
		delay = display_sample_interval
	next_display_sample_at = world.time + delay

/obj/machinery/meter/proc/display_sample_tick()
	if(QDELETED(src) || !can_sample_display())
		stop_display_sample_timers()
		return

	var/new_icon_state = get_meter_icon_state()
	if(new_icon_state != last_meter_icon_state)
		icon_state = new_icon_state
		last_meter_icon_state = new_icon_state

/obj/machinery/meter/proc/get_meter_icon_state()
	if(!target)
		return "meterX"
	if(inoperable())
		return "meter0"

	var/datum/gas_mixture/environment = return_air()
	if(!environment)
		return "meterX"

	var/env_pressure = environment.return_pressure()
	if(env_pressure <= 0.15*ONE_ATMOSPHERE)
		return "meter0"
	if(env_pressure <= 1.8*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*0.3) + 0.5)
		return "meter1_[val]"
	if(env_pressure <= 30*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5)-0.35) + 1
		return "meter2_[val]"
	if(env_pressure <= 59*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5) - 6) + 1
		return "meter3_[val]"
	return "meter4"

/obj/machinery/meter/return_air()
	if(target)
		return target.return_air()
	return ..()

/obj/machinery/meter/Destroy()
	clear_target(FALSE)
	stop_display_sample_timers()
	. = ..()

/obj/machinery/meter/power_change()
	. = ..()
	if(inoperable())
		icon_state = "meter0"
	else
		next_display_sample_at = world.time
	last_meter_icon_state = icon_state
	sync_processing_state(!inoperable())

/obj/machinery/meter/Process()
	return PROCESS_KILL


/obj/machinery/meter/examine(mob/user, distance)
	. = ..()

	if(distance > 3 && !(istype(user, /mob/living/silicon/ai) || isghost(user)))
		to_chat(user, SPAN_WARNING("You are too far away to read it."))

	else if(inoperable())
		to_chat(user, SPAN_WARNING("The display is off."))

	else if(src.target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			to_chat(user, "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]K ([round(environment.temperature-T0C,0.01)]&deg;C)")
		else
			to_chat(user, "The sensor error light is blinking.")
	else
		to_chat(user, "The connect error light is blinking.")


/obj/machinery/meter/interface_interact(mob/user)
	if (!target)
		log_debug(append_admin_tools("\A [src] interacted with by \the [user] had no target.", user, get_turf(src)))
		to_chat(user, SPAN_WARNING("\The [src] has no target! This might be a bug. Please report it."))
		return TRUE
	var/datum/gas_mixture/environment = target.return_air()
	to_chat(user, "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]K ([round(environment.temperature-T0C,0.01)]&deg;C)")
	return TRUE

// turf meter -- prioritizes turfs over pipes for target acquisition

/obj/machinery/meter/turf/Initialize()
	if (!target)
		set_target(loc)
	. = ..()

/obj/machinery/meter/starts_with_radio
	uncreated_component_parts = list(
		/obj/item/stock_parts/radio/transmitter/basic/buildable,
		/obj/item/stock_parts/power/apc/buildable
	)

/singleton/stock_part_preset/radio/basic_transmitter/meter
	transmit_on_tick = list(
		"pressure" = /singleton/public_access/public_variable/pressure,
	)
	frequency = ATMOS_TANK_FREQ
