SUBSYSTEM_DEF(powernets)
	name = "Powernets"
	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_POWERNETS
	flags = SS_KEEP_TIMING
	var/static/cost_powernets = 0
	var/static/cost_power_objects = 0
	var/static/list/powernets = list()
	var/static/list/power_objects = list()
	var/static/powernet_index = 0
	var/static/power_obj_index = 0

/datum/controller/subsystem/powernets/Recover()
	powernet_index = 0
	power_obj_index = 0
	if(SSmachines)
		SSmachines.sync_legacy_processing_lists()

/datum/controller/subsystem/powernets/Initialize(start_uptime)
	if(SSmachines)
		SSmachines.sync_legacy_processing_lists()
	makepowernets()

/datum/controller/subsystem/powernets/fire(resumed, no_mc_tick)
	var/timer = world.tick_usage
	process_powernets(resumed, no_mc_tick)
	cost_powernets = MC_AVERAGE(cost_powernets, (world.tick_usage - timer) * world.tick_lag)
	if(state != SS_RUNNING)
		return

	timer = world.tick_usage
	process_power_objects(resumed, no_mc_tick)
	cost_power_objects = MC_AVERAGE(cost_power_objects, (world.tick_usage - timer) * world.tick_lag)

/datum/controller/subsystem/powernets/UpdateStat(time)
	if(PreventUpdateStat(time))
		return ..()
	..("Queues: Networks [length(powernets)] Objects [length(power_objects)] | Costs: Networks [Round(cost_powernets)] Objects [Round(cost_power_objects)]")

/datum/controller/subsystem/powernets/proc/start_processing_powernet(datum/powernet/network)
	if(!network)
		CRASH("Null powernet was tried to be started")

	if(network.is_processing)
		if(network.is_processing == "SSpowernets.powernets")
			return
		crash_with("Failed to start processing. [log_info_line(network)] is already being processed by [network.is_processing] but queue attempt occured on SSpowernets.powernets.")
		return

	network.is_processing = "SSpowernets.powernets"
	powernets += network
	if(SSmachines)
		SSmachines.sync_legacy_processing_lists()

/datum/controller/subsystem/powernets/proc/stop_processing_powernet(datum/powernet/network)
	if(!network?.is_processing)
		return

	if(network.is_processing != "SSpowernets.powernets")
		crash_with("Failed to stop processing. [log_info_line(network)] is being processed by [network.is_processing] but de-queue attempt occured on SSpowernets.powernets.")
		return

	if(powernets.Remove(network))
		network.is_processing = null
		return

	crash_with("Failed to stop processing. [log_info_line(network)] is being processed by [network.is_processing] and not found in SSpowernets.powernets.")

/datum/controller/subsystem/powernets/proc/start_processing_power_object(obj/item/power_object)
	if(!power_object)
		CRASH("Null power object was tried to be started")

	if(power_object.is_processing)
		if(power_object.is_processing == "SSpowernets.power_objects")
			return
		crash_with("Failed to start processing. [log_info_line(power_object)] is already being processed by [power_object.is_processing] but queue attempt occured on SSpowernets.power_objects.")
		return

	power_object.is_processing = "SSpowernets.power_objects"
	power_objects += power_object
	if(SSmachines)
		SSmachines.sync_legacy_processing_lists()

/datum/controller/subsystem/powernets/proc/stop_processing_power_object(obj/item/power_object)
	if(!power_object?.is_processing)
		return

	if(power_object.is_processing != "SSpowernets.power_objects")
		crash_with("Failed to stop processing. [log_info_line(power_object)] is being processed by [power_object.is_processing] but de-queue attempt occured on SSpowernets.power_objects.")
		return

	if(power_objects.Remove(power_object))
		power_object.is_processing = null
		return

	crash_with("Failed to stop processing. [log_info_line(power_object)] is being processed by [power_object.is_processing] and not found in SSpowernets.power_objects.")

/// Rebuilds power networks from scratch. Called by world initialization and elevators.
/datum/controller/subsystem/powernets/proc/makepowernets()
	for(var/datum/powernet/powernet as anything in powernets)
		qdel(powernet)
	powernets.Cut()
	setup_powernets_for_cables(GLOB.cable_list)

/datum/controller/subsystem/powernets/proc/setup_powernets_for_cables(list/cables)
	for(var/obj/structure/cable/cable as anything in cables)
		if(cable.powernet)
			continue
		var/datum/powernet/network = new
		network.add_cable(cable)
		propagate_network(cable, cable.powernet)

/datum/controller/subsystem/powernets/proc/process_powernets(resumed, no_mc_tick)
	if(!resumed)
		powernet_index = length(powernets)
	var/datum/powernet/network
	while(powernet_index > 0)
		if(powernet_index > length(powernets))
			powernet_index = length(powernets)
			continue
		network = powernets[powernet_index]
		powernet_index--
		if(QDELETED(network))
			if(network)
				network.is_processing = null
			powernets -= network
			continue
		network.reset(wait)
		if(no_mc_tick)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/powernets/proc/process_power_objects(resumed, no_mc_tick)
	if(!resumed)
		power_obj_index = length(power_objects)
	var/obj/item/item
	while(power_obj_index > 0)
		if(power_obj_index > length(power_objects))
			power_obj_index = length(power_objects)
			continue
		item = power_objects[power_obj_index]
		power_obj_index--
		if(QDELETED(item))
			if(item)
				item.is_processing = null
			power_objects -= item
			continue
		if(!item.pwr_drain(wait))
			item.is_processing = null
			power_objects -= item
		if(no_mc_tick)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			return
