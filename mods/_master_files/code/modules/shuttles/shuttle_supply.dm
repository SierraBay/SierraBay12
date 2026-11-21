// TRADE: keep shuttle references for legacy integrations, but disable automated launches on Sierra.
/datum/shuttle/autodock/ferry/supply/can_launch()
	return !SStrade.enabled && ..()

/datum/shuttle/autodock/ferry/supply/can_force()
	return !SStrade.enabled && ..()
