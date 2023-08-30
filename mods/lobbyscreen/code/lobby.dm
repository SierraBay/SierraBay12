/datum/map
	var/base_lobby_html

/datum/map/New()
	. = ..()
	base_lobby_html = file2text('mods/lobbyscreen/html/lobby.html')

/datum/map/show_titlescreen(client/C)
	if(isnewplayer(C.mob))
		var/datum/asset/lobby_assets = get_asset_datum(/datum/asset/simple/mod_lobby)    // Sending fonts+png+mp4 assets to the client
		var/datum/asset/fa_assets = get_asset_datum(/datum/asset/simple/fontawesome) // Sending font awesome to the client
		lobby_assets.send(C)
		fa_assets.send(C)

		if (!Master.current_runlevel)
			// Sending big video only if it's needed
			var/datum/asset/loop = get_asset_datum(/datum/asset/simple/mod_lobby_loop)
			loop.send(C)

		var/mob/new_player/player = C.mob
		show_browser(C, replacetext_char(base_lobby_html, "\[player-ref]", "\ref[player]"), "window=lobbybrowser")
		update_titlescreen(C)

/datum/map/proc/update_titlescreens()
	for(var/mob/new_player/player in GLOB.player_list)
		update_titlescreen(player.client)

/datum/map/proc/update_titlescreen(client/C)
	var/state = Master.current_runlevel || 0
	var/mob/new_player/player = C.mob
	send_output(C, "[state]-[player.ready]", "lobbybrowser:setStatus")
