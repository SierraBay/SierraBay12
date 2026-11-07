/// During Odyssey, living persist antags carry into the next shift — do not meta them at roundend.

/proc/odyssey_antag_dead_for_roundend(datum/mind/P)
	if (!istype(P))
		return FALSE
	if (!P.current || QDELETED(P.current))
		return TRUE
	return P.current.is_real_dead()


/proc/odyssey_filter_dead_antags(list/minds)
	var/list/dead = list()
	for (var/datum/mind/P in minds)
		if (odyssey_antag_dead_for_roundend(P))
			dead += P
	return dead


/datum/antagonist/traitor/roundend_listed_antagonists()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return ..()
	return odyssey_filter_dead_antags(current_antagonists)


/datum/antagonist/changeling/roundend_listed_antagonists()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return ..()
	return odyssey_filter_dead_antags(current_antagonists)


/datum/antagonist/revolutionary/roundend_listed_antagonists()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return ..()
	return odyssey_filter_dead_antags(current_antagonists)


/datum/antagonist/loyalists/roundend_listed_antagonists()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return ..()
	return odyssey_filter_dead_antags(current_antagonists)


/repository/uplink_purchases/print_entries()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return ..()
	// Living persist antags must not be meta'd — temporarily narrow the list and reuse vanilla output.
	var/list/original = purchases_by_mind
	var/list/filtered = list()
	for (var/datum/mind/ply in original)
		if (odyssey_antag_dead_for_roundend(ply))
			filtered[ply] = original[ply]
	purchases_by_mind = filtered
	. = ..()
	purchases_by_mind = original
