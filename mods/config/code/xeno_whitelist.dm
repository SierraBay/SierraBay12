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
	var/selected_ckey = ""
	var/ui_layout = "compact"
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
	if(length(used))
		var/list/first = used[1]
		selected_ckey = first["ckey"]

/datum/nano_module/xenopanel/CanUseTopic(mob/user, datum/topic_state/state = GLOB.xeno_state)
	. = ..()

/datum/nano_module/xenopanel/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.xeno_state)
	var/list/data = list()
	data["searchbox"] = "<form action='byond://'><input type='hidden' name='src' value='\ref[src]'>New ckey <input type='text' size='40' name='input' autofocus><input type='submit' value='Search'></form>"
	data["src_ref"] = "\ref[src]"
	data["sorting"] = sortkey
	data["debug"] = check_rights(R_DEBUG)
	data["disabled"] = !config.usealienwhitelist
	data["sql_whitelist_mode"] = config.usealienwhitelistSQL
	data["ui_layout"] = ui_layout
	data["currentlist"] = used
	data["ckey_list"] = get_ckey_list(used)
	data["selected_ckey"] = selected_ckey
	data["selected_entry"] = get_selected_xeno_entry(used, selected_ckey)
	data["lowerallxenos"] = lowerxenoname
	if(config.usealienwhitelistSQL)
		data["selected_meta"] = get_xeno_whitelist_sql_meta(selected_ckey)

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

	else if (href_list["pick_ckey"])
		selected_ckey = lowertext(sanitize(href_list["pick_ckey"]))
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
			log_admin("Error: Alien Whitelist Panel - Unable to save whitelist to config/database")
			message_staff("Error: Alien Whitelist Panel - Unable to save whitelist to config/database")
		used = SortByRace(ParseXenoWhitelist(GetXenoWhitelist(), lowerxenoname), sortkey)
		if(!length(get_selected_xeno_entry(used, selected_ckey)) && length(used))
			var/list/first = used[1]
			selected_ckey = first["ckey"]
		. = TOPIC_REFRESH

	else if (href_list["refresh"])
		var/confirm_reload = "Вы уверены что хотите перезагрузить данные из config/alienwhitelist.txt?\nВсе несохранённые изменения ниже будут отменены!"
		if(config.usealienwhitelistSQL)
			confirm_reload = "Перезагрузить вайтлист из БД? Локальные несохранённые правки в панели будут сброшены."
		if(alert(confirm_reload, "Refresh", "Да", "Отмена") == "Отмена")
			return TOPIC_NOACTION
		if(config.usealienwhitelistSQL)
			if(!load_alienwhitelistSQL())
				to_chat(usr, SPAN_WARNING("Не удалось перезагрузить вайтлист из БД (см. лог сервера)."))
		else
			load_alienwhitelist()
		used = SortByRace(ParseXenoWhitelist(GetXenoWhitelist(), lowerxenoname), sortkey)
		if(!length(get_selected_xeno_entry(used, selected_ckey)) && length(used))
			var/list/first = used[1]
			selected_ckey = first["ckey"]
		. = TOPIC_REFRESH
	else if (href_list["toggle_layout"])
		ui_layout = (ui_layout == "compact") ? "classic" : "compact"
		. = TOPIC_REFRESH
	else if (href_list["input"])
		var/input = lowertext(sanitize(href_list["input"]))
		sortkey = input
		if(!input)
			return TOPIC_NOACTION
		if(used)
			used = inckeysearch(used, input)
		if(!length(get_selected_xeno_entry(used, selected_ckey)) && length(used))
			var/list/first = used[1]
			selected_ckey = first["ckey"]
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
		return save_xenowhitelist_to_db(user, grant, revoke)
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

/proc/save_xenowhitelist_to_db(client/user, list/grant, list/revoke)
	if(!dbcon_old || !dbcon_old.IsConnected())
		if(user)
			to_chat(user, SPAN_WARNING("База данных недоступна, вайтлист не сохранён."))
		return FALSE
	var/list/errors = list()
	if(!length(grant) && !length(revoke))
		return TRUE
	if(length(revoke))
		for(var/ckey_str in revoke)
			var/list/check = revoke[ckey_str]
			var/sql_ck = sql_sanitize_text("[ckey(ckey_str)]")
			for(var/race in check)
				var/sql_race = sql_sanitize_text(lowertext("[race]"))
				var/DBQuery/q = dbcon_old.NewQuery("UPDATE whitelist SET date = COALESCE(date, NOW()), date_remove = NOW() WHERE ckey = '[sql_ck]' AND race = '[sql_race]' AND date_remove IS NULL")
				if(!q.Execute())
					errors += dbcon_old.ErrorMsg()
					break
			if(length(errors))
				break
			log_admin("Alien Whitelist REVOKED (SQL) by [user ? user.ckey : "system"]. [lowertext(ckey_str)]: [jointext(check, ", ")]")
			message_staff("Alien Whitelist REVOKED (SQL) by [user ? user.ckey : "system"]. [lowertext(ckey_str)]: [jointext(check, ", ")]")
	if(length(errors))
		if(user)
			to_chat(user, SPAN_WARNING("Ошибка SQL при отзыве вайтлиста: [errors[1]]"))
		log_admin("Alien Whitelist SQL error: [errors[1]]")
		return FALSE
	if(length(grant))
		for(var/ckey_str in grant)
			var/list/check = grant[ckey_str]
			var/sql_ck = sql_sanitize_text("[ckey(ckey_str)]")
			var/sql_admin_ckey = sql_sanitize_text("[user ? user.ckey : "system"]")
			for(var/race in check)
				var/sql_race = sql_sanitize_text(lowertext("[race]"))
				var/DBQuery/qdel = dbcon_old.NewQuery("UPDATE whitelist SET date = COALESCE(date, NOW()), date_remove = NOW() WHERE ckey = '[sql_ck]' AND race = '[sql_race]' AND date_remove IS NULL")
				if(!qdel.Execute())
					errors += dbcon_old.ErrorMsg()
					break
				var/DBQuery/qins = dbcon_old.NewQuery("INSERT INTO whitelist (ckey, ackey, race, date, date_remove) VALUES ('[sql_ck]', '[sql_admin_ckey]', '[sql_race]', NOW(), NULL)")
				if(!qins.Execute())
					errors += dbcon_old.ErrorMsg()
					break
			if(length(errors))
				break
			log_admin("Alien Whitelist GRANTED (SQL) by [user ? user.ckey : "system"]. [lowertext(ckey_str)]: [jointext(check, ", ")]")
			message_staff("Alien Whitelist GRANTED (SQL) by [user ? user.ckey : "system"]. [lowertext(ckey_str)]: [jointext(check, ", ")]")
	if(length(errors))
		if(user)
			to_chat(user, SPAN_WARNING("Ошибка SQL при выдаче вайтлиста: [errors[1]]"))
		log_admin("Alien Whitelist SQL error: [errors[1]]")
		return FALSE
	if(!load_alienwhitelistSQL())
		if(user)
			to_chat(user, SPAN_WARNING("Изменения записаны, но не удалось перечитать вайтлист из БД."))
		return FALSE
	if(user)
		to_chat(user, SPAN_NOTICE("Ксеновайтлист сохранён в БД."))
	return TRUE


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

/proc/get_ckey_list(list/l)
	var/list/out = list()
	for(var/list/item in l)
		out += list(item["ckey"])
	return out

/proc/get_selected_xeno_entry(list/l, selected)
	for(var/list/item in l)
		if(item["ckey"] == selected)
			return item
	return list()

/proc/get_xeno_whitelist_sql_meta(selected)
	var/list/out = list()
	if(!config.usealienwhitelistSQL || !length(selected) || !dbcon_old || !dbcon_old.IsConnected())
		return out
	var/sql_selected = sql_sanitize_text(lowertext(selected))
	var/sql = "SELECT race, ackey, date, date_remove FROM whitelist WHERE LOWER(ckey) = '[sql_selected]' ORDER BY id DESC LIMIT 500"
	var/DBQuery/query = dbcon_old.NewQuery(sql)
	if(!query.Execute())
		return out
	while(query.NextRow())
		var/list/row = query.GetRowData()
		var/race = lowertext("[row["race"]]")
		if(out[race])
			continue
		var/list/item = list()
		item["ackey"] = row["ackey"]
		item["date"] = row["date"]
		item["date_remove"] = row["date_remove"]
		out[race] = item
	return out

#undef HOLDER_LIST


/singleton/species/proc/whitelistName(mob/living/carbon/human/H)
	return get_bodytype(H)
