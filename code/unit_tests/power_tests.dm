/datum/unit_test/roundstart_cable_connectivity
	name = "POWER: Roundstart Cables that are Connected Share Powernets"

/datum/unit_test/roundstart_cable_connectivity/proc/find_connected_neighbours(obj/structure/cable/C)
	. = list()
	if(C.d1 != 0)
		. += get_connected_neighbours(C, C.d1)
	if(C.d2 != 0)
		. += get_connected_neighbours(C, C.d2)

/datum/unit_test/roundstart_cable_connectivity/proc/get_connected_neighbours(obj/structure/cable/self, dir)
	var/turf/T = get_step(get_turf(self), dir)
	var/reverse = GLOB.reverse_dir[dir]

	. = list() //can have multiple connected neighbours for a dir, e.g. Y-junctions
	for(var/obj/structure/cable/other in T)
		if(other.d1 == reverse || other.d2 == reverse)
			. += other

/datum/unit_test/roundstart_cable_connectivity/start_test()
	var/failed = 0
	var/list/found_cables = list()

	//there is a cable list, but for testing purposes we search every cable in the world
	for(var/obj/structure/cable/C in world)
		if(C in found_cables)
			continue
		var/list/to_search = list(C)
		var/list/searched = list()
		while(length(to_search))
			var/obj/structure/cable/next = to_search[length(to_search)]
			LIST_DEC(to_search)
			searched += next
			for(var/obj/structure/cable/other in get_connected_neighbours(next))
				if(other in searched)
					continue
				if(next.powernet != other.powernet)
					fail("Cable at ([next.x], [next.y], [next.z]) did not share powernet with connected neighbour at ([other.x], [other.y], [other.z])")
					failed++
				to_search += other

		found_cables += searched

	if(failed)
		fail("Found [failed] bad cables.")
	else
		pass("All connected roundstart cables have matching powernets.")

	return 1


/datum/unit_test/areas_apc_uniqueness
	name = "POWER: Each area should have at most one APC."

/datum/unit_test/areas_apc_uniqueness/start_test()
	var/failure = ""
	for(var/area/A in world)
		var/obj/machinery/power/apc/found_apc = null
		for(var/obj/machinery/power/apc/APC in A)
			if(!found_apc)
				found_apc = APC
				continue
			if(failure)
				failure = "[failure]\n"
			failure = "[failure]Duplicated APCs in area: [A.name]. #1: [log_info_line(found_apc)]  #2: [log_info_line(APC)]"

	if(failure)
		fail(failure)
	else
		pass("No areas with duplicated APCs have been found.")
	return 1

/datum/unit_test/area_power_tally_accuracy
	name = "POWER: All areas must have accurate power use values."

/datum/unit_test/area_power_tally_accuracy/start_test()
	var/failed = FALSE
	var/list/channel_names = list("equip", "light", "environ")
	for(var/area/A in world)
		var/list/old_values = list(A.used_equip, A.used_light, A.used_environ)
		A.retally_power()
		var/list/new_values = list(A.used_equip, A.used_light, A.used_environ)
		for(var/i in 1 to length(old_values))
			if(abs(old_values[i] - new_values[i]) > 1) // Round because there can in fact be roundoff error here apparently.
				failed = TRUE
				log_bad("The area [A.name] had improper power use values on the [channel_names[i]] channel: was [old_values[i]] but should be [new_values[i]].")

	if(failed)
		fail("At least one area had improper power use values")
	else
		pass("All areas had accurate power use values.")
	return 1

/obj/machinery/power/terminal/unit_test
	var/mock_avail = 0
	var/mock_surplus = 0

/obj/machinery/power/terminal/unit_test/connect_to_network()
	return FALSE

/obj/machinery/power/terminal/unit_test/disconnect_from_network()
	return FALSE

/obj/machinery/power/terminal/unit_test/avail()
	return mock_avail

/obj/machinery/power/terminal/unit_test/surplus()
	return mock_surplus

/obj/machinery/power/terminal/unit_test/draw_power(amount)
	return min(mock_surplus, amount)

/datum/unit_test/apc_phase_two
	name = "template - APC phase two"
	template = /datum/unit_test/apc_phase_two

/datum/unit_test/apc_phase_two/proc/is_apc_test_area(area/A)
	return A?.requires_power && !A.dynamic_lighting && A.name == "\improper Test Area - Requires Power - Non-Dynamic Lighting"

/datum/unit_test/apc_phase_two/proc/get_apc_test_turf()
	for(var/turf/T in world)
		var/area/A = get_area(T)
		if(is_apc_test_area(A))
			return T

/datum/unit_test/apc_phase_two/proc/create_test_apc()
	var/turf/T = get_apc_test_turf()
	if(!T)
		fail("Could not find a requires-power unit test turf for APC tests.")
		return
	var/obj/machinery/power/apc/apc = new(T)
	var/obj/item/stock_parts/power/battery/battery = apc.cached_battery_part
	var/obj/item/cell/cell = apc.get_cell()
	if(!battery || !cell)
		fail("Failed to create an APC with an installed battery and power cell.")
		qdel(apc)
		return
	return apc

/datum/unit_test/apc_phase_two/proc/install_mock_terminal(obj/machinery/power/apc/apc, avail = 0, surplus = 0)
	var/obj/item/stock_parts/power/terminal/part = apc?.cached_terminal_part
	if(!part)
		fail("APC is missing its terminal stock part.")
		return
	var/obj/machinery/power/terminal/old_terminal = part.terminal
	var/obj/machinery/power/terminal/unit_test/mock_terminal = new(get_turf(apc))
	mock_terminal.mock_avail = avail
	mock_terminal.mock_surplus = surplus
	part.set_terminal(apc, mock_terminal)
	if(old_terminal)
		qdel(old_terminal)
	return mock_terminal

/datum/unit_test/apc_phase_two/manual_charge_state_updates_from_battery_component
	name = "POWER: APC manual charge state updates from battery component"

/datum/unit_test/apc_phase_two/manual_charge_state_updates_from_battery_component/start_test()
	var/obj/machinery/power/apc/apc = create_test_apc()
	if(!apc)
		return 1
	var/obj/machinery/power/terminal/unit_test/mock_terminal = install_mock_terminal(apc, 100000, 100000)
	if(!mock_terminal)
		qdel(apc)
		return 1
	var/obj/item/stock_parts/power/battery/battery = apc.cached_battery_part
	var/obj/item/cell/cell = apc.get_cell()

	cell.charge = cell.maxcharge - battery.charge_rate
	apc.equipment = POWERCHAN_ON
	apc.lighting = POWERCHAN_ON
	apc.environ = POWERCHAN_ON
	apc.longtermpower = initial(apc.longtermpower)
	apc.force_update_channels()

	battery.not_needed(apc)
	battery.charge_wait_counter = 0
	battery.machine_process(apc)

	if(apc.charging != 1)
		fail("Expected manual APC to report active charging after the battery component processed.")
		qdel(apc)
		return 1
	if(apc.lastused_charging <= 0)
		fail("Expected manual APC to record a positive charging load after the battery component processed.")
		qdel(apc)
		return 1
	var/process_result = apc.Process()
	SSmachines.finalize_machine_schedule(apc, process_result, TRUE)
	if(apc in SSmachines.processing_high)
		fail("Manual APC should not remain in the active machinery queue after battery charge state sync.")
		qdel(apc)
		return 1
	if(process_result != PROCESS_KILL)
		fail("Manual APC should kill self-processing once its dirty work is complete.")
		qdel(apc)
		return 1
	if(SSmachines.dormant_machines[apc])
		fail("Manual APC should not enter dormant scheduling when it has no more work.")
		qdel(apc)
		return 1

	pass("Manual APC charge state is updated by the battery component without requiring a self-tick heartbeat.")
	qdel(apc)
	return 1

/datum/unit_test/apc_phase_two/auto_channels_recalculate_on_battery_threshold_transition
	name = "POWER: APC auto channels recalculate on battery threshold transitions"

/datum/unit_test/apc_phase_two/auto_channels_recalculate_on_battery_threshold_transition/start_test()
	var/obj/machinery/power/apc/apc = create_test_apc()
	if(!apc)
		return 1
	var/obj/machinery/power/terminal/unit_test/mock_terminal = install_mock_terminal(apc, 0, 0)
	if(!mock_terminal)
		qdel(apc)
		return 1
	var/obj/item/stock_parts/power/battery/battery = apc.cached_battery_part
	var/obj/item/cell/cell = apc.get_cell()

	cell.charge = 255
	apc.longtermpower = 1
	apc.power_change()
	apc.force_update_channels()
	apc.lastused_total = 18000

	battery.machine_process(apc)

	if(!apc.channel_dirty)
		fail("Expected the battery component to mark APC auto channels dirty after a threshold-crossing discharge tick.")
		qdel(apc)
		return 1
	apc.Process()

	if(apc.lighting != POWERCHAN_OFF_AUTO)
		fail("Expected APC lighting channel to auto-drop after crossing below the lighting threshold with negative longterm power.")
		qdel(apc)
		return 1
	if(apc.equipment != POWERCHAN_ON_AUTO || apc.environ != POWERCHAN_ON_AUTO)
		fail("Expected APC equipment and environment channels to stay on-auto during the intermediate auto power state.")
		qdel(apc)
		return 1

	pass("Battery-driven threshold transitions still force APC auto channel recalculation without a self-tick heartbeat.")
	qdel(apc)
	return 1

/datum/unit_test/apc_phase_two/manual_hysteresis_stays_current_before_returning_to_auto
	name = "POWER: APC hysteresis stays current while channels are manual"

/datum/unit_test/apc_phase_two/manual_hysteresis_stays_current_before_returning_to_auto/start_test()
	var/obj/machinery/power/apc/apc = create_test_apc()
	if(!apc)
		return 1
	var/obj/machinery/power/terminal/unit_test/mock_terminal = install_mock_terminal(apc, 0, 0)
	if(!mock_terminal)
		qdel(apc)
		return 1
	var/obj/item/stock_parts/power/battery/battery = apc.cached_battery_part
	var/obj/item/cell/cell = apc.get_cell()

	cell.charge = 255
	apc.longtermpower = 1
	apc.equipment = POWERCHAN_ON
	apc.lighting = POWERCHAN_ON
	apc.environ = POWERCHAN_ON
	apc.power_change()

	battery.machine_process(apc)

	if(apc.longtermpower >= 0)
		fail("Expected manual APC hysteresis to continue tracking discharge while channels are set manually.")
		qdel(apc)
		return 1

	apc.equipment = POWERCHAN_ON_AUTO
	apc.lighting = POWERCHAN_ON_AUTO
	apc.environ = POWERCHAN_ON_AUTO
	apc.force_update_channels()

	if(apc.lighting != POWERCHAN_OFF_AUTO)
		fail("Expected APC lighting to drop immediately when returning to auto with a stale-negative hysteresis state.")
		qdel(apc)
		return 1

	pass("Manual APCs keep hysteresis current, so returning to auto uses fresh discharge state.")
	qdel(apc)
	return 1

/datum/unit_test/apc_phase_two/power_state_signal_wakes_power_components
	name = "POWER: Machine power-state signals wake battery and terminal components"

/datum/unit_test/apc_phase_two/power_state_signal_wakes_power_components/start_test()
	var/obj/machinery/power/apc/apc = create_test_apc()
	if(!apc)
		return 1

	var/obj/item/stock_parts/power/battery/battery = apc.cached_battery_part
	var/obj/item/stock_parts/power/terminal/terminal_part = apc.cached_terminal_part
	if(!battery || !terminal_part)
		fail("APC is missing its power stock parts for wakeup testing.")
		qdel(apc)
		return 1

	battery.stop_processing(apc)
	terminal_part.stop_processing(apc)
	if((battery.status & PART_STAT_PROCESSING) || (terminal_part.status & PART_STAT_PROCESSING))
		fail("Power components should be fully stopped before signal wakeup is tested.")
		qdel(apc)
		return 1

	apc.update_power_channel(LIGHT)

	if(!(battery.status & PART_STAT_PROCESSING))
		fail("Battery component should wake when the host machine emits COMSIG_MACHINE_POWER_STATE_CHANGED.")
		qdel(apc)
		return 1
	if(!(terminal_part.status & PART_STAT_PROCESSING))
		fail("Terminal component should wake when the host machine emits COMSIG_MACHINE_POWER_STATE_CHANGED.")
		qdel(apc)
		return 1

	pass("Machine power-state changes wake both battery and terminal components without polling.")
	qdel(apc)
	return 1

/datum/unit_test/solar_generation_moves_to_controller
	name = "POWER: Solar generation is controller-batched without idle panel processing"

/datum/unit_test/solar_generation_moves_to_controller/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for the solar benchmark test.")
		return 1

	var/obj/machinery/power/solar/panel = new(T)
	var/obj/machinery/power/solar_control/control = new(T)
	if(!panel || !control)
		fail("Failed to create solar machinery for the batching test.")
		qdel(panel)
		qdel(control)
		return 1

	var/datum/powernet/net = new
	net.add_machine(panel)
	net.add_machine(control)
	panel.control = control
	control.connected_panels |= panel
	panel.obscured = FALSE
	panel.sunfrac = 1

	if((panel in SSmachines.processing_high) || (panel in SSmachines.processing_normal) || (panel in SSmachines.processing_low))
		fail("Solar panels should not stay in SSmachines processing once generation is controller-batched.")
		qdel(panel)
		qdel(control)
		return 1

	control.Process()

	if(control.gen != solar_gen_rate * panel.efficiency)
		fail("Expected solar controller to batch-generate [solar_gen_rate * panel.efficiency] W, got [control.gen].")
		qdel(panel)
		qdel(control)
		return 1

	if(net.newavail != control.gen)
		fail("Expected controller-batched solar output to be added directly to the shared powernet.")
		qdel(panel)
		qdel(control)
		return 1

	pass("Solar panels no longer idle-process individually and still contribute power through their controller.")
	qdel(panel)
	qdel(control)
	return 1
