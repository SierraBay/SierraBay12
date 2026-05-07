var/global/list/admin_verbs_xeno = list(
	/datum/admins/proc/PlayerNotes,
	/datum/admins/proc/xeno_whitelist_panel
)

/client/add_admin_verbs()
	..()
	if(holder)
		if(holder.rights & R_XENO)			verbs += admin_verbs_xeno

#define HOLDER_LIST		list(SPECIES_FBP, SPECIES_PSI)

/datum/admins/proc/xeno_whitelist_panel()
	set name = "Xenos Whitelist Panel"
	set desc = "Use this to edit players xenowhitelist. Yupi!"
	set category = "Admin"

	if(!usr.client) return

	if(!istype(src,/datum/admins))
		src = usr.client.holder
	if(!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!check_rights(R_XENO))
		if(!check_rights(R_DEBUG))
			to_chat(usr, "<span class='warning'>Access Denied!</span>")
			return
		log_admin("[key_name(usr)] access xeno whitelist via debug.")
		message_staff("[key_name_admin(usr)] currently debugging xeno whitelist.")

	var/datum/nano_module/xenopanel/NM = locate("xenoui_[usr.ckey]")
	if(!NM)
		NM = new /datum/nano_module/xenopanel(usr)
		NM.tag = "xenoui_[usr.ckey]"
	NM.ui_interact(usr)

/*
	This state checks that the user is an ~~admin~~ XenoModerator, end of story
*/
GLOBAL_TYPED_NEW(xeno_state, /datum/topic_state/admin_state/xeno)

/datum/topic_state/admin_state/xeno/can_use_topic(src_object, mob/user)
	return check_rights(R_XENO|R_DEBUG, 0, user) ? STATUS_INTERACTIVE : STATUS_CLOSE


/datum/nano_module/xenopanel
	var/list/used = list()
	var/list/lowerxenoname = list()
	var/sortkey = "ckey"
	var/datum/nanoui/myui	// Shame on me

/datum/nano_module/xenopanel/New()
	.=..()
	for(var/s in GLOB.species_by_name)
		var/singleton/species/species = GLOB.species_by_name[s]
		if(species.spawn_flags & SPECIES_IS_WHITELISTED)
			if(!(lowertext(species.whitelistName()) in lowerxenoname))
				lowerxenoname.Add("[lowertext(species.whitelistName())]")
	for(var/s2 in HOLDER_LIST)
		lowerxenoname.Add("[lowertext(s2)]")
	used = SortByRace(ParseXenoWhitelist(GetXenoWhitelist(), lowerxenoname), sortkey)

/datum/nano_module/xenopanel/CanUseTopic(mob/user, datum/topic_state/state = GLOB.xeno_state)
	. = ..()

/datum/nano_module/xenopanel/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.xeno_state)
	var/list/data = list()
	data["searchbox"] = "<form action='byond://'><input type='hidden' name='src' value='\ref[src]'>New ckey <input type='text' size='40' name='input' autofocus><input type='submit' value='Search'></form>"
	data["sorting"] = sortkey
	data["debug"] = check_rights(R_DEBUG)
	data["disabled"] = !config.usealienwhitelist
	data["currentlist"] = used
	data["lowerallxenos"] = lowerxenoname

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-xeno_whitelist.tmpl", "XenoWhitelist Panel", 3000, 1000, src, state = state)
		ui.set_initial_data(data)
		ui.open()
	myui = ui

/datum/nano_module/xenopanel/Topic(href, href_list, state)
	if(..())
		return 1
	if(href_list["close"]) // This is called when the window is closed; we've signed up to get notified of it.
		qdel(src)
		return 1
	else if (href_list["ckey"] && href_list["race"])
		var/list/l = used
		var/list/ckey
		for(ckey in l)
			if(ckey["ckey"] == href_list["ckey"])
				break
		if(!ckey)
			log_admin("Error: Alien Whitelist Panel - unknown ckey marker found. Ckey [href_list["ckey"]]; Race [href_list["race"]]")
			message_staff("Error: Alien Whitelist Panel - unknown ckey marker found. Ckey [href_list["ckey"]]; Race [href_list["race"]]")
			return TOPIC_NOACTION
		if(href_list["race"] in ckey["YES"])
			ckey["YES"] -= list(href_list["race"])
			ckey["REVOKE"] += list(href_list["race"])
		else if(href_list["race"] in ckey["REVOKE"])
			ckey["REVOKE"] -= list(href_list["race"])
			ckey["YES"] += list(href_list["race"])
		else if(href_list["race"] in ckey["NO"])
			ckey["NO"] -= list(href_list["race"])
			ckey["GRANT"] += list(href_list["race"])
		else if(href_list["race"] in ckey["GRANT"])
			ckey["GRANT"] -= list(href_list["race"])
			ckey["NO"] += list(href_list["race"])
		else
			log_admin("Error: Alien Whitelist Panel - unknown species found. Ckey [href_list["ckey"]]; Race [href_list["race"]]")
			message_staff("Error: Alien Whitelist Panel - unknown species found. Ckey [href_list["ckey"]]; Race [href_list["race"]]")
		. = TOPIC_REFRESH

	else if (href_list["sorting"])
		sortkey = href_list["sorting"]
		used = SortByRace(used, sortkey)
		. = TOPIC_REFRESH

	else if (href_list["send"])
		var/list/grant = list()
		var/list/revoke = list()
		for(var/list/ckey in used)
			var/list/local = ckey["GRANT"]
			if(length(local))
				grant["[ckey["ckey"]]"] += local
			local = ckey["REVOKE"]
			if(length(local))
				revoke["[ckey["ckey"]]"] += local
		var/success = upload_CONFIG(usr, grant, revoke)
		if(!success)
			log_admin("Error: Alien Whitelist Panel - Unable to save whitelist to config")
			message_staff("Error: Alien Whitelist Panel - Unable to save whitelist to config")
		used = SortByRace(ParseXenoWhitelist(GetXenoWhitelist(), lowerxenoname), "ckey")
		. = TOPIC_REFRESH

	else if (href_list["refresh"])
		if(alert("Вы уверены что хотите перезагрузить данные из config/alienwhitelist.txt?\nВсе несохранённые изменения ниже будут отменены!", "Refresh", "Да", "Отмена") == "Отмена")
			return TOPIC_NOACTION
		used = SortByRace(ParseXenoWhitelist(GetXenoWhitelist(), lowerxenoname), "ckey")
		. = TOPIC_REFRESH
	else if (href_list["input"])
		var/input = lowertext(sanitize(href_list["input"]))
		sortkey = input
		if(!input)
			return TOPIC_NOACTION
		if(used)
			used = inckeysearch(used, input)
		if(myui)
			myui.update()
		. = TOPIC_REFRESH

/datum/nano_module/xenopanel/proc/inckeysearch(list/l, ckey)
	var/list/newckey = list()
	var/list/insort = list()
	var/list/notinsort = list()
	var/create = TRUE
	l = sortByKey(l, "ckey")
	for(var/list/check in l)
		if(check["ckey"] == ckey)
			create = FALSE
			newckey += list(check)
		else if(findtext(check["ckey"], ckey, 1, length(ckey)+1))
			insort += list(check)
		else
			notinsort += list(check)

	if(create)
		var/list/check = list()
		check["ckey"] = ckey
		for(var/race in lowerxenoname)
			check["NO"] += list(race)
		newckey += list(check)

	l.Cut()
	l.Add(newckey)
	l.Add(insort)
	l.Add(notinsort)
	return l

/datum/nano_module/xenopanel/proc/upload_CONFIG(client/user, list/grant, list/revoke, sort = TRUE)
	. = 1
	user = user.get_client()
	if(config.usealienwhitelistSQL)
		to_chat(user, SPAN_WARNING("Сервер в режиме SQL-вайтлиста: панель только для просмотра. Измените БД или отключите SQL в конфиге."))
		return 0
	var/text = file2text("config/alienwhitelist.txt")
	if (!text)
		log_misc("Failed to load config/alienwhitelist.txt")
		return 0
	var/list/l = splittext(text, "\n")
	// Empty line in the end
	if(l[length(l)] == "")
		l -= l[length(l)]
	if(length(revoke))
		for(var/ckey in revoke)
			var/list/check = revoke[ckey]
			for(var/race in check)
				l -= "[lowertext(ckey)] - [lowertext(race)]"
			log_admin("Alien Whitelist REVOKED (CONFIG) by [user.ckey]. [lowertext(ckey)]: [jointext(check, ", ")]")
			message_staff("Alien Whitelist REVOKED (CONFIG) by [user.ckey]. [lowertext(ckey)]: [jointext(check, ", ")]")
	if(length(grant))
		for(var/ckey in grant)
			var/list/check = grant[ckey]
			for(var/race in check)
				l += "[lowertext(ckey)] - [lowertext(race)]"
			log_admin("Alien Whitelist GRANTED (CONFIG) by [user.ckey]. [lowertext(ckey)]: [jointext(check, ", ")]")
			message_staff("Alien Whitelist GRANTED (CONFIG) by [user.ckey]. [lowertext(ckey)]: [jointext(check, ", ")]")
	if(!length(l))
		log_misc("Failed to load config/alienwhitelist.txt")
		return 0
	// Not working
	if(sort)
		var/ckeys = list()
		var/list/racecheck = list()
		for(var/check in l)
			var/list/unite = splittext(check, " - ")
			var/list/a = list()
			if(!unite[1] || !unite[2])
				message_staff("Alien Whitelist ERROR when accessing CONFIG in line '[check]'")
				log_admin("Alien Whitelist ERROR when accessing CONFIG in line '[check]'")
				continue
			a["ckey"] = unite[1]
			a["race"] = unite[2]
			ckeys += list(a)
			if(!(unite[2] in racecheck))
				racecheck += list(unite[2])
		racecheck = sortList(racecheck)
		var/list/result = list()
		for(var/check in racecheck)
			var/list/ckeys1 = list()
			for(var/chekycheck in ckeys)
				var/list/local = chekycheck
				if(local["race"] == check)
					ckeys1 += list(chekycheck)
			ckeys1 = sortByKey(ckeys1, "ckey")
			result += ckeys1
			ckeys1.Cut()

		l.Cut()
		for(var/ChEcK in result)
			var/list/key = ChEcK
			var/CKEY = key["ckey"]
			var/RACE = key["race"]
			var/unite = "[CKEY] - [RACE]"
			l += unite
	text = jointext(l, "\n")
	fdel("config/alienwhitelist.txt")
	text2file(text, "config/alienwhitelist.txt")
	return load_alienwhitelist()

//	Если элемент есть в подлисте - вытаскиваем его повыше
/proc/SortByRace(list/L, race = "ckey")
	if(!length(L))
		return list()
	L = sortByKey(L, "ckey")
	if(race && !(race == "ckey"))
		var/list/insort = list()
		var/list/secondsort = list()
		var/list/tirhdsort = list()
		var/list/notinsort = list()
		for(var/list/s in L)
			if(lowertext(race) in s["GRANT"])
				insort += list(s)
			else if(lowertext(race) in s["REVOKE"])
				secondsort += list(s)
			else if(lowertext(race) in s["YES"])
				tirhdsort += list(s)
			else
				notinsort += list(s)
		L.Cut()
		L.Add(insort)
		L.Add(secondsort)
		L.Add(tirhdsort)
		L.Add(notinsort)
	return L

//	Для того чтобы уи мог нормально читать дату, нам нужно наш общий список еще раз переделать. Да - говнокод, но зато какой! ~Laxesh
/proc/ParseXenoWhitelist(list/l, list/allspecies)
	var/list/out = list()
	if(!length(l))
		return list()
	for(var/string in l)
		var/list/unite = list()
		unite["ckey"] = string
		for(var/s in allspecies)
			if(s in l[string])
				unite["YES"] += list(s)
			else
				unite["NO"] += list(s)
		out += list(unite)
	return out

/// Normalize config lines (`ckey - race`) into whitelist[ckey] = list(races...).
/proc/xeno_whitelist_lines_to_assoc(list/lines)
	var/list/secondary = list()
	for(var/s in lines)
		var/list/A = splittext(s, " - ")
		if(length(A) < 2)
			if(lines[length(lines)] == s)
				break
			log_admin("File alien_whitelist parsing error in line: [s]")
			message_staff("File alien_whitelist parsing error in line: [s]")
			continue
		if(A[1] in secondary)
			var/list/B = secondary[A[1]]
			if(findtext(s, " - All"))
				B = list()
				for(var/race in GLOB.species_by_name)
					var/singleton/species/species = GLOB.species_by_name[race]
					if(species.spawn_flags & SPECIES_IS_WHITELISTED)
						B.Add("[lowertext(species.name)]")
			else
				if(!(A[2] in B))
					B.Add(lowertext(A[2]))
		else
			if(findtext(s, " - All"))
				secondary[A[1]] = list()
				for(var/race in GLOB.species_by_name)
					var/singleton/species/species = GLOB.species_by_name[race]
					if(species.spawn_flags & SPECIES_IS_WHITELISTED)
						secondary[A[1]] += list("[lowertext(species.name)]")
			else
				secondary[A[1]] = list(lowertext(A[2]))
	return secondary

/// Whitelist as `list(ckey = list(races...))` for the panel. File mode: from `alien_whitelist` lines or disk. (SQL-backed server list is read-only here; saves always go to config.)
/proc/GetXenoWhitelist()
	if(config.usealienwhitelistSQL && alien_whitelist && length(alien_whitelist))
		return alien_whitelist
	var/list/lines = list()
	if(alien_whitelist && length(alien_whitelist))
		lines = alien_whitelist
	else
		var/text = file2text("config/alienwhitelist.txt")
		if(text)
			lines = splittext(text, "\n")
	if(!length(lines))
		return list()
	return xeno_whitelist_lines_to_assoc(lines)

#undef HOLDER_LIST


/singleton/species/proc/whitelistName(mob/living/carbon/human/H)
	return get_bodytype(H)
