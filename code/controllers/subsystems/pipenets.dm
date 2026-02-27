SUBSYSTEM_DEF(pipenets)
	name = "Pipenets"
	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_PIPENETS
	flags = SS_KEEP_TIMING
	var/static/cost_pipenets = 0
	var/static/list/pipenets = list()

/datum/controller/subsystem/pipenets/fire(resumed, no_mc_tick)
	var/timer = world.tick_usage
	process_pipenets(resumed, no_mc_tick)
	cost_pipenets = MC_AVERAGE(cost_pipenets, (world.tick_usage - timer) * world.tick_lag)

/datum/controller/subsystem/pipenets/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..("Queue [length(pipenets)] Cost [Round(cost_pipenets)]")

/datum/controller/subsystem/pipenets/proc/setup_atmos_machinery(list/machines)
	set background = TRUE
	if(!islist(machines) || !length(machines))
		return

	var/list/atmos_machines = list()
	for(var/obj/machinery/atmospherics/machine in machines)
		atmos_machines += machine
	if(!length(atmos_machines))
		return

	report_progress("Initializing atmos machinery")
	for (var/obj/machinery/atmospherics/machine as anything in atmos_machines)
		machine.atmos_init()
		CHECK_TICK
	report_progress("Initializing pipe networks")
	for (var/obj/machinery/atmospherics/machine as anything in atmos_machines)
		machine.build_network()
		CHECK_TICK

/datum/controller/subsystem/pipenets/proc/process_pipenets(resumed, no_mc_tick)
	var/static/pipenets_index = 0
	var/pipenets_len = length(pipenets)
	if(!resumed)
		pipenets_index = pipenets_len
	if(!pipenets_index)
		return

	var/datum/pipe_network/network
	for(var/i = pipenets_index to 1 step -1)
		if(i > pipenets_len)
			pipenets_len = length(pipenets)
			if(i > pipenets_len)
				continue
		network = pipenets[i]
		if(!network)
			continue
		if(QDELETED(network))
			if(network)
				network.is_processing = null
			pipenets -= network
			pipenets_len = max(pipenets_len - 1, 0)
			continue
		network.Process(wait)
		if(no_mc_tick)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			pipenets_index = i - 1
			return
	pipenets_index = 0
