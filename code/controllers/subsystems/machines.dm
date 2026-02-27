SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_MACHINERY
	flags = SS_KEEP_TIMING
	var/static/cost_machinery = 0
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
	var/static/profiling_apc_process = FALSE
	var/static/apc_process_profile_cycles = 0
	var/static/apc_process_profile_total_calls = 0
	var/static/apc_process_profile_measured_calls = 0
	var/static/apc_process_profile_skipped_calls = 0
	var/static/apc_process_profile_bucket_usage_ms = 0
	var/static/apc_process_profile_bucket_power_state_ms = 0
	var/static/apc_process_profile_bucket_channels_logic_ms = 0
	var/static/apc_process_profile_bucket_output_ms = 0
	/// Auto-stop APC micro-profiling when cycles sampled reaches this value. 0 disables auto-stop.
	var/static/profiling_apc_cycle_limit = 0
	/// Set to TRUE when APC profiling was auto-stopped at the cycle limit.
	var/static/apc_profile_auto_stopped = FALSE
	/// Runtime fallback switch for event-driven processing of docking embedded controllers.
	var/static/optimize_embedded_docking_event = TRUE
	/// Runtime fallback switch for event-driven machinery changes in this branch.
	var/static/optimize_machinery_event = TRUE
	var/static/list/processing = list()
	var/static/list/processing_lazy = list()
	var/static/processing_lazy_slice_n = 4
	var/static/processing_lazy_cursor = 0
	var/static/list/machinery = list()
	var/static/list/machinery_by_type = list()
	/// Cache of `typesof(base_type)` lookups to avoid repeated hierarchy expansion in hot paths.
	var/static/list/machinery_type_cache = list()

/datum/controller/subsystem/machines/Recover()
	processing_lazy_cursor = 0

/datum/controller/subsystem/machines/Initialize(start_uptime)
	if(SSpowernets)
		SSpowernets.makepowernets()
	if(SSpipenets)
		SSpipenets.setup_atmos_machinery(machinery)
	if(SSpipenets)
		SSpipenets.fire(FALSE, TRUE)
	if(SSpowernets)
		SSpowernets.fire(FALSE, TRUE)

/datum/controller/subsystem/machines/fire(resumed, no_mc_tick)
	var/timer = world.tick_usage
	process_machinery(resumed, no_mc_tick)
	cost_machinery = MC_AVERAGE(cost_machinery, (world.tick_usage - timer) * world.tick_lag)

/datum/controller/subsystem/machines/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()

	var/pipes_len = SSpipenets ? length(SSpipenets.pipenets) : 0
	var/powernets_len = SSpowernets ? length(SSpowernets.powernets) : 0
	var/power_objects_len = SSpowernets ? length(SSpowernets.power_objects) : 0
	var/cost_pipenets = SSpipenets ? SSpipenets.cost_pipenets : 0
	var/cost_powernets = SSpowernets ? SSpowernets.cost_powernets : 0
	var/cost_power_objects = SSpowernets ? SSpowernets.cost_power_objects : 0
	var/powernet_last_snapshot_size = SSpowernets ? SSpowernets.powernet_last_snapshot_size : 0
	var/powernet_last_processed = SSpowernets ? SSpowernets.powernet_last_processed : 0
	var/powernet_last_skipped_null = SSpowernets ? SSpowernets.powernet_last_skipped_null : 0
	var/powernet_last_removed_qdeleted = SSpowernets ? SSpowernets.powernet_last_removed_qdeleted : 0
	var/power_shadow_native_autogate_loss_streak = SSpowernets ? SSpowernets.power_shadow_native_autogate_loss_streak : 0
	var/power_shadow_native_autogate_last_probe_dm_us = SSpowernets ? SSpowernets.power_shadow_native_autogate_last_probe_dm_us : 0
	var/power_shadow_native_autogate_last_probe_batch_us = SSpowernets ? SSpowernets.power_shadow_native_autogate_last_probe_batch_us : 0

	var/autogate_state = "off"
	if(SSpowernets && SSpowernets.power_shadow_native_autogate_enabled)
		if(world.time < SSpowernets.power_shadow_native_autogate_suspended_until)
			autogate_state = "cooldown [SSpowernets.power_shadow_native_autogate_suspended_until - world.time]"
		else
			autogate_state = "armed"

	..({"\
		Queues: \
		Pipes [pipes_len] \
		Machines [length(processing)] \
		Lazy [length(processing_lazy)] \
		Networks [powernets_len] \
		Objects [power_objects_len]\n\
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

	var/list/type_tree = machinery_type_cache[machinery_type]
	if(!islist(type_tree))
		type_tree = typesof(machinery_type)
		machinery_type_cache[machinery_type] = type_tree

	var/list/matching_machines = list()
	for(var/type in type_tree)
		var/list/machinery_of_type = machinery_by_type[type]
		if(machinery_of_type)
			matching_machines += machinery_of_type

	return matching_machines

/datum/controller/subsystem/machines/proc/get_all_machinery()
	return machinery.Copy()
/datum/controller/subsystem/machines/proc/process_machinery(resumed, no_mc_tick)
	var/static/machinery_index = 0
	var/static/processing_lazy_index = 0
	var/processing_len = length(processing)
	var/processing_lazy_len = length(processing_lazy)
	if(!resumed && !processing_len && !processing_lazy_len && !profiling_machinery && !profiling_air_alarm_process && !profiling_apc_process)
		machinery_index = 0
		processing_lazy_index = 0
		return
	if (!resumed)
		machinery_index = processing_len
	var/obj/machinery/machine
	var/profile_timer
	for (var/i = machinery_index to 1 step -1)
		if(i > processing_len)
			processing_len = length(processing)
			if(i > processing_len)
				continue
		machine = processing[i]
		if(!machine)
			continue
		if (QDELETED(machine))
			if (machine)
				machine.is_processing = null
			processing -= machine
			processing_len = max(processing_len - 1, 0)
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
	if(profiling_apc_process)
		apc_process_profile_cycles++
		if(profiling_apc_cycle_limit > 0 && apc_process_profile_cycles >= profiling_apc_cycle_limit)
			profiling_apc_process = FALSE
			apc_profile_auto_stopped = TRUE
	machinery_index = 0

	// Lazy processing: process 1/processing_lazy_slice_n of processing_lazy per fire cycle.
	// Uses a rotating cursor so each machine is visited every processing_lazy_slice_n fires (~8s at default wait=2s).
	if (processing_lazy_len)
		if (processing_lazy_index == 0)
			if (processing_lazy_cursor >= processing_lazy_len)
				processing_lazy_cursor = 0
			var/slice_size = max(1, round(processing_lazy_len / processing_lazy_slice_n))
			processing_lazy_index = min(processing_lazy_cursor + slice_size, processing_lazy_len)
		var/obj/machinery/lmachine
		for (var/i = processing_lazy_index to processing_lazy_cursor + 1 step -1)
			if (i > processing_lazy_len)
				processing_lazy_len = length(processing_lazy)
				if(i > processing_lazy_len)
					continue
			lmachine = processing_lazy[i]
			if(!lmachine)
				continue
			if (QDELETED(lmachine))
				if (lmachine)
					lmachine.is_processing = null
				processing_lazy -= lmachine
				processing_lazy_len = max(processing_lazy_len - 1, 0)
				continue
			if (lmachine.Process(wait) == PROCESS_KILL)
				lmachine.is_processing = null
				processing_lazy -= lmachine
				processing_lazy_len = max(processing_lazy_len - 1, 0)
				continue
			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				processing_lazy_index = i - 1
				return
		processing_lazy_cursor = min(processing_lazy_index, processing_lazy_len)
		if (processing_lazy_cursor >= processing_lazy_len)
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


/datum/controller/subsystem/machines/proc/reset_apc_process_profiling()
	apc_process_profile_cycles = 0
	apc_process_profile_total_calls = 0
	apc_process_profile_measured_calls = 0
	apc_process_profile_skipped_calls = 0
	apc_process_profile_bucket_usage_ms = 0
	apc_process_profile_bucket_power_state_ms = 0
	apc_process_profile_bucket_channels_logic_ms = 0
	apc_process_profile_bucket_output_ms = 0
	apc_profile_auto_stopped = FALSE


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


/datum/controller/subsystem/machines/proc/report_apc_process_profiling()
	var/total_calls = apc_process_profile_total_calls
	if(!total_calls)
		return "No APC profiling data collected."

	var/measured_calls = apc_process_profile_measured_calls
	var/skipped_calls = apc_process_profile_skipped_calls
	var/bucket_a_ms = apc_process_profile_bucket_usage_ms
	var/bucket_b_ms = apc_process_profile_bucket_power_state_ms
	var/bucket_c_ms = apc_process_profile_bucket_channels_logic_ms
	var/bucket_d_ms = apc_process_profile_bucket_output_ms
	var/total_measured_ms = bucket_a_ms + bucket_b_ms + bucket_c_ms + bucket_d_ms
	var/avg_bucket_a_ms = measured_calls ? round(bucket_a_ms / measured_calls, 0.001) : 0
	var/avg_bucket_b_ms = measured_calls ? round(bucket_b_ms / measured_calls, 0.001) : 0
	var/avg_bucket_c_ms = measured_calls ? round(bucket_c_ms / measured_calls, 0.001) : 0
	var/avg_bucket_d_ms = measured_calls ? round(bucket_d_ms / measured_calls, 0.001) : 0
	var/avg_total_ms = measured_calls ? round(total_measured_ms / measured_calls, 0.001) : 0
	var/share_bucket_a = total_measured_ms ? round((bucket_a_ms / total_measured_ms) * 100, 0.1) : 0
	var/share_bucket_b = total_measured_ms ? round((bucket_b_ms / total_measured_ms) * 100, 0.1) : 0
	var/share_bucket_c = total_measured_ms ? round((bucket_c_ms / total_measured_ms) * 100, 0.1) : 0
	var/share_bucket_d = total_measured_ms ? round((bucket_d_ms / total_measured_ms) * 100, 0.1) : 0
	var/calls_per_cycle = apc_process_profile_cycles ? round(total_calls / apc_process_profile_cycles, 0.1) : total_calls
	var/measured_per_cycle = apc_process_profile_cycles ? round(measured_calls / apc_process_profile_cycles, 0.1) : measured_calls

	var/list/lines = list()
	lines += "<h3>APC Process Micro-Profiling</h3>"
	lines += "<b>Cycles sampled:</b> [apc_process_profile_cycles] | <b>Total calls:</b> [total_calls] ([calls_per_cycle]/cyc) | <b>Measured calls:</b> [measured_calls] ([measured_per_cycle]/cyc) | <b>Skipped calls:</b> [skipped_calls]<br>"
	lines += "<b>Total measured time:</b> [round(total_measured_ms, 0.01)]ms | <b>Average measured per call:</b> [avg_total_ms]ms<br>"
	lines += "<table border='1' cellpadding='3' cellspacing='0'>"
	lines += "<tr><th>Bucket</th><th>Description</th><th>Total (ms)</th><th>Avg (ms/call)</th><th>Share</th></tr>"
	lines += "<tr><td>A</td><td>Area usage snapshot + clear usage</td><td>[round(bucket_a_ms, 0.01)]</td><td>[avg_bucket_a_ms]</td><td>[share_bucket_a]%</td></tr>"
	lines += "<tr><td>B</td><td>Powernet/cell state + charge logic</td><td>[round(bucket_b_ms, 0.01)]</td><td>[avg_bucket_b_ms]</td><td>[share_bucket_b]%</td></tr>"
	lines += "<tr><td>C</td><td>update_channels() logic</td><td>[round(bucket_c_ms, 0.01)]</td><td>[avg_bucket_c_ms]</td><td>[share_bucket_c]%</td></tr>"
	lines += "<tr><td>D</td><td>Area/icon/output updates</td><td>[round(bucket_d_ms, 0.01)]</td><td>[avg_bucket_d_ms]</td><td>[share_bucket_d]%</td></tr>"
	lines += "</table>"
	lines += "<small>Skipped calls are early exits before main APC state processing.</small>"
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

/// Compatibility shim: delegated to SSpipenets.
/datum/controller/subsystem/machines/proc/process_pipenets(resumed, no_mc_tick)
	return SSpipenets.process_pipenets(resumed, no_mc_tick)

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/process_powernets(resumed, no_mc_tick)
	return SSpowernets.process_powernets(resumed, no_mc_tick)

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/process_power_objects(resumed, no_mc_tick)
	return SSpowernets.process_power_objects(resumed, no_mc_tick)

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/makepowernets()
	return SSpowernets.makepowernets()

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/setup_powernets_for_cables(list/cables)
	return SSpowernets.setup_powernets_for_cables(cables)

/// Compatibility shim: delegated to SSpipenets.
/datum/controller/subsystem/machines/proc/setup_atmos_machinery(list/machines)
	return SSpipenets.setup_atmos_machinery(machines)

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/reset_power_shadow_native_batch_perf()
	return SSpowernets.reset_power_shadow_native_batch_perf()

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/record_power_shadow_native_batch_perf(build_us, encode_us, call_us, decode_us, samples = 1)
	return SSpowernets.record_power_shadow_native_batch_perf(build_us, encode_us, call_us, decode_us, samples)

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/get_power_shadow_native_batch_perf_data()
	return SSpowernets.get_power_shadow_native_batch_perf_data()

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/power_shadow_native_should_skip_batch_target(datum/powernet/PN)
	return SSpowernets.power_shadow_native_should_skip_batch_target(PN)

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/power_shadow_native_autogate_is_suspended()
	return SSpowernets.power_shadow_native_autogate_is_suspended()

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/power_shadow_native_solve_batch_stateful(list/batch_targets, list/batch_dynamic_payload, list/phase_accumulator = null, use_compact_payload = TRUE, use_legacy_id = FALSE)
	return SSpowernets.power_shadow_native_solve_batch_stateful(batch_targets, batch_dynamic_payload, phase_accumulator, use_compact_payload, use_legacy_id)

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/power_shadow_native_solve_batch(list/powernets_snapshot, collect_phase_perf = TRUE)
	return SSpowernets.power_shadow_native_solve_batch(powernets_snapshot, collect_phase_perf)

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/power_shadow_native_autogate_probe(list/powernets_snapshot)
	return SSpowernets.power_shadow_native_autogate_probe(powernets_snapshot)

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/power_shadow_collect_anomalies(delta_threshold, unserved_threshold, list/target_powernets = null)
	return SSpowernets.power_shadow_collect_anomalies(delta_threshold, unserved_threshold, target_powernets)

/// Compatibility shim: delegated to SSpowernets.
/datum/controller/subsystem/machines/proc/power_shadow_apply_auto_repair(delta_threshold, unserved_threshold, do_rebuild = FALSE, list/target_powernets = null)
	return SSpowernets.power_shadow_apply_auto_repair(delta_threshold, unserved_threshold, do_rebuild, target_powernets)
