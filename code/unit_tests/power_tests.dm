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
	name = "POWER SHADOW: Auto-repair retunes and backend-switches"

/datum/unit_test/power_shadow_auto_repair_retunes/start_test()
	var/datum/powernet/problem = new
	problem.shadow_solver_backend = "shadow_fea"
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

	if(problem.shadow_solver_backend != "strict_capacity_flow")
		fail("Expected backend fallback to strict_capacity_flow on severe mismatch.")
		qdel(problem)
		return 1

	if(result["backend_switched"] != 1)
		fail("Expected backend_switched count to be 1, got [result["backend_switched"]].")
		qdel(problem)
		return 1

	qdel(problem)
	pass("Auto-repair retune and backend fallback behaved correctly.")
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
