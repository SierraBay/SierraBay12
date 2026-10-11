/mob/Destroy()
	SStgui?.close_user_uis(src)
	SSnano?.close_user_uis(src)
	return ..()
