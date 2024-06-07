
/mob/living/Login()
	. = ..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client
	//If they're SSD, remove it so they can wake back up.
	update_antag_icons(mind)
	GLOB.living_players |= src
	// [SIERRA-ADD] - STATUSBAR
	if (my_client && get_preference_value(/datum/client_preference/show_statusbar) == GLOB.PREF_SHOW)
		winset(my_client, "mapwindow.statusbar", "is-visible=true")
	// [/SIERRA-ADD]
