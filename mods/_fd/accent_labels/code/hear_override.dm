/mob/on_hear_say(message)
	var/name_verb_pos = findtext_char(message, ",")
	for(var/atom/speaker as() in GLOB.alive_mobs)
		if(!findtext(message, speaker.name, 1, name_verb_pos))
			continue
		message = "[get_accent_tag(speaker)]" + message
		break
	. = ..(message)

/mob/living/silicon/on_hear_say(message)
	var/name_verb_pos = findtext_char(message, ",")
	for(var/atom/speaker as() in GLOB.alive_mobs)
		if(!findtext(message, speaker.name, 1, name_verb_pos))
			continue
		message = "[get_accent_tag(speaker)]" + message
		break
	. = ..(message)

/mob/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0, vname ="")
	if(speaker && language && !(language.flags & (NONVERBAL | SIGNLANG)))
		part_a = "[get_accent_tag(speaker)]" + part_a
	. = ..(message, verb, language, part_a, part_b, part_c, speaker, hard_to_hear, vname)
