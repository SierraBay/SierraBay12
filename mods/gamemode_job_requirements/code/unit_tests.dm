/*
 * Unit tests covering the Mercenary (nuke-ops) gamemode pipeline:
 *  - The gamemode datum and its antagonist template stay wired together sanely.
 *  - check_startable() gates on ready players, ready security personnel and
 *    drafted antagonists the same way
 *    /datum/controller/subsystem/ticker/proc/choose_gamemode() relies on it.
 *  - Synthetic candidates drafted through the real attempt_spawn() end up
 *    equipped, factioned and carrying an uplink and an objective.
 *
 * Two deliberate gaps, both forced by running headless:
 *
 * 1. Candidate *selection* is bypassed. get_players_for_role() and
 *    build_candidate_list() both read client.prefs.be_special_role, and there is
 *    no connected client in a CI run. Everything downstream of selection is
 *    exercised for real, since that is where equip/uplink/objective/faction
 *    regressions actually happen.
 *
 * 2. finalize_spawn() and add_antagonist() are NOT called. add_antagonist()
 *    routes any mind whose mob lacks a live client into create_default(), which
 *    builds a fresh body on the antag base's own z-level. The third test drives
 *    the in-container branch by hand instead - see the comment above that loop
 *    for exactly which steps it reproduces and which it therefore cannot cover.
 *
 * Both gaps need a live single-player smoke test to close; there is no headless
 * substitute for either.
 */

#ifdef UNIT_TEST

#define SUCCESS 1
#define FAILURE 0

/datum/unit_test/mercenary_gamemode_is_consistent
	name = "MERCENARY: Gamemode and antagonist template are consistently configured"

/datum/unit_test/mercenary_gamemode_is_consistent/start_test()
	var/datum/game_mode/nuclear/mode = SSticker.mode_cache["mercenary"]
	if(!istype(mode))
		var/found_type = mode ? "[mode.type]" : "null"
		fail("SSticker.mode_cache(mercenary) is not a /datum/game_mode/nuclear (found [found_type]).")
		return 1

	if(!(MODE_MERCENARY in mode.antag_tags))
		fail("The mercenary gamemode's antag_tags does not contain MODE_MERCENARY.")
		return 1

	var/datum/antagonist/mercenary/antag = GLOB.all_antag_types_[MODE_MERCENARY]
	if(!istype(antag))
		var/found_type = antag ? "[antag.type]" : "null"
		fail("GLOB.all_antag_types_[MODE_MERCENARY] is not a /datum/antagonist/mercenary (found [found_type]).")
		return 1

	var/list/problems = list()
	if(mode.required_enemies > antag.initial_spawn_target)
		problems += "required_enemies ([mode.required_enemies]) is greater than initial_spawn_target ([antag.initial_spawn_target]) - the mode could never meet its own requirement."
	if(antag.initial_spawn_req > antag.initial_spawn_target)
		problems += "initial_spawn_req ([antag.initial_spawn_req]) is greater than initial_spawn_target ([antag.initial_spawn_target])."
	if(antag.initial_spawn_target > antag.hard_cap_round)
		problems += "initial_spawn_target ([antag.initial_spawn_target]) is greater than hard_cap_round ([antag.hard_cap_round])."
	if(!(antag.flags & ANTAG_OVERRIDE_JOB))
		problems += "ANTAG_OVERRIDE_JOB flag is missing - mercs would compete with regular crew for job slots instead of being drafted pre-job-assignment."
	if(!antag.base_to_load && !length(antag.starting_locations))
		problems += "No base_to_load map template and no starting_locations - mercs have nowhere to spawn."

	if(length(problems))
		fail("[english_list(problems)]")
	else
		pass("Mercenary gamemode and antagonist template are consistent.")
	return 1


/*
 * A lobby player whose readied-up job is set directly instead of being read out
 * of client.prefs. /mob/new_player/get_ready_job_title() is the only place the
 * startable check touches preferences, and preferences need a connected client,
 * which a headless run does not have. Stubbing exactly that one accessor keeps
 * the real counting and the real gating under test.
 */
/mob/new_player/merc_test_dummy
	var/test_job_title

/mob/new_player/merc_test_dummy/get_ready_job_title()
	return test_job_title


/datum/unit_test/mercenary_check_startable_requirements
	name = "MERCENARY: check_startable() enforces ready players, ready security and drafted antagonists"

/datum/unit_test/mercenary_check_startable_requirements/start_test()
	var/datum/antagonist/mercenary/antag = GLOB.all_antag_types_[MODE_MERCENARY]
	if(!istype(antag))
		fail("Could not find the mercenary antagonist template.")
		return 1

	var/datum/game_mode/nuclear/mode = new()
	var/list/problems = list()

	// Pin the thresholds the scenario table below is written against. Reading
	// them off the datum instead would let the table silently re-target itself
	// if somebody retunes the mode, which is the regression we want to catch.
	if(mode.required_players != 15)
		problems += "required_players is [mode.required_players], the scenario table expects 15."
	if(mode.required_enemies != 3)
		problems += "required_enemies is [mode.required_enemies], the scenario table expects 3."
	if(mode.required_ready_job_count != 4)
		problems += "required_ready_job_count is [mode.required_ready_job_count], the scenario table expects 4."
	if(mode.required_ready_job_departments != SEC)
		problems += "required_ready_job_departments is [mode.required_ready_job_departments], expected SEC ([SEC])."

	// Resolved from the running map rather than hardcoded, because the security
	// roster is per-map - Sierra's cadet job does not exist elsewhere, so naming
	// its type here would break the build on every other map.
	var/list/security_titles = mode.get_department_job_titles(SEC)
	var/list/non_security_titles = get_titles_outside_departments(SEC)

	// The command-tier and rank-and-file security jobs live in core, so they are
	// safe to name on any map, and every one of them must be counted.
	for(var/job_type in list(/datum/job/hos, /datum/job/officer, /datum/job/warden, /datum/job/detective))
		var/datum/job/job = SSjobs.get_by_path(job_type)
		if(!job)
			continue
		if(!(job.title in security_titles))
			problems += "[job.title] is not being counted as security personnel."

	if(length(security_titles) < 2)
		problems += "Only [length(security_titles)] security job\s on this map - too few to prove the total is shared across jobs."
	if(!length(non_security_titles))
		problems += "Every job on this map is security, so the negative control row cannot run."

	if(!length(problems))
		// ready, security among them, drafted antagonists, voted in, startable
		var/list/scenarios = list(
			list(14, 4, 3, FALSE, FALSE), // One short on players.
			list(15, 4, 0, FALSE, FALSE), // Nobody drafted.
			list(15, 4, 2, FALSE, FALSE), // One short on drafted antagonists.
			list(15, 0, 3, FALSE, FALSE), // No security presence at all.
			list(15, 3, 3, FALSE, FALSE), // One short on security.
			list(15, 4, 3, FALSE, TRUE),  // Exactly at every threshold.
			list(20, 6, 5, FALSE, TRUE),  // Comfortably over every threshold.
			list(15, 3, 3, TRUE,  TRUE),  // Short on security, but players voted for it.
			list(14, 4, 3, TRUE,  FALSE), // A vote waives security, never the headcount.
			list(15, 4, 2, TRUE,  FALSE)  // A vote waives security, never the antagonists.
		)
		for(var/list/scenario in scenarios)
			problems += run_startable_scenario(mode, antag, security_titles, scenario[1], scenario[2], scenario[3], scenario[4], scenario[5])

		// The count must be specific to security, not to "readied up at all" -
		// fill the quota with non-security jobs and it must still fail.
		problems += run_startable_scenario(mode, antag, non_security_titles, 15, 4, 3, FALSE, FALSE)

	qdel(mode)

	if(length(problems))
		fail("[english_list(problems)]")
	else
		pass("check_startable() correctly gated on required_players, required_ready_job_count and required_enemies across all scenarios.")
	return 1

/// Every job title on the running map belonging to none of `department_flags` - the negative control for the counter.
/datum/unit_test/mercenary_check_startable_requirements/proc/get_titles_outside_departments(department_flags)
	var/list/titles = list()
	for(var/title in SSjobs.titles_to_datums)
		var/datum/job/job = SSjobs.titles_to_datums[title]
		if(job && !(job.department_flag & department_flags))
			titles |= job.title
	return titles

/*
 * Runs one row of the table and returns a list holding a complaint, or an empty
 * list if the row behaved. Returning rather than failing inline means every row
 * gets exercised and reported, instead of the run stopping at the first bad one.
 *
 * `job_titles` are dealt round-robin to the first `job_count` players, so a row
 * asking for 4 covers all four security jobs rather than four of the same one.
 */
/datum/unit_test/mercenary_check_startable_requirements/proc/run_startable_scenario(
	datum/game_mode/nuclear/mode,
	datum/antagonist/mercenary/antag,
	list/job_titles,
	ready_count,
	job_count,
	drafted_count,
	voted_in,
	expect_startable
)
	var/list/lobby = list()
	for(var/i in 1 to ready_count)
		var/mob/new_player/merc_test_dummy/P = new()
		P.ready = TRUE
		if(i <= job_count)
			P.test_job_title = job_titles[((i - 1) % length(job_titles)) + 1]
		lobby += P

	var/list/fake_candidates = list()
	for(var/i in 1 to drafted_count)
		fake_candidates += new /datum/mind("MercTestCandidate[i]")

	// Everything from here to the restore below touches live singletons -
	// GLOB.mercs and SSticker - so keep the window as small as possible and
	// never return out of it. DM has no try/finally, and leaked state here
	// would poison every test that runs after this one.
	var/list/saved_pending = antag.pending_antagonists
	var/list/saved_vote_results = SSticker.gamemode_vote_results
	var/saved_bypass = SSticker.bypass_gamemode_vote
	antag.pending_antagonists = fake_candidates
	mode.antag_templates = list(antag) // Routes check_startable to read antag.pending_antagonists (ANTAG_OVERRIDE_JOB path).
	if(voted_in)
		SSticker.gamemode_vote_results = list(mode.config_tag = 1)
		SSticker.bypass_gamemode_vote = 0
	else
		SSticker.gamemode_vote_results = null
	var/result = mode.check_startable(lobby)
	antag.pending_antagonists = saved_pending
	SSticker.gamemode_vote_results = saved_vote_results
	SSticker.bypass_gamemode_vote = saved_bypass
	mode.antag_templates = null

	var/list/complaints = list()
	var/startable = !result
	if(startable != expect_startable)
		var/situation = "[ready_count] ready ([job_count] as [english_list(job_titles)]), [drafted_count] drafted[voted_in ? ", voted in" : ""]"
		if(expect_startable)
			complaints += "check_startable() rejected [situation], which should start: [result]"
		else
			complaints += "check_startable() accepted [situation], which should not start."

	for(var/mob/new_player/P in lobby)
		qdel(P)
	for(var/datum/mind/M in fake_candidates)
		qdel(M)

	return complaints


/datum/unit_test/mercenary_security_players_excluded
	name = "MERCENARY: Players readied as security are not drafted as mercenaries"

/datum/unit_test/mercenary_security_players_excluded/start_test()
	var/datum/antagonist/mercenary/antag = GLOB.all_antag_types_[MODE_MERCENARY]
	if(!istype(antag))
		fail("Could not find the mercenary antagonist template.")
		return 1

	var/list/problems = list()
	if(antag.excluded_ready_job_departments != SEC)
		problems += "excluded_ready_job_departments is [antag.excluded_ready_job_departments], expected SEC ([SEC])."

	var/datum/game_mode/nuclear/mode = new()
	var/list/security_titles = mode.get_department_job_titles(SEC)
	qdel(mode)

	// Every security job must be turned away, not just the obvious ones.
	for(var/title in security_titles)
		if(!check_exclusion_for_title(antag, title))
			problems += "A player readied as [title] would still be drafted as a mercenary."

	// ...and nobody else may be caught by it.
	for(var/title in SSjobs.titles_to_datums)
		var/datum/job/job = SSjobs.titles_to_datums[title]
		if(!job || (job.department_flag & SEC))
			continue
		if(check_exclusion_for_title(antag, job.title))
			problems += "A player readied as [job.title] is wrongly excluded from being a mercenary."

	// A lobby player who readied without picking a job must stay eligible.
	if(check_exclusion_for_title(antag, null))
		problems += "A player with no readied job is wrongly excluded from being a mercenary."

	if(length(problems))
		fail("[english_list(problems)]")
	else
		pass("All [length(security_titles)] security job\s are excluded from the mercenary draft, and no other job is.")
	return 1

/// Truthy (the reason string) if a lobby player readied as `title` would be refused the mercenary role.
/datum/unit_test/mercenary_security_players_excluded/proc/check_exclusion_for_title(datum/antagonist/antag, title)
	var/mob/new_player/merc_test_dummy/dummy = new()
	dummy.ready = TRUE
	dummy.test_job_title = title

	var/datum/mind/mind = new /datum/mind("MercExclusionProbe")
	mind.current = dummy

	. = antag.check_ready_job_exclusion(mind)

	mind.current = null
	qdel(mind)
	qdel(dummy)


/datum/unit_test/mercenary_draft_and_finalize_spawn
	name = "MERCENARY: Drafted candidates are equipped, factioned and objectived correctly"

/datum/unit_test/mercenary_draft_and_finalize_spawn/start_test()
	var/datum/antagonist/mercenary/antag = GLOB.all_antag_types_[MODE_MERCENARY]
	if(!istype(antag))
		fail("Could not find the mercenary antagonist template.")
		return 1

	// Snapshot the live global antagonist state so this test cannot bleed into
	// a real round or into other tests.
	var/list/saved_candidates = antag.candidates
	var/list/saved_pending = antag.pending_antagonists
	var/list/saved_current = antag.current_antagonists.Copy()
	var/list/saved_antag_pool = SSticker.antag_pool.Copy()

	var/spawn_target = antag.initial_spawn_target
	var/list/test_minds = list()
	var/list/problems = list()

	// A couple extra candidates to prove attempt_spawn() stops at spawn_target.
	for(var/i in 1 to (spawn_target + 2))
		var/list/result = create_test_mob_with_mind(null, /mob/living/carbon/human)
		if(isnull(result) || result["result"] != SUCCESS)
			problems += "Could not create test mob #[i]: [result ? result["msg"] : "runtime"]"
			continue
		var/mob/living/carbon/human/H = locate(result["mobref"])
		if(!istype(H) || !H.mind)
			problems += "Test mob #[i] has no mind."
			continue
		test_minds += H.mind

	if(!length(problems))
		antag.candidates = test_minds.Copy()
		antag.pending_antagonists = list()
		// At RUNLEVEL_GAME, draft_antagonist() (antagonist.dm) rejects any mind
		// whose mob is not connected unless it is in SSticker.antag_pool - that
		// is how real late-join ghosts are admitted. The synthetic minds have no
		// client, so register them the same way to let the lottery pass them.
		SSticker.antag_pool |= test_minds
		antag.attempt_spawn(spawn_target)

		if(length(antag.pending_antagonists) != spawn_target)
			problems += "attempt_spawn([spawn_target]) drafted [length(antag.pending_antagonists)] candidates instead of [spawn_target]."

		var/list/drafted = antag.pending_antagonists.Copy()
		// Finalize like the roundstart path. Real rounds draft candidates in
		// game_mode.pre_setup() under RUNLEVEL_LOBBY and later run these minds
		// through finalize_spawn() -> add_antagonist(). That proc routes any
		// mind whose mob lacks a live client to create_default(), the ghost-join
		// branch that builds a fresh body and equips it - impossible in a
		// headless CI run. Drive the in-container branch add_antagonist() takes
		// for a real player instead (add_antagonist_mind -> create_antagonist ->
		// equip -> faction), without loading the antag base's own z-level.
		for(var/datum/mind/M in drafted)
			if(!antag.add_antagonist_mind(M, 0))
				problems += "[M.key || M.name] could not be added as a mercenary."
				continue
			antag.create_antagonist(M, 0, 1, 1)
			antag.equip(M.current)
			if(antag.faction && M.current)
				if(antag.no_prior_faction)
					M.current.last_faction = antag.faction
				else
					M.current.last_faction = M.current.faction
				M.current.faction = antag.faction
		antag.pending_antagonists.Cut()
		antag.candidates.Cut()

		for(var/datum/mind/M in drafted)
			if(!(M in antag.current_antagonists))
				problems += "[M.key || M.name] was drafted but never ended up in current_antagonists."
				continue
			if(M.special_role != antag.role_text)
				problems += "[M.key || M.name] has special_role [M.special_role], expected [antag.role_text]."
			var/mob/living/current = M.current
			if(!current)
				problems += "[M.key || M.name] has no living mob after being finalized."
				continue
			if(!locate(/obj/item/device/radio/uplink) in current.GetAllContents())
				problems += "[M.key || M.name] was not given an uplink radio."
			if(current.faction != antag.faction)
				problems += "[M.key || M.name] has faction [current.faction], expected [antag.faction]."
			if(config.objectives_disabled == CONFIG_OBJECTIVE_ALL && !length(M.objectives))
				problems += "[M.key || M.name] has no objectives."

		// Undo the antagonist status we actually granted.
		for(var/datum/mind/M in drafted)
			antag.remove_antagonist(M)

	// Delete every synthetic mob/mind we created, drafted or not.
	for(var/datum/mind/M in test_minds)
		if(M.current)
			qdel(M.current)
		SSticker.minds -= M
		qdel(M)

	antag.candidates = saved_candidates
	antag.pending_antagonists = saved_pending
	antag.current_antagonists = saved_current
	SSticker.antag_pool = saved_antag_pool

	if(length(problems))
		fail("[english_list(problems)]")
	else
		pass("[spawn_target] mercenaries drafted, equipped, factioned and objectived correctly.")
	return 1

#undef SUCCESS
#undef FAILURE

#endif
