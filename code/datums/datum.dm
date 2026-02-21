/datum
	/// Int. `world.time` when this datum was destroyed, or `GC_CURRENTLY_BEING_QDELETED` if currently being deleted. Controlled by `qdel()`.
	var/gc_destroyed

	/// Whether or not this datum is currently being processed, and by which subsystem. Controlled by the various `START_PROCESSING*()` and `STOP_PROCESSING*()` defines.
	var/is_processing = FALSE

	/// If this datum is pooled, the pool it belongs to.
	var/singleton/instance_pool/instance_pool

	/// If this datum is pooled, the last configurator applied (if any).
	var/singleton/instance_configurator/instance_configurator

	/// List for custom filters applied to this datum/image. Intended for use with image overlays.
	var/list/filter_data

//[SIERRA-ADD]
	/**
	  * Components attached to this datum
	  *
	  * Lazy associated list in the structure of `type -> component/list of components`
	  */
	var/list/_datum_components
	/**
	  * Any datum registered to receive signals from this datum is in this list
	  *
	  * Lazy associated list in the structure of `signal -> registree/list of registrees`
	  */
	var/list/_listen_lookup
	/// Lazy associated list in the structure of `target -> list(signal -> proctype)` that are run when the datum receives that signal
	var/list/list/_signal_procs

	/// Used to avoid unnecessary refstring creation in Destroy().
	var/has_state_machine = FALSE

//[/SIERRA-ADD]
// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.

/datum/proc/Destroy()
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	tag = null
	SSnano && SSnano.close_uis(src)
	if (extensions)
		for (var/expansion_key in extensions)
			var/list/extension = extensions[expansion_key]
			if (islist(extension))
				extension.Cut()
			else
				qdel(extension)
		extensions = null
		//[SIERRA-ADD]
	//BEGIN: ECS SHIT
	var/list/dc = _datum_components
	if(dc)
		for(var/component_key in dc)
			var/component_or_list = dc[component_key]
			if(islist(component_or_list))
				for(var/datum/component/component as anything in component_or_list)
					qdel(component, FALSE)
			else
				var/datum/component/C = component_or_list
				qdel(C, FALSE)
		dc.Cut()

	_clear_signal_refs()
	//END: ECS SHIT
	//[/SIERRA-ADD]
	GLOB.destroyed_event && GLOB.destroyed_event.raise_event(src)
	cleanup_events(src)
	if(has_state_machine)
		var/list/machines = global.state_machines["\ref[src]"]
		if(length(machines))
			for(var/base_type in machines)
				qdel(machines[base_type])
			global.state_machines -= "\ref[src]"
	if (instance_pool?.ReturnInstance(src))
		return QDEL_HINT_IWILLGC
	instance_configurator = null
	instance_pool = null
	weakref = null
	return QDEL_HINT_QUEUE

//[SIERRA-ADD]
///Only override this if you know what you're doing. You do not know what you're doing
///This is a threat
/datum/proc/_clear_signal_refs()
	var/list/lookup = _listen_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for(var/datum/component/comp as anything in comps)
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		_listen_lookup = lookup = null
//[/SIERRA-ADD]

	for(var/target in _signal_procs)
		UnregisterSignal(target, _signal_procs[target])

/**
 * The processing handler for this datum. Called regularly by the relevant subsystem defined by `is_processing`.
 *
 * Return `PROCESS_KILL` to tell the subsystem to stop processing this datum.
 */
/datum/proc/Process()
	set waitfor = 0
	return PROCESS_KILL

// Filter procs for height system
/datum/proc/add_filter(name, priority, list/params)
	LAZYINITLIST(filter_data)
	var/list/p = params.Copy()
	p["priority"] = priority
	filter_data[name] = p
	update_filters()

/datum/proc/update_filters()
	var/atom/A = src // Works with both atoms and images
	A.filters = null
	filter_data = sortTim(filter_data, GLOBAL_PROC_REF(cmp_filter_data_priority), TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		A.filters += filter(arglist(arguments))
	UNSETEMPTY(filter_data)

/datum/proc/transition_filter(name, time, list/new_params, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return

	var/list/old_filter_data = filter_data[name]

	var/list/params = old_filter_data.Copy()
	for(var/thing in new_params)
		params[thing] = new_params[thing]

	animate(filter, new_params, time = time, easing = easing, loop = loop)
	for(var/param in params)
		filter_data[name][param] = params[param]

/datum/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return

	filter_data[name]["priority"] = new_priority
	update_filters()

/datum/proc/get_filter(name)
	var/atom/A = src // Works with both atoms and images
	if(filter_data && filter_data[name])
		return A.filters[filter_data.Find(name)]

/datum/proc/remove_filter(name_or_names)
	if(!filter_data)
		return

	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/datum/proc/clear_filters()
	var/atom/A = src // Works with both atoms and images
	filter_data = null
	A.filters = null
