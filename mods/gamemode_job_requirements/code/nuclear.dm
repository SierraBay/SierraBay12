/*
 * Mercenaries need someone on board able to shoot back, so the mode will not
 * start unless enough of the lobby readied up as security. Every security job
 * counts toward the same total - four guards, or two cadets and two
 * investigators, are equally acceptable. The Head of Security carries SEC|COM
 * and so counts as well.
 */
/datum/game_mode/nuclear
	required_ready_job_departments = SEC
	required_ready_job_count = 4
	required_ready_job_label = "security personnel"

/datum/game_mode/nuclear/check_startable(list/lobby_players)
	. = ..()
	if(.)
		return
	return check_ready_job_requirement(lobby_players)
