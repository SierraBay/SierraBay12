/mob/observer/ghost/view_manfiest()
	set name = "Show Crew Manifest"
	set category = "Ghost"

	var/datum/nano_module/manifest/ui  = new /datum/nano_module/manifest(usr)
	ui.ooc = TRUE
	ui.ui_interact(usr)
