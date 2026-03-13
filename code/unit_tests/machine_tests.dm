/datum/unit_test/machines_shall_obey_part_maximum
	name = "MACHINE: All mapped machines shall respect their own maximum component limit."

/datum/unit_test/machines_shall_obey_part_maximum/start_test()
	var/failed = list()
	var/passed = list()
	for(var/obj/machinery/machine as anything in SSmachines.get_all_machinery())
		if(passed[machine.type] || failed[machine.type])
			continue
		for(var/path in machine.maximum_component_parts)
			if(machine.number_of_components(path) > machine.maximum_component_parts[path])
				failed[machine.type] = TRUE
				log_bad("[log_info_line(machine)] had too many components of type [path].")
		if(!failed[machine.type])
			passed[machine.type] = TRUE

	if(length(failed))
		fail("One or more machines had too many components.")
	else
		pass("All machines respected component limits.")
	return  1

/datum/unit_test/machines_with_circuits_shall_have_construct_states
	name = "MACHINE: All mapped machines with corresponding circuits shall use construct states."

/datum/unit_test/machines_with_circuits_shall_have_construct_states/start_test()
	var/failed = list()
	var/passed = list()
	for(var/obj/machinery/machine in SSmachines.get_all_machinery())
		if(passed[machine.type] || failed[machine.type])
			continue
		var/path = machine.base_type || machine.type
		var/circuit_type = GLOB.machine_path_to_circuit_type[path]
		if(circuit_type && !machine.construct_state)
			failed[machine.type] = TRUE
			log_bad("[log_info_line(machine)] had an associated circuit of type [circuit_type] but no construction state.")
		else
			passed[machine.type] = TRUE

	if(length(failed))
		fail("One or more machines lacked a construction state despite having a circuit.")
	else
		pass("All machines with circuits had construction states.")
	return  1

/datum/unit_test/machine_construct_states_shall_be_valid
	name = "MACHINE: All mapped machines with construct states shall meet state requirements."

/datum/unit_test/machine_construct_states_shall_be_valid/start_test()
	var/failed = list()
	for(var/obj/machinery/machine as anything in SSmachines.get_all_machinery())
		if(failed[machine.type])
			continue
		if(!machine.construct_state)
			continue
		var/fail = machine.construct_state.fail_unit_test(machine)
		if(fail)
			failed[machine.type] = TRUE
			log_bad(fail)

	if(length(failed))
		fail("One or more machines had an invalid construction state.")
	else
		pass("All machines had valid construction states.")
	return  1

/obj/machinery/unit_test_sleep_machine
	name = "sleep test machine"
	process_priority = MACHINERY_PRIORITY_HIGH
	init_flags = INIT_MACHINERY_START_PROCESSING
	var/slept_once = FALSE

/obj/machinery/unit_test_sleep_machine/Process()
	if(!slept_once)
		slept_once = TRUE
		request_process_in(1)
		return 1
	return PROCESS_KILL

/obj/machinery/unit_test_dormant_machine
	name = "dormant test machine"
	process_priority = MACHINERY_PRIORITY_HIGH
	process_schedule_mode = MACHINERY_SCHEDULE_EVENT
	init_flags = INIT_MACHINERY_START_PROCESSING

/obj/machinery/unit_test_dormant_machine/Process()
	return 1

/obj/machinery/unit_test_requested_sleep_machine
	name = "requested sleep test machine"
	process_priority = MACHINERY_PRIORITY_HIGH
	init_flags = INIT_MACHINERY_START_PROCESSING
	var/first_delay = 5
	var/second_delay = null
	var/request_dormant = FALSE

/obj/machinery/unit_test_requested_sleep_machine/Process()
	request_process_in(first_delay)
	if(!isnull(second_delay))
		request_process_in(second_delay)
	if(request_dormant)
		request_process_dormant()
	return 1

/obj/machinery/unit_test_timer_machine
	name = "timer test machine"
	process_priority = MACHINERY_PRIORITY_HIGH
	process_schedule_mode = MACHINERY_SCHEDULE_TIMER
	default_process_delay_ds = 10
	init_flags = INIT_MACHINERY_START_PROCESSING

/obj/machinery/unit_test_timer_machine/Process()
	return 1

/obj/machinery/portable_atmospherics/unit_test_icon_counter
	volume = 1000
	var/icon_update_calls = 0

/obj/machinery/portable_atmospherics/unit_test_icon_counter/on_update_icon()
	icon_update_calls++
	return ..()

/obj/machinery/portable_atmospherics/canister/unit_test_icon_counter
	var/icon_update_calls = 0

/obj/machinery/portable_atmospherics/canister/unit_test_icon_counter/New()
	..()
	air_contents.adjust_gas(GAS_OXYGEN, MolesForPressure())
	can_label = 0
	update_icon()
	icon_update_calls = 0

/obj/machinery/portable_atmospherics/canister/unit_test_icon_counter/on_update_icon()
	icon_update_calls++
	return ..()

/datum/unit_test/machinery_sleep_queue_round_trips
	name = "MACHINE: SSmachines sleep queue removes active work and wakes it at the deadline"

/datum/unit_test/machinery_sleep_queue_round_trips/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for machinery sleep-queue test.")
		return 1

	var/obj/machinery/unit_test_sleep_machine/machine = new(T)
	if(!machine)
		fail("Failed to create the test machine for the machinery sleep-queue test.")
		return 1
	if(!(machine in SSmachines.processing_high))
		fail("Fresh high-priority test machine should begin in SSmachines.processing_high.")
		qdel(machine)
		return 1

	var/process_result = machine.Process()
	SSmachines.finalize_machine_schedule(machine, process_result, TRUE)

	if(machine in SSmachines.processing_high)
		fail("Sleeping a machine should remove it from the active processing queue.")
		qdel(machine)
		return 1
	if(machine.is_processing)
		fail("Sleeping a machine should clear its active processing marker.")
		qdel(machine)
		return 1
	if(machine.processing_flags != MACHINERY_PROCESS_SELF)
		fail("Sleeping a machine should not clear its processing flags.")
		qdel(machine)
		return 1
	if(isnull(SSmachines.sleeping_machines[machine]))
		fail("Sleeping a machine should register it in SSmachines.sleeping_machines.")
		qdel(machine)
		return 1

	sleep(2)
	SSmachines.wake_due_machines()

	if(isnull(SSmachines.sleeping_machines[machine]) && (machine in SSmachines.processing_high))
		pass("Sleeping machinery leaves the active queue and returns when its wake deadline is due.")
		qdel(machine)
		return 1

	fail("Due sleeping machinery should be restored to its active priority queue.")
	qdel(machine)
	return 1

/datum/unit_test/machinery_dormant_queue_round_trips_on_explicit_wake
	name = "MACHINE: Event-scheduled machinery goes dormant and wakes on START_PROCESSING_MACHINE"

/datum/unit_test/machinery_dormant_queue_round_trips_on_explicit_wake/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for machinery dormant-queue test.")
		return 1

	var/obj/machinery/unit_test_dormant_machine/machine = new(T)
	if(!machine)
		fail("Failed to create the test machine for the machinery dormant-queue test.")
		return 1

	var/process_result = machine.Process()
	SSmachines.finalize_machine_schedule(machine, process_result, TRUE)

	if(machine in SSmachines.processing_high)
		fail("Dormant scheduling should remove the machine from the active queue.")
		qdel(machine)
		return 1
	if(!SSmachines.dormant_machines[machine])
		fail("Event-scheduled machinery should enter SSmachines.dormant_machines when idle.")
		qdel(machine)
		return 1
	if(machine.processing_flags != MACHINERY_PROCESS_SELF)
		fail("Dormant scheduling should preserve machinery processing flags.")
		qdel(machine)
		return 1

	START_PROCESSING_MACHINE(machine, MACHINERY_PROCESS_SELF)
	if(!(machine in SSmachines.processing_high))
		fail("START_PROCESSING_MACHINE should wake dormant machinery into the active queue immediately.")
		qdel(machine)
		return 1
	if(SSmachines.dormant_machines[machine])
		fail("START_PROCESSING_MACHINE should clear dormant bookkeeping.")
		qdel(machine)
		return 1

	STOP_PROCESSING_MACHINE(machine, MACHINERY_PROCESS_SELF)
	if((machine in SSmachines.processing_high) || SSmachines.dormant_machines[machine] || !isnull(SSmachines.sleeping_machines[machine]))
		fail("STOP_PROCESSING_MACHINE should clear active, dormant, and sleeping bookkeeping.")
		qdel(machine)
		return 1

	pass("Dormant machines now leave the active queue and wake only on explicit processing requests.")
	qdel(machine)
	return 1

/datum/unit_test/machinery_sleep_requests_keep_earliest_deadline
	name = "MACHINE: Explicit wake requests keep the earliest deadline and beat dormant requests"

/datum/unit_test/machinery_sleep_requests_keep_earliest_deadline/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for explicit wake-request test.")
		return 1

	var/obj/machinery/unit_test_requested_sleep_machine/machine = new(T)
	if(!machine)
		fail("Failed to create the test machine for the explicit wake-request test.")
		return 1

	machine.first_delay = 5
	machine.second_delay = 1
	machine.request_dormant = TRUE
	var/start_time = world.time
	var/process_result = machine.Process()
	SSmachines.finalize_machine_schedule(machine, process_result, TRUE)

	var/wake_time = SSmachines.get_machine_sleep_wake_time(machine)
	if(isnull(wake_time))
		fail("Explicit wake requests should place the machine into timed sleep.")
		qdel(machine)
		return 1
	if(SSmachines.dormant_machines[machine])
		fail("Timed wake requests should beat dormant requests from the same process cycle.")
		qdel(machine)
		return 1
	if(wake_time != start_time + 1)
		fail("Multiple explicit wake requests should keep the earliest deadline. Expected [start_time + 1], got [wake_time].")
		qdel(machine)
		return 1

	pass("Explicit scheduler requests keep the earliest wake time and take precedence over dormant scheduling.")
	qdel(machine)
	return 1

/datum/unit_test/machinery_earlier_reschedule_does_not_leave_a_stale_wake
	name = "MACHINE: Earlier timed reschedules do not produce a second stale wake"

/datum/unit_test/machinery_earlier_reschedule_does_not_leave_a_stale_wake/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for stale reschedule test.")
		return 1

	var/obj/machinery/unit_test_requested_sleep_machine/machine = new(T)
	if(!machine)
		fail("Failed to create the test machine for the stale reschedule test.")
		return 1

	SSmachines.sleep_machine(machine, 5)
	SSmachines.sleep_machine(machine, 1)

	sleep(2)
	SSmachines.wake_due_machines()

	if(!(machine in SSmachines.processing_high))
		fail("A machine rescheduled to an earlier deadline should wake at the earlier deadline.")
		qdel(machine)
		return 1

	STOP_PROCESSING_MACHINE(machine, MACHINERY_PROCESS_SELF)
	sleep(5)
	SSmachines.wake_due_machines()

	if((machine in SSmachines.processing_high) || !isnull(SSmachines.sleeping_machines[machine]))
		fail("The stale later deadline should not enqueue a second wake after the earlier wake has fired.")
		qdel(machine)
		return 1

	pass("Earlier timed reschedules now leave stale heap entries harmless until they are discarded.")
	qdel(machine)
	return 1

/datum/unit_test/machinery_explicit_wake_discards_stale_heap_entries
	name = "MACHINE: Explicit wakes do not requeue machinery from stale heap entries"

/datum/unit_test/machinery_explicit_wake_discards_stale_heap_entries/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for explicit wake stale-entry test.")
		return 1

	var/obj/machinery/unit_test_requested_sleep_machine/machine = new(T)
	if(!machine)
		fail("Failed to create the test machine for the explicit wake stale-entry test.")
		return 1

	SSmachines.sleep_machine(machine, 5)
	START_PROCESSING_MACHINE(machine, MACHINERY_PROCESS_SELF)
	if(!(machine in SSmachines.processing_high))
		fail("START_PROCESSING_MACHINE should wake sleeping machinery immediately.")
		qdel(machine)
		return 1
	if(!isnull(SSmachines.sleeping_machines[machine]))
		fail("Explicit wakes should clear sleeping bookkeeping immediately.")
		qdel(machine)
		return 1

	STOP_PROCESSING_MACHINE(machine, MACHINERY_PROCESS_SELF)
	sleep(6)
	SSmachines.wake_due_machines()

	if((machine in SSmachines.processing_high) || !isnull(SSmachines.sleeping_machines[machine]))
		fail("Stale timed-sleep heap entries should not requeue machinery after an explicit wake and stop.")
		qdel(machine)
		return 1

	pass("Explicit wakes now leave stale heap entries harmless until the wake queue discards them.")
	qdel(machine)
	return 1

/datum/unit_test/machinery_timer_phase_offsets_spread_wake_deadlines
	name = "MACHINE: Timer scheduling spreads wake deadlines across a batch"

/datum/unit_test/machinery_timer_phase_offsets_spread_wake_deadlines/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for timer phase-spread test.")
		return 1

	var/list/wake_times = list()
	var/list/machines = list()
	for(var/i in 1 to 5)
		var/obj/machinery/unit_test_timer_machine/machine = new(T)
		machines += machine
		var/process_result = machine.Process()
		SSmachines.finalize_machine_schedule(machine, process_result, TRUE)
		var/wake_time = SSmachines.get_machine_sleep_wake_time(machine)
		if(isnull(wake_time))
			fail("Timer-scheduled machines should enter timed sleep automatically after Process().")
			for(var/obj/machinery/cleanup as anything in machines)
				qdel(cleanup)
			return 1
		wake_times["[wake_time]"] = TRUE

	if(length(wake_times) <= 1)
		fail("Timer scheduling should spread a batch of machines across more than one wake deadline.")
		for(var/obj/machinery/cleanup as anything in machines)
			qdel(cleanup)
		return 1

	pass("Timer-scheduled machines no longer stampede onto a single wake tick.")
	for(var/obj/machinery/cleanup as anything in machines)
		qdel(cleanup)
	return 1

/datum/unit_test/machinery_recover_rebuilds_next_wake
	name = "MACHINE: Recover rebuilds the earliest wake deadline"

/datum/unit_test/machinery_recover_rebuilds_next_wake/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for machinery recover test.")
		return 1

	var/obj/machinery/unit_test_requested_sleep_machine/slow = new(T)
	var/obj/machinery/unit_test_requested_sleep_machine/fast = new(T)
	if(!slow || !fast)
		fail("Failed to create test machines for the machinery recover test.")
		qdel(slow)
		qdel(fast)
		return 1

	SSmachines.sleep_machine(slow, 5)
	SSmachines.sleep_machine(fast, 2)
	SSmachines.next_machine_wake = 0
	SSmachines.sleep_buckets.Cut()
	SSmachines.sleep_wake_heap.Cut()
	SSmachines.Recover()

	if(SSmachines.next_machine_wake != SSmachines.get_machine_sleep_wake_time(fast))
		fail("Recover should rebuild the earliest wake deadline from timed sleepers.")
		qdel(slow)
		qdel(fast)
		return 1

	pass("Recover rebuilds timed-sleeper wake bookkeeping without losing scheduled machines.")
	qdel(slow)
	qdel(fast)
	return 1

/datum/unit_test/vent_pumps_sleep_when_idle_and_wake_on_reconfiguration
	name = "MACHINE: Vent pumps sleep while steady-state idle and wake on reconfiguration"

/datum/unit_test/vent_pumps_sleep_when_idle_and_wake_on_reconfiguration/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for vent pump sleep test.")
		return 1

	var/turf/pipe_turf = get_step(T, SOUTH)
	if(!pipe_turf)
		fail("Could not find a neighboring turf for vent pump network setup.")
		return 1

	var/obj/machinery/atmospherics/pipe/simple/hidden/supply/pipe = new(pipe_turf)
	var/obj/machinery/atmospherics/unary/vent_pump/on/pump = new(T)
	if(!pipe || !pump)
		fail("Failed to create vent pump benchmark fixtures.")
		qdel(pipe)
		qdel(pump)
		return 1

	pipe.atmos_init()
	pump.atmos_init()
	pipe.build_network()
	pump.build_network()
	var/datum/gas_mixture/environment = T.return_air()
	pump.external_pressure_bound = environment.return_pressure()
	pump.pump_direction = TRUE

	if(!(pump in SSmachines.processing_high))
		fail("Fresh vent pumps should start in the high-priority machinery queue.")
		qdel(pipe)
		qdel(pump)
		return 1

	var/process_result = pump.Process()
	SSmachines.finalize_machine_schedule(pump, process_result, TRUE)

	if(pump in SSmachines.processing_high)
		fail("Steady-state vent pumps should remove themselves from the active machinery queue.")
		qdel(pipe)
		qdel(pump)
		return 1
	if(isnull(SSmachines.sleeping_machines[pump]))
		fail("Steady-state vent pumps should enter the machinery sleep queue.")
		qdel(pipe)
		qdel(pump)
		return 1

	pump.purge()

	if(!(pump in SSmachines.processing_high))
		fail("Vent pump reconfiguration should wake it back into active processing immediately.")
		qdel(pipe)
		qdel(pump)
		return 1

	pass("Vent pumps now sleep while idle and wake immediately on configuration changes.")
	qdel(pipe)
	qdel(pump)
	return 1

/datum/unit_test/vent_scrubbers_sleep_when_idle_and_wake_on_reconfiguration
	name = "MACHINE: Vent scrubbers sleep while steady-state idle and wake on reconfiguration"

/datum/unit_test/vent_scrubbers_sleep_when_idle_and_wake_on_reconfiguration/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for vent scrubber sleep test.")
		return 1

	var/turf/pipe_turf = get_step(T, SOUTH)
	if(!pipe_turf)
		fail("Could not find a neighboring turf for vent scrubber network setup.")
		return 1

	var/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers/pipe = new(pipe_turf)
	var/obj/machinery/atmospherics/unary/vent_scrubber/on/scrubber = new(T)
	if(!pipe || !scrubber)
		fail("Failed to create vent scrubber benchmark fixtures.")
		qdel(pipe)
		qdel(scrubber)
		return 1

	pipe.atmos_init()
	scrubber.atmos_init()
	pipe.build_network()
	scrubber.build_network()
	scrubber.scrubbing_gas = list(GAS_PHORON)

	if(!(scrubber in SSmachines.processing_high))
		fail("Fresh vent scrubbers should start in the high-priority machinery queue.")
		qdel(pipe)
		qdel(scrubber)
		return 1

	var/process_result = scrubber.Process()
	SSmachines.finalize_machine_schedule(scrubber, process_result, TRUE)

	if(scrubber in SSmachines.processing_high)
		fail("Steady-state vent scrubbers should remove themselves from the active machinery queue.")
		qdel(pipe)
		qdel(scrubber)
		return 1
	if(isnull(SSmachines.sleeping_machines[scrubber]))
		fail("Steady-state vent scrubbers should enter the machinery sleep queue.")
		qdel(pipe)
		qdel(scrubber)
		return 1

	scrubber.toggle_panic()

	if(!(scrubber in SSmachines.processing_high))
		fail("Vent scrubber reconfiguration should wake it back into active processing immediately.")
		qdel(pipe)
		qdel(scrubber)
		return 1

	pass("Vent scrubbers now sleep while idle and wake immediately on configuration changes.")
	qdel(pipe)
	qdel(scrubber)
	return 1

/datum/unit_test/hydroponics_timerizes_idle_cycles_and_wakes_on_reagents
	name = "MACHINE: Hydroponics trays sleep between cycles and wake on reagent changes"

/datum/unit_test/hydroponics_timerizes_idle_cycles_and_wakes_on_reagents/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for hydroponics timer test.")
		return 1

	var/obj/machinery/portable_atmospherics/hydroponics/tray = new(T)
	if(!tray)
		fail("Failed to create hydroponics tray for timer test.")
		return 1

	tray.lastcycle = world.time
	tray.force_update = FALSE
	var/process_result = tray.Process()
	SSmachines.finalize_machine_schedule(tray, process_result, TRUE)

	if(tray in SSmachines.processing_normal)
		fail("Hydroponics trays should leave the active queue while waiting for the next cycle.")
		qdel(tray)
		return 1
	if(isnull(SSmachines.sleeping_machines[tray]))
		fail("Hydroponics trays should enter timed sleep between growth cycles.")
		qdel(tray)
		return 1

	tray.reagents.add_reagent(/datum/reagent/water, 1)
	if(!(tray in SSmachines.processing_normal))
		fail("Hydroponics trays should wake immediately when their reagents change.")
		qdel(tray)
		return 1

	pass("Hydroponics trays now sleep between cycles and wake on reagent changes.")
	qdel(tray)
	return 1

/datum/unit_test/meters_use_timer_scheduling_without_breaking_component_processing
	name = "MACHINE: Meters use timer scheduling while radio variants keep component processing"

/datum/unit_test/meters_use_timer_scheduling_without_breaking_component_processing/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for meter timer test.")
		return 1

	var/obj/machinery/meter/meter = new(T)
	if(!meter)
		fail("Failed to create a base meter for timer scheduling test.")
		return 1

	var/process_result = meter.Process()
	SSmachines.finalize_machine_schedule(meter, process_result, TRUE)

	if(meter in SSmachines.processing_normal)
		fail("Base meters should leave the active queue between timer ticks.")
		qdel(meter)
		return 1
	if(isnull(SSmachines.get_machine_sleep_wake_time(meter)))
		fail("Base meters should enter timed sleep after Process().")
		qdel(meter)
		return 1

	var/obj/machinery/meter/starts_with_radio/radio_meter = new(T)
	if(!radio_meter)
		fail("Failed to create a radio-enabled meter for component-processing test.")
		qdel(meter)
		return 1
	if(!(radio_meter.processing_flags & MACHINERY_PROCESS_COMPONENTS))
		fail("Radio-enabled meters should keep component processing enabled.")
		qdel(meter)
		qdel(radio_meter)
		return 1

	process_result = radio_meter.Process()
	SSmachines.finalize_machine_schedule(radio_meter, process_result, TRUE)

	if(!(radio_meter in SSmachines.processing_normal))
		fail("Radio-enabled meters should stay active while their components still process every tick.")
		qdel(meter)
		qdel(radio_meter)
		return 1

	pass("Base meters now sleep between timer ticks while radio variants preserve component processing.")
	qdel(meter)
	qdel(radio_meter)
	return 1

/datum/unit_test/connected_portables_do_not_poll_update_icons
	name = "MACHINE: Connected portable atmospherics do not poll update_icon()"

/datum/unit_test/connected_portables_do_not_poll_update_icons/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for connected portable atmospherics test.")
		return 1

	var/obj/machinery/portable_atmospherics/unit_test_icon_counter/portable = new(T)
	var/obj/machinery/atmospherics/portables_connector/connector = new(T)
	if(!portable || !connector)
		fail("Failed to create connected portable atmospherics test fixtures.")
		qdel(portable)
		qdel(connector)
		return 1
	if(!portable.connect(connector))
		fail("Portable atmospherics test fixture failed to connect to its connector.")
		qdel(portable)
		qdel(connector)
		return 1

	portable.icon_update_calls = 0
	portable.Process()

	if(portable.icon_update_calls)
		fail("Connected portable atmospherics should not call update_icon() from Process().")
		qdel(portable)
		qdel(connector)
		return 1

	pass("Connected portable atmospherics no longer poll icon updates from Process().")
	qdel(portable)
	qdel(connector)
	return 1

/datum/unit_test/canisters_only_refresh_icons_on_pressure_band_changes
	name = "MACHINE: Canisters avoid redundant icon refreshes while pressure stays in-band"

/datum/unit_test/canisters_only_refresh_icons_on_pressure_band_changes/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for canister icon-refresh test.")
		return 1

	var/obj/machinery/portable_atmospherics/canister/unit_test_icon_counter/canister = new(T)
	if(!canister)
		fail("Failed to create a canister for icon-refresh test.")
		return 1

	var/starting_pressure = canister.return_pressure()
	var/starting_band = canister.get_pressure_overlay_level(starting_pressure)
	canister.release_pressure = 1.5 * ONE_ATMOSPHERE
	canister.valve_open = TRUE
	canister.icon_update_calls = 0
	canister.Process()

	var/ending_pressure = canister.return_pressure()
	if(ending_pressure >= starting_pressure)
		fail("Canister icon-refresh fixture failed to vent gas during Process().")
		qdel(canister)
		return 1
	if(canister.get_pressure_overlay_level(ending_pressure) != starting_band)
		fail("Canister icon-refresh fixture crossed a pressure overlay threshold; the steady-state test is invalid.")
		qdel(canister)
		return 1
	if(canister.icon_update_calls)
		fail("Canisters should not refresh icons every tick while staying in the same pressure band.")
		qdel(canister)
		return 1

	pass("Canisters now skip redundant icon refreshes when venting without crossing a pressure overlay threshold.")
	qdel(canister)
	return 1

/datum/unit_test/invisible_soil_uses_timed_observer_rechecks
	name = "MACHINE: Invisible hydro soil uses timed observer rechecks instead of idle processing"

/datum/unit_test/invisible_soil_uses_timed_observer_rechecks/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for invisible soil test.")
		return 1

	var/datum/seed/seed = SSplants.seeds["weeds"]
	if(!seed)
		fail("Could not find a simple hydro seed for invisible soil test.")
		return 1

	var/obj/machinery/portable_atmospherics/hydroponics/soil/invisible/plant = new(T, seed, FALSE)
	if(!plant)
		fail("Failed to create invisible soil test plant.")
		return 1

	var/process_result = plant.Process()
	SSmachines.finalize_machine_schedule(plant, process_result, TRUE)

	if(plant in SSmachines.processing_normal)
		fail("Unobserved invisible soil should not stay in the active machinery queue.")
		qdel(plant)
		return 1
	if(isnull(SSmachines.sleeping_machines[plant]))
		fail("Unobserved invisible soil should schedule a timed observer recheck.")
		qdel(plant)
		return 1

	pass("Invisible soil now uses timed observer rechecks instead of idle processing.")
	qdel(plant)
	return 1

/datum/unit_test/shield_diffusers_sleep_between_pulses_and_wake_on_alarm
	name = "MACHINE: Shield diffusers sleep between diffusion pulses and wake on alarm"

/datum/unit_test/shield_diffusers_sleep_between_pulses_and_wake_on_alarm/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for shield diffuser timer test.")
		return 1

	var/obj/machinery/shield_diffuser/diffuser = new(T)
	if(!diffuser)
		fail("Failed to create a shield diffuser for timer test.")
		return 1

	if(!(diffuser in SSmachines.processing_normal))
		fail("Fresh shield diffusers should start in the normal-priority machinery queue.")
		qdel(diffuser)
		return 1

	var/process_result = diffuser.Process()
	SSmachines.finalize_machine_schedule(diffuser, process_result, TRUE)

	if(diffuser in SSmachines.processing_normal)
		fail("Shield diffusers should leave the active queue between diffusion pulses.")
		qdel(diffuser)
		return 1
	if(isnull(SSmachines.sleeping_machines[diffuser]))
		fail("Shield diffusers should enter timed sleep between diffusion pulses.")
		qdel(diffuser)
		return 1

	diffuser.meteor_alarm(10)
	if(!(diffuser in SSmachines.processing_normal))
		fail("Meteor alarms should wake shield diffusers into active processing immediately.")
		qdel(diffuser)
		return 1

	pass("Shield diffusers now sleep between pulses and wake immediately for meteor alarms.")
	qdel(diffuser)
	return 1

/datum/unit_test/doors_use_timers_without_idle_processing
	name = "MACHINE: Doors use timers and explicit wakeups instead of idle processing"

/datum/unit_test/doors_use_timers_without_idle_processing/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for door timerization test.")
		return 1

	var/obj/machinery/door/door = new(T)
	door.autoclose = TRUE
	if(door.Process() != PROCESS_KILL)
		fail("Idle base doors should not require self-processing.")
		qdel(door)
		return 1
	door.set_close_door_at(world.time + 5)
	if(!door.autoclose_timer_id)
		fail("Autoclose-capable doors should schedule a timer when a close deadline is set.")
		qdel(door)
		return 1
	if(door.processing_flags & MACHINERY_PROCESS_SELF)
		fail("Door autoclose timers should not wake self-processing.")
		qdel(door)
		return 1
	qdel(door)

	var/obj/machinery/door/airlock/airlock = new(T)
	if(!airlock)
		fail("Failed to create an airlock for timerization test.")
		return 1
	if(airlock.processing_flags & MACHINERY_PROCESS_SELF)
		fail("Fresh airlocks should not self-process while idle.")
		qdel(airlock)
		return 1
	airlock.loseMainPower()
	if(!airlock.main_power_timer_id)
		fail("Airlocks should use a timer for deferred main power restoration.")
		qdel(airlock)
		return 1
	if(airlock.processing_flags & MACHINERY_PROCESS_SELF)
		fail("Airlock power restoration timers should not wake self-processing.")
		qdel(airlock)
		return 1
	airlock.command("open")
	if(!(airlock.processing_flags & MACHINERY_PROCESS_SELF))
		fail("Airlocks should wake self-processing only while an active radio command is unresolved.")
		qdel(airlock)
		return 1

	pass("Door autoclose and airlock power timeouts now use timers while active airlock commands wake processing explicitly.")
	qdel(airlock)
	return 1

/* [SIERRA-REMOVE] - MODPACK_RND
/datum/unit_test/fabricator_recipes_shall_be_buildable
	name = "MACHINE: All fabricators will be able to produce all of their recipes"
/datum/unit_test/fabricator_recipes_shall_be_buildable/start_test()
	var/failed = list()
	for(var/thing in typesof(/obj/machinery/fabricator))
		var/obj/machinery/fabricator/fab = new thing
		for(var/datum/fabricator_recipe/recipe in SSfabrication.get_recipes(fab.fabricator_class))
			for(var/mat in recipe.resources)
				if(isnull(fab.storage_capacity[mat]))
					log_bad("[fab.name] ([fab.type]) could not print [recipe.name] due to lacking [mat].")
					failed += thing
					break
		qdel(fab)
	if(length(failed))
		fail("One or more fabricators could not produce an associated recipe.")
	else
		pass("All fabricators could produce their associated recipes.")
	return  1
*/
