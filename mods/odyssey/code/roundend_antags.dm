/// During Odyssey, living sleepers/changelings carry into the next shift — do not meta them at roundend.

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


/repository/uplink_purchases/print_entries()
	var/list/visible = purchases_by_mind
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.active)
		visible = list()
		for (var/datum/mind/ply in purchases_by_mind)
			if (odyssey_antag_dead_for_roundend(ply))
				visible[ply] = purchases_by_mind[ply]
	if (!length(visible))
		return
	to_world("<b>The following went shopping:</b>")
	var/list/pur_log = list()
	for (var/datum/mind/ply in visible)
		pur_log.Cut()
		var/uplink_purchase_entry/upe = visible[ply]
		to_world("<b>[ply.name]</b> (used [upe.total_cost] TC\s):")
		for (var/datum/uplink_item/UI in upe.purchased_items)
			pur_log += "[upe.purchased_items[UI]]x[UI.log_icon()][UI.name]"
		to_world(english_list(pur_log, nothing_text = ""))
