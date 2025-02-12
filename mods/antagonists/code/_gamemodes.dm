/datum/game_mode/intrigue
	name = "Traitor & Ninja"
	round_description = "Traitors and a ninja are about to end your carrier."
	extended_round_description = "Traitors and a ninja are about to end your carrier."
	config_tag = "intrigue"
	required_players = 10
	required_enemies = 4
	end_on_antag_death = FALSE
	antag_tags = list(MODE_TRAITOR, MODE_NINJA)
	require_all_templates = TRUE

/datum/game_mode/thething
	name = "Ling vs Renegade"
	round_description = "There are alien changelings onboard. But can them expect significant resistance?"
	extended_round_description = "There are alien changelings onboard. But can them expect significant resistance?"
	config_tag = "thething"
	required_players = 12
	required_enemies = 1
	end_on_antag_death = FALSE
	antag_scaling_coeff = 10
	antag_tags = list(MODE_CHANGELING, MODE_RENEGADE)
	require_all_templates = TRUE

/*
// This gamemodes depends on further fixes for their antags. So here the waiting room.
/datum/game_mode/tralf
	name = "Traitor & Malfunctioning AI"
	round_description = "Traitor and a Malfunctioning AI are about to end your carrier."
	extended_round_description = "Traitor and a Malfunctioning AI are about to end your carrier."
	config_tag = "tralf"
	required_players = 9
	required_enemies = 4
	end_on_antag_death = FALSE
	antag_tags = list(MODE_TRAITOR, MODE_MALFUNCTION)
	require_all_templates = TRUE
*/
