/jukebox/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui, force_open = TRUE, datum/topic_state/state = GLOB.default_state)//, datum/topic_state/state = GLOB.jukebox_state)
	if(istype(owner, /obj/machinery/jukebox))
		var/obj/machinery/jukebox/J = owner
		data["tape"] = J.tape


/jukebox/Topic(href, href_list)
	switch ("[href_list["act"]]")
		if ("next") Next()
		if ("last") Last()
		if ("stop") Stop()
		if ("play") Play()
		if ("volume") Volume("[href_list["dat"]]")
		if ("track") Track("[href_list["dat"]]")
		if ("eject")
			if(istype(owner, /obj/machinery/jukebox))
				var/obj/machinery/jukebox/J = owner
				J.eject()
	return TOPIC_REFRESH
