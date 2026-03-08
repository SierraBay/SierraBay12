/datum/power_solver
	var/backend_id = "base"
	var/backend_name = "Base Solver"

/datum/power_solver/shadow_fea
	backend_id = "shadow_fea"
	backend_name = "Shadow FEA"
	var/last_total_supply = 0
	var/last_primary_demand = 0
	var/last_deferred_demand = 0
	var/last_served_primary = 0
	var/last_served_deferred = 0
	var/last_unserved = 0

/datum/power_solver/shadow_fea/proc/solve_shadow_fea(datum/powernet/net)
	if(!istype(net))
		return list("avail" = 0, "load" = 0, "comparison_avail" = 0, "comparison_load" = 0, "unserved" = 0, "deferred_unserved" = 0, "total_unserved" = 0, "primary_demand" = 0, "served_primary" = 0)

	var/smes_supply = 0
	var/primary_demand = 0
	var/deferred_demand = 0

	if(net.nodes && length(net.nodes))
		for(var/obj/machinery/power/node in net.nodes)
			var/list/profile = node.power_solver_shadow_profile()
			if(!islist(profile))
				continue
			primary_demand += max(profile["primary_demand"], 0)
			deferred_demand += max(profile["deferred_demand"], 0)
			smes_supply += max(profile["supply"], 0)

	var/base_supply = max(net.avail - max(net.smes_avail, smes_supply), 0)

	var/total_supply = max(base_supply + smes_supply, 0)
	var/served_primary = min(total_supply, primary_demand)
	var/remaining_supply = max(total_supply - served_primary, 0)
	var/served_deferred = min(remaining_supply, deferred_demand)
	var/predicted_load = max(served_primary + served_deferred, 0)
	var/comparison_avail = max(net.avail, 0)
	var/comparison_load = max(served_primary, 0)
	var/unserved = max(primary_demand - served_primary, 0)
	var/deferred_unserved = max(deferred_demand - served_deferred, 0)
	var/total_unserved = unserved + deferred_unserved

	last_total_supply = total_supply
	last_primary_demand = primary_demand
	last_deferred_demand = deferred_demand
	last_served_primary = served_primary
	last_served_deferred = served_deferred
	last_unserved = unserved

	return list(
		"avail" = total_supply,
		"load" = predicted_load,
		"comparison_avail" = comparison_avail,
		"comparison_load" = comparison_load,
		"unserved" = unserved,
		"deferred_unserved" = deferred_unserved,
		"total_unserved" = total_unserved,
		"primary_demand" = primary_demand,
		"served_primary" = served_primary
	)

/datum/power_solver/strict_capacity_flow
	backend_id = "strict_capacity_flow"
	backend_name = "Strict Capacity Flow"

/datum/power_solver/strict_capacity_flow/proc/solve_strict_capacity_flow(datum/powernet/net)
	if(!istype(net))
		return list("avail" = 0, "load" = 0, "comparison_avail" = 0, "comparison_load" = 0, "unserved" = 0, "deferred_unserved" = 0, "total_unserved" = 0, "primary_demand" = 0, "served_primary" = 0)

	var/smes_supply = 0
	var/primary_demand = 0
	var/deferred_demand = 0

	if(net.nodes && length(net.nodes))
		for(var/obj/machinery/power/node in net.nodes)
			var/list/profile = node.power_solver_shadow_profile()
			if(!islist(profile))
				continue
			primary_demand += max(profile["primary_demand"], 0)
			deferred_demand += max(profile["deferred_demand"], 0)
			smes_supply += max(profile["supply"], 0)

	var/base_supply = max(net.avail - max(net.smes_avail, smes_supply), 0)

	var/total_supply = max(base_supply + smes_supply, 0)
	var/served_primary = min(total_supply, primary_demand)
	var/predicted_load = max(served_primary, 0)
	var/comparison_avail = max(net.avail, 0)
	var/comparison_load = predicted_load
	var/unserved = max(primary_demand - served_primary, 0)
	var/deferred_unserved = deferred_demand
	var/total_unserved = unserved + deferred_unserved

	return list(
		"avail" = total_supply,
		"load" = predicted_load,
		"comparison_avail" = comparison_avail,
		"comparison_load" = comparison_load,
		"unserved" = unserved,
		"deferred_unserved" = deferred_unserved,
		"total_unserved" = total_unserved,
		"primary_demand" = primary_demand,
		"served_primary" = served_primary
	)

#define POWER_SHADOW_NATIVE_NODE_SUPPLY 1
#define POWER_SHADOW_NATIVE_NODE_PRIMARY_DEMAND 2
#define POWER_SHADOW_NATIVE_NODE_DEFERRED_DEMAND 3

#define POWER_SHADOW_NATIVE_PAYLOAD_BACKEND 1
#define POWER_SHADOW_NATIVE_PAYLOAD_AVAIL 2
#define POWER_SHADOW_NATIVE_PAYLOAD_SMES_AVAIL 3
#define POWER_SHADOW_NATIVE_PAYLOAD_NODES 4

#define POWER_SHADOW_NATIVE_RESULT_AVAIL 1
#define POWER_SHADOW_NATIVE_RESULT_LOAD 2
#define POWER_SHADOW_NATIVE_RESULT_COMPARISON_AVAIL 3
#define POWER_SHADOW_NATIVE_RESULT_COMPARISON_LOAD 4
#define POWER_SHADOW_NATIVE_RESULT_UNSERVED 5
#define POWER_SHADOW_NATIVE_RESULT_DEFERRED_UNSERVED 6
#define POWER_SHADOW_NATIVE_RESULT_TOTAL_UNSERVED 7
#define POWER_SHADOW_NATIVE_RESULT_PRIMARY_DEMAND 8
#define POWER_SHADOW_NATIVE_RESULT_SERVED_PRIMARY 9

/datum/powernet
	var/list/cables = list()	// all cables & junctions
	var/list/nodes = list()		// all connected machines

	var/load = 0				// the current load on the powernet, increased by each machine at processing
	var/newavail = 0			// what available power was gathered last tick, then becomes...
	var/avail = 0				//...the current available power in the powernet
	var/viewload = 0			// the load as it appears on the power console (gradually updated)
	var/number = 0				// Unused //TODEL

	var/smes_demand = 0			// Amount of power demanded by all SMESs from this network. Needed for load balancing.
	var/list/inputting = list()	// List of SMESs that are demanding power from this network. Needed for load balancing.

	var/smes_avail = 0			// Amount of power (avail) from SMESes. Used by SMES load balancing
	var/smes_newavail = 0		// As above, just for newavail

	var/perapc = 0			// per-apc avilability
	var/perapc_excess = 0
	var/netexcess = 0			// excess power on the powernet (typically avail-load)

	var/problem = 0				// If this is not 0 there is some sort of issue in the powernet. Monitors will display warnings.

	var/shadow_solver_enabled = TRUE
	var/shadow_solver_backend = "shadow_fea"
	var/shadow_solver_native_enabled = FALSE
	var/shadow_solver_native_topology_revision = 1
	var/shadow_solver_native_stateful_registered_revision = -1
	var/shadow_solver_native_stateful_id = 0
	var/static/shadow_solver_native_stateful_next_id = 1
	var/datum/power_solver/shadow_solver
	var/shadow_solver_write_enabled = TRUE
	var/shadow_solver_write_mode = "fea_only"
	var/shadow_solver_force_fea_only = TRUE
	var/shadow_solver_last_smes_input_source = "legacy"
	var/shadow_solver_last_smes_input_percentage = -1
	var/shadow_solver_last_apc_advisory_scale = 1
	var/shadow_solver_last_apc_advisory_perapc = 0
	var/shadow_solver_last_apc_advisory_primary_demand = 0
	var/shadow_solver_last_apc_advisory_served_primary = 0
	var/shadow_solver_last_apc_count = 0
	var/shadow_solver_apc_advisory_valid = FALSE
	var/shadow_solver_apc_cap_floor_ratio = 0.35
	var/shadow_solver_last_apc_enforced_floor = 0
	var/shadow_solver_last_apc_enforced_budget = 0
	var/shadow_solver_last_avail = 0
	var/shadow_solver_last_load = 0
	var/shadow_solver_last_unserved = 0
	var/shadow_solver_last_deferred_unserved = 0
	var/shadow_solver_last_total_unserved = 0
	var/shadow_solver_avail_delta = 0
	var/shadow_solver_load_delta = 0
	var/shadow_solver_mismatch_threshold = 5000
	var/shadow_solver_mismatch = FALSE
	var/shadow_solver_next_log = 0
	var/shadow_solver_guard_enabled = TRUE
	var/shadow_solver_guard_consecutive_mismatch = 0
	var/shadow_solver_guard_trip_threshold = 5
	var/shadow_solver_guard_mismatch_threshold_override = 0
	var/shadow_solver_guard_cooldown_ticks = 300
	var/shadow_solver_guard_suspended_until = 0
	var/shadow_solver_guard_rollback_events = 0
	var/shadow_solver_guard_last_reason = "none"
	var/shadow_solver_guard_last_rollback_time = 0
	var/shadow_solver_unserved_consecutive_ticks = 0
	var/shadow_solver_unserved_trip_ticks = 5
	var/shadow_solver_acceptance_min_samples = 50
	var/shadow_solver_acceptance_max_mismatch_rate = 12.5
	var/shadow_solver_acceptance_max_avg_load_delta = 12000
	var/shadow_solver_acceptance_max_avg_avail_delta = 12000
	var/shadow_solver_acceptance_max_avg_unserved = 8000
	var/shadow_solver_acceptance_last_pass = FALSE
	var/shadow_solver_acceptance_last_reason = "insufficient_samples"
	var/shadow_solver_stats_started_at = 0
	var/shadow_solver_stats_samples = 0
	var/shadow_solver_stats_mismatches = 0
	var/shadow_solver_stats_abs_load_delta_sum = 0
	var/shadow_solver_stats_abs_avail_delta_sum = 0
	var/shadow_solver_stats_unserved_sum = 0
	var/shadow_solver_native_compact_supported = TRUE
	var/shadow_solver_native_perf_samples = 0
	var/shadow_solver_native_perf_build_us_sum = 0
	var/shadow_solver_native_perf_encode_us_sum = 0
	var/shadow_solver_native_perf_call_us_sum = 0
	var/shadow_solver_native_perf_decode_us_sum = 0
	var/list/shadow_solver_native_nodes_payload_named_cache
	var/list/shadow_solver_native_nodes_payload_compact_cache
	var/shadow_solver_native_nodes_payload_cache_tick = -1
	var/shadow_solver_native_nodes_payload_cache_valid = FALSE
	var/shadow_solver_cache_enabled = TRUE
	var/shadow_solver_cache_valid = FALSE
	var/list/shadow_solver_cache_snapshot
	var/shadow_solver_cache_timestamp = 0
	var/shadow_solver_cache_hits = 0
	var/shadow_solver_cache_misses = 0
	var/shadow_solver_cache_max_age_ticks = 30
	var/shadow_solver_cache_stability_threshold = 1500
	var/shadow_solver_cache_significant_threshold = 2500
	var/shadow_solver_cache_min_stable_ticks = 2
	var/shadow_solver_cache_stable_ticks = 0
	var/shadow_solver_cache_last_avail = 0
	var/shadow_solver_cache_last_load = 0
	var/shadow_solver_cache_last_smes_demand = 0
	var/shadow_solver_cache_last_inputting_count = 0
	var/shadow_solver_cache_last_numapc = 0
	var/shadow_solver_cache_topology_dirty = TRUE
	var/shadow_solver_cache_tick_dirty = TRUE
	var/apc_terminal_count = 0
	var/apc_terminal_count_dirty = TRUE

/datum/powernet/New()
	START_PROCESSING_POWERNET(src)
	enforce_fea_only_mode()
	if(!shadow_solver_native_stateful_id)
		shadow_solver_native_stateful_id = shadow_solver_native_stateful_next_id++
	..()

/datum/powernet/Destroy()
	for(var/obj/structure/cable/C in cables)
		cables -= C
		C.powernet = null
	for(var/obj/machinery/power/M in nodes)
		nodes -= M
		M.powernet = null
	STOP_PROCESSING_POWERNET(src)
	return ..()

//Returns the amount of excess power (before refunding to SMESs) from last tick.
//This is for machines that might adjust their power consumption using this data.
/datum/powernet/proc/last_surplus()
	return max(avail - load, 0)

/datum/powernet/proc/draw_power(amount)
	var/draw = clamp(amount, 0, avail - load)
	load += draw
	return draw

/datum/powernet/proc/is_empty()
	return !length(cables) && !length(nodes)

//remove a cable from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/remove_cable(obj/structure/cable/C)
	cables -= C
	C.powernet = null
	mark_shadow_solver_topology_dirty()
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it

//add a cable to the current powernet
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/add_cable(obj/structure/cable/C)
	if(C.powernet)// if C already has a powernet...
		if(C.powernet == src)
			return
		else
			C.powernet.remove_cable(C) //..remove it
	C.powernet = src
	cables +=C
	mark_shadow_solver_topology_dirty()

//remove a power machine from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/remove_machine(obj/machinery/power/M)
	nodes -=M
	M.powernet = null
	mark_shadow_solver_topology_dirty()
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it - qdel


//add a power machine to the current powernet
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/add_machine(obj/machinery/power/M)
	if(M.powernet)// if M already has a powernet...
		if(M.powernet == src)
			return
		else
			M.disconnect_from_network()//..remove it
	M.powernet = src
	nodes[M] = M
	mark_shadow_solver_topology_dirty()

// Triggers warning for certain amount of ticks
/datum/powernet/proc/trigger_warning(duration_ticks = 20)
	problem = max(duration_ticks, problem)

/datum/powernet/proc/update_shadow_solver_metrics(shadow_avail, shadow_load, shadow_unserved = 0, shadow_deferred_unserved = 0, shadow_total_unserved = -1)
	if(!shadow_solver_enabled)
		return
	shadow_solver_last_avail = max(shadow_avail, 0)
	shadow_solver_last_load = max(shadow_load, 0)
	shadow_solver_last_unserved = max(shadow_unserved, 0)
	shadow_solver_last_deferred_unserved = max(shadow_deferred_unserved, 0)
	if(shadow_total_unserved < 0)
		shadow_solver_last_total_unserved = shadow_solver_last_unserved + shadow_solver_last_deferred_unserved
	else
		shadow_solver_last_total_unserved = max(shadow_total_unserved, 0)
	var/unserved_threshold = max(get_shadow_solver_guard_threshold(), 1)
	if(shadow_solver_last_unserved >= unserved_threshold)
		shadow_solver_unserved_consecutive_ticks++
	else
		shadow_solver_unserved_consecutive_ticks = 0
	shadow_solver_avail_delta = shadow_solver_last_avail - avail
	shadow_solver_load_delta = shadow_solver_last_load - load
	shadow_solver_mismatch = abs(shadow_solver_avail_delta) > shadow_solver_mismatch_threshold \
		|| abs(shadow_solver_load_delta) > shadow_solver_mismatch_threshold \
		|| shadow_solver_last_unserved > shadow_solver_mismatch_threshold
	update_shadow_solver_stats()

/datum/powernet/proc/is_shadow_solver_unserved_persistent(unserved_threshold = 0)
	var/threshold = unserved_threshold > 0 ? max(round(unserved_threshold), 1) : max(get_shadow_solver_guard_threshold(), 1)
	if(shadow_solver_last_unserved < threshold)
		return FALSE
	return shadow_solver_unserved_consecutive_ticks >= max(shadow_solver_unserved_trip_ticks, 1)

/datum/powernet/proc/update_shadow_solver_stats()
	if(!shadow_solver_stats_started_at)
		shadow_solver_stats_started_at = world.time

	shadow_solver_stats_samples++
	shadow_solver_stats_abs_load_delta_sum += abs(shadow_solver_load_delta)
	shadow_solver_stats_abs_avail_delta_sum += abs(shadow_solver_avail_delta)
	shadow_solver_stats_unserved_sum += shadow_solver_last_unserved
	if(shadow_solver_mismatch)
		shadow_solver_stats_mismatches++

/datum/powernet/proc/reset_shadow_solver_stats()
	shadow_solver_stats_started_at = world.time
	shadow_solver_stats_samples = 0
	shadow_solver_stats_mismatches = 0
	shadow_solver_stats_abs_load_delta_sum = 0
	shadow_solver_stats_abs_avail_delta_sum = 0
	shadow_solver_stats_unserved_sum = 0
	shadow_solver_native_compact_supported = TRUE
	shadow_solver_native_perf_samples = 0
	shadow_solver_native_perf_build_us_sum = 0
	shadow_solver_native_perf_encode_us_sum = 0
	shadow_solver_native_perf_call_us_sum = 0
	shadow_solver_native_perf_decode_us_sum = 0
	invalidate_shadow_solver_native_payload_cache()
	shadow_solver_cache_hits = 0
	shadow_solver_cache_misses = 0

/datum/powernet/proc/record_shadow_solver_native_perf(build_us, encode_us, call_us, decode_us)
	shadow_solver_native_perf_samples++
	shadow_solver_native_perf_build_us_sum += max(build_us, 0)
	shadow_solver_native_perf_encode_us_sum += max(encode_us, 0)
	shadow_solver_native_perf_call_us_sum += max(call_us, 0)
	shadow_solver_native_perf_decode_us_sum += max(decode_us, 0)

/datum/powernet/proc/reset_shadow_solver_native_perf()
	shadow_solver_native_perf_samples = 0
	shadow_solver_native_perf_build_us_sum = 0
	shadow_solver_native_perf_encode_us_sum = 0
	shadow_solver_native_perf_call_us_sum = 0
	shadow_solver_native_perf_decode_us_sum = 0

/datum/powernet/proc/invalidate_shadow_solver_native_payload_cache()
	shadow_solver_native_nodes_payload_named_cache = null
	shadow_solver_native_nodes_payload_compact_cache = null
	shadow_solver_native_nodes_payload_cache_tick = -1
	shadow_solver_native_nodes_payload_cache_valid = FALSE

/datum/powernet/proc/invalidate_shadow_solver_cache()
	shadow_solver_cache_valid = FALSE
	shadow_solver_cache_snapshot = null
	shadow_solver_cache_timestamp = 0
	shadow_solver_cache_stable_ticks = 0

/datum/powernet/proc/invalidate_apc_advisory()
	shadow_solver_apc_advisory_valid = FALSE
	shadow_solver_last_apc_advisory_scale = 1
	shadow_solver_last_apc_advisory_perapc = 0
	shadow_solver_last_apc_advisory_primary_demand = 0
	shadow_solver_last_apc_advisory_served_primary = 0
	shadow_solver_last_apc_count = 0
	shadow_solver_last_apc_enforced_floor = 0
	shadow_solver_last_apc_enforced_budget = 0

/datum/powernet/proc/mark_shadow_solver_topology_dirty()
	shadow_solver_cache_topology_dirty = TRUE
	shadow_solver_cache_tick_dirty = TRUE
	apc_terminal_count_dirty = TRUE
	invalidate_apc_advisory()
	shadow_solver_native_topology_revision++
	shadow_solver_native_stateful_registered_revision = -1
	invalidate_shadow_solver_native_payload_cache()
	invalidate_shadow_solver_cache()

/datum/powernet/proc/get_apc_terminal_count()
	if(!apc_terminal_count_dirty)
		return apc_terminal_count

	var/count = 0
	if(nodes && length(nodes))
		for(var/obj/machinery/power/terminal/term in nodes)
			if(istype(term.master_machine(), /obj/machinery/power/apc))
				count++

	apc_terminal_count = count
	apc_terminal_count_dirty = FALSE
	return apc_terminal_count

/datum/powernet/proc/mark_shadow_solver_tick_dirty()
	shadow_solver_cache_tick_dirty = TRUE

/datum/powernet/proc/update_shadow_solver_stability_baseline(numapc)
	shadow_solver_cache_last_avail = avail
	shadow_solver_cache_last_load = load
	shadow_solver_cache_last_smes_demand = smes_demand
	shadow_solver_cache_last_inputting_count = length(inputting)
	shadow_solver_cache_last_numapc = max(numapc, 0)
	shadow_solver_cache_topology_dirty = FALSE

/datum/powernet/proc/is_shadow_solver_zone_stable(numapc)
	if(shadow_solver_cache_topology_dirty)
		return FALSE
	if(shadow_solver_cache_tick_dirty)
		return FALSE
	if(abs(avail - shadow_solver_cache_last_avail) > shadow_solver_cache_stability_threshold)
		return FALSE
	if(abs(load - shadow_solver_cache_last_load) > shadow_solver_cache_stability_threshold)
		return FALSE
	if(abs(smes_demand - shadow_solver_cache_last_smes_demand) > shadow_solver_cache_stability_threshold)
		return FALSE
	if(length(inputting) != shadow_solver_cache_last_inputting_count)
		return FALSE
	if(max(numapc, 0) != shadow_solver_cache_last_numapc)
		return FALSE
	return TRUE

/datum/powernet/proc/should_use_cached_shadow_solver_snapshot(numapc)
	if(!shadow_solver_cache_enabled || !shadow_solver_cache_valid)
		return FALSE
	if(world.time - shadow_solver_cache_timestamp > max(shadow_solver_cache_max_age_ticks, 1))
		return FALSE
	if(shadow_solver_cache_stable_ticks < max(shadow_solver_cache_min_stable_ticks, 0))
		return FALSE
	if(!is_shadow_solver_zone_stable(numapc))
		return FALSE
	return TRUE

/datum/powernet/proc/is_shadow_solver_snapshot_significant(list/snapshot)
	if(!islist(snapshot))
		return FALSE
	if(!shadow_solver_cache_valid || !islist(shadow_solver_cache_snapshot))
		return TRUE

	var/delta_avail = abs(snapshot["avail"] - shadow_solver_cache_snapshot["avail"])
	var/delta_load = abs(snapshot["load"] - shadow_solver_cache_snapshot["load"])
	var/delta_unserved = abs(snapshot["unserved"] - shadow_solver_cache_snapshot["unserved"])
	var/threshold = max(shadow_solver_cache_significant_threshold, 1)
	return delta_avail > threshold || delta_load > threshold || delta_unserved > threshold

/datum/powernet/proc/get_or_build_shadow_solver_snapshot(numapc, list/precomputed_snapshot = null, allow_native = TRUE)
	if(!shadow_solver_enabled)
		return null

	if(should_use_cached_shadow_solver_snapshot(numapc))
		shadow_solver_cache_hits++
		shadow_solver_cache_stable_ticks++
		update_shadow_solver_stability_baseline(numapc)
		return shadow_solver_cache_snapshot?.Copy()

	shadow_solver_cache_misses++
	var/list/snapshot = precomputed_snapshot
	if(!islist(snapshot))
		var/datum/power_solver/active_solver = ensure_shadow_solver()
		if(!istype(active_solver))
			update_shadow_solver_stability_baseline(numapc)
			return null
		snapshot = get_shadow_solver_snapshot(active_solver, FALSE, allow_native)
	if(!islist(snapshot))
		update_shadow_solver_stability_baseline(numapc)
		return null

	if(is_shadow_solver_snapshot_significant(snapshot) || shadow_solver_cache_tick_dirty || shadow_solver_cache_topology_dirty)
		shadow_solver_cache_snapshot = snapshot.Copy()
		shadow_solver_cache_valid = TRUE
		shadow_solver_cache_timestamp = world.time

	if(is_shadow_solver_zone_stable(numapc))
		shadow_solver_cache_stable_ticks++
	else
		shadow_solver_cache_stable_ticks = 0

	shadow_solver_cache_tick_dirty = FALSE
	update_shadow_solver_stability_baseline(numapc)

	if(shadow_solver_cache_valid && islist(shadow_solver_cache_snapshot))
		return shadow_solver_cache_snapshot.Copy()
	return snapshot

/datum/powernet/proc/get_shadow_solver_stats_data()
	var/samples = max(shadow_solver_stats_samples, 0)
	var/native_samples = max(shadow_solver_native_perf_samples, 0)
	if(!samples)
		return list(
			"samples" = 0,
			"mismatch_rate" = 0,
			"avg_abs_load_delta" = 0,
			"avg_abs_avail_delta" = 0,
			"avg_unserved" = 0,
			"native_samples" = native_samples,
			"native_avg_build_us" = native_samples ? shadow_solver_native_perf_build_us_sum / native_samples : 0,
			"native_avg_encode_us" = native_samples ? shadow_solver_native_perf_encode_us_sum / native_samples : 0,
			"native_avg_call_us" = native_samples ? shadow_solver_native_perf_call_us_sum / native_samples : 0,
			"native_avg_decode_us" = native_samples ? shadow_solver_native_perf_decode_us_sum / native_samples : 0
		)

	return list(
		"samples" = samples,
		"mismatch_rate" = round((shadow_solver_stats_mismatches / samples) * 100, 0.1),
		"avg_abs_load_delta" = shadow_solver_stats_abs_load_delta_sum / samples,
		"avg_abs_avail_delta" = shadow_solver_stats_abs_avail_delta_sum / samples,
		"avg_unserved" = shadow_solver_stats_unserved_sum / samples,
		"native_samples" = native_samples,
		"native_avg_build_us" = native_samples ? shadow_solver_native_perf_build_us_sum / native_samples : 0,
		"native_avg_encode_us" = native_samples ? shadow_solver_native_perf_encode_us_sum / native_samples : 0,
		"native_avg_call_us" = native_samples ? shadow_solver_native_perf_call_us_sum / native_samples : 0,
		"native_avg_decode_us" = native_samples ? shadow_solver_native_perf_decode_us_sum / native_samples : 0
	)

/datum/powernet/proc/get_shadow_solver_backend_name()
	if(istype(shadow_solver))
		return shadow_solver.backend_name
	switch(shadow_solver_backend)
		if("strict_capacity_flow")
			return "Strict Capacity Flow"
		else
			return "Shadow FEA"

/datum/powernet/proc/get_shadow_solver_write_mode_name()
	if(shadow_solver_force_fea_only || shadow_solver_write_mode == "fea_only")
		return "FEA Only"
	if(!shadow_solver_write_enabled)
		return "Legacy"
	switch(shadow_solver_write_mode)
		if("pilot_smes_input")
			return "Pilot SMES Input"
		if("pilot_apc_advisory")
			return "Pilot APC Advisory"
		if("pilot_apc_enforced")
			return "Pilot APC Enforced"
		if("fea_only")
			return "FEA Only"
		else
			return "Legacy"

/datum/powernet/proc/enforce_fea_only_mode()
	if(!shadow_solver_force_fea_only)
		return
	shadow_solver_enabled = TRUE
	shadow_solver_write_enabled = TRUE
	shadow_solver_write_mode = "fea_only"

/datum/powernet/proc/set_shadow_solver_write_mode(new_mode)
	if(shadow_solver_force_fea_only)
		shadow_solver_write_mode = "fea_only"
		shadow_solver_write_enabled = TRUE
		return

	if(new_mode != "pilot_smes_input" && new_mode != "pilot_apc_advisory" && new_mode != "pilot_apc_enforced" && new_mode != "fea_only" && new_mode != "legacy")
		new_mode = "legacy"
	shadow_solver_write_mode = new_mode
	if(new_mode != "pilot_apc_enforced")
		shadow_solver_guard_consecutive_mismatch = 0
	if(new_mode == "legacy")
		shadow_solver_write_enabled = FALSE
	else
		shadow_solver_write_enabled = TRUE

/datum/powernet/proc/get_shadow_solver_guard_state_name()
	if(!shadow_solver_guard_enabled)
		return "Disabled"
	if(world.time < shadow_solver_guard_suspended_until)
		return "Cooldown"
	return "Armed"

/datum/powernet/proc/get_shadow_solver_guard_threshold()
	if(shadow_solver_guard_mismatch_threshold_override > 0)
		return shadow_solver_guard_mismatch_threshold_override
	return shadow_solver_mismatch_threshold

/datum/powernet/proc/get_shadow_solver_guard_mismatch()
	var/threshold = get_shadow_solver_guard_threshold()
	return abs(shadow_solver_avail_delta) > threshold \
		|| abs(shadow_solver_load_delta) > threshold \
		|| shadow_solver_last_unserved > threshold

/datum/powernet/proc/get_shadow_solver_guard_ticks_left()
	if(world.time >= shadow_solver_guard_suspended_until)
		return 0
	return shadow_solver_guard_suspended_until - world.time

/datum/powernet/proc/reset_shadow_solver_guard_state()
	shadow_solver_guard_consecutive_mismatch = 0
	shadow_solver_unserved_consecutive_ticks = 0
	shadow_solver_guard_suspended_until = 0
	shadow_solver_guard_last_reason = "none"
	shadow_solver_acceptance_last_pass = FALSE
	shadow_solver_acceptance_last_reason = "insufficient_samples"

/datum/powernet/proc/evaluate_shadow_solver_acceptance()
	var/list/st = get_shadow_solver_stats_data()
	var/samples = st["samples"]
	if(samples < shadow_solver_acceptance_min_samples)
		shadow_solver_acceptance_last_pass = FALSE
		shadow_solver_acceptance_last_reason = "insufficient_samples"
		return FALSE

	if(st["mismatch_rate"] > shadow_solver_acceptance_max_mismatch_rate)
		shadow_solver_acceptance_last_pass = FALSE
		shadow_solver_acceptance_last_reason = "mismatch_rate"
		return FALSE

	if(st["avg_abs_load_delta"] > shadow_solver_acceptance_max_avg_load_delta)
		shadow_solver_acceptance_last_pass = FALSE
		shadow_solver_acceptance_last_reason = "avg_load_delta"
		return FALSE

	if(st["avg_abs_avail_delta"] > shadow_solver_acceptance_max_avg_avail_delta)
		shadow_solver_acceptance_last_pass = FALSE
		shadow_solver_acceptance_last_reason = "avg_avail_delta"
		return FALSE

	if(st["avg_unserved"] > shadow_solver_acceptance_max_avg_unserved)
		shadow_solver_acceptance_last_pass = FALSE
		shadow_solver_acceptance_last_reason = "avg_unserved"
		return FALSE

	shadow_solver_acceptance_last_pass = TRUE
	shadow_solver_acceptance_last_reason = "ok"
	return TRUE

/datum/powernet/proc/get_shadow_solver_acceptance_state_name()
	evaluate_shadow_solver_acceptance()
	return shadow_solver_acceptance_last_pass ? "Pass" : "Fail"

/datum/powernet/proc/evaluate_shadow_solver_guard()
	if(!shadow_solver_guard_enabled)
		return
	if(shadow_solver_write_mode == "fea_only")
		shadow_solver_guard_consecutive_mismatch = 0
		return
	if(!shadow_solver_write_enabled || shadow_solver_write_mode != "pilot_apc_enforced")
		shadow_solver_guard_consecutive_mismatch = 0
		return
	if(world.time < shadow_solver_guard_suspended_until)
		return

	if(get_shadow_solver_guard_mismatch())
		shadow_solver_guard_consecutive_mismatch++
	else
		shadow_solver_guard_consecutive_mismatch = 0

	if(shadow_solver_guard_consecutive_mismatch < max(shadow_solver_guard_trip_threshold, 1))
		return

	set_shadow_solver_write_mode("pilot_apc_advisory")
	shadow_solver_write_enabled = TRUE
	shadow_solver_guard_rollback_events++
	shadow_solver_guard_last_reason = "consecutive_mismatch"
	shadow_solver_guard_last_rollback_time = world.time
	shadow_solver_guard_suspended_until = world.time + max(shadow_solver_guard_cooldown_ticks, 0)
	shadow_solver_guard_consecutive_mismatch = 0
	log_debug("Powernet shadow guard rollback: switched write mode to pilot_apc_advisory due to consecutive mismatch.")

/datum/powernet/proc/should_enforce_apc_cap()
	return shadow_solver_apc_advisory_valid && shadow_solver_write_enabled && (shadow_solver_write_mode == "pilot_apc_enforced" || shadow_solver_write_mode == "fea_only")

/datum/powernet/proc/get_apc_enforced_budget()
	if(!shadow_solver_apc_advisory_valid || shadow_solver_last_apc_count <= 0)
		return null
	var/legacy_perapc = max(avail / shadow_solver_last_apc_count, 0)
	var/floor_budget = legacy_perapc * clamp(shadow_solver_apc_cap_floor_ratio, 0, 1)
	shadow_solver_last_apc_enforced_floor = floor_budget
	shadow_solver_last_apc_enforced_budget = max(shadow_solver_last_apc_advisory_perapc, floor_budget)
	return shadow_solver_last_apc_enforced_budget

/datum/powernet/proc/set_shadow_solver_backend(new_backend)
	if(new_backend != "strict_capacity_flow" && new_backend != "shadow_fea")
		new_backend = "shadow_fea"
	shadow_solver_backend = new_backend
	shadow_solver = null
	reset_shadow_solver_stats()
	mark_shadow_solver_topology_dirty()

/datum/powernet/proc/ensure_shadow_solver()
	if(istype(shadow_solver))
		if(shadow_solver_backend == shadow_solver.backend_id)
			return shadow_solver

	switch(shadow_solver_backend)
		if("strict_capacity_flow")
			shadow_solver = new /datum/power_solver/strict_capacity_flow
		else
			shadow_solver = new /datum/power_solver/shadow_fea
	return shadow_solver

/datum/powernet/proc/get_shadow_solver_native_timer_id(tag)
	return "power_shadow_native_[tag]_\ref[src]_[(world.timeofday % 864000)]"

/datum/powernet/proc/get_shadow_solver_snapshot(datum/power_solver/active_solver, collect_native_perf = FALSE, allow_native = TRUE)
	if(!istype(active_solver))
		return null

	if(allow_native)
		var/list/native_snapshot = try_get_shadow_solver_native_snapshot(active_solver, collect_native_perf)
		if(islist(native_snapshot))
			return native_snapshot

	if(istype(active_solver, /datum/power_solver/shadow_fea))
		var/datum/power_solver/shadow_fea/shadow_solver = active_solver
		return shadow_solver.solve_shadow_fea(src)

	if(istype(active_solver, /datum/power_solver/strict_capacity_flow))
		var/datum/power_solver/strict_capacity_flow/strict_solver = active_solver
		return strict_solver.solve_strict_capacity_flow(src)

	return null

/datum/powernet/proc/rebuild_shadow_solver_native_nodes_payload_cache()
	var/list/named_payload_nodes = list()
	var/list/compact_payload_nodes = list()
	if(nodes && length(nodes))
		for(var/obj/machinery/power/node in nodes)
			var/list/profile = node.power_solver_shadow_profile()
			if(!islist(profile))
				continue
			var/node_supply = max(profile["supply"], 0)
			var/node_primary_demand = max(profile["primary_demand"], 0)
			var/node_deferred_demand = max(profile["deferred_demand"], 0)
			compact_payload_nodes += list(list(
				node_supply,
				node_primary_demand,
				node_deferred_demand
			))
			named_payload_nodes += list(list(
				"supply" = node_supply,
				"primary_demand" = node_primary_demand,
				"deferred_demand" = node_deferred_demand
			))

	shadow_solver_native_nodes_payload_named_cache = named_payload_nodes
	shadow_solver_native_nodes_payload_compact_cache = compact_payload_nodes
	shadow_solver_native_nodes_payload_cache_tick = world.time
	shadow_solver_native_nodes_payload_cache_valid = TRUE

/datum/powernet/proc/build_shadow_solver_native_nodes_payload(compact_format = FALSE)
	if(!shadow_solver_native_nodes_payload_cache_valid || shadow_solver_native_nodes_payload_cache_tick != world.time)
		rebuild_shadow_solver_native_nodes_payload_cache()

	if(compact_format)
		return shadow_solver_native_nodes_payload_compact_cache
	return shadow_solver_native_nodes_payload_named_cache

/datum/powernet/proc/build_shadow_solver_native_payload(datum/power_solver/active_solver)
	return list(
		"backend" = active_solver.backend_id,
		"avail" = max(avail, 0),
		"smes_avail" = max(smes_avail, 0),
		"nodes" = build_shadow_solver_native_nodes_payload(FALSE)
	)

/datum/powernet/proc/build_shadow_solver_native_payload_compact(datum/power_solver/active_solver)
	return list(
		active_solver.backend_id,
		max(avail, 0),
		max(smes_avail, 0),
		build_shadow_solver_native_nodes_payload(TRUE)
	)

/datum/powernet/proc/get_shadow_solver_native_stateful_identifier(use_legacy_id = FALSE)
	if(use_legacy_id)
		return "\ref[src]"
	if(shadow_solver_native_stateful_id <= 0)
		shadow_solver_native_stateful_id = shadow_solver_native_stateful_next_id++
	return shadow_solver_native_stateful_id

/datum/powernet/proc/build_shadow_solver_native_stateful_register_payload(datum/power_solver/active_solver, use_compact_format = TRUE, use_legacy_id = FALSE)
	if(!istype(active_solver))
		return null
	var/id_value = get_shadow_solver_native_stateful_identifier(use_legacy_id)
	if(use_compact_format)
		return list(
			id_value,
			max(shadow_solver_native_topology_revision, 0),
			active_solver.backend_id,
			build_shadow_solver_native_nodes_payload(TRUE)
		)
	return list(
		"id" = id_value,
		"revision" = max(shadow_solver_native_topology_revision, 0),
		"backend" = active_solver.backend_id,
		"nodes" = build_shadow_solver_native_nodes_payload(TRUE)
	)

/datum/powernet/proc/build_shadow_solver_native_stateful_dynamic_payload(use_compact_format = TRUE, use_legacy_id = FALSE)
	var/id_value = get_shadow_solver_native_stateful_identifier(use_legacy_id)
	if(use_compact_format)
		return list(
			id_value,
			max(avail, 0),
			max(smes_avail, 0)
		)
	return list(
		"id" = id_value,
		"avail" = max(avail, 0),
		"smes_avail" = max(smes_avail, 0)
	)

/datum/powernet/proc/decode_shadow_solver_native_snapshot(list/decoded)
	if(!islist(decoded))
		return null

	var/result_avail = decoded["avail"]
	var/result_load = decoded["load"]
	var/result_comparison_avail = decoded["comparison_avail"]
	var/result_comparison_load = decoded["comparison_load"]
	var/result_unserved = decoded["unserved"]
	var/result_deferred_unserved = decoded["deferred_unserved"]
	var/result_total_unserved = decoded["total_unserved"]
	var/result_primary_demand = decoded["primary_demand"]
	var/result_served_primary = decoded["served_primary"]

	if(isnull(result_avail) || isnull(result_load) || isnull(result_unserved))
		if(length(decoded) < POWER_SHADOW_NATIVE_RESULT_UNSERVED)
			return null
		result_avail = decoded[POWER_SHADOW_NATIVE_RESULT_AVAIL]
		result_load = decoded[POWER_SHADOW_NATIVE_RESULT_LOAD]
		result_comparison_avail = decoded[POWER_SHADOW_NATIVE_RESULT_COMPARISON_AVAIL]
		result_comparison_load = decoded[POWER_SHADOW_NATIVE_RESULT_COMPARISON_LOAD]
		result_unserved = decoded[POWER_SHADOW_NATIVE_RESULT_UNSERVED]
		result_deferred_unserved = decoded[POWER_SHADOW_NATIVE_RESULT_DEFERRED_UNSERVED]
		result_total_unserved = decoded[POWER_SHADOW_NATIVE_RESULT_TOTAL_UNSERVED]
		result_primary_demand = decoded[POWER_SHADOW_NATIVE_RESULT_PRIMARY_DEMAND]
		result_served_primary = decoded[POWER_SHADOW_NATIVE_RESULT_SERVED_PRIMARY]

	if(isnull(result_avail) || isnull(result_load) || isnull(result_unserved))
		return null

	result_deferred_unserved = max(result_deferred_unserved, 0)
	result_total_unserved = max(result_total_unserved, max(result_unserved, 0) + result_deferred_unserved)
	if(isnull(result_primary_demand))
		result_primary_demand = 0
	if(isnull(result_served_primary))
		result_served_primary = max(result_primary_demand - max(result_unserved, 0), 0)
	if(isnull(result_comparison_avail))
		result_comparison_avail = result_avail
	if(isnull(result_comparison_load))
		result_comparison_load = result_load

	return list(
		"avail" = max(result_avail, 0),
		"load" = max(result_load, 0),
		"comparison_avail" = max(result_comparison_avail, 0),
		"comparison_load" = max(result_comparison_load, 0),
		"unserved" = max(result_unserved, 0),
		"deferred_unserved" = result_deferred_unserved,
		"total_unserved" = result_total_unserved,
		"primary_demand" = max(result_primary_demand, 0),
		"served_primary" = max(result_served_primary, 0)
	)

/datum/powernet/proc/try_get_shadow_solver_native_snapshot(datum/power_solver/active_solver, collect_perf = FALSE, force_legacy_payload = FALSE)
	if(!shadow_solver_native_enabled)
		return null
	if(!istype(active_solver))
		return null

	var/timer_id
	var/build_us = 0
	var/encode_us = 0
	var/call_us = 0
	var/decode_us = 0
	if(collect_perf)
		timer_id = get_shadow_solver_native_timer_id("single")
		rustg_time_reset(timer_id)

	var/use_compact_payload = (!force_legacy_payload && shadow_solver_native_compact_supported)
	var/list/payload = use_compact_payload ? build_shadow_solver_native_payload_compact(active_solver) : build_shadow_solver_native_payload(active_solver)
	if(!islist(payload))
		return null
	if(collect_perf)
		build_us = max(rustg_time_microseconds(timer_id), 0)
		rustg_time_reset(timer_id)

	var/payload_json = json_encode(payload)
	if(!istext(payload_json) || !length(payload_json))
		if(use_compact_payload)
			var/list/legacy_snapshot = try_get_shadow_solver_native_snapshot(active_solver, collect_perf, TRUE)
			if(islist(legacy_snapshot))
				shadow_solver_native_compact_supported = FALSE
				return legacy_snapshot
		return null
	if(collect_perf)
		encode_us = max(rustg_time_microseconds(timer_id), 0)
		rustg_time_reset(timer_id)

	var/raw = rustg_power_shadow_solve(payload_json)
	if(!istext(raw) || !length(raw))
		if(use_compact_payload)
			var/list/legacy_snapshot = try_get_shadow_solver_native_snapshot(active_solver, collect_perf, TRUE)
			if(islist(legacy_snapshot))
				shadow_solver_native_compact_supported = FALSE
				return legacy_snapshot
		return null
	if(collect_perf)
		call_us = max(rustg_time_microseconds(timer_id), 0)
		rustg_time_reset(timer_id)

	var/list/decoded = json_decode(raw)
	if(collect_perf)
		decode_us = max(rustg_time_microseconds(timer_id), 0)

	var/list/snapshot = decode_shadow_solver_native_snapshot(decoded)
	if(!islist(snapshot))
		if(use_compact_payload)
			var/list/legacy_snapshot = try_get_shadow_solver_native_snapshot(active_solver, collect_perf, TRUE)
			if(islist(legacy_snapshot))
				shadow_solver_native_compact_supported = FALSE
				return legacy_snapshot
		return null
	if(use_compact_payload)
		shadow_solver_native_compact_supported = TRUE
	if(collect_perf)
		record_shadow_solver_native_perf(build_us, encode_us, call_us, decode_us)
	return snapshot

/datum/powernet/proc/get_legacy_smes_input_percentage()
	if(!length(inputting) || !smes_demand)
		return null
	return clamp((netexcess / smes_demand) * 100, 0, 100)

/datum/powernet/proc/get_solver_smes_input_percentage(list/snapshot)
	if(!shadow_solver_write_enabled || (shadow_solver_write_mode != "pilot_smes_input" && shadow_solver_write_mode != "fea_only"))
		return null
	if(!islist(snapshot) || !smes_demand)
		return null

	// FEA snapshots fold deferred demand into load, so avail-load becomes "leftover after SMES charging"
	// rather than "budget available to deferred demand". Use served_primary to recover the actual budget
	// that can be allocated to SMES charging.
	var/served_primary = snapshot["served_primary"]
	if(isnull(served_primary))
		served_primary = snapshot["comparison_load"]
	if(isnull(served_primary))
		served_primary = snapshot["load"]

	var/solver_excess = max(snapshot["avail"] - max(served_primary, 0), 0)
	return clamp((solver_excess / smes_demand) * 100, 0, 100)

/datum/powernet/proc/update_apc_advisory(list/snapshot, numapc)
	if(!islist(snapshot) || numapc <= 0)
		invalidate_apc_advisory()
		return

	shadow_solver_last_apc_count = max(numapc, 0)
	var/primary_demand = max(snapshot["primary_demand"], 0)
	var/served_primary = max(snapshot["served_primary"], 0)
	var/scale = primary_demand > 0 ? clamp(served_primary / primary_demand, 0, 1) : 1

	shadow_solver_last_apc_advisory_primary_demand = primary_demand
	shadow_solver_last_apc_advisory_served_primary = served_primary
	shadow_solver_last_apc_advisory_scale = scale
	shadow_solver_last_apc_advisory_perapc = (served_primary / max(numapc, 1))
	shadow_solver_apc_advisory_valid = TRUE
	get_apc_enforced_budget()

	if(shadow_solver_write_enabled && shadow_solver_write_mode == "pilot_apc_advisory")
		perapc = shadow_solver_last_apc_advisory_perapc

/datum/powernet/proc/apply_smes_input_percentage(smes_input_percentage)
	if(isnull(smes_input_percentage))
		return
	for(var/obj/machinery/power/smes/S in inputting)
		S.input_power(smes_input_percentage)

/datum/powernet/proc/apply_shadow_solver_write_path(list/snapshot)
	var/legacy_percentage = get_legacy_smes_input_percentage()
	var/solver_percentage = get_solver_smes_input_percentage(snapshot)

	if(!isnull(solver_percentage))
		shadow_solver_last_smes_input_source = "solver"
		shadow_solver_last_smes_input_percentage = solver_percentage
		apply_smes_input_percentage(solver_percentage)
		return

	if(!isnull(legacy_percentage))
		shadow_solver_last_smes_input_source = "legacy"
		shadow_solver_last_smes_input_percentage = legacy_percentage
		apply_smes_input_percentage(legacy_percentage)
		return

	shadow_solver_last_smes_input_source = "none"
	shadow_solver_last_smes_input_percentage = -1

/datum/powernet/proc/run_shadow_solver_comparison(list/snapshot)
	if(!shadow_solver_enabled)
		return
	if(!islist(snapshot))
		return

	var/comparison_avail = snapshot["avail"]
	if(!isnull(snapshot["comparison_avail"]))
		comparison_avail = snapshot["comparison_avail"]
	var/comparison_load = snapshot["load"]
	if(!isnull(snapshot["comparison_load"]))
		comparison_load = snapshot["comparison_load"]
	var/primary_unserved = max(snapshot["unserved"], 0)
	var/deferred_unserved = max(snapshot["deferred_unserved"], 0)
	var/total_unserved = snapshot["total_unserved"]
	if(isnull(total_unserved))
		total_unserved = primary_unserved + deferred_unserved
	update_shadow_solver_metrics(comparison_avail, comparison_load, primary_unserved, deferred_unserved, total_unserved)
	evaluate_shadow_solver_guard()
	if(!shadow_solver_mismatch || world.time < shadow_solver_next_log)
		return

	shadow_solver_next_log = world.time + 200
	var/datum/power_solver/active_solver = ensure_shadow_solver()
	if(!istype(active_solver))
		return
	log_debug("Powernet shadow mismatch ([active_solver.backend_id]): avail=[avail], load=[load], shadow_avail=[shadow_solver_last_avail], shadow_load=[shadow_solver_last_load], shadow_unserved_primary=[shadow_solver_last_unserved], shadow_unserved_deferred=[shadow_solver_last_deferred_unserved], d_avail=[shadow_solver_avail_delta], d_load=[shadow_solver_load_delta]")


//handles the power changes in the powernet
//called every ticks by the powernet controller
/datum/powernet/proc/reset(wait, list/precomputed_shadow_snapshot = null, allow_native_shadow_solver = TRUE)
	var/numapc = get_apc_terminal_count()

	if(problem > 0)
		problem = max(problem - 1, 0)

	if(abs(avail - shadow_solver_cache_last_avail) > shadow_solver_cache_stability_threshold)
		mark_shadow_solver_tick_dirty()
	if(abs(load - shadow_solver_cache_last_load) > shadow_solver_cache_stability_threshold)
		mark_shadow_solver_tick_dirty()
	if(abs(smes_demand - shadow_solver_cache_last_smes_demand) > shadow_solver_cache_stability_threshold)
		mark_shadow_solver_tick_dirty()
	if(length(inputting) != shadow_solver_cache_last_inputting_count)
		mark_shadow_solver_tick_dirty()
	if(numapc != shadow_solver_cache_last_numapc)
		mark_shadow_solver_tick_dirty()

	netexcess = avail - load
	var/list/write_snapshot
	if(shadow_solver_enabled)
		write_snapshot = get_or_build_shadow_solver_snapshot(numapc, precomputed_shadow_snapshot, allow_native_shadow_solver)
		run_shadow_solver_comparison(write_snapshot)
	update_apc_advisory(write_snapshot, numapc)

	if(numapc)
		//very simple load balancing. If there was a net excess this tick then it must have been that some APCs used less than perapc, since perapc*numapc = avail
		//Therefore we can raise the amount of power rationed out to APCs on the assumption that those APCs that used less than perapc will continue to do so.
		//If that assumption fails, then some APCs will miss out on power next tick, however it will be rebalanced for the tick after.
		if (netexcess >= 0)
			perapc_excess += min(netexcess/numapc, (avail - perapc) - perapc_excess)
		else
			perapc_excess = 0

		perapc = avail/numapc + perapc_excess

	// At this point, all other machines have finished using power. Anything left over may be used up to charge SMESs.
	if(length(inputting) && smes_demand)
		apply_shadow_solver_write_path(write_snapshot)
	else
		shadow_solver_last_smes_input_source = "none"
		shadow_solver_last_smes_input_percentage = -1

	netexcess = avail - load

	if(netexcess)
		var/perc = get_percent_load(1)
		for(var/obj/machinery/power/smes/S in nodes)
			S.restore(perc)

	//updates the viewed load (as seen on power computers)
	viewload = round(load)

	//reset the powernet
	load = 0
	avail = newavail
	smes_avail = smes_newavail
	inputting.Cut()
	smes_demand = 0
	newavail = 0
	smes_newavail = 0

/datum/powernet/proc/get_percent_load(smes_only = 0)
	if(smes_only)
		var/smes_used = load - (avail - smes_avail) 			// SMESs are always last to provide power
		if(!smes_used || smes_used < 0 || !smes_avail)			// SMES power isn't available or being used at all, SMES load is therefore 0%
			return 0
		return clamp((smes_used / smes_avail) * 100, 0, 100)	// Otherwise return percentage load of SMESs.
	else
		if(!load)
			return 0
		return clamp((avail / load) * 100, 0, 100)

/datum/powernet/proc/get_electrocute_damage()
	var/damage = avail / 80000
	if (damage < 1)
		return 0

	return damage

// Proc: apcs_overload()
// Parameters: 3 (failure_chance - chance to actually break the APC, overload_chance - Chance of breaking lights, reboot_chance - Chance of temporarily disabling the APC)
// Description: Damages output powernet by power surge. Destroys few APCs and lights, depending on parameters.
/datum/powernet/proc/apcs_overload(failure_chance, overload_chance, reboot_chance)
	for(var/obj/machinery/power/terminal/T in nodes)
		var/obj/machinery/power/apc/A = T.master_machine()
		if(istype(A))
			if (prob(failure_chance))
				A.set_broken(TRUE)
			if (prob(overload_chance))
				A.overload_lighting()
			if(prob(reboot_chance))
				A.energy_fail(rand(30,60))

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////


// return a knot cable (O-X) if one is present in the turf
// null if there's none
/turf/proc/get_cable_node()
	if(!istype(src, /turf/simulated))
		return null
	for(var/obj/structure/cable/C in src)
		if(C.d1 == 0)
			return C
	return null
