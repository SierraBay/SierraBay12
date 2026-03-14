#define SSMACHINES_QUEUE_HIGH 1
#define SSMACHINES_QUEUE_NORMAL 2
#define SSMACHINES_QUEUE_LOW 3

/datum/machine_sleep_bucket
	var/wake_time = 0
	var/lookup_key = null
	var/list/machines = list()
	var/active = TRUE

/datum/machine_sleep_bucket/New(new_wake_time)
	..()
	wake_time = new_wake_time
	lookup_key = "[wake_time]"


SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_MACHINERY
	flags = SS_KEEP_TIMING
	var/static/cost_machinery = 0
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
	var/static/machine_priority_step = 1
	var/static/machine_high_index = 0
	var/static/machine_normal_index = 0
	var/static/machine_low_index = 0
	var/static/next_machine_wake = 0
	var/static/datum/machine_sleep_bucket/next_machine_wake_bucket = null
	var/static/next_phase_assignment = 0
	var/static/list/machinery = list()
	var/static/list/machinery_by_type = list()

/datum/controller/subsystem/machines/Recover()
	machine_priority_step = 1
	machine_high_index = 0
	machine_normal_index = 0
	machine_low_index = 0
	recalculate_next_machine_wake()
	sync_legacy_processing_lists()

/datum/controller/subsystem/machines/Initialize(start_uptime)
	sync_legacy_processing_lists()

/datum/controller/subsystem/machines/fire(resumed, no_mc_tick)
	var/timer = world.tick_usage
	process_machinery(resumed, no_mc_tick)
	cost_machinery = MC_AVERAGE(cost_machinery, (world.tick_usage - timer) * world.tick_lag)

/datum/controller/subsystem/machines/proc/sync_legacy_processing_lists()
	if(SSpipes)
		pipenets = SSpipes.pipenets
	if(SSpowernets)
		powernets = SSpowernets.powernets
		power_objects = SSpowernets.power_objects

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
	var/lookup_key = "[wake_time]"
	var/datum/machine_sleep_bucket/bucket = sleep_buckets[lookup_key]
	if(bucket)
		return bucket

	bucket = new(wake_time)
	sleep_buckets[lookup_key] = bucket
	heap_push_wake_time(bucket)
	return bucket

/datum/controller/subsystem/machines/proc/deactivate_sleep_bucket(datum/machine_sleep_bucket/bucket, refresh_next_wake = TRUE)
	if(!bucket || !bucket.active)
		return

	bucket.active = FALSE
	if(bucket.lookup_key && sleep_buckets[bucket.lookup_key] == bucket)
		sleep_buckets -= bucket.lookup_key

	if(refresh_next_wake && bucket == next_machine_wake_bucket)
		refresh_next_machine_wake()

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

/datum/controller/subsystem/machines/proc/clear_machine_active_queue_state(obj/machinery/machine)
	if(!machine)
		return

	machine.is_processing = null
	machine.processing_queue_index = 0

/datum/controller/subsystem/machines/proc/remove_machine_at_active_index(list/processing_list, remove_index, queue_id)
	if(!processing_list || remove_index <= 0 || remove_index > length(processing_list))
		return FALSE

	var/last_index = length(processing_list)
	var/obj/machinery/removed_machine = processing_list[remove_index]
	if(remove_index != last_index)
		var/obj/machinery/swapped_machine = processing_list[last_index]
		if(swapped_machine)
			if(swapped_machine.is_processing != queue_id)
				crash_with("Failed to update processing queue index. [log_info_line(swapped_machine)] occupied [get_machine_processing_label(queue_id)] index [remove_index] while marked as [swapped_machine.is_processing].")
				return FALSE
		processing_list[remove_index] = swapped_machine
		if(swapped_machine)
			swapped_machine.processing_queue_index = remove_index

	processing_list.Cut(last_index, last_index + 1)
	clear_machine_active_queue_state(removed_machine)
	return TRUE

/datum/controller/subsystem/machines/proc/remove_machine_at_active_index_stable(list/processing_list, remove_index)
	if(!processing_list || remove_index <= 0 || remove_index > length(processing_list))
		return FALSE

	var/obj/machinery/removed_machine = processing_list[remove_index]
	processing_list.Cut(remove_index, remove_index + 1)
	for(var/index in remove_index to length(processing_list))
		var/obj/machinery/shifted_machine = processing_list[index]
		if(shifted_machine)
			shifted_machine.processing_queue_index = index

	clear_machine_active_queue_state(removed_machine)
	return TRUE

/datum/controller/subsystem/machines/proc/remove_machine_from_active_queue(obj/machinery/machine, list/current_processing_list = null, current_processing_index = 0, current_processing_queue_id = 0)
	if(!machine?.is_processing)
		return FALSE

	var/queue_id = machine.is_processing
	var/list/processing_list = current_processing_list
	if(!processing_list || !current_processing_queue_id || queue_id != current_processing_queue_id)
		processing_list = get_machine_processing_list_by_id(queue_id)
	if(!processing_list)
		crash_with("Failed to remove processing. [log_info_line(machine)] is being processed by [queue_id] but no matching SSmachines queue exists.")
		return FALSE

	var/remove_index = 0
	if(current_processing_list == processing_list && current_processing_queue_id && queue_id == current_processing_queue_id)
		if(current_processing_index > 0 && current_processing_index <= length(current_processing_list) && current_processing_list[current_processing_index] == machine)
			remove_index = current_processing_index

	if(!remove_index)
		var/stored_index = machine.processing_queue_index
		if(stored_index > 0 && stored_index <= length(processing_list) && processing_list[stored_index] == machine)
			remove_index = stored_index

	if(!remove_index)
		remove_index = processing_list.Find(machine)

	if(remove_index)
		if(current_processing_list == processing_list && current_processing_queue_id && queue_id == current_processing_queue_id && current_processing_index > 0 && remove_index < current_processing_index)
			if(remove_machine_at_active_index_stable(processing_list, remove_index))
				return TRUE
		else if(remove_machine_at_active_index(processing_list, remove_index, queue_id))
			return TRUE

	crash_with("Failed to remove processing. [log_info_line(machine)] is being processed by [get_machine_processing_label(queue_id)] and not found in [get_machine_processing_label(queue_id)].")
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
	target_list += machine
	machine.is_processing = queue_id
	machine.processing_queue_index = length(target_list)

/datum/controller/subsystem/machines/proc/sleep_machine_until(obj/machinery/machine, wake_time, list/current_processing_list = null, current_processing_index = 0, current_processing_queue_id = 0)
	if(!machine || QDELETED(machine) || !machine.processing_flags)
		return

	wake_time = max(world.time + 1, wake_time)
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
	var/datum/machine_sleep_bucket/bucket = next_machine_wake_bucket
	if(bucket != heap_peek_bucket() || !bucket?.active || !length(bucket?.machines))
		bucket = refresh_next_machine_wake()
	if(!bucket || world.time < bucket.wake_time)
		return

	while(bucket && world.time >= bucket.wake_time)
		heap_pop_wake_time()
		if(!bucket.active || !length(bucket.machines))
			bucket = refresh_next_machine_wake()
			continue

		var/list/machines_to_wake = bucket.machines
		deactivate_sleep_bucket(bucket, FALSE)
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

/// Deprecated compatibility wrapper for legacy call sites.
/datum/controller/subsystem/machines/proc/makepowernets()
	if(!SSpowernets)
		CRASH("SSpowernets is unavailable during powernet rebuild.")
	SSpowernets.makepowernets()
	sync_legacy_processing_lists()

/// Deprecated compatibility wrapper for legacy call sites.
/datum/controller/subsystem/machines/proc/setup_powernets_for_cables(list/cables)
	if(!SSpowernets)
		CRASH("SSpowernets is unavailable during powernet setup.")
	SSpowernets.setup_powernets_for_cables(cables)
	sync_legacy_processing_lists()

/// Deprecated compatibility wrapper for legacy call sites.
/datum/controller/subsystem/machines/proc/setup_atmos_machinery(list/machines)
	if(!SSpipes)
		CRASH("SSpipes is unavailable during atmos setup.")
	SSpipes.setup_atmos_machinery(machines)
	sync_legacy_processing_lists()

/datum/controller/subsystem/machines/UpdateStat(time)
	if(PreventUpdateStat(time))
		return ..()
	var/machine_total = length(processing_high) + length(processing_normal) + length(processing_low)
	var/datum/machine_sleep_bucket/next_bucket = next_machine_wake_bucket
	var/next_wake_display = next_bucket && next_bucket.active && length(next_bucket.machines) ? "[next_bucket.wake_time]" : "none"
	var/due_backlog = 0
	if(next_bucket && next_bucket.active && world.time >= next_bucket.wake_time)
		due_backlog = length(next_bucket.machines)
	..("Queues: Machines [machine_total] (H:[length(processing_high)] N:[length(processing_normal)] L:[length(processing_low)] S:[length(sleeping_machines)] D:[length(dormant_machines)] Next:[next_wake_display] Due:[due_backlog]) | Cost: [Round(cost_machinery)] | Overall [Roundm(cost ? machine_total / cost : 0, 0.1)]")

/datum/controller/subsystem/machines/proc/process_machinery(resumed, no_mc_tick)
	wake_due_machines()
	if(!resumed)
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
			if(QDELETED(machine))
				remove_machine_at_active_index(processing_high, current_processing_index, SSMACHINES_QUEUE_HIGH)
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

			if(no_mc_tick)
				CHECK_TICK
			else if(MC_TICK_CHECK)
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
			if(QDELETED(machine))
				remove_machine_at_active_index(processing_normal, current_processing_index, SSMACHINES_QUEUE_NORMAL)
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

			if(no_mc_tick)
				CHECK_TICK
			else if(MC_TICK_CHECK)
				return
		machine_priority_step = 3
	while(machine_low_index > 0)
		if(machine_low_index > length(processing_low))
			machine_low_index = length(processing_low)
			continue
		current_processing_index = machine_low_index
		machine = processing_low[current_processing_index]
		machine_low_index--
		if(QDELETED(machine))
			remove_machine_at_active_index(processing_low, current_processing_index, SSMACHINES_QUEUE_LOW)
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

		if(no_mc_tick)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			return
	machine_priority_step = 1
