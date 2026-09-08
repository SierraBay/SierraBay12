// calculating a difference between last online and real players
// to override player count budget in away sites generation
/datum/map/build_away_sites()
	get_previous_online()
	..()

/datum/map/proc/get_previous_online()
	// since persistence is loaded after away sites, we are doing this
	var/datum/persistent/mod_last_online/P = new

	if(!P)
		return

	var/list/tokens = P.FinalizeTokens()

	if(!LAZYLEN(tokens) || !tokens["last_online"])
		return

	var/real_players = 0

	for(var/client/C)
		++real_players

	var/last_players = text2num(tokens["last_online"])

	if(last_players > 0 && last_players > real_players)
		var/diff = last_players - real_players
		min_offmap_players -= diff
		report_progress("Override: new starting player budget is [-min_offmap_players] (Last players: [last_players], difference: [diff])")