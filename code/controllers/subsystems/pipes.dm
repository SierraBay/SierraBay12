SUBSYSTEM_DEF(pipes)
	name = "Pipes"
	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_PIPES
	flags = SS_KEEP_TIMING
	var/static/cost_pipenets = 0
	var/static/list/pipenets = list()
	var/static/pipe_index = 0

/datum/controller/subsystem/pipes/Recover()
	pipe_index = 0
	if(SSmachines)
		SSmachines.sync_legacy_processing_lists()

/datum/controller/subsystem/pipes/Initialize(start_uptime)
	if(SSmachines)
		SSmachines.sync_legacy_processing_lists()
		setup_atmos_machinery(SSmachines.machinery)

/datum/controller/subsystem/pipes/fire(resumed, no_mc_tick)
	var/timer = world.tick_usage
	process_pipenets(resumed, no_mc_tick)
	cost_pipenets = MC_AVERAGE(cost_pipenets, (world.tick_usage - timer) * world.tick_lag)

/datum/controller/subsystem/pipes/UpdateStat(time)
	if(PreventUpdateStat(time))
		return ..()
	..("Queue: [length(pipenets)] | Cost: [Round(cost_pipenets)]")

/datum/controller/subsystem/pipes/proc/start_processing_pipenet(datum/pipe_network/network)
	if(!network)
		CRASH("Null pipe network was tried to be started")

	if(network.is_processing)
		if(network.is_processing == "SSpipes.pipenets")
			return
		crash_with("Failed to start processing. [log_info_line(network)] is already being processed by [network.is_processing] but queue attempt occured on SSpipes.pipenets.")
		return

	network.is_processing = "SSpipes.pipenets"
	pipenets += network
	if(SSmachines)
		SSmachines.sync_legacy_processing_lists()

/datum/controller/subsystem/pipes/proc/stop_processing_pipenet(datum/pipe_network/network)
	if(!network?.is_processing)
		return

	if(network.is_processing != "SSpipes.pipenets")
		crash_with("Failed to stop processing. [log_info_line(network)] is being processed by [network.is_processing] but de-queue attempt occured on SSpipes.pipenets.")
		return

	if(pipenets.Remove(network))
		network.is_processing = null
		return

	crash_with("Failed to stop processing. [log_info_line(network)] is being processed by [network.is_processing] and not found in SSpipes.pipenets.")

/datum/controller/subsystem/pipes/proc/setup_atmos_machinery(list/machines)
	set background = TRUE
	var/list/atmos_machines = list()
	for(var/obj/machinery/atmospherics/machine in machines)
		atmos_machines += machine
	report_progress("Initializing atmos machinery")
	for(var/obj/machinery/atmospherics/machine as anything in atmos_machines)
		machine.atmos_init()
		CHECK_TICK
	report_progress("Initializing pipe networks")
	for(var/obj/machinery/atmospherics/machine as anything in atmos_machines)
		machine.build_network()
		CHECK_TICK

/datum/controller/subsystem/pipes/proc/process_pipenets(resumed, no_mc_tick)
	if(!resumed)
		pipe_index = length(pipenets)
	var/datum/pipe_network/network
	while(pipe_index > 0)
		if(pipe_index > length(pipenets))
			pipe_index = length(pipenets)
			continue
		network = pipenets[pipe_index]
		pipe_index--
		if(QDELETED(network))
			if(network)
				network.is_processing = null
			pipenets -= network
			continue
		network.Process(wait)
		if(no_mc_tick)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			return
