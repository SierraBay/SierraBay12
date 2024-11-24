GLOBAL_LIST_EMPTY(global_listen_count)

/datum
	/// Tracks how many event registrations are listening to us. Used in cleanup to prevent dangling references.
	var/event_source_count = 0
	/// Tracks how many event registrations we are listening to. Used in cleanup to prevent dangling references.
	var/event_listen_count = 0


/proc/cleanup_events(datum/source)
	if(GLOB.global_listen_count && GLOB.global_listen_count[source])
		cleanup_global_listener(source, GLOB.global_listen_count[source])
	if(source?.event_source_count > 0)
		cleanup_source_listeners(source, source?.event_source_count)
	if(source?.event_listen_count > 0)
		cleanup_event_listener(source, source?.event_listen_count)

/singleton/observ/register(datum/event_source, datum/listener, proc_call)
	. = ..()
	if(.)
		event_source.event_source_count++
		listener.event_listen_count++

/singleton/observ/unregister(datum/event_source, datum/listener, proc_call)
	. = ..()
	if(.)
		event_source.event_source_count -= .
		listener.event_listen_count -= .

/singleton/observ/register_global(datum/listener, proc_call)
	. = ..()
	if(.)
		GLOB.global_listen_count[listener] += 1

/singleton/observ/unregister_global(datum/listener, proc_call)
	. = ..()
	if(.)
		GLOB.global_listen_count[listener] -= 1
		if(GLOB.global_listen_count[listener] <= 0)
			GLOB.global_listen_count -= listener

/proc/cleanup_global_listener(listener, listen_count)
	GLOB.global_listen_count -= listener
	for(var/entry in GLOB.all_observable_events)
		var/singleton/observ/event = entry
		if(event.unregister_global(listener))
			log_debug("[event] - [listener] was deleted while still registered to global events.")
			if(!(--listen_count))
				return
/proc/cleanup_source_listeners(datum/event_source, source_listener_count)
	event_source.event_source_count = 0
	for(var/entry in GLOB.all_observable_events)
		var/singleton/observ/event = entry
		var/proc_owners = event.event_sources[event_source]
		if(proc_owners)
			for(var/proc_owner in proc_owners)
				if(event.unregister(event_source, proc_owner))
					log_debug("[event] - [event_source] was deleted while still being listened to by [proc_owner].")
					if(!(--source_listener_count))
						return

/proc/cleanup_event_listener(datum/listener, listener_count)
	listener.event_listen_count = 0
	for(var/entry in GLOB.all_observable_events)
		var/singleton/observ/event = entry
		for(var/event_source in event.event_sources)
			if(event.unregister(event_source, listener))
				log_debug("[event] - [listener] was deleted while still listening to [event_source].")
				if(!(--listener_count))
					return
