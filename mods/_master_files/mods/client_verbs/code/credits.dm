/client/var/datum/tgui_module/credits/tgui_credits

/client/credits()
	set name = "Credits"
	set category = "OOC"
	if(!tgui_credits)
		tgui_credits = new(src)
	tgui_credits.tgui_interact(mob)
