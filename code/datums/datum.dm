/datum
	var/gc_destroyed //Time when this object was destroyed.
	var/is_processing = FALSE
	var/list/active_timers  //for SStimer

	/// Components attached to this datum.
	var/list/datum_components = list()
	/// Any datum registered to receive signals from this datum is in this list.
	var/list/comp_lookup = list()
	/// Lazy associated list of signals that are run when the datum receives that signal
	var/list/signal_procs = list()

#ifdef TESTING
	var/running_find_references
	var/last_find_references = 0
#endif


// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy(force=FALSE)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

	SEND_SIGNAL(src, SIGNAL_DESTROY, src)
	SEND_GLOBAL_SIGNAL(SIGNAL_DESTROY, src)

	tag = null
	weakref = null // Clear this reference to ensure it's kept for as brief duration as possible.

	SSnano && SSnano.close_uis(src)

	var/list/timers = active_timers
	active_timers = null
	for(var/datum/timedevent/timer as anything in timers)
		if (timer.spent)
			continue
		qdel(timer)

	var/list/dc = datum_components
	if(dc)
		var/all_components = dc[/datum/component]
		if(length(all_components))
			for(var/datum/component/component as anything in all_components)
				qdel(component, FALSE, TRUE)
		else
			var/datum/component/C = all_components
			qdel(C, FALSE, TRUE)
		dc.Cut()

	clear_signal_refs()

	if(extensions)
		for(var/expansion_key in extensions)
			var/list/extension = extensions[expansion_key]
			if(islist(extension))
				extension.Cut()
			else
				qdel(extension)
		extensions = null

	GLOB.destroyed_event && GLOB.destroyed_event.raise_event(src)

	if (!isturf(src))	// Not great, but the 'correct' way to do it would add overhead for little benefit.
		cleanup_events(src)

	var/list/machines = global.state_machines["\ref[src]"]
	if(length(machines))
		for(var/base_type in machines)
			qdel(machines[base_type])
		global.state_machines -= "\ref[src]"

	return QDEL_HINT_QUEUE

/// Only override this if you know what you're doing. You do not know what you're doing
/// This is a threat
/datum/proc/clear_signal_refs()
	var/list/lookup = comp_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for(var/datum/component/comp as anything in comps)
					comp.unregister_signal(src, sig)
			else
				var/datum/component/comp = comps
				comp.unregister_signal(src, sig)
		comp_lookup = lookup = null

	for(var/target in signal_procs)
		unregister_signal(target, signal_procs[target])

/datum/proc/Process()
	set waitfor = 0
	return PROCESS_KILL
