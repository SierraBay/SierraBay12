PROCESSING_SUBSYSTEM_DEF(atmos_machines)
	name = "Atmos Machines"
	priority = SS_PRIORITY_MACHINERY
	wait = 2 SECONDS
	process_proc = TYPE_PROC_REF(/obj/machinery/atmospherics, process_atmos)
