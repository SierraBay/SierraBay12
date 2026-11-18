// Donor TGUI dialogs, retaining Sierra character and loadout mechanics.
/datum/category_item/player_setup_item/physical/basic/OnTopic(href,list/href_list, mob/user)
	if(href_list["rename"])
		var/raw_name = tgui_input_text(user, "Choose your character's name:", "Character Name", null, multiline = FALSE, encode = FALSE)
		if (!isnull(raw_name) && CanUseTopic(user))

			var/singleton/cultural_info/check = SSculture.get_culture(pref.cultural_info[TAG_CULTURE])
			var/new_name = check.sanitize_name(raw_name, pref.species)
			if(new_name)
				pref.real_name = new_name
				return TOPIC_REFRESH
			else
				to_chat(user, SPAN_WARNING("Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and ."))
				return TOPIC_NOACTION

	else if(href_list["random_name"])
		pref.real_name = random_name(pref.gender, pref.species)
		return TOPIC_REFRESH

	else if(href_list["spawnpoint"])
		var/list/spawnkeys = list()
		for(var/spawntype in spawntypes())
			spawnkeys += spawntype
		var/choice = tgui_input_list(user, "Where would you like to spawn when late-joining?", null, spawnkeys, null)
		if(!choice || !spawntypes()[choice] || !CanUseTopic(user))	return TOPIC_NOACTION
		pref.spawnpoint = choice
		return TOPIC_REFRESH

	return ..()
