/*
 * GAMEMODE_JOB_REQUIREMENTS
 *
 * Lets a game mode demand that some number of ready players will spawn in a job
 * from a given department before the mode is allowed to start. Once the job
 * controller has run, what counts is the job each player was actually given, so
 * slot caps, job bans and age limits are all respected. Before that, the job a
 * player readied up as is the best estimate there is.
 *
 * Departments are matched by flag rather than by a list of job types on purpose.
 * Job types are per-map - /datum/job/security_assistant, for instance, exists
 * only on Sierra - so a list of them would fail to compile on every other map.
 * Flags also mean a map that adds a security job gets it counted for free.
 *
 * A mode opts in by filling the three vars below and chaining
 * check_ready_job_requirement() into its check_startable() - see nuclear.dm.
 * Modes that leave the vars alone are completely unaffected.
 */

/datum/game_mode
	/// Department flags whose jobs count toward `required_ready_job_count`. 0 disables the requirement entirely.
	var/required_ready_job_departments = 0
	/// How many ready players from `required_ready_job_departments` the mode needs before it may start.
	var/required_ready_job_count = 0
	/// Plural noun for the rejection message, as in "2/4 ready security personnel".
	var/required_ready_job_label = "players"

/*
 * Falsy if the requirement is met (or does not apply), otherwise a status
 * message, matching the contract of /datum/game_mode/proc/check_startable().
 */
/datum/game_mode/proc/check_ready_job_requirement(list/lobby_players)
	if(!required_ready_job_departments || required_ready_job_count <= 0)
		return
	// Players who deliberately voted this mode in get what they asked for, even
	// if nobody signed up to oppose them.
	if(was_voted_in())
		return
	var/ready = count_ready_for_departments(SSticker.ready_players(lobby_players), required_ready_job_departments)
	if(ready < required_ready_job_count)
		return "[ready]/[required_ready_job_count] ready [required_ready_job_label]"

/// TRUE if players picked this mode in the pre-round gamemode vote.
/datum/game_mode/proc/was_voted_in()
	if(SSticker.bypass_gamemode_vote)
		return FALSE
	// SSticker.choose_gamemode() takes the first entry as the winner, and leaves
	// the list empty when a vote finished without one.
	var/list/results = SSticker.gamemode_vote_results
	if(!length(results))
		return FALSE
	return results[1] == config_tag

/// Every job title on the running map belonging to any of `department_flags`.
/datum/game_mode/proc/get_department_job_titles(department_flags)
	var/list/titles = list()
	if(!department_flags)
		return titles
	for(var/title in SSjobs.titles_to_datums)
		var/datum/job/job = SSjobs.titles_to_datums[title]
		if(job && (job.department_flag & department_flags))
			titles |= job.title
	return titles

/datum/antagonist
	/// Department flags whose readied players may not be drafted for this antagonist. 0 disables the exclusion.
	var/excluded_ready_job_departments = 0

/*
 * Falsy if `player` may be drafted, otherwise a reason string, matching the
 * contract of /datum/antagonist/proc/can_become_antag_detailed().
 *
 * The stock restricted_jobs/blacklisted_jobs lists cannot do this job for any
 * antagonist carrying ANTAG_OVERRIDE_JOB. Those lists test player.assigned_job,
 * but such antagonists are drafted from game_mode.pre_setup(), which runs before
 * SSjobs.divide_occupations() - so assigned_job is still null and the lists
 * never match. Before jobs exist, the only thing that says what a player came to
 * do is the job they readied up as.
 *
 * A job with more players readied as it than it has roundstart slots cannot take
 * them all, so the surplus is let through - see has_spare_ready_players().
 */
/datum/antagonist/proc/check_ready_job_exclusion(datum/mind/player)
	if(!excluded_ready_job_departments)
		return
	// Only meaningful in the lobby. A ghost joining mid-round has no readied job
	// and is filtered by the usual late-join rules instead.
	var/mob/new_player/lobby_player = player?.current
	if(!istype(lobby_player))
		return
	// Already drafted for this role, so this check passed at draft time. It must
	// not run again from finalize_spawn(): by then the rest of the lobby has
	// spawned, the surplus count is gone, and a drafted surplus player would be
	// refused the role they were drafted for.
	if(player.special_role == role_text)
		return
	var/title = lobby_player.get_ready_job_title()
	if(!title)
		return
	var/datum/job/job = SSjobs.get_by_title(title)
	if(!job || !(job.department_flag & excluded_ready_job_departments))
		return
	if(has_spare_ready_players(job, lobby_player))
		return
	return "Player readied as [job.title], which is excluded from this antagonist role."

/*
 * TRUE if enough other ready, undrafted players readied as `job` to fill every
 * one of its roundstart slots without `candidate`, so drafting `candidate` cannot
 * leave the job short.
 *
 * With six players readied as a four-slot job, the first two to come up in the
 * draft may be taken and the last four are kept. Drafted players already carry a
 * special_role, so they drop out of the count as the draft goes on.
 *
 * Other players' bans and age limits are not checked here, so a job can still end
 * up short. check_ready_job_requirement() counts assigned jobs after the draft,
 * so a mode that needs this department fails safe in that case.
 */
/datum/antagonist/proc/has_spare_ready_players(datum/job/job, mob/new_player/candidate)
	// Unlimited slots take everyone, so nobody readied as the job is surplus.
	if(job.spawn_positions < 0)
		return FALSE
	var/others = 0
	for(var/mob/new_player/player as anything in SSticker.ready_players())
		if(player == candidate || player.mind?.special_role)
			continue
		if(player.get_ready_job_title() == job.title)
			others++
	return others >= job.spawn_positions

/*
 * How many of `ready_players` will spawn in a job from `department_flags`.
 *
 * SSticker.choose_gamemode() calls check_startable() after divide_occupations(),
 * so each player's assigned job is used when there is one. Players drafted as a
 * job-replacing antagonist have an assigned_role but no assigned_job, so they are
 * not counted. The earlier get_runnable_modes() pass runs before jobs are given
 * out, and there the readied job is used instead.
 */
/datum/game_mode/proc/count_ready_for_departments(list/ready_players, department_flags)
	var/count = 0
	for(var/mob/new_player/player in ready_players)
		var/datum/job/job = get_expected_job(player)
		if(job && (job.department_flag & department_flags))
			count++
	return count

/*
 * The job `player` will spawn in: their assigned job once the job controller has
 * run, otherwise the job they readied up as. Alt titles need no handling, because
 * preferences keep job_high as the base title.
 */
/datum/game_mode/proc/get_expected_job(mob/new_player/player)
	if(player.mind?.assigned_role)
		return player.mind.assigned_job
	var/title = player.get_ready_job_title()
	if(!title)
		return null
	return SSjobs.get_by_title(title)
