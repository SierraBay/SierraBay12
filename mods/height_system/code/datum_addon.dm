/datum
	var/list/filter_data


// Compare filter data priority for sorting (height_system)
/proc/cmp_filter_data_priority(list/A, list/B)
    return A["priority"] - B["priority"]


/// Filter procs for height system (migrated from PR #4641)
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
