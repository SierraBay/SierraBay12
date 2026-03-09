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


/datum/unit_test/rcon_device_scan_excludes_deleted_smes
	name = "POWER: RCON scan excludes deleted SMES units"

/datum/unit_test/rcon_device_scan_excludes_deleted_smes/start_test()
	var/turf/T = get_safe_turf()
	var/obj/host = new(T)
	var/datum/nano_module/program/rcon/rcon = new(host)
	var/obj/machinery/power/smes/buildable/smes = new(T)
	smes.RCon_tag = "unit_test_rcon_[world.time]"

	rcon.FindDevices()
	if(!(smes in rcon.known_SMESs))
		fail("RCON scan did not include a live tagged SMES.")
		qdel(smes)
		qdel(rcon)
		qdel(host)
		return 1

	qdel(smes)
	rcon.FindDevices()
	if(smes in rcon.known_SMESs)
		fail("RCON scan still included a deleted SMES after rescanning.")
		qdel(rcon)
		qdel(host)
		return 1

	qdel(rcon)
	qdel(host)
	pass("RCON rescans use live machinery state and drop deleted SMES units.")
	return 1


/datum/unit_test/cable_scan_uses_pending_power_supply
	name = "POWER: Cable scan display uses pending generator output"

/datum/unit_test/cable_scan_uses_pending_power_supply/start_test()
	var/turf/T = get_safe_turf()
	if(!istype(T))
		fail("Failed to find a safe turf for cable scan testing.")
		return 1

	var/datum/powernet/PN = new
	var/obj/structure/cable/C = new(T)
	PN.add_cable(C)

	PN.avail = 0
	PN.newavail = 31500000

	if(C.get_displayed_power() != PN.newavail)
		fail("Cable display power did not prefer pending network output when current avail was zero.")
		qdel(C)
		qdel(PN)
		return 1

	if(C.get_wattage() != "31500 kW")
		fail("Cable display wattage was '[C.get_wattage()]' instead of '31500 kW' for pending output.")
		qdel(C)
		qdel(PN)
		return 1

	qdel(C)
	qdel(PN)
	pass("Cable scan display includes pending generator output from the current tick.")
	return 1


/obj/machinery/power/native_payload_cache_probe
	var/profile_calls = 0
	var/profile_primary_demand = 2500
	var/profile_deferred_demand = 500
	var/profile_supply = 1000

/obj/machinery/power/native_payload_cache_probe/power_solver_shadow_profile()
	profile_calls++
	return list(
		"primary_demand" = profile_primary_demand,
		"deferred_demand" = profile_deferred_demand,
		"supply" = profile_supply
	)


/datum/unit_test/power_shadow_fea_lock_enforced
	name = "POWER SHADOW: FEA lock enforces non-legacy mode"

/datum/unit_test/power_shadow_fea_lock_enforced/start_test()
	var/datum/powernet/PN = new
	PN.shadow_solver_force_fea_only = TRUE
	PN.set_shadow_solver_write_mode("legacy")

	if(PN.shadow_solver_write_mode != "fea_only")
		fail("FEA lock did not force write mode to fea_only.")
		qdel(PN)
		return 1

	if(!PN.shadow_solver_write_enabled)
		fail("FEA lock did not force write path enabled.")
		qdel(PN)
		return 1

	qdel(PN)
	pass("FEA lock correctly enforced fea_only mode.")
	return 1


/datum/unit_test/power_shadow_cache_reuse
	name = "POWER SHADOW: Stable network reuses cached snapshot"

/datum/unit_test/power_shadow_cache_reuse/start_test()
	var/datum/powernet/PN = new
	PN.shadow_solver_enabled = TRUE
	PN.shadow_solver_cache_enabled = TRUE
	PN.shadow_solver_cache_min_stable_ticks = 0
	PN.shadow_solver_cache_max_age_ticks = 1000
	PN.avail = 100000
	PN.load = 20000
	PN.smes_avail = 0
	PN.smes_demand = 0
	PN.inputting.Cut()

	var/list/first = PN.get_or_build_shadow_solver_snapshot(0)
	if(!islist(first))
		fail("Expected first snapshot to be generated.")
		qdel(PN)
		return 1

	var/list/second = PN.get_or_build_shadow_solver_snapshot(0)
	if(!islist(second))
		fail("Expected second snapshot to be available.")
		qdel(PN)
		return 1

	if(PN.shadow_solver_cache_hits < 1)
		fail("Expected cache hit on stable second snapshot call.")
		qdel(PN)
		return 1

	qdel(PN)
	pass("Stable powernet reused cached snapshot.")
	return 1


/datum/unit_test/power_shadow_native_payload_cache_reuse
	name = "POWER SHADOW: Native node payload cache only rebuilds on topology changes"

/datum/unit_test/power_shadow_native_payload_cache_reuse/start_test()
	var/turf/T = get_safe_turf()
	if(!istype(T))
		fail("Failed to find a safe turf for native payload cache testing.")
		return 1

	var/datum/powernet/PN = new
	var/obj/machinery/power/native_payload_cache_probe/node = new(T)
	PN.nodes[node] = node
	PN.mark_shadow_solver_topology_dirty()

	var/list/first = PN.build_shadow_solver_native_nodes_payload(TRUE)
	var/list/second = PN.build_shadow_solver_native_nodes_payload(TRUE)
	if(!islist(first) || !islist(second))
		fail("Expected native payload cache builds to return compact node payload lists.")
		qdel(node)
		qdel(PN)
		return 1

	if(node.profile_calls != 1)
		fail("Expected profile proc to run once before topology changes, got [node.profile_calls] calls.")
		qdel(node)
		qdel(PN)
		return 1

	PN.mark_shadow_solver_topology_dirty()
	var/list/third = PN.build_shadow_solver_native_nodes_payload(TRUE)
	if(!islist(third))
		fail("Expected native payload cache rebuild after topology invalidation.")
		qdel(node)
		qdel(PN)
		return 1

	if(node.profile_calls != 2)
		fail("Expected profile proc to run exactly once more after topology dirty, got [node.profile_calls] calls.")
		qdel(node)
		qdel(PN)
		return 1

	qdel(node)
	qdel(PN)
	pass("Native node payload cache now reuses topology-stable payloads and rebuilds only after topology invalidation.")
	return 1


/datum/unit_test/power_shadow_native_legacy_payload_stays_live
	name = "POWER SHADOW: Legacy native payload rebuilds dynamic node profiles"

/datum/unit_test/power_shadow_native_legacy_payload_stays_live/start_test()
	var/turf/T = get_safe_turf()
	if(!istype(T))
		fail("Failed to find a safe turf for legacy native payload live-profile testing.")
		return 1

	var/datum/powernet/PN = new
	var/obj/machinery/power/native_payload_cache_probe/node = new(T)
	PN.nodes[node] = node
	PN.mark_shadow_solver_topology_dirty()

	var/datum/power_solver/solver = PN.ensure_shadow_solver()
	if(!istype(solver))
		fail("Failed to create a shadow solver for legacy native payload live-profile testing.")
		qdel(node)
		qdel(PN)
		return 1

	var/list/first_payload = PN.build_shadow_solver_native_payload_compact(solver)
	if(!islist(first_payload) || length(first_payload) < 4)
		fail("Expected compact legacy payload to include nodes.")
		qdel(node)
		qdel(PN)
		return 1

	node.profile_primary_demand = 9000
	node.profile_deferred_demand = 1200
	node.profile_supply = 300

	var/list/second_payload = PN.build_shadow_solver_native_payload_compact(solver)
	var/list/second_nodes = second_payload[4]
	if(!islist(second_nodes) || !length(second_nodes))
		fail("Expected compact legacy payload rebuild to return node rows.")
		qdel(node)
		qdel(PN)
		return 1

	var/list/node_row = second_nodes[1]
	if(!islist(node_row))
		fail("Expected compact legacy payload node row to be a list.")
		qdel(node)
		qdel(PN)
		return 1

	if(node_row[1] != 300 || node_row[2] != 9000 || node_row[3] != 1200)
		fail("Legacy compact payload reused stale node profile data instead of rebuilding dynamic values.")
		qdel(node)
		qdel(PN)
		return 1

	qdel(node)
	qdel(PN)
	pass("Legacy native payload rebuilds node profiles every solve while stateful register payload stays topology-cached.")
	return 1


/datum/unit_test/power_shadow_adaptive_cache_threshold
	name = "POWER SHADOW: Adaptive cache drift threshold scales with network size"

/datum/unit_test/power_shadow_adaptive_cache_threshold/start_test()
	var/datum/powernet/large = new
	large.avail = 1000000
	large.load = 250000
	large.smes_demand = 0
	large.shadow_solver_cache_valid = TRUE
	large.shadow_solver_cache_snapshot = list("avail" = 1000000, "load" = 250000, "unserved" = 0)
	large.shadow_solver_cache_timestamp = world.time
	large.shadow_solver_cache_stable_ticks = 5
	large.update_shadow_solver_stability_baseline(0)
	large.shadow_solver_cache_tick_dirty = FALSE
	large.avail = 1010000

	if(!large.is_shadow_solver_zone_stable(0))
		fail("Expected a 10kW drift to remain stable on a 1MW network.")
		qdel(large)
		return 1

	var/datum/powernet/small = new
	small.avail = 20000
	small.load = 8000
	small.smes_demand = 0
	small.shadow_solver_cache_valid = TRUE
	small.shadow_solver_cache_snapshot = list("avail" = 20000, "load" = 8000, "unserved" = 0)
	small.shadow_solver_cache_timestamp = world.time
	small.shadow_solver_cache_stable_ticks = 5
	small.update_shadow_solver_stability_baseline(0)
	small.shadow_solver_cache_tick_dirty = FALSE
	small.avail = 30000

	if(small.is_shadow_solver_zone_stable(0))
		fail("Expected the same 10kW drift to invalidate cache stability on a small network.")
		qdel(large)
		qdel(small)
		return 1

	qdel(large)
	qdel(small)
	pass("Adaptive cache drift thresholds stay lenient on large nets and strict on small nets.")
	return 1


/datum/unit_test/power_shadow_cache_extrapolation_no_apc
	name = "POWER SHADOW: No-APC networks extrapolate cached snapshots before solving"

/datum/unit_test/power_shadow_cache_extrapolation_no_apc/start_test()
	var/datum/powernet/PN = new
	PN.shadow_solver_enabled = TRUE
	PN.shadow_solver_cache_enabled = TRUE
	PN.shadow_solver_cache_valid = TRUE
	PN.shadow_solver_cache_timestamp = world.time
	PN.shadow_solver_cache_stable_ticks = 0
	PN.avail = 100000
	PN.load = 20000
	PN.smes_demand = 0
	PN.inputting.Cut()
	PN.shadow_solver_cache_snapshot = list(
		"avail" = 100000,
		"load" = 20000,
		"comparison_avail" = 100000,
		"comparison_load" = 20000,
		"unserved" = 0,
		"deferred_unserved" = 0,
		"total_unserved" = 0,
		"primary_demand" = 0,
		"served_primary" = 0
	)
	PN.update_shadow_solver_stability_baseline(0)
	PN.mark_shadow_solver_tick_dirty()
	PN.avail = 102000

	var/list/extrapolated = PN.get_or_build_shadow_solver_snapshot(0)
	if(!islist(extrapolated))
		fail("Expected no-APC powernet to return an extrapolated cached snapshot.")
		qdel(PN)
		return 1

	if(extrapolated["comparison_avail"] != 102000)
		fail("Expected extrapolated snapshot to expose live comparison_avail 102000, got [extrapolated["comparison_avail"]].")
		qdel(PN)
		return 1

	if(extrapolated["avail"] != 102000)
		fail("Expected extrapolated snapshot avail to track live avail drift, got [extrapolated["avail"]].")
		qdel(PN)
		return 1

	if(PN.shadow_solver_cache_hits < 1 || PN.shadow_solver_cache_misses != 0)
		fail("Expected extrapolated snapshot reuse to count as a cache hit without a cache miss (hits=[PN.shadow_solver_cache_hits], misses=[PN.shadow_solver_cache_misses]).")
		qdel(PN)
		return 1

	qdel(PN)
	pass("No-APC powernets extrapolate fresh cached snapshots instead of invoking a full solve for minor drift.")
	return 1


/datum/unit_test/power_shadow_partial_batch_routing
	name = "POWER SHADOW: Partial batch snapshot maps preserve reusable snapshots"

/datum/unit_test/power_shadow_partial_batch_routing/start_test()
	if(!SSpowernets)
		fail("Powernets subsystem was not available for partial batch routing test.")
		return 1

	var/datum/powernet/hit = new
	var/datum/powernet/miss = new
	var/list/batch_snapshots = list()
	batch_snapshots[hit] = SSpowernets.power_shadow_native_make_snapshot_entry(list("avail" = 100, "load" = 20, "unserved" = 0), "cache")

	var/list/hit_entry = SSpowernets.power_shadow_native_get_runtime_batch_entry(hit, batch_snapshots, FALSE)
	if(!islist(hit_entry["snapshot"]) || hit_entry["reuse_mode"] != "cache")
		fail("Expected cached batch entry to remain available when batch coverage is partial.")
		qdel(hit)
		qdel(miss)
		return 1

	var/list/miss_entry = SSpowernets.power_shadow_native_get_runtime_batch_entry(miss, batch_snapshots, FALSE)
	if(islist(miss_entry["snapshot"]))
		fail("Missing network should not inherit another network's precomputed batch snapshot.")
		qdel(hit)
		qdel(miss)
		return 1

	var/list/forced_entry = SSpowernets.power_shadow_native_get_runtime_batch_entry(hit, batch_snapshots, TRUE)
	if(islist(forced_entry["snapshot"]))
		fail("Global DM fallback should suppress even valid batch snapshots.")
		qdel(hit)
		qdel(miss)
		return 1

	qdel(hit)
	qdel(miss)
	pass("Partial batch snapshot maps keep valid reusable snapshots without forcing unrelated networks off the fast path.")
	return 1


/datum/unit_test/power_shadow_acceptance_thresholds
	name = "POWER SHADOW: Acceptance thresholds evaluate correctly"

/datum/unit_test/power_shadow_acceptance_thresholds/start_test()
	var/datum/powernet/PN = new
	PN.shadow_solver_acceptance_min_samples = 10
	PN.shadow_solver_acceptance_max_mismatch_rate = 25
	PN.shadow_solver_acceptance_max_avg_load_delta = 15000
	PN.shadow_solver_acceptance_max_avg_avail_delta = 15000
	PN.shadow_solver_acceptance_max_avg_unserved = 9000

	PN.shadow_solver_stats_samples = 20
	PN.shadow_solver_stats_mismatches = 2
	PN.shadow_solver_stats_abs_load_delta_sum = 200000 // avg 10000
	PN.shadow_solver_stats_abs_avail_delta_sum = 180000 // avg 9000
	PN.shadow_solver_stats_unserved_sum = 120000 // avg 6000

	if(!PN.evaluate_shadow_solver_acceptance())
		fail("Acceptance should have passed for valid aggregate stats.")
		qdel(PN)
		return 1

	PN.shadow_solver_stats_mismatches = 10 // 50%
	if(PN.evaluate_shadow_solver_acceptance())
		fail("Acceptance should have failed due to mismatch rate.")
		qdel(PN)
		return 1

	if(PN.shadow_solver_acceptance_last_reason != "mismatch_rate")
		fail("Expected failure reason mismatch_rate, got [PN.shadow_solver_acceptance_last_reason].")
		qdel(PN)
		return 1

	qdel(PN)
	pass("Acceptance thresholds and reasons behaved correctly.")
	return 1


/datum/unit_test/power_shadow_guard_rollback
	name = "POWER SHADOW: Guard rolls back enforced APC mode"

/datum/unit_test/power_shadow_guard_rollback/start_test()
	var/datum/powernet/PN = new
	PN.shadow_solver_force_fea_only = FALSE
	PN.shadow_solver_guard_enabled = TRUE
	PN.shadow_solver_write_enabled = TRUE
	PN.set_shadow_solver_write_mode("pilot_apc_enforced")
	PN.shadow_solver_guard_trip_threshold = 2
	PN.shadow_solver_guard_cooldown_ticks = 50
	PN.shadow_solver_mismatch_threshold = 100
	PN.shadow_solver_guard_mismatch_threshold_override = 100

	PN.shadow_solver_avail_delta = 1000
	PN.shadow_solver_load_delta = 0
	PN.shadow_solver_last_unserved = 0
	PN.evaluate_shadow_solver_guard()
	PN.evaluate_shadow_solver_guard()

	if(PN.shadow_solver_write_mode != "pilot_apc_advisory")
		fail("Guard did not rollback from enforced to advisory mode.")
		qdel(PN)
		return 1

	if(PN.shadow_solver_guard_rollback_events < 1)
		fail("Guard rollback event counter did not increment.")
		qdel(PN)
		return 1

	qdel(PN)
	pass("Guard rollback correctly switched mode and tracked event.")
	return 1


/datum/unit_test/power_shadow_solver_smes_input
	name = "POWER SHADOW: Solver SMES percentage computed in FEA mode"

/datum/unit_test/power_shadow_solver_smes_input/start_test()
	var/datum/powernet/PN = new
	PN.shadow_solver_write_enabled = TRUE
	PN.shadow_solver_write_mode = "fea_only"
	PN.smes_demand = 50

	// In FEA mode the predicted load already includes deferred demand served to SMESes.
	// The controller must therefore use served_primary, not load, to recover the SMES charging budget.
	var/list/snapshot = list(
		"avail" = 100,
		"load" = 100,
		"comparison_load" = 60,
		"served_primary" = 60
	)
	var/solver_percent = PN.get_solver_smes_input_percentage(snapshot)

	if(isnull(solver_percent))
		fail("Solver SMES input percentage should not be null in fea_only mode.")
		qdel(PN)
		return 1

	if(abs(solver_percent - 80) > 0.1)
		fail("Expected solver SMES input percentage ~80, got [solver_percent].")
		qdel(PN)
		return 1

	qdel(PN)
	pass("Solver SMES input percentage computed correctly.")
	return 1


/datum/unit_test/power_shadow_auto_repair_collect
	name = "POWER SHADOW: Auto-repair collector finds anomalous nets"

/datum/unit_test/power_shadow_auto_repair_collect/start_test()
	var/datum/powernet/problem = new
	var/datum/powernet/normal = new

	problem.shadow_solver_mismatch = TRUE
	problem.shadow_solver_avail_delta = 500000
	problem.shadow_solver_load_delta = 500000
	problem.shadow_solver_last_unserved = 200000

	normal.shadow_solver_mismatch = FALSE
	normal.shadow_solver_avail_delta = 0
	normal.shadow_solver_load_delta = 0
	normal.shadow_solver_last_unserved = 0
	normal.shadow_solver_acceptance_min_samples = 1
	normal.shadow_solver_stats_samples = 1
	normal.shadow_solver_stats_mismatches = 0
	normal.shadow_solver_stats_abs_load_delta_sum = 0
	normal.shadow_solver_stats_abs_avail_delta_sum = 0
	normal.shadow_solver_stats_unserved_sum = 0
	normal.evaluate_shadow_solver_acceptance()

	var/list/result = SSmachines.power_shadow_collect_anomalies(300000, 100000, list(problem, normal))
	if(result["problem_count"] != 1)
		fail("Expected exactly 1 anomalous network, got [result["problem_count"]].")
		qdel(problem)
		qdel(normal)
		return 1

	if(result["networks"] != 2)
		fail("Expected collector to inspect 2 networks, got [result["networks"]].")
		qdel(problem)
		qdel(normal)
		return 1

	qdel(problem)
	qdel(normal)
	pass("Auto-repair collector correctly identified anomalous network.")
	return 1


/datum/unit_test/power_shadow_auto_repair_retunes
	name = "POWER SHADOW: Auto-repair retunes and activates conservative mode"

/datum/unit_test/power_shadow_auto_repair_retunes/start_test()
	var/datum/powernet/problem = new
	problem.shadow_solver_backend = "adaptive_shadow"
	problem.shadow_solver_mismatch = TRUE
	problem.shadow_solver_avail_delta = 400000
	problem.shadow_solver_load_delta = 300000
	problem.shadow_solver_last_unserved = 250000
	problem.shadow_solver_mismatch_threshold = 5000
	problem.avail = 1000000
	problem.load = 800000

	var/old_threshold = problem.shadow_solver_mismatch_threshold
	var/list/result = SSmachines.power_shadow_apply_auto_repair(300000, 100000, FALSE, list(problem))

	if(result["retuned"] != 1)
		fail("Expected 1 retuned network, got [result["retuned"]].")
		qdel(problem)
		return 1

	if(problem.shadow_solver_mismatch_threshold <= old_threshold)
		fail("Expected adaptive threshold to increase during retune.")
		qdel(problem)
		return 1

	var/datum/power_solver/adaptive_shadow/solver = problem.ensure_shadow_solver()
	if(!istype(solver) || !solver.conservative_mode)
		fail("Expected conservative mode activation on severe mismatch.")
		qdel(problem)
		return 1

	if(result["backend_switched"] != 1)
		fail("Expected backend_switched count to be 1, got [result["backend_switched"]].")
		qdel(problem)
		return 1

	qdel(problem)
	pass("Auto-repair retune and conservative mode activation behaved correctly.")
	return 1


/datum/unit_test/power_shadow_unserved_persistence_filter
	name = "POWER SHADOW: Unserved persistence filter blocks transient spikes"

/datum/unit_test/power_shadow_unserved_persistence_filter/start_test()
	var/datum/powernet/PN = new
	PN.shadow_solver_guard_mismatch_threshold_override = 10000
	PN.shadow_solver_unserved_trip_ticks = 3

	PN.update_shadow_solver_metrics(0, 0, 12000)
	if(PN.is_shadow_solver_unserved_persistent())
		fail("Transient unserved spike should not be marked persistent after a single tick.")
		qdel(PN)
		return 1

	PN.update_shadow_solver_metrics(0, 0, 13000)
	if(PN.is_shadow_solver_unserved_persistent())
		fail("Transient unserved spike should not be marked persistent after two ticks.")
		qdel(PN)
		return 1

	PN.update_shadow_solver_metrics(0, 0, 14000)
	if(!PN.is_shadow_solver_unserved_persistent())
		fail("Persistent unserved should trigger after configured consecutive ticks.")
		qdel(PN)
		return 1

	PN.update_shadow_solver_metrics(0, 0, 1000)
	if(PN.is_shadow_solver_unserved_persistent())
		fail("Persistent unserved state should clear when unserved drops below threshold.")
		qdel(PN)
		return 1

	qdel(PN)
	pass("Unserved persistence filter behaves as expected.")
	return 1


/datum/unit_test/power_shadow_apc_cap_topology_invalidation
	name = "POWER SHADOW: APC cap invalidates immediately on topology change"

/datum/unit_test/power_shadow_apc_cap_topology_invalidation/start_test()
	var/turf/T = get_space_turf()
	if(!istype(T))
		fail("Failed to find a test turf for APC cap invalidation.")
		return 1

	var/area/test_area = get_area(T)
	if(!istype(test_area))
		fail("Failed to resolve a test area for APC cap invalidation.")
		return 1

	var/obj/machinery/power/apc/previous_apc = test_area.apc
	var/old_used_equip = test_area.used_equip
	var/old_used_light = test_area.used_light
	var/old_used_environ = test_area.used_environ
	var/old_oneoff_equip = test_area.oneoff_equip
	var/old_oneoff_light = test_area.oneoff_light
	var/old_oneoff_environ = test_area.oneoff_environ

	var/obj/machinery/power/apc/APC = new(T)
	var/datum/powernet/PN = new
	var/obj/machinery/power/terminal/terminal = APC.terminal()

	if(!terminal)
		fail("Test APC did not create a terminal.")
		qdel(PN)
		qdel(APC)
		test_area.apc = previous_apc
		test_area.used_equip = old_used_equip
		test_area.used_light = old_used_light
		test_area.used_environ = old_used_environ
		test_area.oneoff_equip = old_oneoff_equip
		test_area.oneoff_light = old_oneoff_light
		test_area.oneoff_environ = old_oneoff_environ
		return 1

	terminal.powernet = PN
	APC.autoflag = FALSE
	APC.equipment = POWERCHAN_ON
	APC.lighting = POWERCHAN_OFF
	APC.environ = POWERCHAN_OFF

	test_area.used_equip = 1200
	test_area.used_light = 0
	test_area.used_environ = 0
	test_area.oneoff_equip = 0
	test_area.oneoff_light = 0
	test_area.oneoff_environ = 0

	PN.shadow_solver_force_fea_only = FALSE
	PN.shadow_solver_write_enabled = TRUE
	PN.set_shadow_solver_write_mode("pilot_apc_enforced")
	PN.shadow_solver_apc_cap_floor_ratio = 0
	PN.update_apc_advisory(list("primary_demand" = 2400, "served_primary" = 600), 2)

	var/capped_usage = APC.get_power_usage()
	if(capped_usage != 300)
		fail("Expected enforced APC budget 300 before topology change, got [capped_usage].")
		qdel(PN)
		qdel(APC)
		test_area.apc = previous_apc
		test_area.used_equip = old_used_equip
		test_area.used_light = old_used_light
		test_area.used_environ = old_used_environ
		test_area.oneoff_equip = old_oneoff_equip
		test_area.oneoff_light = old_oneoff_light
		test_area.oneoff_environ = old_oneoff_environ
		return 1

	PN.mark_shadow_solver_topology_dirty()
	var/post_dirty_usage = APC.get_power_usage()
	if(post_dirty_usage != 1200)
		fail("Topology-dirty powernet should stop enforcing APC cap immediately; expected 1200, got [post_dirty_usage].")
		qdel(PN)
		qdel(APC)
		test_area.apc = previous_apc
		test_area.used_equip = old_used_equip
		test_area.used_light = old_used_light
		test_area.used_environ = old_used_environ
		test_area.oneoff_equip = old_oneoff_equip
		test_area.oneoff_light = old_oneoff_light
		test_area.oneoff_environ = old_oneoff_environ
		return 1

	PN.update_apc_advisory(list("primary_demand" = 2400, "served_primary" = 1000), 2)
	var/recapped_usage = APC.get_power_usage()
	if(recapped_usage != 500)
		fail("Expected refreshed APC budget 500 after advisory rebuild, got [recapped_usage].")
		qdel(PN)
		qdel(APC)
		test_area.apc = previous_apc
		test_area.used_equip = old_used_equip
		test_area.used_light = old_used_light
		test_area.used_environ = old_used_environ
		test_area.oneoff_equip = old_oneoff_equip
		test_area.oneoff_light = old_oneoff_light
		test_area.oneoff_environ = old_oneoff_environ
		return 1

	qdel(PN)
	qdel(APC)
	test_area.apc = previous_apc
	test_area.used_equip = old_used_equip
	test_area.used_light = old_used_light
	test_area.used_environ = old_used_environ
	test_area.oneoff_equip = old_oneoff_equip
	test_area.oneoff_light = old_oneoff_light
	test_area.oneoff_environ = old_oneoff_environ
	pass("APC enforced caps are skipped while topology is dirty and resume only after fresh advisory data exists.")
	return 1


/datum/unit_test/power_shadow_smes_terminal_profiles
	name = "POWER SHADOW: SMES terminal profiles stay scoped to the correct powernet"

/datum/unit_test/power_shadow_smes_terminal_profiles/start_test()
	var/turf/T = get_space_turf()
	if(!istype(T))
		fail("Failed to find an isolated turf for SMES terminal profile testing.")
		return 1

	var/turf/input_turf_a = get_step(T, NORTH)
	var/turf/input_turf_b = get_step(T, EAST)
	if(!istype(input_turf_a) || !istype(input_turf_b))
		fail("Failed to find adjacent turfs for SMES terminal profile testing.")
		return 1

	var/obj/machinery/power/smes/buildable/SMES = new(T)
	var/list/terminal_parts = list()
	for(var/obj/item/stock_parts/power/terminal/part in SMES.component_parts)
		terminal_parts += part

	if(length(terminal_parts) < 2)
		fail("Test SMES did not have enough terminal parts to exercise input powernets.")
		qdel(SMES)
		return 1

	var/obj/machinery/power/terminal/input_term_a = new(input_turf_a)
	var/obj/machinery/power/terminal/input_term_b = new(input_turf_b)
	var/obj/item/stock_parts/power/terminal/part_a = terminal_parts[1]
	var/obj/item/stock_parts/power/terminal/part_b = terminal_parts[2]
	part_a.set_terminal(SMES, input_term_a)
	part_b.set_terminal(SMES, input_term_b)

	var/datum/powernet/output_net = new
	var/datum/powernet/input_net = new
	SMES.powernet = output_net
	input_term_a.powernet = input_net
	input_term_b.powernet = input_net

	SMES.charge = round(SMES.capacity / 2)
	SMES.input_attempt = TRUE
	SMES.output_attempt = TRUE
	SMES.input_cut = FALSE
	SMES.input_pulsed = FALSE
	SMES.output_cut = FALSE
	SMES.output_pulsed = FALSE
	SMES.input_level = min(50000, SMES.input_level_max)
	SMES.output_level = min(75000, SMES.output_level_max)

	var/expected_supply = SMES.get_shadow_solver_output_supply()
	var/expected_deferred_demand = SMES.get_shadow_solver_deferred_demand()

	var/list/output_profile = SMES.power_solver_shadow_profile()
	if(!islist(output_profile))
		fail("Output-side SMES profile should expose supply on its output powernet.")
		qdel(SMES)
		qdel(output_net)
		qdel(input_net)
		return 1

	if(output_profile["supply"] != expected_supply || output_profile["deferred_demand"] != 0)
		fail("Output-side SMES profile leaked wrong values; expected supply [expected_supply] and deferred demand 0, got supply [output_profile["supply"]] and deferred demand [output_profile["deferred_demand"]].")
		qdel(SMES)
		qdel(output_net)
		qdel(input_net)
		return 1

	var/list/input_profile_a = input_term_a.power_solver_shadow_profile()
	var/list/input_profile_b = input_term_b.power_solver_shadow_profile()
	if(!islist(input_profile_a))
		fail("Primary input-side SMES terminal should report deferred demand.")
		qdel(SMES)
		qdel(output_net)
		qdel(input_net)
		return 1

	if(input_profile_a["supply"] != 0 || input_profile_a["deferred_demand"] != expected_deferred_demand)
		fail("Input-side SMES terminal leaked supply or wrong deferred demand; expected supply 0 and deferred demand [expected_deferred_demand], got supply [input_profile_a["supply"]] and deferred demand [input_profile_a["deferred_demand"]].")
		qdel(SMES)
		qdel(output_net)
		qdel(input_net)
		return 1

	if(input_profile_b)
		fail("Duplicate SMES terminals on the same input powernet should not report deferred demand twice.")
		qdel(SMES)
		qdel(output_net)
		qdel(input_net)
		return 1

	qdel(SMES)
	qdel(output_net)
	qdel(input_net)
	pass("SMES solver profiles keep output supply on the output net and report input demand only once per input powernet.")
	return 1


/datum/unit_test/power_shadow_smes_input_power_target_cap
	name = "POWER SHADOW: SMES input path respects target load per input powernet"

/datum/unit_test/power_shadow_smes_input_power_target_cap/start_test()
	var/turf/T = get_space_turf()
	if(!istype(T))
		fail("Failed to find an isolated turf for SMES input power cap testing.")
		return 1

	var/turf/input_turf_a = get_step(T, SOUTH)
	var/turf/input_turf_b = get_step(T, WEST)
	if(!istype(input_turf_a) || !istype(input_turf_b))
		fail("Failed to find adjacent turfs for SMES input power cap testing.")
		return 1

	var/obj/machinery/power/smes/buildable/SMES = new(T)
	var/list/terminal_parts = list()
	for(var/obj/item/stock_parts/power/terminal/part in SMES.component_parts)
		terminal_parts += part

	if(length(terminal_parts) < 2)
		fail("Test SMES did not have enough terminal parts to exercise duplicate input terminals.")
		qdel(SMES)
		return 1

	var/obj/machinery/power/terminal/input_term_a = new(input_turf_a)
	var/obj/machinery/power/terminal/input_term_b = new(input_turf_b)
	var/obj/item/stock_parts/power/terminal/part_a = terminal_parts[1]
	var/obj/item/stock_parts/power/terminal/part_b = terminal_parts[2]
	part_a.set_terminal(SMES, input_term_a)
	part_b.set_terminal(SMES, input_term_b)

	var/datum/powernet/input_net = new
	input_net.avail = 200000
	input_net.load = 0
	input_term_a.powernet = input_net
	input_term_b.powernet = input_net

	SMES.charge = 0
	SMES.target_load = 50000
	SMES.input_available = 0
	SMES.inputting = 0

	SMES.input_power(100, input_net)

	if(SMES.input_available != 50000)
		fail("SMES drew [SMES.input_available]W from a single input powernet with duplicate terminals; expected exactly 50000W.")
		qdel(SMES)
		qdel(input_net)
		return 1

	if(input_net.load != 50000)
		fail("Input powernet load increased by [input_net.load]W; expected exactly 50000W from capped SMES input.")
		qdel(SMES)
		qdel(input_net)
		return 1

	if(SMES.charge != 50000 * CELLRATE)
		fail("SMES charge increased by [SMES.charge]J; expected [50000 * CELLRATE]J after capped input.")
		qdel(SMES)
		qdel(input_net)
		return 1

	qdel(SMES)
	qdel(input_net)
	pass("SMES input path does not overdraw a single input powernet when duplicate terminals share that net.")
	return 1


/datum/unit_test/power_smes_display_state_latches_between_power_phases
	name = "POWER: SMES display keeps charging state between machine and powernet phases"

/datum/unit_test/power_smes_display_state_latches_between_power_phases/start_test()
	var/turf/T = get_safe_turf()
	if(!istype(T))
		fail("Failed to find a safe turf for SMES display state testing.")
		return 1

	var/obj/machinery/power/smes/buildable/SMES = new(T)
	SMES.set_broken(FALSE)
	SMES.inputting(TRUE)
	SMES.inputting = 2
	SMES.input_available = 50000

	SMES.Process()

	if(SMES.get_display_inputting() != 2)
		fail("SMES display state dropped charging status between machine and powernet phases; expected 2, got [SMES.get_display_inputting()].")
		qdel(SMES)
		return 1

	if(SMES.get_display_input_available() != 50000)
		fail("SMES display state dropped input draw between machine and powernet phases; expected 50000W, got [SMES.get_display_input_available()]W.")
		qdel(SMES)
		return 1

	SMES.Process()

	if(SMES.get_display_inputting() != 0)
		fail("SMES display state did not clear after a full tick without charging; expected 0, got [SMES.get_display_inputting()].")
		qdel(SMES)
		return 1

	if(SMES.get_display_input_available() != 0)
		fail("SMES display input draw did not clear after a full tick without charging; expected 0W, got [SMES.get_display_input_available()]W.")
		qdel(SMES)
		return 1

	SMES.inputting(TRUE)
	SMES.inputting = 2
	SMES.input_available = 50000
	SMES.inputting(FALSE)

	if(SMES.get_display_inputting() != 0 || SMES.get_display_input_available() != 0)
		fail("SMES display state did not clear immediately when charging mode was toggled off.")
		qdel(SMES)
		return 1

	qdel(SMES)
	pass("SMES display keeps the most recent completed charging state until the next power phase, and clears immediately when charging is disabled.")
	return 1


/datum/unit_test/power_shadow_tier_selection_coarse
	name = "POWER SHADOW: Coarse tier selected for small no-APC networks"

/datum/unit_test/power_shadow_tier_selection_coarse/start_test()
	var/datum/powernet/PN = new
	PN.shadow_solver_enabled = TRUE
	PN.avail = 30000
	PN.load = 10000
	PN.smes_demand = 0
	PN.apc_terminal_count = 0
	PN.apc_terminal_count_dirty = FALSE

	PN.select_shadow_solver_tier()
	if(PN.shadow_solver_tier != "coarse")
		fail("Expected coarse tier for small no-APC network, got [PN.shadow_solver_tier].")
		qdel(PN)
		return 1

	// Above 50kW threshold should not be coarse
	PN.avail = 60000
	PN.select_shadow_solver_tier()
	if(PN.shadow_solver_tier == "coarse")
		fail("Expected non-coarse tier for network above 50kW, got [PN.shadow_solver_tier].")
		qdel(PN)
		return 1

	qdel(PN)
	pass("Coarse tier correctly selected for small no-APC networks.")
	return 1


/datum/unit_test/power_shadow_tier_selection_refined
	name = "POWER SHADOW: Refined tier selected when contention exists"

/datum/unit_test/power_shadow_tier_selection_refined/start_test()
	var/datum/powernet/PN = new
	PN.shadow_solver_enabled = TRUE
	PN.avail = 100000
	PN.load = 90000
	PN.apc_terminal_count = 3
	PN.apc_terminal_count_dirty = FALSE
	PN.shadow_solver_last_unserved = 0

	// 90% load with 3 APCs -> refined
	PN.select_shadow_solver_tier()
	if(PN.shadow_solver_tier != "refined")
		fail("Expected refined tier at 90% capacity with 3 APCs, got [PN.shadow_solver_tier].")
		qdel(PN)
		return 1

	// 50% load, no contention -> normal
	PN.load = 50000
	PN.select_shadow_solver_tier()
	if(PN.shadow_solver_tier != "normal")
		fail("Expected normal tier at 50% capacity, got [PN.shadow_solver_tier].")
		qdel(PN)
		return 1

	// Nonzero unserved from last tick -> refined
	PN.shadow_solver_last_unserved = 5000
	PN.select_shadow_solver_tier()
	if(PN.shadow_solver_tier != "refined")
		fail("Expected refined tier with nonzero unserved, got [PN.shadow_solver_tier].")
		qdel(PN)
		return 1

	// Tier lock overrides auto-selection
	PN.shadow_solver_tier_locked = TRUE
	PN.shadow_solver_tier = "normal"
	PN.select_shadow_solver_tier()
	if(PN.shadow_solver_tier != "normal")
		fail("Expected locked tier to be preserved, got [PN.shadow_solver_tier].")
		qdel(PN)
		return 1

	qdel(PN)
	pass("Tier selection correctly responds to capacity, unserved state, and tier lock.")
	return 1


/datum/unit_test/power_shadow_proportional_budget
	name = "POWER SHADOW: Refined tier gives proportional APC budgets"

/datum/unit_test/power_shadow_proportional_budget/start_test()
	var/datum/powernet/PN = new
	PN.shadow_solver_tier = "refined"
	PN.shadow_solver_apc_advisory_valid = TRUE
	PN.shadow_solver_last_apc_count = 2
	PN.shadow_solver_last_apc_advisory_primary_demand = 10000
	PN.shadow_solver_last_apc_advisory_served_primary = 8000
	PN.shadow_solver_apc_cap_floor_ratio = 0.1
	PN.avail = 10000

	// APC with 7000W demand should get 70% of 8000 = 5600
	var/budget_large = PN.get_apc_enforced_budget(7000)
	if(isnull(budget_large) || abs(budget_large - 5600) > 1)
		fail("Expected proportional budget ~5600 for 7000W APC, got [budget_large].")
		qdel(PN)
		return 1

	// APC with 3000W demand should get 30% of 8000 = 2400
	var/budget_small = PN.get_apc_enforced_budget(3000)
	if(isnull(budget_small) || abs(budget_small - 2400) > 1)
		fail("Expected proportional budget ~2400 for 3000W APC, got [budget_small].")
		qdel(PN)
		return 1

	// Normal tier: equal budget regardless of demand
	PN.shadow_solver_tier = "normal"
	var/budget_a = PN.get_apc_enforced_budget(7000)
	var/budget_b = PN.get_apc_enforced_budget(3000)
	if(isnull(budget_a) || isnull(budget_b) || budget_a != budget_b)
		fail("Normal tier should give equal budget regardless of demand.")
		qdel(PN)
		return 1

	qdel(PN)
	pass("Proportional APC budgets work correctly in refined tier.")
	return 1


/datum/unit_test/power_shadow_conservative_mode
	name = "POWER SHADOW: Conservative mode blocks deferred demand"

/datum/unit_test/power_shadow_conservative_mode/start_test()
	var/datum/powernet/PN = new
	PN.avail = 100000
	PN.smes_avail = 0
	PN.shadow_solver_enabled = TRUE

	var/turf/T = get_safe_turf()
	var/obj/machinery/power/native_payload_cache_probe/node = new(T)
	node.profile_primary_demand = 50000
	node.profile_deferred_demand = 30000
	node.profile_supply = 0
	PN.nodes[node] = node

	var/datum/power_solver/adaptive_shadow/solver = new
	solver.conservative_mode = FALSE
	var/list/normal_result = solver.solve(PN)

	solver.conservative_mode = TRUE
	var/list/conservative_result = solver.solve(PN)

	// Normal: load should include deferred
	if(normal_result["load"] <= normal_result["served_primary"])
		fail("Normal mode should include deferred in load.")
		qdel(node)
		qdel(PN)
		return 1

	// Conservative: load should equal served_primary (no deferred)
	if(conservative_result["load"] != conservative_result["served_primary"])
		fail("Conservative mode load should equal served_primary (no deferred).")
		qdel(node)
		qdel(PN)
		return 1

	if(conservative_result["deferred_unserved"] != 30000)
		fail("Conservative mode should leave all deferred demand unserved.")
		qdel(node)
		qdel(PN)
		return 1

	qdel(node)
	qdel(PN)
	pass("Conservative mode correctly blocks deferred demand serving.")
	return 1
