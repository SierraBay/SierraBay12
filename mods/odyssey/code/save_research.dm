/// Campaign research progress for Odyssey (science briefs, dept briefs, notes).

/proc/odyssey_research_blank() as /list
	return list(
		"samples_collected" = list(),
		"anomalies_catalogued" = list(),
		"sector_notes" = list(),
		"active_briefs" = list(),
		"completed_brief_ids" = list(),
		"next_brief_id" = 1,
		"dept_briefs" = list(),
		"completed_dept_brief_ids" = list(),
		"next_dept_brief_id" = 1
	)


/proc/odyssey_research_ensure() as /list
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!islist(state.research))
		state.research = odyssey_research_blank()
	var/list/R = state.research
	if (!islist(R["samples_collected"]))
		R["samples_collected"] = list()
	if (!islist(R["anomalies_catalogued"]))
		R["anomalies_catalogued"] = list()
	if (!islist(R["sector_notes"]))
		R["sector_notes"] = list()
	if (!islist(R["active_briefs"]))
		R["active_briefs"] = list()
	if (!islist(R["completed_brief_ids"]))
		R["completed_brief_ids"] = list()
	if (isnull(R["next_brief_id"]))
		R["next_brief_id"] = 1
	if (!islist(R["dept_briefs"]))
		R["dept_briefs"] = list()
	if (!islist(R["completed_dept_brief_ids"]))
		R["completed_dept_brief_ids"] = list()
	if (isnull(R["next_dept_brief_id"]))
		R["next_dept_brief_id"] = 1
	return R


/proc/odyssey_collect_research() as /list
	var/list/R = odyssey_research_ensure()
	return R.Copy()


/proc/odyssey_apply_research(list/data)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!islist(data))
		state.research = odyssey_research_blank()
		return
	state.research = data.Copy()
	odyssey_research_ensure()
	log_debug("ODYSSEY: research snapshot applied briefs=[length(state.research["active_briefs"])] dept=[length(state.research["dept_briefs"])]")
