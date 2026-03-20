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
		if(!A.powernet)
			failed = TRUE
			log_bad("The area [A.name] was missing its local powernet.")
			continue
		var/list/old_values = list(
			A.powernet.passive_equipment_consumption,
			A.powernet.passive_lighting_consumption,
			A.powernet.passive_environment_consumption
		)
		A.retally_power()
		var/list/new_values = list(
			A.powernet.passive_equipment_consumption,
			A.powernet.passive_lighting_consumption,
			A.powernet.passive_environment_consumption
		)
		for(var/i in 1 to length(old_values))
			if(abs(old_values[i] - new_values[i]) > 1) // Round because there can in fact be roundoff error here apparently.
				failed = TRUE
				log_bad("The area [A.name] had improper power use values on the [channel_names[i]] channel: was [old_values[i]] but should be [new_values[i]].")

	if(failed)
		fail("At least one area had improper power use values")
	else
		pass("All areas had accurate power use values.")
	return 1

/datum/unit_test/area_local_powernet_initialization
	name = "POWER: Areas must initialize their local powernets."

/datum/unit_test/area_local_powernet_initialization/start_test()
	var/failed = FALSE
	for(var/area/A in world)
		if(!A.powernet)
			failed = TRUE
			log_bad("The area [A.name] did not have a local powernet.")
			continue
		if(A.powernet.powernet_area != A)
			failed = TRUE
			log_bad("The area [A.name] had a local powernet owned by [A.powernet.powernet_area].")

		if(A.always_unpowered && !(A.powernet.power_flags & PW_ALWAYS_UNPOWERED))
			failed = TRUE
			log_bad("The always-unpowered area [A.name] did not propagate PW_ALWAYS_UNPOWERED to its local powernet.")
		if(!A.requires_power && !(A.powernet.power_flags & PW_ALWAYS_POWERED))
			failed = TRUE
			log_bad("The area [A.name] does not require power but its local powernet was not flagged PW_ALWAYS_POWERED.")

	if(failed)
		fail("At least one area had an invalid local powernet state.")
	else
		pass("All areas initialized and synced their local powernets.")
	return 1

/datum/unit_test/local_powernet_usage_revision
	name = "POWER: local powernet usage revision updates on usage changes."

/datum/unit_test/local_powernet_usage_revision/start_test()
	var/datum/local_powernet/local_net = new
	var/initial_revision = local_net.usage_revision

	local_net.adjust_static_power(PW_CHANNEL_EQUIPMENT, 5)
	if(local_net.usage_revision != initial_revision + 1)
		fail("Static power changes did not increment usage_revision.")
		return 1

	var/after_static = local_net.usage_revision
	local_net.use_active_power(PW_CHANNEL_EQUIPMENT, 3)
	if(local_net.usage_revision != after_static + 1)
		fail("One-off power changes did not increment usage_revision.")
		return 1

	var/after_active = local_net.usage_revision
	local_net.clear_usage()
	if(local_net.usage_revision != after_active + 1)
		fail("Clearing active power use did not increment usage_revision.")
		return 1

	var/after_clear = local_net.usage_revision
	local_net.set_power_channel(PW_CHANNEL_EQUIPMENT, FALSE)
	if(local_net.usage_revision != after_clear + 1)
		fail("Channel state changes did not increment usage_revision.")
		return 1

	pass("local powernet usage_revision updates when cached usage inputs change.")
	return 1

/datum/unit_test/local_powernet_apc_state_apply
	name = "POWER: local powernet APC state apply batches and no-ops."

/datum/unit_test/local_powernet_apc_state_apply/start_test()
	var/datum/local_powernet/local_net = new
	var/initial_revision = local_net.usage_revision
	if(local_net.apply_apc_power_state(null, TRUE, TRUE, TRUE))
		fail("A no-op APC power state apply reported a change.")
		return 1
	if(local_net.usage_revision != initial_revision)
		fail("A no-op APC power state apply changed usage_revision.")
		return 1

	local_net.apply_apc_power_state(null, FALSE, FALSE, TRUE)
	if(local_net.usage_revision != initial_revision + 1)
		fail("Batched APC power state changes should increment usage_revision once.")
		return 1

	var/after_batch = local_net.usage_revision
	if(local_net.apply_apc_power_state(null, FALSE, FALSE, TRUE))
		fail("Repeating the same APC power state should be a no-op.")
		return 1
	if(local_net.usage_revision != after_batch)
		fail("Repeating the same APC power state changed usage_revision.")
		return 1

	pass("local powernet APC state application stays batched and cheap on no-ops.")
	return 1

/datum/unit_test/powernet_apc_cache
	name = "POWER: powernet caches APC membership for sensors and APC balancing."

/datum/unit_test/powernet_apc_cache/start_test()
	var/turf/T = get_safe_turf()
	var/obj/machinery/power/apc/APC = new(T)
	var/obj/machinery/power/terminal/terminal = APC.terminal()
	var/obj/machinery/power/sensor/sensor = new(T)
	var/datum/powernet/net = new

	if(!terminal)
		qdel(sensor)
		qdel(APC)
		qdel(net)
		fail("Test APC did not create a terminal.")
		return 1

	net.add_machine(sensor)
	net.add_machine(terminal)

	var/list/found_apcs = sensor.find_apcs()
	if(length(net.apcs) != 1 || !(APC in net.apcs))
		qdel(sensor)
		qdel(APC)
		qdel(net)
		fail("Powernet did not cache the APC when its terminal joined the network.")
		return 1
	if(length(found_apcs) != 1 || !(APC in found_apcs))
		qdel(sensor)
		qdel(APC)
		qdel(net)
		fail("Power sensor did not return the APC from the cached powernet APC list.")
		return 1

	net.remove_machine(terminal)
	if(length(net.apcs))
		qdel(sensor)
		qdel(APC)
		qdel(net)
		fail("Powernet APC cache was not cleared when the APC terminal left the network.")
		return 1

	qdel(sensor)
	qdel(APC)
	qdel(net)
	pass("Powernet APC membership is cached once and reused by APC balancing and sensors.")
	return 1

/area/unit_test/apc_sandbox
	requires_power = TRUE
	dynamic_lighting = FALSE

/obj/machinery/power/apc/unit_test_apc
	var/power_change_calls = 0
	var/list/power_change_usage_samples = list()

/obj/machinery/power/apc/unit_test_apc/power_change(datum/apc_tick_state/state_override = null)
	power_change_calls++
	power_change_usage_samples += (state_override ? state_override.desired_total_load : get_power_usage())
	return ..()

/obj/machinery/power/terminal/unit_test_apc
	var/available_power = 0
	var/surplus_power = 0
	var/connected = TRUE
	var/draw_calls = 0
	var/connect_calls = 0
	var/disconnect_calls = 0

/obj/machinery/power/terminal/unit_test_apc/avail()
	return connected ? available_power : 0

/obj/machinery/power/terminal/unit_test_apc/surplus()
	return connected ? surplus_power : 0

/obj/machinery/power/terminal/unit_test_apc/draw_power(amount)
	if(!connected)
		return 0
	draw_calls++
	var/drawn = min(amount, surplus_power)
	surplus_power -= drawn
	available_power = max(available_power - drawn, 0)
	return drawn

/obj/machinery/power/terminal/unit_test_apc/proc/reset_counts()
	draw_calls = 0
	connect_calls = 0
	disconnect_calls = 0

/obj/machinery/power/terminal/unit_test_apc/proc/set_supply(new_available, new_surplus = null)
	available_power = new_available
	surplus_power = isnull(new_surplus) ? new_available : new_surplus
	var/obj/machinery/machine = master_machine()
	if(machine)
		if(istype(machine, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc = machine
			apc.mark_cache_dirty()
		else
			machine.power_change()

/obj/machinery/power/terminal/unit_test_apc/connect_to_network()
	connected = TRUE
	connect_calls++
	var/obj/machinery/machine = master_machine()
	if(machine)
		if(istype(machine, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc = machine
			apc.apc_power_component_changed()
		else
			machine.power_change()
	return TRUE

/obj/machinery/power/terminal/unit_test_apc/disconnect_from_network()
	connected = FALSE
	disconnect_calls++
	var/obj/machinery/machine = master_machine()
	if(machine)
		if(istype(machine, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc = machine
			apc.apc_power_component_changed()
		else
			machine.power_change()
	return TRUE

/obj/item/cell/unit_test_apc
	maxcharge = 1000
	var/discharge_calls = 0
	var/charge_calls = 0

/obj/item/cell/unit_test_apc/use(amount)
	discharge_calls++
	return ..()

/obj/item/cell/unit_test_apc/give(amount)
	charge_calls++
	return ..()

/obj/item/cell/unit_test_apc/proc/reset_counts()
	discharge_calls = 0
	charge_calls = 0

/datum/unit_test/apc_behavior_template
	name = "template - APC behavior"
	template = /datum/unit_test/apc_behavior_template

/datum/unit_test/apc_behavior_template/proc/claim_apc_test_area()
	var/turf/center = get_safe_turf()
	var/list/turfs = list(center)
	for(var/dir in GLOB.cardinal)
		var/turf/T = get_step(center, dir)
		if(istype(T) && !(T in turfs))
			turfs += T

	var/list/restore = list()
	var/area/unit_test/apc_sandbox/test_area = new
	for(var/turf/T as anything in turfs)
		restore[T] = get_area(T)
		if(restore[T] != test_area)
			ChangeArea(T, test_area)
	return list(
		"area" = test_area,
		"center" = center,
		"restore" = restore
	)

/datum/unit_test/apc_behavior_template/proc/release_apc_test_area(list/fixture)
	var/list/restore = fixture["restore"]
	if(restore)
		for(var/turf/T as anything in restore)
			var/area/original_area = restore[T]
			if(istype(original_area))
				ChangeArea(T, original_area)
				original_area.retally_power()
	var/area/unit_test/apc_sandbox/test_area = fixture["area"]
	if(test_area)
		if(test_area.powernet)
			test_area.powernet.powernet_apc = null
			test_area.powernet.passive_equipment_consumption = 0
			test_area.powernet.passive_lighting_consumption = 0
			test_area.powernet.passive_environment_consumption = 0
			test_area.powernet.equipment_consumption = 0
			test_area.powernet.lighting_consumption = 0
			test_area.powernet.environment_consumption = 0
			test_area.powernet.registered_machines.Cut()
			test_area.powernet.retally_passive_usage()
		qdel(test_area)

/datum/unit_test/apc_behavior_template/proc/reset_apc_fixture_counters(list/fixture)
	var/obj/machinery/power/apc/unit_test_apc/apc = fixture["apc"]
	var/obj/machinery/power/terminal/unit_test_apc/terminal = fixture["terminal"]
	var/obj/item/cell/unit_test_apc/cell = fixture["cell"]
	if(apc)
		apc.power_change_calls = 0
		apc.power_change_usage_samples.Cut()
	terminal?.reset_counts()
	cell?.reset_counts()

/datum/unit_test/apc_behavior_template/proc/setup_apc_fixture(with_cell = TRUE, terminal_power = 0, cell_charge = null)
	var/list/fixture = claim_apc_test_area()
	var/turf/center = fixture["center"]
	var/obj/machinery/power/apc/unit_test_apc/apc = new(center)
	fixture["apc"] = apc
	fixture["local_net"] = apc.get_local_powernet()

	var/obj/item/stock_parts/power/terminal/terminal_part = apc.get_component_of_type(/obj/item/stock_parts/power/terminal)
	fixture["terminal_part"] = terminal_part
	if(terminal_part.terminal)
		qdel(terminal_part.terminal)
	var/obj/machinery/power/terminal/unit_test_apc/test_terminal = new(center)
	test_terminal.available_power = terminal_power
	test_terminal.surplus_power = terminal_power
	terminal_part.set_terminal(apc, test_terminal)
	fixture["terminal"] = test_terminal

	var/obj/item/stock_parts/power/battery/battery = apc.get_component_of_type(/obj/item/stock_parts/power/battery)
	fixture["battery"] = battery
	if(battery.cell)
		qdel(battery.remove_cell())
	if(with_cell)
		var/obj/item/cell/unit_test_apc/test_cell = new(battery)
		test_cell.charge = isnull(cell_charge) ? test_cell.maxcharge : cell_charge
		test_cell.update_icon()
		battery.add_cell(apc, test_cell)
		test_cell.forceMove(battery)
		fixture["cell"] = test_cell

	reset_apc_fixture_counters(fixture)
	return fixture

/datum/unit_test/apc_behavior_template/proc/cleanup_apc_fixture(list/fixture)
	var/obj/machinery/power/apc/apc = fixture["apc"]
	if(apc)
		qdel(apc)
	release_apc_test_area(fixture)

/datum/unit_test/apc_behavior_template/proc/fail_fixture(list/fixture, message)
	cleanup_apc_fixture(fixture)
	fail(message)
	return 1

/datum/unit_test/apc_behavior_template/proc/pass_fixture(list/fixture, message)
	cleanup_apc_fixture(fixture)
	pass(message)
	return 1

/datum/unit_test/apc_behavior_template/apc_desired_draw_semantics
	name = "POWER: APC desired draw follows raw autoset semantics."

/datum/unit_test/apc_behavior_template/apc_desired_draw_semantics/start_test()
	var/list/fixture = setup_apc_fixture(TRUE, 0, 1000)
	var/obj/machinery/power/apc/unit_test_apc/apc = fixture["apc"]
	var/datum/local_powernet/local_net = fixture["local_net"]

	local_net.adjust_static_power(PW_CHANNEL_EQUIPMENT, 30)
	local_net.adjust_static_power(PW_CHANNEL_LIGHTING, 20)
	local_net.adjust_static_power(PW_CHANNEL_ENVIRONMENT, 10)

	apc.equipment_channel = POWERCHAN_OFF_TEMP
	apc.lighting_channel = POWERCHAN_OFF_AUTO
	apc.environment_channel = POWERCHAN_OFF_AUTO
	apc.mark_cache_dirty()
	if(apc.get_power_usage() != 40)
		return fail_fixture(fixture, "APC desired draw should include OFF_TEMP and environment OFF_AUTO raw load, but exclude lighting OFF_AUTO.")

	apc.lighting_channel = POWERCHAN_ON
	apc.mark_cache_dirty()
	if(apc.get_power_usage() != 60)
		return fail_fixture(fixture, "APC desired draw should include POWERCHAN_ON raw load.")

	apc.operating = FALSE
	apc.mark_cache_dirty()
	if(apc.get_power_usage() != 0)
		return fail_fixture(fixture, "APC desired draw should be zero with the breaker off.")

	apc.operating = TRUE
	apc.shorted = TRUE
	apc.mark_cache_dirty()
	if(apc.get_power_usage() != 0)
		return fail_fixture(fixture, "APC desired draw should be zero while shorted.")

	apc.shorted = FALSE
	apc.failure_timer = 5
	apc.mark_cache_dirty()
	if(apc.get_power_usage() != 0)
		return fail_fixture(fixture, "APC desired draw should be zero while the failure timer is active.")

	return pass_fixture(fixture, "APC desired draw matches the old autoset rules from raw local powernet usage.")

/datum/unit_test/apc_behavior_template/apc_same_tick_power_change_fresh_draw
	name = "POWER: APC power_change uses fresh same-tick draw after APC update fanout."

/datum/unit_test/apc_behavior_template/apc_same_tick_power_change_fresh_draw/start_test()
	var/list/fixture = setup_apc_fixture(TRUE, 0, 1000)
	var/obj/machinery/power/apc/unit_test_apc/apc = fixture["apc"]
	var/datum/local_powernet/local_net = fixture["local_net"]

	local_net.adjust_static_power(PW_CHANNEL_EQUIPMENT, 10)
	apc.Process()
	reset_apc_fixture_counters(fixture)

	local_net.adjust_static_power(PW_CHANNEL_EQUIPMENT, 20)
	apc.set_channel_state(EQUIP, POWERCHAN_OFF_TEMP)
	apc.update()

	if(apc.power_change_calls < 1)
		return fail_fixture(fixture, "APC update fanout did not wake APC power_change().")
	var/observed_usage = apc.power_change_usage_samples[length(apc.power_change_usage_samples)]
	if(observed_usage != 30)
		return fail_fixture(fixture, "APC power_change() observed stale draw ([observed_usage]) instead of the current 30W raw desired draw.")

	return pass_fixture(fixture, "APC invalidates its tick snapshot before local fanout, so same-tick power_change sees fresh draw.")

/datum/unit_test/apc_behavior_template/apc_power_change_edges
	name = "POWER: APC steady-state power_change only fires on uncovered loss/recovery edges."

/datum/unit_test/apc_behavior_template/apc_power_change_edges/start_test()
	var/list/fixture = setup_apc_fixture(FALSE, 100, null)
	var/obj/machinery/power/apc/unit_test_apc/apc = fixture["apc"]
	var/datum/local_powernet/local_net = fixture["local_net"]
	var/obj/machinery/power/terminal/unit_test_apc/terminal = fixture["terminal"]

	apc.equipment_channel = POWERCHAN_ON
	apc.lighting_channel = POWERCHAN_OFF
	apc.environment_channel = POWERCHAN_OFF
	apc.mark_cache_dirty()
	local_net.adjust_static_power(PW_CHANNEL_EQUIPMENT, 50)
	apc.Process() // establish the powered baseline
	reset_apc_fixture_counters(fixture)

	terminal.set_supply(0)
	apc.Process()
	if(apc.power_change_calls != 1)
		return fail_fixture(fixture, "Losing uncovered external supply should trigger one APC power_change edge.")

	reset_apc_fixture_counters(fixture)
	apc.Process()
	if(apc.power_change_calls != 0)
		return fail_fixture(fixture, "APC retriggered power_change on a steady uncovered outage.")

	terminal.set_supply(100)
	apc.Process()
	if(apc.power_change_calls != 1)
		return fail_fixture(fixture, "Recovering external supply should trigger one APC power_change edge.")

	reset_apc_fixture_counters(fixture)
	apc.Process()
	if(apc.power_change_calls != 0)
		return fail_fixture(fixture, "APC retriggered power_change every powered steady-state tick after recovery.")

	return pass_fixture(fixture, "APC steady-state power_change is edge-triggered on real uncovered loss/recovery transitions.")

/datum/unit_test/apc_behavior_template/apc_deficit_power_change_behavior
	name = "POWER: APC only retriggers power_change for uncovered deficits."

/datum/unit_test/apc_behavior_template/apc_deficit_power_change_behavior/start_test()
	var/list/fixture = setup_apc_fixture(TRUE, 100, 1000)
	var/obj/machinery/power/apc/unit_test_apc/apc = fixture["apc"]
	var/datum/local_powernet/local_net = fixture["local_net"]
	var/obj/machinery/power/terminal/unit_test_apc/terminal = fixture["terminal"]
	var/obj/item/cell/unit_test_apc/cell = fixture["cell"]

	apc.equipment_channel = POWERCHAN_ON
	apc.lighting_channel = POWERCHAN_OFF
	apc.environment_channel = POWERCHAN_OFF
	apc.mark_cache_dirty()
	local_net.adjust_static_power(PW_CHANNEL_EQUIPMENT, 50)
	apc.Process() // establish the powered baseline
	reset_apc_fixture_counters(fixture)

	terminal.set_supply(20)
	apc.Process()
	if(apc.power_change_calls != 0)
		return fail_fixture(fixture, "A battery-covered external deficit should not retrigger APC power_change().")

	reset_apc_fixture_counters(fixture)
	terminal.set_supply(10)
	cell.charge = 0
	apc.mark_cache_dirty()
	apc.Process()
	if(apc.power_change_calls != 1)
		return fail_fixture(fixture, "An uncovered deficit should retrigger APC power_change().")

	return pass_fixture(fixture, "APC only retriggers power_change when a deficit is no longer fully covered.")

/datum/unit_test/apc_behavior_template/apc_single_draw_single_fallback
	name = "POWER: APC steady-state uses one terminal draw and one fallback path."

/datum/unit_test/apc_behavior_template/apc_single_draw_single_fallback/start_test()
	var/list/fixture = setup_apc_fixture(TRUE, 20, 1000)
	var/obj/machinery/power/apc/unit_test_apc/apc = fixture["apc"]
	var/datum/local_powernet/local_net = fixture["local_net"]
	var/obj/machinery/power/terminal/unit_test_apc/terminal = fixture["terminal"]
	var/obj/item/cell/unit_test_apc/cell = fixture["cell"]

	apc.equipment_channel = POWERCHAN_ON
	apc.lighting_channel = POWERCHAN_OFF
	apc.environment_channel = POWERCHAN_OFF
	apc.mark_cache_dirty()
	local_net.adjust_static_power(PW_CHANNEL_EQUIPMENT, 50)
	reset_apc_fixture_counters(fixture)
	apc.Process()

	if(terminal.draw_calls != 1)
		return fail_fixture(fixture, "APC should perform exactly one terminal draw in steady-state, saw [terminal.draw_calls].")
	if(cell.discharge_calls != 1)
		return fail_fixture(fixture, "APC should perform exactly one local fallback discharge, saw [cell.discharge_calls].")

	return pass_fixture(fixture, "APC steady-state performs one external draw and one fallback discharge at most.")

/datum/unit_test/apc_behavior_template/apc_no_component_processing
	name = "POWER: APC steady-state removes terminal and battery from processing_parts."

/datum/unit_test/apc_behavior_template/apc_no_component_processing/start_test()
	var/list/fixture = setup_apc_fixture(TRUE, 0, 1000)
	var/obj/machinery/power/apc/unit_test_apc/apc = fixture["apc"]
	var/obj/item/stock_parts/power/battery/battery = fixture["battery"]
	var/obj/item/stock_parts/power/terminal/terminal_part = fixture["terminal_part"]

	if(apc.processing_flags & MACHINERY_PROCESS_COMPONENTS)
		return fail_fixture(fixture, "APC should not keep MACHINERY_PROCESS_COMPONENTS enabled for steady-state power parts.")
	if(apc.processing_parts && (battery in apc.processing_parts))
		return fail_fixture(fixture, "APC battery remained in processing_parts.")
	if(apc.processing_parts && (terminal_part in apc.processing_parts))
		return fail_fixture(fixture, "APC terminal component remained in processing_parts.")

	return pass_fixture(fixture, "APC-managed batteries and terminals no longer stay in steady-state component processing.")

/datum/unit_test/apc_behavior_template/apc_terminal_events_wake
	name = "POWER: APC terminal events wake APC and refresh power state."

/datum/unit_test/apc_behavior_template/apc_terminal_events_wake/start_test()
	var/list/fixture = setup_apc_fixture(FALSE, 50, null)
	var/obj/machinery/power/apc/unit_test_apc/apc = fixture["apc"]
	var/datum/local_powernet/local_net = fixture["local_net"]
	var/obj/machinery/power/terminal/unit_test_apc/terminal = fixture["terminal"]
	var/obj/item/stock_parts/power/terminal/terminal_part = fixture["terminal_part"]
	var/turf/center = fixture["center"]

	apc.equipment_channel = POWERCHAN_ON
	apc.lighting_channel = POWERCHAN_OFF
	apc.environment_channel = POWERCHAN_OFF
	apc.mark_cache_dirty()
	local_net.adjust_static_power(PW_CHANNEL_EQUIPMENT, 50)
	apc.power_change() // establish the powered baseline from the connected terminal
	reset_apc_fixture_counters(fixture)

	terminal.disconnect_from_network()
	if(apc.power_change_calls < 1)
		return fail_fixture(fixture, "Terminal disconnect did not wake APC power_change().")
	if(!GET_FLAGS(apc.stat, MACHINE_STAT_NOPOWER))
		return fail_fixture(fixture, "Terminal disconnect did not update APC to no-power.")

	reset_apc_fixture_counters(fixture)
	terminal.available_power = 50
	terminal.surplus_power = 50
	terminal.connect_to_network()
	if(apc.power_change_calls < 1)
		return fail_fixture(fixture, "Terminal connect did not wake APC power_change().")
	if(GET_FLAGS(apc.stat, MACHINE_STAT_NOPOWER))
		return fail_fixture(fixture, "Terminal connect did not restore APC power state.")

	reset_apc_fixture_counters(fixture)
	terminal_part.machine_moved(apc, center, get_step(center, NORTH))
	if(apc.power_change_calls < 1)
		return fail_fixture(fixture, "Terminal move/ripout did not wake APC power_change().")
	if(terminal_part.terminal)
		return fail_fixture(fixture, "Terminal move/ripout did not sever the APC terminal component.")
	if(!GET_FLAGS(apc.stat, MACHINE_STAT_NOPOWER))
		return fail_fixture(fixture, "Terminal move/ripout did not refresh APC no-power state.")

	return pass_fixture(fixture, "Terminal connect, disconnect, and move events wake APC and refresh APC power state immediately.")

/datum/unit_test/apc_behavior_template/apc_cell_events_wake
	name = "POWER: APC cell insert/remove wakes APC and refreshes power state."

/datum/unit_test/apc_behavior_template/apc_cell_events_wake/start_test()
	var/list/fixture = setup_apc_fixture(TRUE, 0, 1000)
	var/obj/machinery/power/apc/unit_test_apc/apc = fixture["apc"]
	var/datum/local_powernet/local_net = fixture["local_net"]
	var/obj/item/stock_parts/power/battery/battery = fixture["battery"]

	apc.equipment_channel = POWERCHAN_ON
	apc.lighting_channel = POWERCHAN_OFF
	apc.environment_channel = POWERCHAN_OFF
	apc.mark_cache_dirty()
	local_net.adjust_static_power(PW_CHANNEL_EQUIPMENT, 50)
	apc.power_change() // establish the battery-backed powered baseline
	reset_apc_fixture_counters(fixture)

	var/obj/item/cell/removed = battery.remove_cell()
	if(apc.power_change_calls < 1)
		qdel(removed)
		return fail_fixture(fixture, "Cell removal did not wake APC power_change().")
	if(!GET_FLAGS(apc.stat, MACHINE_STAT_NOPOWER))
		qdel(removed)
		return fail_fixture(fixture, "Cell removal did not refresh APC to no-power.")
	qdel(removed)

	reset_apc_fixture_counters(fixture)
	var/obj/item/cell/unit_test_apc/new_cell = new(battery)
	new_cell.charge = new_cell.maxcharge
	new_cell.update_icon()
	battery.add_cell(apc, new_cell)
	new_cell.forceMove(battery)
	if(apc.power_change_calls < 1)
		return fail_fixture(fixture, "Cell insertion did not wake APC power_change().")
	if(GET_FLAGS(apc.stat, MACHINE_STAT_NOPOWER))
		return fail_fixture(fixture, "Cell insertion did not refresh APC powered state.")

	return pass_fixture(fixture, "Cell insert/remove events wake APC and refresh APC power state immediately.")
