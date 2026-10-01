// Low-pop friendly thresholds for ship-vote rounds, plus a votable Renegade mode.
// Submap crew antag eligibility uses allows_main_ship_submap_crew() below.

/datum/antagonist/traitor/allows_main_ship_submap_crew()
	return TRUE

/datum/antagonist/changeling/allows_main_ship_submap_crew()
	return TRUE

/datum/antagonist/cultist/allows_main_ship_submap_crew()
	return TRUE

/datum/antagonist/renegade/allows_main_ship_submap_crew()
	return TRUE

/datum/game_mode/cult
	required_players = 5
	required_enemies = 1

/datum/game_mode/changeling
	required_players = 5
	required_enemies = 1

/datum/antagonist/cultist
	initial_spawn_req = 1
	initial_spawn_target = 3

/datum/game_mode/renegade
	name = "Renegade"
	round_description = "Someone on the vessel is armed, paranoid, and determined to survive."
	extended_round_description = "One or more crewmembers have gone renegade. They are not after the ship itself — they simply intend to live through whatever goes wrong today."
	config_tag = "renegade"
	required_players = 0
	required_enemies = 1
	end_on_antag_death = FALSE
	antag_tags = list(MODE_RENEGADE)
