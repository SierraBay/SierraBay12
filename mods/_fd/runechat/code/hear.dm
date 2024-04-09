/mob/hear_say(message, verb = "says", datum/language/language, alt_name, italics, mob/speaker, sound/speech_sound, sound_vol)
	if (!client)
		return

	var/is_ghost = isghost(src)
	var/in_view = (speaker in view(src))

	if (is_ghost)
		if (!in_view && !speaker?.client)
			return

	var/pressure = 0
	var/turf/turf = get_turf(src)

	if (turf)
		var/datum/gas_mixture/air = turf.return_air()
		if (air)
			pressure = air.return_pressure()

	var/distance = get_dist(speaker, turf)

	if (pressure < ONE_ATMOSPHERE * 0.5)
		if (pressure < SOUND_MINIMUM_PRESSURE)
			if (distance > 1 && !is_ghost)
				return
			speech_sound = null
		else
			sound_vol *= 0.5
		italics = TRUE

	var/non_verbal = language?.flags & (NONVERBAL | SIGNLANG)
	var/do_stars

	var/display_name = "Unknown"
	if (ishuman(speaker))
		var/mob/living/carbon/human/human = speaker
		display_name = human.GetVoice()
	else if (speaker)
		display_name = speaker.name

	if (non_verbal)
		if (!speaker || (sdisabilities & BLINDED) || blinded || !in_view)
			do_stars = TRUE
		speech_sound = null
	else if (is_deaf() || get_sound_volume_multiplier() < 0.2)
		if (!(language?.flags & INNATE))
			if (speaker == src)
				to_chat(src, SPAN_WARNING("You cannot hear yourself speak!"))
			else if (!is_blind())
				to_chat(src, {"[SPAN_CLASS("name", display_name)][alt_name] says something you cannot hear."})
			return
		speech_sound = null

	if (speech_sound && in_view)
		var/turf/sound_turf = speaker ? get_turf(speaker) : turf
		if (sound_turf)
			playsound_local(sound_turf, speech_sound, sound_vol, TRUE)

	var/display_message = message

	if (!(language?.flags & INNATE) && !say_understands(speaker, language))
		if (!istype(speaker, /mob/living/simple_animal))
			if (language)
				display_message = language.scramble(display_message, languages)
			else
				do_stars = TRUE

	if (do_stars)
		display_message = stars(display_message)

	if ((sleeping || stat == UNCONSCIOUS) && !non_verbal)
		hear_sleep(display_message)
		return

	if (italics)
		display_message = "<i>[display_message]</i>"

	var/runechat_message = display_message

	var/display_controls
	if (is_ghost)
		if (display_name != speaker.real_name && speaker.real_name)
			display_name = "[speaker.real_name] ([display_name])"
		if (in_view && get_preference_value(/datum/client_preference/ghost_ears) == GLOB.PREF_ALL_SPEECH)
			display_message = "<b>[display_message]</b>"
		var/control_preference = get_preference_value(/datum/client_preference/ghost_follow_link_length)
		switch (control_preference)
			if (GLOB.PREF_SHORT)
				display_controls = "([ghost_follow_link(speaker, src)])"
			if (GLOB.PREF_LONG)
				display_controls = "([ghost_follow_link(speaker, src, short_links = FALSE)])"

	var/display_verb = verb
	if (!language)
		display_message = {"[display_verb], [SPAN_CLASS("message", "[SPAN_CLASS("body", display_message)]")]"}
	else
		var/hint_preference = get_preference_value(/datum/client_preference/language_display)
		if (is_ghost)
			if (hint_preference != GLOB.PREF_OFF)
				if (get_preference_value(/datum/client_preference/ghost_language_hide) == GLOB.PREF_YES)
					hint_preference = GLOB.PREF_OFF
		else if (say_understands(speaker, language) && isliving(src))
			var/mob/living/living = src
			if (living.default_language == language)
				hint_preference = GLOB.PREF_OFF
		switch (hint_preference)
			if (GLOB.PREF_FULL)
				display_verb = "[verb] in [language.name]"
			if (GLOB.PREF_SHORTHAND)
				display_verb = "[verb] ([language.shorthand])"
		display_message = language.format_message(display_message, display_verb)

	on_hear_say({"[SPAN_CLASS("game say", "[display_controls][SPAN_CLASS("name", display_name)][alt_name] [display_message]")]"})

	if (istype(language, /datum/language/noise))
		create_chat_message(speaker, runechat_message, italics, list("emote"))
	else
		create_chat_message(speaker, capitalize(runechat_message), italics, list())



/mob/hear_signlang(message, verb = "gestures", datum/language/language, mob/speaker = null)
	if(!client)
		return

	if(sleeping || stat == UNCONSCIOUS)
		return 0

	var/runechat_message

	if(say_understands(speaker, language))
		var/nverb = null
		switch(src.get_preference_value(/datum/client_preference/language_display))
			if(GLOB.PREF_FULL) // Full language name
				nverb = "[verb] in [language.name]"
			if(GLOB.PREF_SHORTHAND) //Shorthand codes
				nverb = "[verb] ([language.shorthand])"
			if(GLOB.PREF_OFF)//Regular output
				nverb = verb
		runechat_message = message
		message = "<B>[speaker]</B> [nverb], \"[message]\""
	else
		var/adverb
		var/length = length(message) * pick(0.8, 0.9, 1.0, 1.1, 1.2)	//Inserts a little fuzziness.
		switch(length)
			if(0 to 12) 	adverb = " briefly"
			if(12 to 30)	adverb = " a short message"
			if(30 to 48)	adverb = " a message"
			if(48 to 90)	adverb = " a lengthy message"
			else			adverb = " a very lengthy message"
		runechat_message = "[verb][adverb]"
		message = "<B>[speaker]</B> [verb][adverb]."

	if(src.status_flags & PASSEMOTES)
		for(var/obj/item/holder/H in src.contents)
			H.show_message(message)
		for(var/mob/living/M in src.contents)
			M.show_message(message)
	create_chat_message(speaker, capitalize(runechat_message), FALSE, list("emote"), FALSE)
	src.show_message(message)
