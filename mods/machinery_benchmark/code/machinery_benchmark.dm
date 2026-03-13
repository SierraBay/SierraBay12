/datum/machinery_benchmark_result
	var/name = "unnamed"
	var/iterations = 0
	var/elapsed_ds = 0
	var/average_us = 0
	var/details = ""

/datum/machinery_benchmark_case
	var/name = "unnamed"
	var/details = ""
	var/atom/test_atom

/datum/machinery_benchmark_case/proc/setup(turf/T)
	return TRUE

/datum/machinery_benchmark_case/proc/run_once()
	return

/datum/machinery_benchmark_case/proc/cleanup()
	if(test_atom)
		qdel(test_atom)
		test_atom = null

/datum/machinery_benchmark_case/noop
	name = "Loop baseline"
	details = "Measures benchmark harness overhead without machinery work."

/datum/machinery_benchmark_case/noop/setup(turf/T)
	return TRUE

/datum/machinery_benchmark_case/canister_closed
	name = "Canister.Process() closed"
	details = "Portable atmos baseline with the valve closed."

/datum/machinery_benchmark_case/canister_closed/setup(turf/T)
	var/obj/machinery/portable_atmospherics/canister/air/canister = new(T)
	test_atom = canister
	canister.valve_open = FALSE
	canister.release_pressure = 10 * ONE_ATMOSPHERE
	return TRUE

/datum/machinery_benchmark_case/canister_closed/run_once()
	var/obj/machinery/portable_atmospherics/canister/canister = test_atom
	canister.Process()

/datum/machinery_benchmark_case/canister_open
	name = "Canister.Process() open"
	details = "Portable atmos with active pressure equalization."

/datum/machinery_benchmark_case/canister_open/setup(turf/T)
	var/obj/machinery/portable_atmospherics/canister/air/canister = new(T)
	test_atom = canister
	canister.valve_open = TRUE
	canister.release_pressure = 10 * ONE_ATMOSPHERE
	return TRUE

/datum/machinery_benchmark_case/canister_open/run_once()
	var/obj/machinery/portable_atmospherics/canister/canister = test_atom
	canister.Process()

/datum/machinery_benchmark_case/vent_pump_idle
	name = "Vent pump Process()"
	details = "Vent pump hot path without a connected network."

/datum/machinery_benchmark_case/vent_pump_idle/setup(turf/T)
	var/obj/machinery/atmospherics/unary/vent_pump/on/pump = new(T)
	test_atom = pump
	pump.welded = FALSE
	pump.update_use_power(POWER_USE_IDLE)
	return TRUE

/datum/machinery_benchmark_case/vent_pump_idle/run_once()
	var/obj/machinery/atmospherics/unary/vent_pump/pump = test_atom
	pump.Process()

/datum/machinery_benchmark_case/vent_scrubber_idle
	name = "Vent scrubber Process()"
	details = "Vent scrubber hot path without a connected network."

/datum/machinery_benchmark_case/vent_scrubber_idle/setup(turf/T)
	var/obj/machinery/atmospherics/unary/vent_scrubber/on/scrubber = new(T)
	test_atom = scrubber
	scrubber.welded = FALSE
	scrubber.update_use_power(POWER_USE_IDLE)
	return TRUE

/datum/machinery_benchmark_case/vent_scrubber_idle/run_once()
	var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber = test_atom
	scrubber.Process()

/datum/machinery_benchmark_case/alarm_recheck
	name = "Air alarm recheck cycle"
	details = "queue_atmos_recheck() plus Process() on a single alarm."

/datum/machinery_benchmark_case/alarm_recheck/setup(turf/T)
	var/obj/machinery/alarm/alarm = new(T)
	test_atom = alarm
	return TRUE

/datum/machinery_benchmark_case/alarm_recheck/run_once()
	var/obj/machinery/alarm/alarm = test_atom
	alarm.queue_atmos_recheck()
	alarm.Process()

/datum/machinery_benchmark_case/shield_diffuser
	name = "Shield diffuser Process()"
	details = "Neighbour scan for shields with no nearby barriers."

/datum/machinery_benchmark_case/shield_diffuser/setup(turf/T)
	var/obj/machinery/shield_diffuser/diffuser = new(T)
	test_atom = diffuser
	diffuser.enabled = TRUE
	diffuser.alarm = FALSE
	return TRUE

/datum/machinery_benchmark_case/shield_diffuser/run_once()
	var/obj/machinery/shield_diffuser/diffuser = test_atom
	diffuser.Process()

/datum/machinery_benchmark_suite
	var/minimum_duration_ds = 10
	var/max_iterations = 131072
	var/warmup_iterations = 64
	var/top_type_limit = 12

/datum/machinery_benchmark_suite/proc/get_safe_turf()
	for(var/obj/landmark/test/safe_turf/landmark in landmarks_list)
		var/turf/T = get_turf(landmark)
		if(T)
			return T
	return locate(1, 1, 1)

/datum/machinery_benchmark_suite/proc/get_cases()
	return list(
		new /datum/machinery_benchmark_case/noop,
		new /datum/machinery_benchmark_case/canister_closed,
		new /datum/machinery_benchmark_case/canister_open,
		new /datum/machinery_benchmark_case/vent_pump_idle,
		new /datum/machinery_benchmark_case/vent_scrubber_idle,
		new /datum/machinery_benchmark_case/alarm_recheck,
		new /datum/machinery_benchmark_case/shield_diffuser,
	)

/datum/machinery_benchmark_suite/proc/run_case(datum/machinery_benchmark_case/case, turf/T)
	if(!case.setup(T))
		case.cleanup()
		return null

	for(var/i in 1 to warmup_iterations)
		case.run_once()

	var/iterations = 128
	var/elapsed_ds = 0
	while(iterations <= max_iterations)
		var/start = uptime()
		for(var/i in 1 to iterations)
			case.run_once()
		elapsed_ds = max(1, uptime() - start)
		if(elapsed_ds >= minimum_duration_ds)
			break
		iterations *= 2

	var/datum/machinery_benchmark_result/result = new
	result.name = case.name
	result.iterations = iterations
	result.elapsed_ds = elapsed_ds
	result.average_us = round((elapsed_ds * 100000) / max(1, iterations), 0.01)
	result.details = case.details
	case.cleanup()
	return result

/datum/machinery_benchmark_suite/proc/append_snapshot_lines(list/lines)
	lines += "SSmachines snapshot"
	lines += "  processing_high: [length(SSmachines.processing_high)]"
	lines += "  processing_normal: [length(SSmachines.processing_normal)]"
	lines += "  processing_low: [length(SSmachines.processing_low)]"
	lines += "  pipenets: [length(SSmachines.pipenets)]"
	lines += "  powernets: [length(SSmachines.powernets)]"
	lines += "  power objects: [length(SSmachines.power_objects)]"
	lines += ""

	var/list/type_counts = list()
	for(var/atom/movable/item in SSmachines.processing_high)
		if(QDELETED(item))
			continue
		type_counts[item.type] = (type_counts[item.type] || 0) + 1
	for(var/atom/movable/item in SSmachines.processing_normal)
		if(QDELETED(item))
			continue
		type_counts[item.type] = (type_counts[item.type] || 0) + 1
	for(var/atom/movable/item in SSmachines.processing_low)
		if(QDELETED(item))
			continue
		type_counts[item.type] = (type_counts[item.type] || 0) + 1

	if(!length(type_counts))
		lines += "Active processing types: none"
		lines += ""
		return

	lines += "Top active machinery types"
	for(var/rank in 1 to top_type_limit)
		var/best_type = null
		var/best_count = 0
		for(var/typepath in type_counts)
			var/count = type_counts[typepath]
			if(count > best_count)
				best_type = typepath
				best_count = count
		if(!best_type)
			break
		lines += "  [rank]. [best_type]: [best_count]"
		type_counts -= best_type
	lines += ""

/datum/machinery_benchmark_suite/proc/build_report(list/results)
	var/list/lines = list()
	lines += "Machinery Benchmark"
	lines += "Clock source: uptime() deciseconds. Results are approximate; compare runs with the same profile size."
	lines += "Profile target: at least [minimum_duration_ds / 10]s per case, up to [max_iterations] iterations."
	lines += ""
	append_snapshot_lines(lines)
	lines += "Synthetic cases"
	for(var/datum/machinery_benchmark_result/result in results)
		lines += "  [result.name]"
		lines += "    iterations: [result.iterations]"
		lines += "    elapsed: [round(result.elapsed_ds / 10, 0.1)]s"
		lines += "    avg: [result.average_us] us/op"
		if(result.details)
			lines += "    note: [result.details]"
	return jointext(lines, "\n")

/datum/machinery_benchmark_suite/proc/run_benchmark(client/C)
	var/turf/T = get_safe_turf()
	if(!T)
		return null

	var/list/results = list()
	for(var/datum/machinery_benchmark_case/case as anything in get_cases())
		var/datum/machinery_benchmark_result/result = run_case(case, T)
		if(result)
			results += result
		stoplag(1)

	return build_report(results)

/client/proc/run_machinery_benchmark()
	set name = "Run Machinery Benchmark"
	set category = "Debug"
	set desc = "Runs a synthetic machinery microbenchmark and shows the current SSmachines queue snapshot."
	set waitfor = FALSE

	if(!check_rights(R_DEBUG))
		return

	var/profile
	profile = input(src, "Choose benchmark duration. Longer profiles are stabler, but block the server longer.", "Machinery Benchmark", "Balanced") as null|anything in list("Quick", "Balanced", "Long")
	if(!profile)
		return

	var/datum/machinery_benchmark_suite/suite = new
	switch(profile)
		if("Quick")
			suite.minimum_duration_ds = 5
			suite.max_iterations = 32768
		if("Balanced")
			suite.minimum_duration_ds = 10
			suite.max_iterations = 131072
		if("Long")
			suite.minimum_duration_ds = 20
			suite.max_iterations = 262144

	to_chat(src, SPAN_NOTICE("Machinery benchmark started. This is a synthetic benchmark and may briefly stall the server while each case runs."))
	log_and_message_admins("started the machinery benchmark ([profile]).")

	var/report = suite.run_benchmark(src)
	if(!report)
		to_chat(src, SPAN_WARNING("Machinery benchmark failed: could not find a safe turf."))
		return

	show_browser(src, "<html><body><pre>[html_encode(report)]</pre></body></html>", "window=machinery_benchmark;size=960x720")
	to_chat(src, SPAN_NOTICE("Machinery benchmark finished. Report opened in a browser window."))
