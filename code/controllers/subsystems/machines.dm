#define SSMACHINES_PIPENETS 1
#define SSMACHINES_MACHINERY 2
#define SSMACHINES_POWERNETS 3
#define SSMACHINES_POWER_OBJECTS 4


#define START_PROCESSING_IN_LIST(Datum, List) \
if (Datum.is_processing) {\
	if(Datum.is_processing != "SSmachines.[#List]")\
	{\
		crash_with("Failed to start processing. [log_info_line(Datum)] is already being processed by [Datum.is_processing] but queue attempt occured on SSmachines.[#List]."); \
	}\
} else {\
	Datum.is_processing = "SSmachines.[#List]";\
	SSmachines.List += Datum;\
}

#define STOP_PROCESSING_IN_LIST(Datum, List) \
if(Datum.is_processing) {\
	if(SSmachines.List.Remove(Datum)) {\
		Datum.is_processing = null;\
	} else {\
		crash_with("Failed to stop processing. [log_info_line(Datum)] is being processed by [is_processing] and not found in SSmachines.[#List]"); \
	}\
}

#define START_PROCESSING_PIPENET(Datum) START_PROCESSING_IN_LIST(Datum, pipenets)
#define STOP_PROCESSING_PIPENET(Datum) STOP_PROCESSING_IN_LIST(Datum, pipenets)

#define START_PROCESSING_POWERNET(Datum) START_PROCESSING_IN_LIST(Datum, powernets)
#define STOP_PROCESSING_POWERNET(Datum) STOP_PROCESSING_IN_LIST(Datum, powernets)

#define START_PROCESSING_POWER_OBJECT(Datum) START_PROCESSING_IN_LIST(Datum, power_objects)
#define STOP_PROCESSING_POWER_OBJECT(Datum) STOP_PROCESSING_IN_LIST(Datum, power_objects)


SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_MACHINERY
	flags = SS_KEEP_TIMING
	var/static/current_step = SSMACHINES_PIPENETS
	var/static/cost_pipenets = 0
	var/static/cost_machinery = 0
	var/static/cost_powernets = 0
	var/static/cost_power_objects = 0
	var/static/profiling_machinery = FALSE
	var/static/list/processing_profile_time_by_type = list()
	var/static/list/processing_profile_count_by_type = list()
	var/static/profiling_machinery_cycles = 0
	/// Auto-stop machinery profiling when cycles sampled reaches this value. 0 disables auto-stop.
	var/static/profiling_machinery_cycle_limit = 0
	/// Set to TRUE when machinery profiling was auto-stopped at the cycle limit.
	var/static/machinery_profile_auto_stopped = FALSE
	var/static/profiling_air_alarm_process = FALSE
	var/static/alarm_process_profile_cycles = 0
	var/static/alarm_process_profile_total_calls = 0
	var/static/alarm_process_profile_measured_calls = 0
	var/static/alarm_process_profile_skipped_calls = 0
	var/static/alarm_process_profile_bucket_env_math_ms = 0
	var/static/alarm_process_profile_bucket_state_output_ms = 0
	/// Auto-stop air alarm micro-profiling when cycles sampled reaches this value. 0 disables auto-stop.
	var/static/profiling_air_alarm_cycle_limit = 0
	/// Set to TRUE when air alarm profiling was auto-stopped at the cycle limit.
	var/static/air_alarm_profile_auto_stopped = FALSE
	/// Runtime fallback switch for event-driven processing of docking embedded controllers.
	var/static/optimize_embedded_docking_event = TRUE
	var/static/powernet_last_snapshot_size = 0
	var/static/powernet_last_processed = 0
	var/static/powernet_last_skipped_null = 0
	var/static/powernet_last_removed_qdeleted = 0
	var/static/powernet_next_anomaly_log_time = 0
	var/static/power_shadow_native_autogate_enabled = TRUE
	var/static/power_shadow_native_autogate_probe_interval = 100
	var/static/power_shadow_native_autogate_loss_streak = 0
	var/static/power_shadow_native_autogate_trip_threshold = 5
	var/static/power_shadow_native_autogate_cooldown_ticks = 1200
	var/static/power_shadow_native_autogate_suspended_until = 0
	var/static/power_shadow_native_autogate_next_probe_tick = 0
	var/static/power_shadow_native_autogate_last_probe_dm_us = 0
	var/static/power_shadow_native_autogate_last_probe_batch_us = 0
	var/static/profiling_machinery = FALSE
	var/static/list/processing_profile_time_by_type = list()
	var/static/list/processing_profile_count_by_type = list()
	var/static/profiling_machinery_cycles = 0
	var/static/list/pipenets = list()
	var/static/list/powernets = list()
	var/static/list/power_objects = list()
	var/static/list/processing = list()
	var/static/list/processing_lazy = list()
	var/static/processing_lazy_slice_n = 4
	var/static/processing_lazy_cursor = 0
	var/static/list/queue = list()
	var/static/list/machinery = list()
	var/static/list/machinery_by_type = list()

/datum/controller/subsystem/machines/Recover()
	current_step = SSMACHINES_PIPENETS
	processing_lazy_cursor = 0
	queue.Cut()


/datum/controller/subsystem/machines/Initialize(start_uptime)
	makepowernets()
	setup_atmos_machinery(machinery)
	fire(FALSE, TRUE)


/datum/controller/subsystem/machines/fire(resumed, no_mc_tick)
	var/timer
	if (!resumed)
		current_step = SSMACHINES_PIPENETS
	if (current_step == SSMACHINES_PIPENETS)
		timer = world.tick_usage
		process_pipenets(resumed, no_mc_tick)
		cost_pipenets = MC_AVERAGE(cost_pipenets, (world.tick_usage - timer) * world.tick_lag)
		if (state != SS_RUNNING)
			return
		current_step = SSMACHINES_MACHINERY
		resumed = FALSE
	if (current_step == SSMACHINES_MACHINERY)
		timer = world.tick_usage
		process_machinery(resumed, no_mc_tick)
		cost_machinery = MC_AVERAGE(cost_machinery, (world.tick_usage - timer) * world.tick_lag)
		if(state != SS_RUNNING)
			return
		current_step = SSMACHINES_POWERNETS
		resumed = FALSE
	if (current_step == SSMACHINES_POWERNETS)
		timer = world.tick_usage
		process_powernets(resumed, no_mc_tick)
		cost_powernets = MC_AVERAGE(cost_powernets, (world.tick_usage - timer) * world.tick_lag)
		if(state != SS_RUNNING)
			return
		current_step = SSMACHINES_POWER_OBJECTS
		resumed = FALSE
	if (current_step == SSMACHINES_POWER_OBJECTS)
		timer = world.tick_usage
		process_power_objects(resumed, no_mc_tick)
		cost_power_objects = MC_AVERAGE(cost_power_objects, (world.tick_usage - timer) * world.tick_lag)
		if (state != SS_RUNNING)
			return
		current_step = SSMACHINES_PIPENETS

/datum/controller/subsystem/machines/proc/register_machinery(obj/machinery/machine)
	if(!machine)
		CRASH("Null machinery was tried to be registered")

	machinery += machine
	LAZYADDASSOCLIST(machinery_by_type, machine.type, machine)
	var/area/A = get_area(machine)
	if(A)
		LAZYADD(A.machinery_list, machine)

/datum/controller/subsystem/machines/proc/unregister_machinery(obj/machinery/machine)
	if(!machine)
		CRASH("Null machinery was tried to be unregistered")

	machinery -= machine
	var/list/machinery_of_type = machinery_by_type[machine.type]
	machinery_of_type -= machine
	if(!length(machinery_of_type))
		machinery_by_type -= machine.type

	var/area/A = get_area(machine)
	if(A)
		LAZYREMOVE(A.machinery_list, machine)

/datum/controller/subsystem/machines/proc/get_machinery_of_type(obj/machinery/machinery_type)
	if(!machinery_type)
		return list()

	if(!ispath(machinery_type))
		machinery_type = machinery_type.type

	if(!ispath(machinery_type, /obj/machinery))
		CRASH("Non-machinery type passed in `/datum/controller/subsystem/machines/proc/get_machinery_of_type`")

	if(machinery_type == /obj/machinery)
		return get_all_machinery()

	var/list/machinery = list()
	for(var/type in typesof(machinery_type))
		var/list/machinery_of_type = machinery_by_type[type]
		if(machinery_of_type)
			machinery += machinery_of_type

	return machinery

/datum/controller/subsystem/machines/proc/get_all_machinery()
	return machinery.Copy()

/// Rebuilds power networks from scratch. Called by world initialization and elevators.
/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/powernet as anything in powernets)
		qdel(powernet)
	powernets.Cut()
	power_shadow_native_autogate_loss_streak = 0
	power_shadow_native_autogate_suspended_until = 0
	power_shadow_native_autogate_next_probe_tick = world.time + max(power_shadow_native_autogate_probe_interval, 1)
	power_shadow_native_autogate_last_probe_dm_us = 0
	power_shadow_native_autogate_last_probe_batch_us = 0
	rustg_power_shadow_stateful_reset()
	setup_powernets_for_cables(GLOB.cable_list)


/datum/controller/subsystem/machines/proc/setup_powernets_for_cables(list/cables)
	for (var/obj/structure/cable/cable as anything in cables)
		if (cable.powernet)
			continue
		var/datum/powernet/network = new
		network.add_cable(cable)
		propagate_network(cable, cable.powernet)


/datum/controller/subsystem/machines/proc/setup_atmos_machinery(list/machines)
	set background = TRUE
	var/list/atmos_machines = list()
	for (var/obj/machinery/atmospherics/machine in machines)
		atmos_machines += machine
	report_progress("Initializing atmos machinery")
	for (var/obj/machinery/atmospherics/machine as anything in atmos_machines)
		machine.atmos_init()
		CHECK_TICK
	report_progress("Initializing pipe networks")
	for (var/obj/machinery/atmospherics/machine as anything in atmos_machines)
		machine.build_network()
		CHECK_TICK


/datum/controller/subsystem/machines/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	var/autogate_state = "off"
	if(power_shadow_native_autogate_enabled)
		if(world.time < power_shadow_native_autogate_suspended_until)
			autogate_state = "cooldown [power_shadow_native_autogate_suspended_until - world.time]"
		else
			autogate_state = "armed"
	..({"\
		Queues: \
		Pipes [length(pipenets)] \
		Machines [length(processing)] \
		Lazy [length(processing_lazy)] \
		Networks [length(powernets)] \
		Objects [length(power_objects)]\n\
		Costs: \
		Pipes [Round(cost_pipenets)] \
		Machines [Round(cost_machinery)] \
		Networks [Round(cost_powernets)] \
		Objects [Round(cost_power_objects)]\n\
		PowerLoop: \
		Snap [powernet_last_snapshot_size] \
		Done [powernet_last_processed] \
		Null [powernet_last_skipped_null] \
		QDel [powernet_last_removed_qdeleted]\n\
		NativeGate [autogate_state] \
		Loss [power_shadow_native_autogate_loss_streak] \
		ProbeDM [round(power_shadow_native_autogate_last_probe_dm_us, 0.1)] \
		ProbeBatch [round(power_shadow_native_autogate_last_probe_batch_us, 0.1)]\n\
		Overall [Roundm(cost ? length(processing) / cost : 0, 0.1)]
	"})


/datum/controller/subsystem/machines/proc/process_pipenets(resumed, no_mc_tick)
	var/static/pipenets_index = 0
	if (!resumed)
		pipenets_index = length(pipenets)
	var/datum/pipe_network/network
	for (var/i = pipenets_index to 1 step -1)
		if(i > length(pipenets))
			continue
		network = pipenets[i]
		if (QDELETED(network))
			if (network)
				network.is_processing = null
			pipenets -= network
			continue
		network.Process(wait)
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			pipenets_index = i - 1
			return
	pipenets_index = 0


/datum/controller/subsystem/machines/proc/process_machinery(resumed, no_mc_tick)
	var/static/machinery_index = 0
	var/static/processing_lazy_index = 0
	if (!resumed)
		machinery_index = length(processing)
	var/obj/machinery/machine
	var/profile_timer
	for (var/i = machinery_index to 1 step -1)
		if(i > length(processing))
			continue
		machine = processing[i]
		if (QDELETED(machine))
			if (machine)
				machine.is_processing = null
			processing -= machine
			continue

		if(profiling_machinery)
			profile_timer = world.tick_usage

		if(machine.processing_flags & MACHINERY_PROCESS_COMPONENTS)
			for(var/obj/item/stock_parts/part as anything in machine.processing_parts)
				if(part.machine_process(machine) == PROCESS_KILL)
					part.stop_processing()

		if((machine.processing_flags & MACHINERY_PROCESS_SELF) && machine.Process(wait) == PROCESS_KILL)
			STOP_PROCESSING_MACHINE(machine, MACHINERY_PROCESS_SELF)

		if(profiling_machinery)
			var/profile_cost = max((world.tick_usage - profile_timer) * world.tick_lag, 0)
			var/mtype = machine.type
			processing_profile_time_by_type[mtype] = (processing_profile_time_by_type[mtype] || 0) + profile_cost
			processing_profile_count_by_type[mtype] = (processing_profile_count_by_type[mtype] || 0) + 1

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			machinery_index = i - 1
			return
	if(profiling_machinery)
		profiling_machinery_cycles++
		if(profiling_machinery_cycle_limit > 0 && profiling_machinery_cycles >= profiling_machinery_cycle_limit)
			profiling_machinery = FALSE
			machinery_profile_auto_stopped = TRUE
	if(profiling_air_alarm_process)
		alarm_process_profile_cycles++
		if(profiling_air_alarm_cycle_limit > 0 && alarm_process_profile_cycles >= profiling_air_alarm_cycle_limit)
			profiling_air_alarm_process = FALSE
			air_alarm_profile_auto_stopped = TRUE
	machinery_index = 0

	// Lazy processing: process 1/processing_lazy_slice_n of processing_lazy per fire cycle.
	// Uses a rotating cursor so each machine is visited every processing_lazy_slice_n fires (~8s at default wait=2s).
	if (length(processing_lazy))
		if (processing_lazy_index == 0)
			if (processing_lazy_cursor >= length(processing_lazy))
				processing_lazy_cursor = 0
			var/slice_size = max(1, round(length(processing_lazy) / processing_lazy_slice_n))
			processing_lazy_index = min(processing_lazy_cursor + slice_size, length(processing_lazy))
		var/obj/machinery/lmachine
		for (var/i = processing_lazy_index to processing_lazy_cursor + 1 step -1)
			if (i > length(processing_lazy))
				continue
			lmachine = processing_lazy[i]
			if (QDELETED(lmachine))
				if (lmachine)
					lmachine.is_processing = null
				processing_lazy -= lmachine
				continue
			if (lmachine.Process(wait) == PROCESS_KILL)
				lmachine.is_processing = null
				processing_lazy -= lmachine
				continue
			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				processing_lazy_index = i - 1
				return
		processing_lazy_cursor = min(processing_lazy_index, length(processing_lazy))
		if (processing_lazy_cursor >= length(processing_lazy))
			processing_lazy_cursor = 0
	processing_lazy_index = 0


/datum/controller/subsystem/machines/proc/reset_machinery_profiling()
	processing_profile_time_by_type = list()
	processing_profile_count_by_type = list()
	profiling_machinery_cycles = 0
	machinery_profile_auto_stopped = FALSE


/datum/controller/subsystem/machines/proc/reset_air_alarm_process_profiling()
	alarm_process_profile_cycles = 0
	alarm_process_profile_total_calls = 0
	alarm_process_profile_measured_calls = 0
	alarm_process_profile_skipped_calls = 0
	alarm_process_profile_bucket_env_math_ms = 0
	alarm_process_profile_bucket_state_output_ms = 0
	air_alarm_profile_auto_stopped = FALSE


/datum/controller/subsystem/machines/proc/report_machinery_hotspots(top_n = 25)
	if(!length(processing_profile_time_by_type))
		return "No profiling data collected."

	top_n = max(round(top_n), 1)
	var/total_ms = 0
	for(var/path in processing_profile_time_by_type)
		total_ms += processing_profile_time_by_type[path]
	if(total_ms <= 0)
		return "No measurable processing time recorded."

	var/list/time_left = processing_profile_time_by_type.Copy()
	var/list/lines = list()
	lines += "<h3>Machinery Processing Hotspots</h3>"
	lines += "<b>Cycles sampled:</b> [profiling_machinery_cycles] | <b>Total measured time:</b> [round(total_ms, 0.01)]ms | <b>Processing list size:</b> [length(processing)]<br>"
	lines += "<table border='1' cellpadding='3' cellspacing='0'>"
	lines += "<tr><th>#</th><th>Type</th><th>Total (ms)</th><th>Calls</th><th>Avg (ms)</th><th>Share</th></tr>"
	var/rank = 0
	while(rank < top_n && length(time_left))
		var/best_path = null
		var/best_ms = -1
		for(var/path in time_left)
			var/path_ms = time_left[path]
			if(path_ms > best_ms)
				best_ms = path_ms
				best_path = path

		if(isnull(best_path))
			break

		time_left.Remove(best_path)
		if(best_ms <= 0)
			continue

		rank++
		var/calls = processing_profile_count_by_type[best_path] || 0
		var/avg_ms = calls ? round(best_ms / calls, 0.001) : 0
		var/share = round((best_ms / total_ms) * 100, 0.1)
		var/avg_per_cycle = profiling_machinery_cycles ? round(calls / profiling_machinery_cycles, 0.1) : calls
		lines += "<tr><td>[rank]</td><td>[best_path]</td><td>[round(best_ms, 0.01)]</td><td>[calls] ([avg_per_cycle]/cyc)</td><td>[avg_ms]</td><td>[share]%</td></tr>"

	lines += "</table>"
	return lines.Join("\n")


/datum/controller/subsystem/machines/proc/report_air_alarm_process_profiling()
	var/total_calls = alarm_process_profile_total_calls
	if(!total_calls)
		return "No air alarm profiling data collected."

	var/measured_calls = alarm_process_profile_measured_calls
	var/skipped_calls = alarm_process_profile_skipped_calls
	var/bucket_a_ms = alarm_process_profile_bucket_env_math_ms
	var/bucket_b_ms = alarm_process_profile_bucket_state_output_ms
	var/total_measured_ms = bucket_a_ms + bucket_b_ms
	var/avg_bucket_a_ms = measured_calls ? round(bucket_a_ms / measured_calls, 0.001) : 0
	var/avg_bucket_b_ms = measured_calls ? round(bucket_b_ms / measured_calls, 0.001) : 0
	var/avg_total_ms = measured_calls ? round(total_measured_ms / measured_calls, 0.001) : 0
	var/share_bucket_a = total_measured_ms ? round((bucket_a_ms / total_measured_ms) * 100, 0.1) : 0
	var/share_bucket_b = total_measured_ms ? round((bucket_b_ms / total_measured_ms) * 100, 0.1) : 0
	var/calls_per_cycle = alarm_process_profile_cycles ? round(total_calls / alarm_process_profile_cycles, 0.1) : total_calls
	var/measured_per_cycle = alarm_process_profile_cycles ? round(measured_calls / alarm_process_profile_cycles, 0.1) : measured_calls

	var/list/lines = list()
	lines += "<h3>Air Alarm Process Micro-Profiling</h3>"
	lines += "<b>Cycles sampled:</b> [alarm_process_profile_cycles] | <b>Total calls:</b> [total_calls] ([calls_per_cycle]/cyc) | <b>Measured calls:</b> [measured_calls] ([measured_per_cycle]/cyc) | <b>Skipped calls:</b> [skipped_calls]<br>"
	lines += "<b>Total measured time:</b> [round(total_measured_ms, 0.01)]ms | <b>Average measured per call:</b> [avg_total_ms]ms<br>"
	lines += "<table border='1' cellpadding='3' cellspacing='0'>"
	lines += "<tr><th>Bucket</th><th>Description</th><th>Total (ms)</th><th>Avg (ms/call)</th><th>Share</th></tr>"
	lines += "<tr><td>A</td><td>Environment read + gas math</td><td>[round(bucket_a_ms, 0.01)]</td><td>[avg_bucket_a_ms]</td><td>[share_bucket_a]%</td></tr>"
	lines += "<tr><td>B</td><td>State eval + output/actions</td><td>[round(bucket_b_ms, 0.01)]</td><td>[avg_bucket_b_ms]</td><td>[share_bucket_b]%</td></tr>"
	lines += "</table>"
	lines += "<small>Skipped calls are early exits before a simulated turf/environment was available.</small>"
	return lines.Join("\n")


/// Returns an HTML table showing the count of each machinery type currently in the processing and processing_lazy lists.
/// Useful for identifying candidates to migrate to lazy processing. No profiling run required.
/datum/controller/subsystem/machines/proc/report_machinery_distribution()
	var/total_fast = length(processing)
	var/total_lazy = length(processing_lazy)

	var/list/fast_counts = list()
	for(var/obj/machinery/m as anything in processing)
		var/t = m.type
		fast_counts[t] = (fast_counts[t] || 0) + 1

	var/list/lazy_counts = list()
	for(var/obj/machinery/m as anything in processing_lazy)
		var/t = m.type
		lazy_counts[t] = (lazy_counts[t] || 0) + 1

	// Collect all types seen in either list
	var/list/all_types = fast_counts.Copy()
	for(var/t in lazy_counts)
		if(!(t in all_types))
			all_types[t] = 0

	// Sort by fast_count descending (selection sort)
	var/list/sorted_types = list()
	var/list/remaining = all_types.Copy()
	while(length(remaining))
		var/best = null
		var/best_n = -1
		for(var/t in remaining)
			var/n = fast_counts[t] || 0
			if(n > best_n)
				best_n = n
				best = t
		if(isnull(best))
			break
		sorted_types += best
		remaining.Remove(best)

	var/list/lines = list()
	lines += "<h3>Machinery Processing Distribution</h3>"
	lines += "<b>Fast list (2s):</b> [total_fast] | <b>Lazy list (~8s):</b> [total_lazy] | <b>Total registered:</b> [length(machinery)]<br>"
	lines += "<table border='1' cellpadding='3' cellspacing='0'>"
	lines += "<tr><th>#</th><th>Type</th><th>Fast (2s)</th><th>Fast %</th><th>Lazy (~8s)</th></tr>"
	var/rank = 0
	for(var/t in sorted_types)
		rank++
		var/fc = fast_counts[t] || 0
		var/lc = lazy_counts[t] || 0
		var/pct = total_fast ? round((fc / total_fast) * 100, 0.1) : 0
		lines += "<tr><td>[rank]</td><td>[t]</td><td>[fc]</td><td>[pct]%</td><td>[lc]</td></tr>"
	lines += "</table>"
	return lines.Join("\n")


/datum/controller/subsystem/machines/proc/reset_machinery_profiling()
	processing_profile_time_by_type = list()
	processing_profile_count_by_type = list()
	profiling_machinery_cycles = 0


/datum/controller/subsystem/machines/proc/report_machinery_hotspots(top_n = 25)
	if(!length(processing_profile_time_by_type))
		return "No profiling data collected."

	top_n = max(round(top_n), 1)
	var/total_ms = 0
	for(var/path in processing_profile_time_by_type)
		total_ms += processing_profile_time_by_type[path]
	if(total_ms <= 0)
		return "No measurable processing time recorded."

	var/list/time_left = processing_profile_time_by_type.Copy()
	var/list/lines = list()
	lines += "<h3>Machinery Processing Hotspots</h3>"
	lines += "<b>Cycles sampled:</b> [profiling_machinery_cycles] | <b>Total measured time:</b> [round(total_ms, 0.01)]ms | <b>Processing list size:</b> [length(processing)]<br>"
	lines += "<table border='1' cellpadding='3' cellspacing='0'>"
	lines += "<tr><th>#</th><th>Type</th><th>Total (ms)</th><th>Calls</th><th>Avg (ms)</th><th>Share</th></tr>"
	var/rank = 0
	while(rank < top_n && length(time_left))
		var/best_path = null
		var/best_ms = -1
		for(var/path in time_left)
			var/path_ms = time_left[path]
			if(path_ms > best_ms)
				best_ms = path_ms
				best_path = path

		if(isnull(best_path))
			break

		time_left.Remove(best_path)
		if(best_ms <= 0)
			continue

		rank++
		var/calls = processing_profile_count_by_type[best_path] || 0
		var/avg_ms = calls ? round(best_ms / calls, 0.001) : 0
		var/share = round((best_ms / total_ms) * 100, 0.1)
		var/avg_per_cycle = profiling_machinery_cycles ? round(calls / profiling_machinery_cycles, 0.1) : calls
		lines += "<tr><td>[rank]</td><td>[best_path]</td><td>[round(best_ms, 0.01)]</td><td>[calls] ([avg_per_cycle]/cyc)</td><td>[avg_ms]</td><td>[share]%</td></tr>"

	lines += "</table>"
	return lines.Join("\n")


/datum/controller/subsystem/machines/proc/power_shadow_native_autogate_is_suspended()
	if(!power_shadow_native_autogate_enabled)
		return FALSE
	return world.time < power_shadow_native_autogate_suspended_until


/datum/controller/subsystem/machines/proc/power_shadow_native_solve_batch_stateful(list/batch_targets, list/batch_dynamic_payload)
	var/static/native_stateful_supported = TRUE
	var/static/native_stateful_failure_streak = 0
	if(!native_stateful_supported || !islist(batch_targets) || !length(batch_targets))
		return null
	if(!islist(batch_dynamic_payload) || length(batch_dynamic_payload) != length(batch_targets))
		return null

	var/list/register_payload = list()
	var/index = 1
	for(var/datum/powernet/PN in batch_targets)
		var/datum/power_solver/solver = PN.ensure_shadow_solver()
		if(!istype(solver))
			index++
			continue
		if(PN.shadow_solver_native_stateful_registered_revision != PN.shadow_solver_native_topology_revision)
			var/list/register_item = PN.build_shadow_solver_native_stateful_register_payload(solver)
			if(islist(register_item))
				register_payload += list(register_item)
		index++

	var/list/stateful_payload = list(
		"register" = register_payload,
		"solve" = batch_dynamic_payload
	)
	var/payload_json = json_encode(stateful_payload)
	if(!istext(payload_json) || !length(payload_json))
		return null

	var/raw = rustg_power_shadow_stateful_apply(payload_json)
	if(!istext(raw) || !length(raw))
		native_stateful_failure_streak++
		if(native_stateful_failure_streak >= 5)
			native_stateful_supported = FALSE
			log_debug("Power shadow native stateful batch disabled after repeated failures.")
		return null

	var/list/decoded = json_decode(raw)
	if(islist(decoded) && islist(decoded["results"]))
		decoded = decoded["results"]
	if(!islist(decoded))
		native_stateful_failure_streak++
		if(findtext(raw, "power_shadow_stateful_apply") || findtext(raw, "not found"))
			native_stateful_supported = FALSE
			log_debug("Power shadow native stateful batch disabled: rust-g power_shadow_stateful_apply is unavailable.")
		else if(native_stateful_failure_streak >= 5)
			native_stateful_supported = FALSE
			log_debug("Power shadow native stateful batch disabled after repeated decode failures.")
		return null

	native_stateful_failure_streak = 0
	var/list/snapshot_by_network = list()
	index = 1
	for(var/datum/powernet/PN in batch_targets)
		if(index > length(decoded))
			break
		var/list/snapshot = PN.decode_shadow_solver_native_snapshot(decoded[index])
		if(islist(snapshot))
			snapshot_by_network[PN] = snapshot
			PN.shadow_solver_native_stateful_registered_revision = PN.shadow_solver_native_topology_revision
		index++

	return snapshot_by_network


/datum/controller/subsystem/machines/proc/power_shadow_native_solve_batch(list/powernets_snapshot)
	var/static/native_many_supported = TRUE
	var/static/native_many_failure_streak = 0
	if(!islist(powernets_snapshot) || !length(powernets_snapshot))
		return null

	var/list/batch_targets = list()
	var/list/batch_payload = list()
	var/list/batch_dynamic_payload = list()
	for(var/datum/powernet/PN in powernets_snapshot)
		if(!PN || QDELETED(PN))
			continue
		if(!PN.shadow_solver_enabled || !PN.shadow_solver_native_enabled)
			continue
		var/datum/power_solver/solver = PN.ensure_shadow_solver()
		if(!istype(solver))
			continue
		var/list/dynamic_payload = PN.build_shadow_solver_native_stateful_dynamic_payload(solver)
		var/list/fallback_payload = PN.build_shadow_solver_native_payload_compact(solver)
		if(!islist(dynamic_payload) || !islist(fallback_payload))
			continue
		batch_targets += PN
		batch_dynamic_payload += list(dynamic_payload)
		batch_payload += list(fallback_payload)

	if(!length(batch_targets))
		return null

	var/list/stateful_snapshots = power_shadow_native_solve_batch_stateful(batch_targets, batch_dynamic_payload)
	if(islist(stateful_snapshots))
		return stateful_snapshots

	if(!native_many_supported)
		return null

	var/payload_json = json_encode(batch_payload)
	if(!istext(payload_json) || !length(payload_json))
		return null

	var/raw = rustg_power_shadow_solve_many(payload_json)
	if(!istext(raw) || !length(raw))
		native_many_failure_streak++
		if(native_many_failure_streak >= 5)
			native_many_supported = FALSE
			log_debug("Power shadow native batch disabled after repeated failures.")
		return null

	var/list/decoded = json_decode(raw)
	if(islist(decoded) && islist(decoded["results"]))
		decoded = decoded["results"]
	if(!islist(decoded))
		native_many_failure_streak++
		if(findtext(raw, "power_shadow_solve_many") || findtext(raw, "not found"))
			native_many_supported = FALSE
			log_debug("Power shadow native batch disabled: rust-g power_shadow_solve_many is unavailable.")
		else if(native_many_failure_streak >= 5)
			native_many_supported = FALSE
			log_debug("Power shadow native batch disabled after repeated decode failures.")
		return null

	native_many_failure_streak = 0
	var/list/snapshot_by_network = list()
	var/index = 1
	for(var/datum/powernet/PN in batch_targets)
		if(index > length(decoded))
			break
		var/list/snapshot = PN.decode_shadow_solver_native_snapshot(decoded[index])
		if(islist(snapshot))
			snapshot_by_network[PN] = snapshot
		index++

	return snapshot_by_network


/datum/controller/subsystem/machines/proc/power_shadow_native_autogate_probe(list/powernets_snapshot)
	if(!power_shadow_native_autogate_enabled)
		return
	if(!islist(powernets_snapshot) || !length(powernets_snapshot))
		return
	if(power_shadow_native_autogate_is_suspended())
		return
	if(world.time < power_shadow_native_autogate_next_probe_tick)
		return

	power_shadow_native_autogate_next_probe_tick = world.time + max(power_shadow_native_autogate_probe_interval, 1)
	var/list/sample_targets = list()
	for(var/datum/powernet/PN in powernets_snapshot)
		if(!PN || QDELETED(PN))
			continue
		if(!PN.shadow_solver_enabled || !PN.shadow_solver_native_enabled)
			continue
		sample_targets += PN
		if(length(sample_targets) >= 16)
			break
	if(!length(sample_targets))
		return

	var/timer_dm = "power_shadow_autogate_dm_[world.time]"
	rustg_time_reset(timer_dm)
	var/dm_samples = 0
	for(var/datum/powernet/PN in sample_targets)
		var/datum/power_solver/solver = PN.ensure_shadow_solver()
		if(!istype(solver))
			continue
		var/list/dm_snapshot = PN.get_shadow_solver_snapshot(solver, FALSE, FALSE)
		if(islist(dm_snapshot))
			dm_samples++
	var/dm_total_us = max(rustg_time_microseconds(timer_dm), 0)
	if(!dm_samples || dm_total_us <= 0)
		return
	var/dm_us = dm_total_us / dm_samples

	var/timer_batch = "power_shadow_autogate_batch_[world.time]"
	rustg_time_reset(timer_batch)
	var/list/batch_snapshot = power_shadow_native_solve_batch(sample_targets)
	var/batch_total_us = max(rustg_time_microseconds(timer_batch), 0)
	var/batch_samples = islist(batch_snapshot) ? length(batch_snapshot) : 0
	if(!batch_samples || batch_total_us <= 0)
		return
	var/batch_us = batch_total_us / batch_samples

	power_shadow_native_autogate_last_probe_dm_us = dm_us
	power_shadow_native_autogate_last_probe_batch_us = batch_us
	if(batch_us > dm_us)
		power_shadow_native_autogate_loss_streak++
	else
		power_shadow_native_autogate_loss_streak = 0

	if(power_shadow_native_autogate_loss_streak < max(power_shadow_native_autogate_trip_threshold, 1))
		return

	power_shadow_native_autogate_loss_streak = 0
	power_shadow_native_autogate_suspended_until = world.time + max(power_shadow_native_autogate_cooldown_ticks, 1)
	log_debug("Power shadow native autogate tripped: suspended native batch for [power_shadow_native_autogate_cooldown_ticks] ticks (probe dm_avg=[round(dm_us, 0.1)]us/sample, batch_avg=[round(batch_us, 0.1)]us/sample, sample_count=[dm_samples]).")


/datum/controller/subsystem/machines/proc/process_powernets(resumed, no_mc_tick)
	var/static/powernets_index = 0
	var/static/list/powernets_snapshot = list()
	var/static/list/power_shadow_batch_snapshots
	var/static/power_shadow_force_dm_fallback = FALSE
	if (!resumed)
		powernets_snapshot.Cut()
		power_shadow_batch_snapshots = null
		power_shadow_force_dm_fallback = FALSE
		powernet_last_snapshot_size = 0
		powernet_last_processed = 0
		powernet_last_skipped_null = 0
		powernet_last_removed_qdeleted = 0
		var/native_targets = 0
		for(var/datum/powernet/network as anything in powernets)
			if(!network)
				continue
			if(network.shadow_solver_enabled && network.shadow_solver_native_enabled)
				native_targets++
			powernets_snapshot += network
		powernet_last_snapshot_size = length(powernets_snapshot)
		if(native_targets)
			if(power_shadow_native_autogate_is_suspended())
				power_shadow_force_dm_fallback = TRUE
			else
				power_shadow_native_autogate_probe(powernets_snapshot)
				power_shadow_batch_snapshots = power_shadow_native_solve_batch(powernets_snapshot)
				if(!islist(power_shadow_batch_snapshots) || length(power_shadow_batch_snapshots) < native_targets)
					power_shadow_force_dm_fallback = TRUE
		else
			power_shadow_batch_snapshots = null
		if(world.time >= power_shadow_native_autogate_suspended_until && power_shadow_native_autogate_suspended_until)
			power_shadow_native_autogate_suspended_until = 0
			log_debug("Power shadow native autogate re-armed.")
		powernets_index = length(powernets_snapshot)
	var/datum/powernet/network
	for (var/i = powernets_index to 1 step -1)
		if(i > length(powernets_snapshot))
			continue
		network = powernets_snapshot[i]
		if(!network)
			powernet_last_skipped_null++
			continue
		if (QDELETED(network))
			if (network)
				network.is_processing = null
			powernets -= network
			powernet_last_removed_qdeleted++
			continue
		var/list/precomputed_shadow_snapshot
		if(!power_shadow_force_dm_fallback && islist(power_shadow_batch_snapshots))
			precomputed_shadow_snapshot = power_shadow_batch_snapshots[network]
		network.reset(wait, precomputed_shadow_snapshot, !power_shadow_force_dm_fallback)
		powernet_last_processed++
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			powernets_index = i - 1
			return
	powernets_index = 0
	powernets_snapshot.Cut()
	if(islist(power_shadow_batch_snapshots))
		power_shadow_batch_snapshots.Cut()
	power_shadow_batch_snapshots = null
	power_shadow_force_dm_fallback = FALSE
	if((powernet_last_skipped_null || powernet_last_removed_qdeleted) && world.time >= powernet_next_anomaly_log_time)
		log_debug("SSmachines powernet loop anomalies: snapshot=[powernet_last_snapshot_size], processed=[powernet_last_processed], null_skips=[powernet_last_skipped_null], qdeleted_removed=[powernet_last_removed_qdeleted]")
		powernet_next_anomaly_log_time = world.time + 600


/datum/controller/subsystem/machines/proc/process_power_objects(resumed, no_mc_tick)
	var/static/power_objects_index = 0
	if (!resumed)
		power_objects_index = length(power_objects)
	var/obj/item/item
	for (var/i = power_objects_index to 1 step -1)
		if(i > length(power_objects))
			continue
		item = power_objects[i]
		if (QDELETED(item))
			if (item)
				item.is_processing = null
			power_objects -= item
			continue
		if (!item.pwr_drain(wait))
			item.is_processing = null
			power_objects -= item
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			power_objects_index = i - 1
			return
	power_objects_index = 0
/datum/controller/subsystem/machines/proc/power_shadow_collect_anomalies(delta_threshold, unserved_threshold, list/target_powernets = null)
	var/list/powernets_to_check = islist(target_powernets) ? target_powernets : powernets
	var/list/problem_refs = list()
	var/list/problem_nets = list()
	var/problem_count = 0
	var/networks = 0

	for(var/datum/powernet/PN in powernets_to_check)
		networks++
		var/abs_delta = abs(PN.shadow_solver_avail_delta) + abs(PN.shadow_solver_load_delta)
		var/is_problem = FALSE
		if(PN.shadow_solver_mismatch)
			is_problem = TRUE
		if(abs_delta >= delta_threshold)
			is_problem = TRUE
		if(PN.is_shadow_solver_unserved_persistent(unserved_threshold))
			is_problem = TRUE
		if(!PN.evaluate_shadow_solver_acceptance() && PN.shadow_solver_acceptance_last_reason != "insufficient_samples")
			is_problem = TRUE

		if(!is_problem)
			continue

		problem_count++
		problem_nets += PN
		if(length(problem_refs) < 10)
			problem_refs += "\ref[PN]"

	return list(
		"networks" = networks,
		"problem_count" = problem_count,
		"problem_refs" = problem_refs,
		"problem_nets" = problem_nets
	)


/datum/controller/subsystem/machines/proc/power_shadow_apply_auto_repair(delta_threshold, unserved_threshold, do_rebuild = FALSE, list/target_powernets = null)
	var/list/collected = power_shadow_collect_anomalies(delta_threshold, unserved_threshold, target_powernets)
	var/list/problem_nets = collected["problem_nets"]
	var/list/problem_refs = collected["problem_refs"]
	var/problem_count = collected["problem_count"]
	var/networks = collected["networks"]

	var/retuned = 0
	var/backend_switched = 0
	for(var/datum/powernet/PN in problem_nets)
		var/abs_delta = abs(PN.shadow_solver_avail_delta) + abs(PN.shadow_solver_load_delta)
		var/scale_base = max(max(PN.avail, PN.shadow_solver_last_avail), max(PN.load, PN.shadow_solver_last_load))
		scale_base = max(scale_base, 10000)
		var/adaptive_threshold = max(PN.shadow_solver_mismatch_threshold, round(scale_base * 0.2), 5000)

		PN.shadow_solver_mismatch_threshold = adaptive_threshold
		PN.shadow_solver_guard_mismatch_threshold_override = adaptive_threshold
		PN.shadow_solver_acceptance_max_avg_load_delta = max(PN.shadow_solver_acceptance_max_avg_load_delta, round(adaptive_threshold * 1.5))
		PN.shadow_solver_acceptance_max_avg_avail_delta = max(PN.shadow_solver_acceptance_max_avg_avail_delta, round(adaptive_threshold * 1.5))
		PN.shadow_solver_acceptance_max_avg_unserved = max(PN.shadow_solver_acceptance_max_avg_unserved, round(adaptive_threshold * 0.8))

		if(PN.shadow_solver_backend == "shadow_fea" && abs_delta > adaptive_threshold * 2 && PN.shadow_solver_last_unserved > unserved_threshold)
			PN.set_shadow_solver_backend("strict_capacity_flow")
			backend_switched++

		PN.reset_shadow_solver_guard_state()
		PN.reset_shadow_solver_stats()
		if(hascall(PN, "mark_shadow_solver_topology_dirty"))
			call(PN, "mark_shadow_solver_topology_dirty")()
		retuned++

	var/rebuilt = 0
	var/rebuild_applied = FALSE
	if(do_rebuild && !islist(target_powernets))
		makepowernets()
		rebuild_applied = TRUE
		for(var/datum/powernet/NewPN in powernets)
			NewPN.reset_shadow_solver_stats()
			if(hascall(NewPN, "mark_shadow_solver_topology_dirty"))
				call(NewPN, "mark_shadow_solver_topology_dirty")()
			rebuilt++

	return list(
		"networks" = networks,
		"problem_count" = problem_count,
		"problem_refs" = problem_refs,
		"retuned" = retuned,
		"backend_switched" = backend_switched,
		"rebuilt" = rebuilt,
		"rebuild_applied" = rebuild_applied
	)


#undef SSMACHINES_PIPENETS
#undef SSMACHINES_MACHINERY
#undef SSMACHINES_POWERNETS
#undef SSMACHINES_POWER_OBJECTS
