/datum/admins/proc/player_list()
	if (!usr.client.holder)
		return
	var/index = length(GLOB.player_list)
	var/list/entries = new (index)
	var/entry_template = file2text("html/pages/player_list_entry.html")
	var/regex/strip_symbols = regex(@/['"\\<>]/, "g")
	for (var/mob/player as anything in GLOB.player_list)
		var/job
		if (ishuman(player))
			var/mob/living/carbon/human/human = player
			job = "[human.species.name] [human.job]"
		else if (isAI(player))
			job = "AI"
		else if (ispAI(player))
			job = "pAI"
		else if (isrobot(player))
			job = "Robot"
		else if (isghost(player))
			job = "Ghost"
		else if (isnewplayer(player))
			job = "Lobby"
		else if (isanimal(player) || isalien(player))
			job = "Animal"
		else if (isslime(player))
			job = "Slime"
		else
			job = "[player.type]"
		var/entry = replacetext_char(entry_template, "{BACKGROUND}", index & 1 ? "#e0e0e0" : "#f0f0f0")
		entry = replacetext_char(entry, "{INDEX}", index)
		entry = replacetext_char(entry, "{JOB}", replacetext_char(job, strip_symbols, ""))
		entry = replacetext_char(entry, "{REAL_NAME}", replacetext_char(player.real_name, strip_symbols, ""))
		entry = replacetext_char(entry, "{NAME}", replacetext_char(player.name, strip_symbols, ""))
		entry = replacetext_char(entry, "{KEY}", replacetext_char(player.key, strip_symbols, ""))
		entry = replacetext_char(entry, "{ANTAG}", is_special_character(player) ? "true" : "false")
		entry = replacetext_char(entry, "{REF}", "\ref[player]")
		entry = replacetext_char(entry, "{ADDR}", player.lastKnownIP)
		entries[index] = entry
		--index
	var/doc = replacetext_char(file2text("html/pages/player_list.html"), "{REF_SRC}", "\ref[src]")
	doc = replacetext_char(doc, "{REF_USR}", "\ref[usr]")
	doc = replacetext_char(doc, "{ENTRIES}", jointext(entries, null))
	show_browser(usr, doc, "window=player_list;size=640x480")
