#define SSMACHINES_PIPENETS 1
#define SSMACHINES_MACHINERY 2
#define SSMACHINES_APCS 3
#define SSMACHINES_POWERNETS 4
#define SSMACHINES_POWER_OBJECTS 5


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

#define START_PROCESSING_APC(Datum) START_PROCESSING_IN_LIST(Datum, processing_apcs)
#define STOP_PROCESSING_APC(Datum) STOP_PROCESSING_IN_LIST(Datum, processing_apcs)


SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_MACHINERY
	flags = SS_KEEP_TIMING
	var/static/current_step = SSMACHINES_PIPENETS
	var/static/cost_pipenets = 0
	var/static/cost_machinery = 0
	var/static/cost_apcs = 0
	var/static/cost_powernets = 0
	var/static/cost_power_objects = 0
	var/static/list/pipenets = list()
	var/static/list/powernets = list()
	var/static/list/power_objects = list()
	var/static/list/processing = list()
	var/static/list/processing_apcs = list()
	var/static/list/queue = list()
	var/static/list/machinery = list()
	var/static/list/machinery_by_type = list()
	var/debug_type_breakdown = FALSE
	var/list/debug_machine_process_counts = list()
	var/list/debug_machine_process_costs = list()
	var/list/debug_part_process_counts = list()
	var/list/debug_part_process_costs = list()

/datum/controller/subsystem/machines/Recover()
	current_step = SSMACHINES_PIPENETS
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
		current_step = SSMACHINES_APCS
		resumed = FALSE
	if (current_step == SSMACHINES_APCS)
		timer = world.tick_usage
		process_apcs(resumed, no_mc_tick)
		cost_apcs = MC_AVERAGE(cost_apcs, (world.tick_usage - timer) * world.tick_lag)
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

/datum/controller/subsystem/machines/proc/register_processing_apc(obj/machinery/power/apc/apc)
	if(!apc)
		CRASH("Null APC was tried to be registered for processing")

	START_PROCESSING_APC(apc)

/datum/controller/subsystem/machines/proc/unregister_processing_apc(obj/machinery/power/apc/apc)
	if(!apc)
		CRASH("Null APC was tried to be unregistered from processing")

	STOP_PROCESSING_APC(apc)

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
	var/total_processing = length(processing) + length(processing_apcs)
	..({"\
		Queues: \
		Pipes [length(pipenets)] \
		Machines [length(processing)] \
		APCs [length(processing_apcs)] \
		Networks [length(powernets)] \
		Objects [length(power_objects)]\n\
		Costs: \
		Pipes [Round(cost_pipenets)] \
		Machines [Round(cost_machinery)] \
		APCs [Round(cost_apcs)] \
		Networks [Round(cost_powernets)] \
		Objects [Round(cost_power_objects)]\
		[debug_type_breakdown ? " Debug ON" : ""]\n\
		Overall [Roundm(cost ? total_processing / cost : 0, 0.1)]
	"})

/datum/controller/subsystem/machines/VV_static()
	return ..() + list(
		"debug_type_breakdown",
		"debug_machine_process_counts",
		"debug_machine_process_costs",
		"debug_part_process_counts",
		"debug_part_process_costs"
	)

/datum/controller/subsystem/machines/proc/reset_type_debug(notify = TRUE)
	debug_machine_process_counts.Cut()
	debug_machine_process_costs.Cut()
	debug_part_process_counts.Cut()
	debug_part_process_costs.Cut()
	if(notify && usr)
		to_chat(usr, SPAN_NOTICE("SSmachines type breakdown counters reset."))

/datum/controller/subsystem/machines/proc/toggle_type_debug()
	if(usr && !check_rights(R_DEBUG))
		return

	debug_type_breakdown = !debug_type_breakdown
	if(debug_type_breakdown)
		reset_type_debug(FALSE)

	if(usr)
		to_chat(usr, SPAN_NOTICE("SSmachines type breakdown debug [debug_type_breakdown ? "enabled" : "disabled"]."))

/datum/controller/subsystem/machines/proc/debug_record_cost(list/counts, list/costs, key, start_tick_usage, start_time)
	if(isnull(key))
		return

	counts[key] = (counts[key] || 0) + 1
	var/tick_cost = world.tick_usage - start_tick_usage + ((world.time - start_time) / world.tick_lag * 100)
	costs[key] = (costs[key] || 0) + max(tick_cost * world.tick_lag, 0)

/datum/controller/subsystem/machines/proc/get_processing_type_breakdown()
	var/list/breakdown = list()
	for(var/obj/machinery/machine as anything in processing)
		breakdown[machine.type] = (breakdown[machine.type] || 0) + 1
	sortTim(breakdown, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)
	return breakdown

/datum/controller/subsystem/machines/proc/format_type_debug_section(title, list/counts, list/costs, limit = 15)
	var/list/lines = list("[title]:")
	if(!length(costs))
		lines += "  none"
		return jointext(lines, "\n")

	var/list/ranked = costs.Copy()
	sortTim(ranked, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)

	var/i = 0
	for(var/key in ranked)
		i++
		if(i > limit)
			break
		lines += "  [i]. [key] | cost [Roundm(costs[key], 0.001)] | calls [counts[key] || 0]"

	return jointext(lines, "\n")

/datum/controller/subsystem/machines/proc/dump_type_debug(limit = 15)
	if(usr && !check_rights(R_DEBUG))
		return

	var/list/report_lines = list()
	report_lines += "SSmachines type breakdown"
	report_lines += "Debug enabled: [debug_type_breakdown ? "yes" : "no"]"
	report_lines += "Current machinery queue: [length(processing)]"
	report_lines += "Current APC queue: [length(processing_apcs)]"

	var/list/current_breakdown = get_processing_type_breakdown()
	report_lines += ""
	report_lines += "Current active machinery types:"
	if(length(current_breakdown))
		var/i = 0
		for(var/key in current_breakdown)
			i++
			if(i > limit)
				break
			report_lines += "  [i]. [key] | active [current_breakdown[key]]"
	else
		report_lines += "  none"

	report_lines += ""
	report_lines += format_type_debug_section("Machine Process totals", debug_machine_process_counts, debug_machine_process_costs, limit)
	report_lines += ""
	report_lines += format_type_debug_section("Component machine_process totals", debug_part_process_counts, debug_part_process_costs, limit)

	var/report = jointext(report_lines, "\n")
	if(usr)
		usr << browse("<pre>[report]</pre>", "window=ssmachines_type_debug;size=900x700")
	return report


/datum/controller/subsystem/machines/proc/process_pipenets(resumed, no_mc_tick)
	if (!resumed)
		queue = pipenets.Copy()
	var/datum/pipe_network/network
	for (var/i = length(queue) to 1 step -1)
		network = queue[i]
		if (QDELETED(network))
			if (network)
				network.is_processing = null
			pipenets -= network
			continue
		network.Process(wait)
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			queue.Cut(i)
			return


/datum/controller/subsystem/machines/proc/process_machinery(resumed, no_mc_tick)
	if (!resumed)
		queue = processing.Copy()
	var/obj/machinery/machine
	for (var/i = length(queue) to 1 step -1)
		machine = queue[i]
		if (QDELETED(machine))
			if (machine)
				machine.is_processing = null
			processing -= machine
			continue

		if(machine.processing_flags & MACHINERY_PROCESS_COMPONENTS)
			for(var/obj/item/stock_parts/part as anything in machine.processing_parts)
				var/part_result
				if(debug_type_breakdown)
					var/part_start_tick_usage = world.tick_usage
					var/part_start_time = world.time
					part_result = part.machine_process(machine)
					debug_record_cost(debug_part_process_counts, debug_part_process_costs, part.type, part_start_tick_usage, part_start_time)
				else
					part_result = part.machine_process(machine)
				if(part_result == PROCESS_KILL)
					part.stop_processing()

		if(machine.processing_flags & MACHINERY_PROCESS_SELF)
			var/process_result
			if(debug_type_breakdown)
				var/machine_start_tick_usage = world.tick_usage
				var/machine_start_time = world.time
				process_result = machine.Process(wait)
				debug_record_cost(debug_machine_process_counts, debug_machine_process_costs, machine.type, machine_start_tick_usage, machine_start_time)
			else
				process_result = machine.Process(wait)
			if(process_result == PROCESS_KILL)
				STOP_PROCESSING_MACHINE(machine, MACHINERY_PROCESS_SELF)

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			queue.Cut(i)
			return

/datum/controller/subsystem/machines/proc/process_apcs(resumed, no_mc_tick)
	if (!resumed)
		queue = processing_apcs.Copy()
	var/obj/machinery/power/apc/apc
	for (var/i = length(queue) to 1 step -1)
		apc = queue[i]
		if (QDELETED(apc))
			if (apc)
				apc.is_processing = null
			processing_apcs -= apc
			continue

		if(apc.processing_flags & MACHINERY_PROCESS_COMPONENTS)
			for(var/obj/item/stock_parts/part as anything in apc.processing_parts)
				if(part.machine_process(apc) == PROCESS_KILL)
					part.stop_processing(apc)

		apc.process_apc_tick(wait)

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			queue.Cut(i)
			return


/datum/controller/subsystem/machines/proc/process_powernets(resumed, no_mc_tick)
	if (!resumed)
		queue = powernets.Copy()
	var/datum/powernet/network
	for (var/i = length(queue) to 1 step -1)
		network = queue[i]
		if (QDELETED(network))
			if (network)
				network.is_processing = null
			powernets -= network
			continue
		network.reset(wait)
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			queue.Cut(i)
			return


/datum/controller/subsystem/machines/proc/process_power_objects(resumed, no_mc_tick)
	if (!resumed)
		queue = power_objects.Copy()
	var/obj/item/item
	for (var/i = length(queue) to 1 step -1)
		item = queue[i]
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
			queue.Cut(i)
			return


#undef SSMACHINES_PIPENETS
#undef SSMACHINES_MACHINERY
#undef SSMACHINES_APCS
#undef SSMACHINES_POWERNETS
#undef SSMACHINES_POWER_OBJECTS
