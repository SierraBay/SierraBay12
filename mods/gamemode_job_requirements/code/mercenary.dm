/*
 * Security is what the mercenaries are meant to run into, not what they are
 * made of. A player who readied up as security stays crew and is never drafted
 * onto the strike team.
 *
 * This is the other half of /datum/game_mode/nuclear's security requirement: the
 * mode refuses to start without four ready security personnel, and this keeps
 * those same four from being drafted away into the thing they are supposed to
 * oppose.
 */
/datum/antagonist/mercenary
	excluded_ready_job_departments = SEC

/datum/antagonist/mercenary/can_become_antag_detailed(datum/mind/player, ignore_role)
	. = ..()
	if(.)
		return
	// ignore_role is how admins force a role onto someone; it already waives the
	// restricted_jobs and player-age checks, so it waives this one too.
	if(ignore_role)
		return
	return check_ready_job_exclusion(player)
