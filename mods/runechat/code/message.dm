/// ------ AUDIBLE MESSAGES ------ ///

/atom/audible_message(message, deaf_message, hearing_distance = world.view, checkghosts = null, list/exclude_objs = null, list/exclude_mobs = null, runemessage = -1)
	var/turf/T = get_turf(src)
	var/list/mobs = list()
	var/list/objs = list()
	get_mobs_and_objs_in_view_fast(T, hearing_distance, mobs, objs, checkghosts)
	for(var/m in mobs)
		var/mob/M = m
		if (length(exclude_mobs) && (M in exclude_mobs))
			exclude_mobs -= M
			continue
		M.show_message(message,2,deaf_message,1)
		if(runemessage != -1)
			M.create_chat_message(src, "[runemessage]", FALSE, list("emote"))

	for(var/o in objs)
		var/obj/O = o
		if (length(exclude_objs) && (O in exclude_objs))
			exclude_objs -= O
			continue
		O.show_message(message,2,deaf_message,1)


/mob/audible_message(message, self_message, deaf_message, hearing_distance = world.view, checkghosts = null, narrate = FALSE, list/exclude_objs = null, list/exclude_mobs = null, runemessage = -1)
	var/turf/T = get_turf(src)
	var/list/mobs = list()
	var/list/objs = list()
	get_mobs_and_objs_in_view_fast(T, hearing_distance, mobs, objs, checkghosts)

	for(var/m in mobs)
		var/mob/M = m
		if (length(exclude_mobs) && (M in exclude_mobs))
			exclude_mobs -= M
			continue
		var/mob_message = message

		if(isghost(M))
			if(ghost_skip_message(M))
				continue
			mob_message = add_ghost_track(mob_message, M)

		if(!(M.knows_target(src)) && !(isghost(M)))
			for(var/datum/pronouns/entry as anything in GLOB.pronouns.instances)
				mob_message = replacetext(mob_message, " [initial(entry.his)] ", " their ")
				mob_message = replacetext(mob_message, " [initial(entry.him)] ", " them ")
				mob_message = replacetext(mob_message, " [initial(entry.self)] ", " themselves ")

		if(self_message && M == src)
			M.show_message(self_message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)
		else if(M.see_invisible >= invisibility || narrate) // Cannot view the invisible
			M.show_message(mob_message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)
		else
			M.show_message(mob_message, AUDIBLE_MESSAGE)

		if(runemessage != -1)
			M.create_chat_message(src, "[runemessage]", FALSE, list("emote"))

	for(var/o in objs)
		var/obj/O = o
		if (length(exclude_objs) && (O in exclude_objs))
			exclude_objs -= O
			continue
		O.show_message(message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)


/// ------ VISIBLE MESSAGES ------ ///


/atom/visible_message(message, blind_message, range = world.view, checkghosts = null, list/exclude_objs = null, list/exclude_mobs = null, runemessage = -1)
	set waitfor = FALSE
	var/turf/T = get_turf(src)
	var/list/mobs = list()
	var/list/objs = list()
	get_mobs_and_objs_in_view_fast(T,range, mobs, objs, checkghosts)

	for(var/o in objs)
		var/obj/O = o
		if (length(exclude_objs) && (O in exclude_objs))
			exclude_objs -= O
			continue
		O.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)

	for(var/m in mobs)
		var/mob/M = m
		if (length(exclude_mobs) && (M in exclude_mobs))
			exclude_mobs -= M
			continue
		if(M.see_invisible >= invisibility)
			M.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
			if(runemessage != -1)
				M.create_chat_message(src, "[runemessage]", FALSE, list("emote"), audible = FALSE)
		else if(blind_message)
			M.show_message(blind_message, AUDIBLE_MESSAGE)


/mob/visible_message(message, self_message, blind_message, range = world.view, checkghosts = null, narrate = FALSE, list/exclude_objs = null, list/exclude_mobs = null, runemessage = -1)
	set waitfor = FALSE
	var/turf/T = get_turf(src)
	var/list/mobs = list()
	var/list/objs = list()
	get_mobs_and_objs_in_view_fast(T,range, mobs, objs, checkghosts)

	for(var/o in objs)
		var/obj/O = o
		if (length(exclude_objs) && (O in exclude_objs))
			exclude_objs -= O
			continue
		O.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)

	for(var/m in mobs)
		var/mob/M = m
		if (length(exclude_mobs) && (M in exclude_mobs))
			exclude_mobs -= M
			continue

		var/mob_message = message

		if(isghost(M))
			if(ghost_skip_message(M))
				continue
			mob_message = add_ghost_track(mob_message, M)

		if(self_message && M == src)
			M.show_message(self_message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
			continue

		if(!(M.knows_target(src)) && !isghost(M))
			for(var/datum/pronouns/entry as anything in GLOB.pronouns.instances)
				mob_message = replacetext(mob_message, " [initial(entry.his)] ", " their ")
				mob_message = replacetext(mob_message, " [initial(entry.him)] ", " them ")
				mob_message = replacetext(mob_message, " [initial(entry.self)] ", " themselves ")

		if((!M.is_blind() && M.see_invisible >= src.invisibility) || narrate)
			M.show_message(mob_message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
			if(runemessage != -1)
				M.create_chat_message(src, "[runemessage]", FALSE, list("emote"), audible = FALSE)
			continue

		if(blind_message)
			M.show_message(blind_message, AUDIBLE_MESSAGE)
			continue
	//Multiz, have shadow do same
	if(bound_overlay)
		bound_overlay.visible_message(message, blind_message, range)
