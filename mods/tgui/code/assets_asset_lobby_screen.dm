// In case upstream decides to make lobby use assets
/datum/asset/group/lobby
	children = list(
		/datum/asset/simple/lobby,
		/datum/asset/simple/namespaced/fontawesome
	)

/datum/asset/simple/lobby
	legacy = TRUE
	keep_local_name = TRUE
	assets = list(
		"courierprime-code.woff" = 'mods/tgui/resources/html/fonts/courierprime-code.woff',
		"round-control.woff"     = 'mods/tgui/resources/html/fonts/round-control.woff',
		"light_left.png"  = 'mods/tgui/resources/html/lobby_screen/light_left.png',
		"light_right.png" = 'mods/tgui/resources/html/lobby_screen/light_right.png',
		"smallbutton.png" = 'mods/tgui/resources/html/lobby_screen/smallbutton.png',
		"buttons.mp4"     = 'mods/tgui/resources/html/lobby_screen/buttons.mp4'
	)

/datum/asset/simple/lobby_loop
	legacy = TRUE
	keep_local_name = TRUE
	assets = list("loop.mp4" = 'mods/tgui/resources/html/lobby_screen/loop.mp4')
