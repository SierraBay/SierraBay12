#define SSMACHINES_PIPENETS 1
#define SSMACHINES_MACHINERY 2
#define SSMACHINES_POWERNETS 3
#define SSMACHINES_POWER_OBJECTS 4
#define SSMACHINES_QUEUE_HIGH 1
#define SSMACHINES_QUEUE_NORMAL 2
#define SSMACHINES_QUEUE_LOW 3


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

/datum/machine_sleep_bucket
	var/wake_time = 0
	var/lookup_key = null
	var/list/machines = list()
	var/active = TRUE

/datum/machine_sleep_bucket/New(new_wake_time)
	..()
	wake_time = round(new_wake_time)
	lookup_key = "[wake_time]"


SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_MACHINERY
	flags = SS_KEEP_TIMING
	var/static/current_step = SSMACHINES_PIPENETS
	var/static/cost_pipenets = 0
	var/static/cost_machinery = 0
	var/static/cost_powernets = 0
	var/static/cost_power_objects = 0
	var/static/list/pipenets = list()
	var/static/list/powernets = list()
	var/static/list/power_objects = list()
	var/static/list/processing_high = list()
	var/static/list/processing_normal = list()
	var/static/list/processing_low = list()
	var/static/list/sleeping_machines = list()
	var/static/list/sleep_buckets = list()
	var/static/list/sleep_wake_heap = list()
	var/static/list/dormant_machines = list()
	var/static/list/type_lookup_cache = list()
	var/static/pipe_index = 0
	var/static/machine_priority_step = 1
	var/static/machine_high_index = 0
	var/static/machine_normal_index = 0
	var/static/machine_low_index = 0
	var/static/next_machine_wake = 0
	var/static/datum/machine_sleep_bucket/next_machine_wake_bucket = null
	var/static/next_phase_assignment = 0
	var/static/powernet_index = 0
	var/static/power_obj_index = 0
	var/static/list/machinery = list()
	var/static/list/machinery_by_type = list()

/datum/controller/subsystem/machines/Recover()
	current_step = SSMACHINES_PIPENETS
	pipe_index = 0
	machine_priority_step = 1
	machine_high_index = 0
	machine_normal_index = 0
	machine_low_index = 0
	recalculate_next_machine_wake()
	powernet_index = 0
	power_obj_index = 0


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
	type_lookup_cache.Cut()
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
	type_lookup_cache.Cut()

	var/area/A = get_area(machine)
	if(A)
		LAZYREMOVE(A.machinery_list, machine)

/datum/controller/subsystem/machines/proc/get_machinery_of_type(obj/machinery/machinery_type)
	if(!machinery_type)
		return list()

	if(!ispath(machinery_type))
		machinery_type = machinery_type.type

	if(!ispath(machinery_type, /obj/machinery))
		CRASH("Non-machinery type passed in `/datum/controller/subsystem/machines/proc/get_machinery_of_type`")

	var/list/cached = type_lookup_cache[machinery_type]
	if(cached)
		return cached.Copy()

	var/list/machinery = list()
	if(machinery_type == /obj/machinery)
		machinery = get_all_machinery()
	else
		for(var/type in typesof(machinery_type))
			var/list/machinery_of_type = machinery_by_type[type]
			if(machinery_of_type)
				machinery += machinery_of_type

	type_lookup_cache[machinery_type] = machinery
	return machinery.Copy()

/datum/controller/subsystem/machines/proc/get_all_machinery()
	return machinery.Copy()

/datum/controller/subsystem/machines/proc/get_machine_processing_queue_id(process_priority = 2)
	switch(process_priority)
		if(1)
			return SSMACHINES_QUEUE_HIGH
		if(3)
			return SSMACHINES_QUEUE_LOW
	return SSMACHINES_QUEUE_NORMAL

/datum/controller/subsystem/machines/proc/get_machine_processing_list(queue_id = SSMACHINES_QUEUE_NORMAL)
	switch(queue_id)
		if(SSMACHINES_QUEUE_HIGH)
			return processing_high
		if(SSMACHINES_QUEUE_LOW)
			return processing_low
	return processing_normal

/datum/controller/subsystem/machines/proc/get_machine_processing_label(queue_id)
	switch(queue_id)
		if(SSMACHINES_QUEUE_HIGH)
			return "SSmachines.processing_high"
		if(SSMACHINES_QUEUE_NORMAL)
			return "SSmachines.processing_normal"
		if(SSMACHINES_QUEUE_LOW)
			return "SSmachines.processing_low"
	return "[queue_id]"

/datum/controller/subsystem/machines/proc/get_machine_sleep_wake_time(obj/machinery/machine)
	var/datum/machine_sleep_bucket/bucket = sleeping_machines[machine]
	if(!istype(bucket, /datum/machine_sleep_bucket))
		return null
	return bucket.wake_time

/datum/controller/subsystem/machines/proc/heap_peek_bucket()
	if(!length(sleep_wake_heap))
		return null
	return sleep_wake_heap[1]

/datum/controller/subsystem/machines/proc/heap_peek_wake_time()
	var/datum/machine_sleep_bucket/bucket = heap_peek_bucket()
	if(!bucket)
		return 0
	return bucket.wake_time

/datum/controller/subsystem/machines/proc/get_or_create_sleep_bucket(wake_time)
	wake_time = round(wake_time)
	var/lookup_key = "[wake_time]"
	var/datum/machine_sleep_bucket/bucket = sleep_buckets[lookup_key]
	if(bucket)
		return bucket

	bucket = new(wake_time)
	sleep_buckets[lookup_key] = bucket
	heap_push_wake_time(bucket)
	return bucket

/datum/controller/subsystem/machines/proc/deactivate_sleep_bucket(datum/machine_sleep_bucket/bucket)
	if(!bucket || !bucket.active)
		return

	bucket.active = FALSE
	if(bucket.lookup_key && sleep_buckets[bucket.lookup_key] == bucket)
		sleep_buckets -= bucket.lookup_key

	if(bucket == next_machine_wake_bucket)
		next_machine_wake_bucket = null
		next_machine_wake = 0

/datum/controller/subsystem/machines/proc/get_machine_processing_list_by_id(queue_id)
	switch(queue_id)
		if(SSMACHINES_QUEUE_HIGH)
			return processing_high
		if(SSMACHINES_QUEUE_NORMAL)
			return processing_normal
		if(SSMACHINES_QUEUE_LOW)
			return processing_low
	return null

/datum/controller/subsystem/machines/proc/heap_sift_up(index)
	while(index > 1)
		var/parent_index = floor(index / 2)
		var/datum/machine_sleep_bucket/parent_bucket = sleep_wake_heap[parent_index]
		var/datum/machine_sleep_bucket/current_bucket = sleep_wake_heap[index]
		if(parent_bucket.wake_time <= current_bucket.wake_time)
			return

		sleep_wake_heap[parent_index] = current_bucket
		sleep_wake_heap[index] = parent_bucket
		index = parent_index

/datum/controller/subsystem/machines/proc/heap_sift_down(index)
	var/heap_count = length(sleep_wake_heap)
	while(TRUE)
		var/left_index = index * 2
		if(left_index > heap_count)
			return

		var/right_index = left_index + 1
		var/smallest_index = left_index
		var/datum/machine_sleep_bucket/left_bucket = sleep_wake_heap[left_index]
		var/datum/machine_sleep_bucket/right_bucket = right_index <= heap_count ? sleep_wake_heap[right_index] : null
		if(right_bucket && right_bucket.wake_time < left_bucket.wake_time)
			smallest_index = right_index

		var/datum/machine_sleep_bucket/current_bucket = sleep_wake_heap[index]
		var/datum/machine_sleep_bucket/smallest_bucket = sleep_wake_heap[smallest_index]
		if(current_bucket.wake_time <= smallest_bucket.wake_time)
			return

		sleep_wake_heap[index] = smallest_bucket
		sleep_wake_heap[smallest_index] = current_bucket
		index = smallest_index

/datum/controller/subsystem/machines/proc/heap_push_wake_time(datum/machine_sleep_bucket/bucket)
	if(!bucket)
		return

	sleep_wake_heap += bucket
	heap_sift_up(length(sleep_wake_heap))

/datum/controller/subsystem/machines/proc/heap_pop_wake_time()
	var/heap_count = length(sleep_wake_heap)
	if(!heap_count)
		return null

	var/datum/machine_sleep_bucket/bucket = sleep_wake_heap[1]
	if(heap_count == 1)
		sleep_wake_heap.Cut()
		return bucket

	sleep_wake_heap[1] = sleep_wake_heap[heap_count]
	sleep_wake_heap.Cut(heap_count, heap_count + 1)
	heap_sift_down(1)
	return bucket

/datum/controller/subsystem/machines/proc/refresh_next_machine_wake()
	while(length(sleep_wake_heap))
		var/datum/machine_sleep_bucket/bucket = heap_peek_bucket()
		if(bucket && bucket.active && length(bucket.machines))
			next_machine_wake_bucket = bucket
			next_machine_wake = bucket.wake_time
			return bucket

		heap_pop_wake_time()

	next_machine_wake_bucket = null
	next_machine_wake = 0
	return null

/datum/controller/subsystem/machines/proc/recalculate_next_machine_wake()
	var/list/rebuilt_sleeping_machines = list()
	sleep_buckets.Cut()
	sleep_wake_heap.Cut()
	next_machine_wake_bucket = null
	next_machine_wake = 0

	for(var/obj/machinery/machine as anything in sleeping_machines)
		if(QDELETED(machine) || !machine.processing_flags)
			continue

		var/datum/machine_sleep_bucket/existing_bucket = sleeping_machines[machine]
		var/wake_time = istype(existing_bucket, /datum/machine_sleep_bucket) ? existing_bucket.wake_time : sleeping_machines[machine]
		if(!isnum(wake_time))
			continue

		wake_time = round(wake_time)
		var/datum/machine_sleep_bucket/bucket = get_or_create_sleep_bucket(wake_time)
		bucket.machines += machine
		rebuilt_sleeping_machines[machine] = bucket

	sleeping_machines = rebuilt_sleeping_machines
	refresh_next_machine_wake()

/datum/controller/subsystem/machines/proc/remove_sleep_bookkeeping(obj/machinery/machine)
	if(!machine || !length(sleeping_machines))
		return null

	var/datum/machine_sleep_bucket/bucket = sleeping_machines[machine]
	if(!istype(bucket, /datum/machine_sleep_bucket))
		return null

	sleeping_machines -= machine
	if(bucket.machines)
		bucket.machines -= machine
		if(!length(bucket.machines))
			deactivate_sleep_bucket(bucket)

	return bucket.wake_time

/datum/controller/subsystem/machines/proc/remove_dormant_bookkeeping(obj/machinery/machine)
	if(!machine || !length(dormant_machines))
		return FALSE
	if(dormant_machines[machine])
		dormant_machines -= machine
		return TRUE
	return FALSE

/datum/controller/subsystem/machines/proc/remove_machine_from_active_queue(obj/machinery/machine, list/current_processing_list = null, current_processing_index = 0, current_processing_queue_id = 0)
	if(!machine?.is_processing)
		return FALSE

	if(current_processing_list && current_processing_queue_id && machine.is_processing == current_processing_queue_id)
		if(current_processing_index > 0 && current_processing_index <= length(current_processing_list) && current_processing_list[current_processing_index] == machine)
			current_processing_list.Cut(current_processing_index, current_processing_index + 1)
			machine.is_processing = null
			return TRUE

	var/list/processing_list = get_machine_processing_list_by_id(machine.is_processing)
	if(!processing_list)
		crash_with("Failed to remove processing. [log_info_line(machine)] is being processed by [machine.is_processing] but no matching SSmachines queue exists.")
		return FALSE

	if(processing_list.Remove(machine))
		machine.is_processing = null
		return TRUE

	crash_with("Failed to remove processing. [log_info_line(machine)] is being processed by [get_machine_processing_label(machine.is_processing)] and not found in [get_machine_processing_label(machine.is_processing)].")
	return FALSE

/datum/controller/subsystem/machines/proc/assign_machine_phase(obj/machinery/machine, spread)
	if(!machine)
		return 0
	spread = max(1, round(spread))
	if(isnull(machine.process_phase_offset_ds))
		machine.process_phase_offset_ds = next_phase_assignment % spread
		next_phase_assignment++
	return machine.process_phase_offset_ds % spread

/datum/controller/subsystem/machines/proc/get_auto_process_wake_time(obj/machinery/machine)
	if(!machine)
		return null

	var/interval = max(1, round(machine.default_process_delay_ds))
	var/jitter = max(0, round(machine.default_process_jitter_ds))
	var/spread = max(1, interval + jitter)
	var/phase = assign_machine_phase(machine, spread)
	var/wake_time = world.time + interval

	if(spread > 1)
		var/remainder = (wake_time - phase) % spread
		if(remainder)
			wake_time += spread - remainder

	return max(world.time + 1, wake_time)

/datum/controller/subsystem/machines/proc/enqueue_machine(obj/machinery/machine)
	if(!machine || machine.is_processing || !machine.processing_flags)
		return

	var/queue_id = get_machine_processing_queue_id(machine.process_priority)
	var/list/target_list = get_machine_processing_list(queue_id)
	machine.is_processing = queue_id
	target_list += machine

/datum/controller/subsystem/machines/proc/sleep_machine_until(obj/machinery/machine, wake_time, list/current_processing_list = null, current_processing_index = 0, current_processing_queue_id = 0)
	if(!machine || QDELETED(machine) || !machine.processing_flags)
		return

	wake_time = max(world.time + 1, round(wake_time))
	var/datum/machine_sleep_bucket/existing_bucket = sleeping_machines[machine]
	if(istype(existing_bucket, /datum/machine_sleep_bucket))
		if(existing_bucket.wake_time <= wake_time)
			return
		remove_sleep_bookkeeping(machine)

	remove_dormant_bookkeeping(machine)
	if(machine.is_processing && !remove_machine_from_active_queue(machine, current_processing_list, current_processing_index, current_processing_queue_id))
		return

	var/datum/machine_sleep_bucket/bucket = get_or_create_sleep_bucket(wake_time)
	bucket.machines += machine
	sleeping_machines[machine] = bucket
	if(!next_machine_wake || wake_time < next_machine_wake)
		next_machine_wake_bucket = bucket
		next_machine_wake = wake_time

/datum/controller/subsystem/machines/proc/set_machine_dormant(obj/machinery/machine, list/current_processing_list = null, current_processing_index = 0, current_processing_queue_id = 0)
	if(!machine || QDELETED(machine) || !machine.processing_flags)
		return

	remove_sleep_bookkeeping(machine)
	if(machine.is_processing && !remove_machine_from_active_queue(machine, current_processing_list, current_processing_index, current_processing_queue_id))
		return

	dormant_machines[machine] = TRUE

/datum/controller/subsystem/machines/proc/finalize_machine_schedule(obj/machinery/machine, process_result, processed_self = FALSE, list/current_processing_list = null, current_processing_index = 0, current_processing_queue_id = 0)
	if(!machine || QDELETED(machine) || !processed_self)
		return

	var/requested_wake = machine.next_requested_process_at
	var/requested_dormant = machine.requested_dormant_processing

	if(process_result == PROCESS_KILL)
		if(!isnull(requested_wake) || requested_dormant)
			machine.next_requested_process_at = null
			machine.requested_dormant_processing = FALSE
		machine.processing_flags &= ~MACHINERY_PROCESS_SELF
		if(!machine.processing_flags)
			stop_processing_machine(machine, current_processing_list, current_processing_index, current_processing_queue_id)
		return

	if(machine.processing_flags & MACHINERY_PROCESS_COMPONENTS)
		if(!isnull(requested_wake) || requested_dormant)
			machine.next_requested_process_at = null
			machine.requested_dormant_processing = FALSE
		return

	if(machine.process_schedule_mode == MACHINERY_SCHEDULE_POLL && isnull(requested_wake) && !requested_dormant)
		return

	machine.next_requested_process_at = null
	machine.requested_dormant_processing = FALSE

	if(!isnull(requested_wake))
		sleep_machine_until(machine, requested_wake, current_processing_list, current_processing_index, current_processing_queue_id)
		return

	if(requested_dormant)
		set_machine_dormant(machine, current_processing_list, current_processing_index, current_processing_queue_id)
		return

	switch(machine.process_schedule_mode)
		if(MACHINERY_SCHEDULE_TIMER)
			if(machine.default_process_delay_ds > 0)
				sleep_machine_until(machine, get_auto_process_wake_time(machine), current_processing_list, current_processing_index, current_processing_queue_id)
			else
				set_machine_dormant(machine, current_processing_list, current_processing_index, current_processing_queue_id)
		if(MACHINERY_SCHEDULE_EVENT)
			set_machine_dormant(machine, current_processing_list, current_processing_index, current_processing_queue_id)
		else
			if(dormant_machines[machine])
				dormant_machines -= machine
			if(!machine.is_processing && machine.processing_flags)
				enqueue_machine(machine)

/datum/controller/subsystem/machines/proc/sleep_machine(obj/machinery/machine, delay_ds)
	if(!machine || QDELETED(machine) || !machine.processing_flags)
		return

	sleep_machine_until(machine, world.time + max(1, round(delay_ds)))

/datum/controller/subsystem/machines/proc/wake_machine(obj/machinery/machine)
	if(!machine || QDELETED(machine))
		return

	if(istype(sleeping_machines[machine], /datum/machine_sleep_bucket))
		remove_sleep_bookkeeping(machine)
	if(dormant_machines[machine])
		dormant_machines -= machine
	enqueue_machine(machine)

/datum/controller/subsystem/machines/proc/wake_due_machines()
	var/datum/machine_sleep_bucket/bucket = next_machine_wake_bucket || refresh_next_machine_wake()
	if(!bucket || world.time < bucket.wake_time)
		return

	while(bucket && world.time >= bucket.wake_time)
		heap_pop_wake_time()
		if(!bucket.active || !length(bucket.machines))
			bucket = refresh_next_machine_wake()
			continue

		var/list/machines_to_wake = bucket.machines
		deactivate_sleep_bucket(bucket)
		bucket.machines = null
		for(var/obj/machinery/machine as anything in machines_to_wake)
			if(sleeping_machines[machine] != bucket)
				continue
			sleeping_machines -= machine
			if(QDELETED(machine) || !machine.processing_flags)
				continue
			enqueue_machine(machine)
		bucket = refresh_next_machine_wake()

/datum/controller/subsystem/machines/proc/start_processing_machine(obj/machinery/machine)
	if(!machine)
		CRASH("Null machinery was tried to be started")

	var/target_queue_id = get_machine_processing_queue_id(machine.process_priority)
	if(machine.is_processing)
		if(machine.is_processing == target_queue_id)
			return
		if(get_machine_processing_list_by_id(machine.is_processing))
			stop_processing_machine(machine)
		else
			crash_with("Failed to start processing. [log_info_line(machine)] is already being processed by [machine.is_processing] but queue attempt occured on [get_machine_processing_label(target_queue_id)].")
			return

	if(istype(sleeping_machines[machine], /datum/machine_sleep_bucket))
		remove_sleep_bookkeeping(machine)
	if(dormant_machines[machine])
		dormant_machines -= machine
	enqueue_machine(machine)

/datum/controller/subsystem/machines/proc/stop_processing_machine(obj/machinery/machine, list/current_processing_list = null, current_processing_index = 0, current_processing_queue_id = 0)
	if(!machine)
		return

	if(machine.is_processing)
		if(!remove_machine_from_active_queue(machine, current_processing_list, current_processing_index, current_processing_queue_id))
			crash_with("Failed to stop processing. [log_info_line(machine)] is being processed by [machine.is_processing] but de-queue attempt occured on SSmachines.")
	else
		if(istype(sleeping_machines[machine], /datum/machine_sleep_bucket))
			remove_sleep_bookkeeping(machine)
		if(dormant_machines[machine])
			dormant_machines -= machine
		return

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
	var/machine_total = length(processing_high) + length(processing_normal) + length(processing_low)
	var/datum/machine_sleep_bucket/next_bucket = next_machine_wake_bucket
	var/next_wake_display = next_bucket && next_bucket.active && length(next_bucket.machines) ? "[next_bucket.wake_time]" : "none"
	var/due_backlog = 0
	if(next_bucket && next_bucket.active && world.time >= next_bucket.wake_time)
		due_backlog = length(next_bucket.machines)
	..({"\
		Queues: \
		Pipes [length(pipenets)] \
		Machines [machine_total] (H:[length(processing_high)] N:[length(processing_normal)] L:[length(processing_low)] S:[length(sleeping_machines)] D:[length(dormant_machines)] Next:[next_wake_display] Due:[due_backlog]) \
		Networks [length(powernets)] \
		Objects [length(power_objects)]\n\
		Costs: \
		Pipes [Round(cost_pipenets)] \
		Machines [Round(cost_machinery)] \
		Networks [Round(cost_powernets)] \
		Objects [Round(cost_power_objects)]\n\
		Overall [Roundm(cost ? machine_total / cost : 0, 0.1)]
	"})


/datum/controller/subsystem/machines/proc/process_pipenets(resumed, no_mc_tick)
	if (!resumed)
		pipe_index = length(pipenets)
	var/datum/pipe_network/network
	while(pipe_index > 0)
		if(pipe_index > length(pipenets))
			pipe_index = length(pipenets)
			continue
		network = pipenets[pipe_index]
		pipe_index--
		if (QDELETED(network))
			if (network)
				network.is_processing = null
			pipenets -= network
			continue
		network.Process(wait)
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			return


/datum/controller/subsystem/machines/proc/process_machinery(resumed, no_mc_tick)
	wake_due_machines()
	if (!resumed)
		machine_priority_step = 1
		machine_high_index = length(processing_high)
		machine_normal_index = length(processing_normal)
		machine_low_index = length(processing_low)
	var/obj/machinery/machine
	var/processing_flags
	var/process_result
	var/current_processing_index
	if(machine_priority_step == 1)
		while(machine_high_index > 0)
			if(machine_high_index > length(processing_high))
				machine_high_index = length(processing_high)
				continue
			current_processing_index = machine_high_index
			machine = processing_high[current_processing_index]
			machine_high_index--
			if (QDELETED(machine))
				if (machine)
					machine.is_processing = null
				processing_high -= machine
				continue

			processing_flags = machine.processing_flags
			if(processing_flags & MACHINERY_PROCESS_COMPONENTS)
				for(var/obj/item/stock_parts/part as anything in machine.processing_parts)
					if(part.machine_process(machine) == PROCESS_KILL)
						part.stop_processing(machine)
				processing_flags = machine.processing_flags

			if(processing_flags & MACHINERY_PROCESS_SELF)
				process_result = machine.Process(wait)
				processing_flags = machine.processing_flags
				if(process_result == PROCESS_KILL)
					machine.processing_flags &= ~MACHINERY_PROCESS_SELF
					if(!machine.processing_flags)
						stop_processing_machine(machine, processing_high, current_processing_index, SSMACHINES_QUEUE_HIGH)
				else if((processing_flags & MACHINERY_PROCESS_COMPONENTS) || machine.process_schedule_mode != MACHINERY_SCHEDULE_POLL || !isnull(machine.next_requested_process_at) || machine.requested_dormant_processing)
					finalize_machine_schedule(machine, process_result, TRUE, processing_high, current_processing_index, SSMACHINES_QUEUE_HIGH)

			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				return
		machine_priority_step = 2
	if(machine_priority_step == 2)
		while(machine_normal_index > 0)
			if(machine_normal_index > length(processing_normal))
				machine_normal_index = length(processing_normal)
				continue
			current_processing_index = machine_normal_index
			machine = processing_normal[current_processing_index]
			machine_normal_index--
			if (QDELETED(machine))
				if (machine)
					machine.is_processing = null
				processing_normal -= machine
				continue

			processing_flags = machine.processing_flags
			if(processing_flags & MACHINERY_PROCESS_COMPONENTS)
				for(var/obj/item/stock_parts/part as anything in machine.processing_parts)
					if(part.machine_process(machine) == PROCESS_KILL)
						part.stop_processing(machine)
				processing_flags = machine.processing_flags

			if(processing_flags & MACHINERY_PROCESS_SELF)
				process_result = machine.Process(wait)
				processing_flags = machine.processing_flags
				if(process_result == PROCESS_KILL)
					machine.processing_flags &= ~MACHINERY_PROCESS_SELF
					if(!machine.processing_flags)
						stop_processing_machine(machine, processing_normal, current_processing_index, SSMACHINES_QUEUE_NORMAL)
				else if((processing_flags & MACHINERY_PROCESS_COMPONENTS) || machine.process_schedule_mode != MACHINERY_SCHEDULE_POLL || !isnull(machine.next_requested_process_at) || machine.requested_dormant_processing)
					finalize_machine_schedule(machine, process_result, TRUE, processing_normal, current_processing_index, SSMACHINES_QUEUE_NORMAL)

			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				return
		machine_priority_step = 3
	while(machine_low_index > 0)
		if(machine_low_index > length(processing_low))
			machine_low_index = length(processing_low)
			continue
		current_processing_index = machine_low_index
		machine = processing_low[current_processing_index]
		machine_low_index--
		if (QDELETED(machine))
			if (machine)
				machine.is_processing = null
			processing_low -= machine
			continue

		processing_flags = machine.processing_flags
		if(processing_flags & MACHINERY_PROCESS_COMPONENTS)
			for(var/obj/item/stock_parts/part as anything in machine.processing_parts)
				if(part.machine_process(machine) == PROCESS_KILL)
					part.stop_processing(machine)
			processing_flags = machine.processing_flags

		if(processing_flags & MACHINERY_PROCESS_SELF)
			process_result = machine.Process(wait)
			processing_flags = machine.processing_flags
			if(process_result == PROCESS_KILL)
				machine.processing_flags &= ~MACHINERY_PROCESS_SELF
				if(!machine.processing_flags)
					stop_processing_machine(machine, processing_low, current_processing_index, SSMACHINES_QUEUE_LOW)
			else if((processing_flags & MACHINERY_PROCESS_COMPONENTS) || machine.process_schedule_mode != MACHINERY_SCHEDULE_POLL || !isnull(machine.next_requested_process_at) || machine.requested_dormant_processing)
				finalize_machine_schedule(machine, process_result, TRUE, processing_low, current_processing_index, SSMACHINES_QUEUE_LOW)

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			return
	machine_priority_step = 1


/datum/controller/subsystem/machines/proc/process_powernets(resumed, no_mc_tick)
	if (!resumed)
		powernet_index = length(powernets)
	var/datum/powernet/network
	while(powernet_index > 0)
		if(powernet_index > length(powernets))
			powernet_index = length(powernets)
			continue
		network = powernets[powernet_index]
		powernet_index--
		if (QDELETED(network))
			if (network)
				network.is_processing = null
			powernets -= network
			continue
		network.reset(wait)
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			return


/datum/controller/subsystem/machines/proc/process_power_objects(resumed, no_mc_tick)
	if (!resumed)
		power_obj_index = length(power_objects)
	var/obj/item/item
	while(power_obj_index > 0)
		if(power_obj_index > length(power_objects))
			power_obj_index = length(power_objects)
			continue
		item = power_objects[power_obj_index]
		power_obj_index--
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
			return


#undef SSMACHINES_PIPENETS
#undef SSMACHINES_MACHINERY
#undef SSMACHINES_POWERNETS
#undef SSMACHINES_POWER_OBJECTS
