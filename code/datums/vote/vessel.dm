#define VESSEL_VOTE_SIERRA "sierra"
#define USE_SHIP_FILE "use_ship"

/// End-of-round / admin vote: away main ships or reboot onto Sierra.
/datum/vote/vessel
	name = "vessel"
	manual_allowed = TRUE
	admin_priority_voting = TRUE

/datum/vote/vessel/can_run(mob/creator, automatic)
	if (!automatic && !isadmin(creator))
		return FALSE
	return TRUE

/datum/vote/vessel/setup_vote(mob/creator, automatic)
	..()
	choices += VESSEL_VOTE_SIERRA
	display_choices[VESSEL_VOTE_SIERRA] = "NSV Sierra"
	additional_text[VESSEL_VOTE_SIERRA] = "<td align='center'>—</td>"

	for (var/site_name in SSmapping.away_sites_templates)
		var/datum/map_template/ruin/away_site/site = SSmapping.away_sites_templates[site_name]
		if (!site.votable_as_main_ship)
			continue
		choices += site.id
		display_choices[site.id] = site.name
		additional_text[site.id] = "<td align='center'>[site.tallness]Z</td>"

	additional_header = "<th>Decks</th>"

/datum/vote/vessel/report_result()
	if (..())
		return 1
	apply_vessel_choice(result[1])

/datum/vote/vessel/proc/apply_vessel_choice(choice)
	fdel("use_map")
	if (choice == VESSEL_VOTE_SIERRA)
		fdel(USE_SHIP_FILE)
		text2file("sierra", "use_map")
		to_world(SPAN_NOTICE("Next round: <b>NSV Sierra</b> (recompile on reboot)."))
		log_vote("Vessel vote selected Sierra; wrote use_map=sierra.")
		return

	fdel(USE_SHIP_FILE)
	text2file("lobby_host", "use_map")
	text2file(choice, USE_SHIP_FILE)
	to_world(SPAN_NOTICE("Next round: <b>[display_choices[choice] || choice]</b> on Lobby Host (recompile on reboot)."))
	log_vote("Vessel vote selected [choice]; wrote use_map=lobby_host use_ship=[choice].")

/datum/vote/vessel/end_game
	manual_allowed = FALSE

/datum/vote/vessel/end_game/start_vote()
	SSticker.end_game_state = END_GAME_AWAITING_MAP
	..()

/datum/vote/vessel/end_game/report_result()
	. = ..()
	SSticker.end_game_state = END_GAME_READY_TO_END

/// Reads and consumes use_ship; returns a valid away template id or null.
/proc/consume_next_ship_id()
	if (!fexists(USE_SHIP_FILE))
		return null
	var/id = trim_left(trim_right(file2text(USE_SHIP_FILE) || ""))
	fdel(USE_SHIP_FILE)
	if (!id || id == VESSEL_VOTE_SIERRA)
		return null
	for (var/site_name in SSmapping.away_sites_templates)
		var/datum/map_template/ruin/away_site/site = SSmapping.away_sites_templates[site_name]
		if (site.id == id && site.votable_as_main_ship)
			return id
	log_error("use_ship contained unknown/unvotable id '[id]'; ignoring.")
	return null
