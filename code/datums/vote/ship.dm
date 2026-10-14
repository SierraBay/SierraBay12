/datum/vote/ship
	name = "ship"
	manual_allowed = TRUE
	admin_priority_voting = TRUE

/datum/vote/ship/can_run(mob/creator, automatic)
	if (!GLOB.using_map.ship_vote_enabled)
		return FALSE
	if (GLOB.using_map.ship_loaded)
		return FALSE
	if (GAME_STATE >= RUNLEVEL_GAME)
		return FALSE
	if (!automatic && !isadmin(creator))
		return FALSE
	var/has_choice = FALSE
	for (var/site_name in SSmapping.away_sites_templates)
		var/datum/map_template/ruin/away_site/site = SSmapping.away_sites_templates[site_name]
		if (site.votable_as_main_ship)
			has_choice = TRUE
			break
	if (!has_choice)
		return FALSE
	return ..()

/datum/vote/ship/Process()
	if (GAME_STATE >= RUNLEVEL_GAME)
		to_world("<b>Ship voting aborted due to game start.</b>")
		return VOTE_PROCESS_ABORT
	return ..()

/datum/vote/ship/setup_vote(mob/creator, automatic)
	..()
	for (var/site_name in SSmapping.away_sites_templates)
		var/datum/map_template/ruin/away_site/site = SSmapping.away_sites_templates[site_name]
		if (!site.votable_as_main_ship)
			continue
		choices += site.id
		display_choices[site.id] = site.name
		additional_text[site.id] = "<td align='center'>[site.tallness]Z</td>"
	additional_header = "<th>Decks</th>"
	if (!length(choices))
		log_error("Ship vote: no votable_as_main_ship templates registered.")

/datum/vote/ship/report_result()
	// Do not load the ship here: load_new_z() inside SSvote (SS_NO_TICK_CHECK) causes MC budget desync.
	// SSticker.pregame_tick loads the vessel, then starts the gamemode vote.
	if (..())
		to_world(SPAN_WARNING("Ship vote failed; default vessel will be loaded."))
		SSticker.selected_ship_id = GLOB.using_map.default_main_ship_id
		SSticker.ship_vote_results = list(SSticker.selected_ship_id)
		return 1

	SSticker.ship_vote_results = result.Copy()
	SSticker.selected_ship_id = result[1]
	to_world(SPAN_NOTICE("Selected vessel: <b>[display_choices[result[1]] || result[1]]</b>. Loading..."))
