/mob/observer/ghost/Login()
	..()

	// [SIERRA-ADD] - STATUSBAR
	if (my_client && get_preference_value(/datum/client_preference/show_statusbar) == GLOB.PREF_SHOW)
		winset(my_client, "mapwindow.statusbar", "is-visible=true")
	// [/SIERRA-ADD]

	if (ghost_image)
		ghost_image.appearance = src
		ghost_image.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_ALPHA
	SSghost_images.queue_image_update(src)
	change_light_colour(DARKTINT_GOOD)
