// TGUI
/datum/Destroy()
	SStgui?.close_uis(src)
	tgui_shared_states = null
	return ..()

