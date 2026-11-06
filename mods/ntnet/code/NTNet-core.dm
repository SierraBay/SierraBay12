#include "terminal\terminal-core.dm"

#define NTNET_ID_MIN_NUMBER 1000
#define NTNET_ID_MAX_NUMBER 9999

/// NTNet ID (such as "AL1234") -> the machine that has it.
GLOBAL_LIST_EMPTY(ntnet_machines_by_id)

// modify core
/obj/machinery
	var/NTNet_id

/obj/machinery/Destroy()
	if(NTNet_id && GLOB.ntnet_machines_by_id[NTNet_id] == src)
		GLOB.ntnet_machines_by_id -= NTNet_id
	return ..()

/// Gives the machine a random NTNet ID, such as "AL1234": the prefix and a number no other machine with that prefix got.
/// Once every number of a prefix has been handed out, random_id() logs an error and starts over, so IDs can repeat.
/obj/machinery/proc/assign_ntnet_id(prefix)
	NTNet_id = "[prefix][random_id(prefix, NTNET_ID_MIN_NUMBER, NTNET_ID_MAX_NUMBER)]"
	GLOB.ntnet_machines_by_id[NTNet_id] = src

/// Returns the machine with this NTNet ID, or null.
/proc/get_ntnet_machine(ntnet_id)
	RETURN_TYPE(/obj/machinery)
	return GLOB.ntnet_machines_by_id[ntnet_id]

/obj/machinery/door/airlock/Initialize()
	. = ..()
	if(. != INITIALIZE_HINT_QDEL)
		assign_ntnet_id("AL")

/obj/machinery/firealarm/Initialize()
	. = ..()
	if(. != INITIALIZE_HINT_QDEL)
		assign_ntnet_id("FA")

/obj/machinery/power/apc/Initialize()
	. = ..()
	if(. != INITIALIZE_HINT_QDEL)
		assign_ntnet_id("PC")

/obj/machinery/alarm/Initialize()
	. = ..()
	if(. != INITIALIZE_HINT_QDEL)
		assign_ntnet_id("AA")

/obj/machinery/camera/Initialize()
	. = ..()
	if(. != INITIALIZE_HINT_QDEL)
		assign_ntnet_id("CM")

#undef NTNET_ID_MIN_NUMBER
#undef NTNET_ID_MAX_NUMBER
