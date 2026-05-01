/mob/new_player/ViewManifest()
	if(usr.get_preference_value(/datum/client_preference/show_nanoui_start) == GLOB.PREF_NO)
		return ..()
	var/datum/nano_module/manifest/ui = new /datum/nano_module/manifest(usr)
	ui.ui_interact(usr)

/mob/new_player/LateChoices()
	if(usr.get_preference_value(/datum/client_preference/show_nanoui_start) == GLOB.PREF_NO)
		return ..()
	var/datum/nano_module/joinpanel/ui = locate("joinui_[usr.ckey]")
	if(!ui)
		ui = new /datum/nano_module/joinpanel(usr)
		ui.tag = "joinui_[usr.ckey]"
	ui.ui_interact(usr)
