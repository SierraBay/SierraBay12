/obj/item/unit_test_power_object
	name = "unit test power object"

/obj/item/unit_test_power_object/pwr_drain(tick_delay)
	return FALSE

/datum/unit_test/subsystem_split_mirror_lists_are_synced
	name = "MACHINE: Legacy SSmachines mirror lists stay synced to split subsystems"

/datum/unit_test/subsystem_split_mirror_lists_are_synced/start_test()
	if(SSmachines.pipenets != SSpipes.pipenets)
		fail("SSmachines.pipenets should mirror the live SSpipes.pipenets list.")
		return 1
	if(SSmachines.powernets != SSpowernets.powernets)
		fail("SSmachines.powernets should mirror the live SSpowernets.powernets list.")
		return 1
	if(SSmachines.power_objects != SSpowernets.power_objects)
		fail("SSmachines.power_objects should mirror the live SSpowernets.power_objects list.")
		return 1

	pass("Legacy SSmachines list readers now see the split subsystem state directly.")
	return 1

/datum/unit_test/subsystem_split_pipe_macros_target_sspipes
	name = "MACHINE: START_PROCESSING_PIPENET queues work on SSpipes"

/datum/unit_test/subsystem_split_pipe_macros_target_sspipes/start_test()
	var/datum/pipe_network/network = new
	START_PROCESSING_PIPENET(network)

	if(!(network in SSpipes.pipenets))
		fail("START_PROCESSING_PIPENET should queue the network on SSpipes.")
		qdel(network)
		return 1
	if(!(network in SSmachines.pipenets))
		fail("Legacy SSmachines.pipenets should mirror the queued SSpipes network.")
		STOP_PROCESSING_PIPENET(network)
		qdel(network)
		return 1

	STOP_PROCESSING_PIPENET(network)
	if(network in SSpipes.pipenets)
		fail("STOP_PROCESSING_PIPENET should remove the network from SSpipes.")
		qdel(network)
		return 1

	pass("Pipe-network processing macros now target SSpipes while legacy mirrors stay readable.")
	qdel(network)
	return 1

/datum/unit_test/subsystem_split_power_macros_target_sspowernets
	name = "POWER: Powernet and power-object processing now queue on SSpowernets"

/datum/unit_test/subsystem_split_power_macros_target_sspowernets/start_test()
	var/datum/powernet/network = new
	if(!(network in SSpowernets.powernets))
		fail("Fresh powernets should register on SSpowernets.")
		qdel(network)
		return 1
	if(!(network in SSmachines.powernets))
		fail("Legacy SSmachines.powernets should mirror SSpowernets.")
		qdel(network)
		return 1

	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for power-object processing test.")
		qdel(network)
		return 1
	var/obj/item/unit_test_power_object/power_object = new(T)
	START_PROCESSING_POWER_OBJECT(power_object)
	if(!(power_object in SSpowernets.power_objects))
		fail("START_PROCESSING_POWER_OBJECT should queue the object on SSpowernets.")
		qdel(power_object)
		qdel(network)
		return 1
	if(!(power_object in SSmachines.power_objects))
		fail("Legacy SSmachines.power_objects should mirror SSpowernets.")
		STOP_PROCESSING_POWER_OBJECT(power_object)
		qdel(power_object)
		qdel(network)
		return 1

	STOP_PROCESSING_POWER_OBJECT(power_object)
	pass("Power processing is now owned by SSpowernets without breaking legacy list readers.")
	qdel(power_object)
	qdel(network)
	return 1

/datum/unit_test/subsystem_split_legacy_power_setup_forwards
	name = "POWER: SSmachines.setup_powernets_for_cables forwards into SSpowernets"

/datum/unit_test/subsystem_split_legacy_power_setup_forwards/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for powernet setup forwarding test.")
		return 1

	var/obj/structure/cable/cable = new(T)
	cable.d1 = 0
	cable.d2 = NORTH
	SSmachines.setup_powernets_for_cables(list(cable))

	if(!cable.powernet)
		fail("Legacy SSmachines.setup_powernets_for_cables should still assign a powernet.")
		qdel(cable)
		return 1
	if(!(cable.powernet in SSpowernets.powernets))
		fail("Legacy powernet setup should populate SSpowernets, not an internal SSmachines list.")
		qdel(cable)
		return 1

	pass("Legacy powernet setup now forwards to SSpowernets.")
	qdel(cable)
	return 1

/datum/unit_test/subsystem_split_legacy_atmos_setup_forwards
	name = "MACHINE: SSmachines.setup_atmos_machinery forwards into SSpipes"

/datum/unit_test/subsystem_split_legacy_atmos_setup_forwards/start_test()
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for atmos setup forwarding test.")
		return 1

	var/obj/machinery/atmospherics/pipe/simple/hidden/supply/pipe = new(T)
	SSmachines.setup_atmos_machinery(list(pipe))

	if(!pipe.parent?.network)
		fail("Legacy SSmachines.setup_atmos_machinery should still build pipe networks.")
		qdel(pipe)
		return 1
	if(!(pipe.parent.network in SSpipes.pipenets))
		fail("Legacy atmos setup should populate SSpipes, not an internal SSmachines list.")
		qdel(pipe)
		return 1

	pass("Legacy atmos setup now forwards to SSpipes.")
	qdel(pipe)
	return 1

/datum/unit_test/subsystem_split_pipe_recover_preserves_bookkeeping
	name = "MACHINE: SSpipes.Recover preserves queued pipe networks"

/datum/unit_test/subsystem_split_pipe_recover_preserves_bookkeeping/start_test()
	var/datum/pipe_network/network = new
	START_PROCESSING_PIPENET(network)
	SSpipes.pipe_index = 0
	SSpipes.Recover()

	if(!(network in SSpipes.pipenets))
		fail("SSpipes.Recover should not lose queued pipe networks.")
		qdel(network)
		return 1
	if(SSmachines.pipenets != SSpipes.pipenets)
		fail("SSpipes.Recover should resync the legacy SSmachines.pipenets mirror.")
		STOP_PROCESSING_PIPENET(network)
		qdel(network)
		return 1

	STOP_PROCESSING_PIPENET(network)
	pass("SSpipes.Recover resets indices without dropping queued networks.")
	qdel(network)
	return 1

/datum/unit_test/subsystem_split_power_recover_preserves_bookkeeping
	name = "POWER: SSpowernets.Recover preserves queued powernets and power objects"

/datum/unit_test/subsystem_split_power_recover_preserves_bookkeeping/start_test()
	var/datum/powernet/network = new
	var/turf/T = get_safe_turf()
	if(!T)
		fail("Could not find a safe turf for powernet recover test.")
		qdel(network)
		return 1
	var/obj/item/unit_test_power_object/power_object = new(T)
	START_PROCESSING_POWER_OBJECT(power_object)

	SSpowernets.powernet_index = 0
	SSpowernets.power_obj_index = 0
	SSpowernets.Recover()

	if(!(network in SSpowernets.powernets))
		fail("SSpowernets.Recover should not lose queued powernets.")
		qdel(power_object)
		qdel(network)
		return 1
	if(!(power_object in SSpowernets.power_objects))
		fail("SSpowernets.Recover should not lose queued power objects.")
		qdel(power_object)
		qdel(network)
		return 1
	if(SSmachines.powernets != SSpowernets.powernets || SSmachines.power_objects != SSpowernets.power_objects)
		fail("SSpowernets.Recover should resync the legacy SSmachines mirror lists.")
		STOP_PROCESSING_POWER_OBJECT(power_object)
		qdel(power_object)
		qdel(network)
		return 1

	STOP_PROCESSING_POWER_OBJECT(power_object)
	pass("SSpowernets.Recover resets indices without dropping queued power work.")
	qdel(power_object)
	qdel(network)
	return 1
