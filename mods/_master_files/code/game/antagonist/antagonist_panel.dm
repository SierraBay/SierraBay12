/datum/antagonist/proc/get_check_antag_preferences_output()
	var/list/high_pref = list()
	var/list/low_pref = list()
	for(var/client/C in GLOB.clients)
		if(!C.prefs)
			continue
		var/label = C.mob ? "[C.mob.real_name]/([C.key])" : "[C.key]"
		var/link = C.mob ? "<a href='byond://?_src_=holder;adminplayeropts=\ref[C.mob]'>[label]</a>" : label
		if(id in C.prefs.be_special_role)
			high_pref += link
		else if(id in C.prefs.may_be_special_role)
			low_pref += link

	if(!length(high_pref) && !length(low_pref))
		return ""

	var/dat = "<br><B>[role_text_plural] candidacy preferences:</B><br>"
	if(length(high_pref))
		dat += "High: [jointext(high_pref, ", ")]<br>"
	if(length(low_pref))
		dat += "Low: [jointext(low_pref, ", ")]<br>"
	return dat

/datum/admins/proc/check_prefs_antag()
	var/list/dat = list()
	dat += "<html><head><title>Antag Prefs</title></head><body><h1><B>Antagonist candidacy preferences</B></h1>"
	var/has_output = FALSE
	var/list/all_antag_types = GLOB.all_antag_types_
	for(var/antag_type in all_antag_types)
		var/datum/antagonist/A = all_antag_types[antag_type]
		var/pref_output = A.get_check_antag_preferences_output()
		if(pref_output)
			has_output = TRUE
			dat += pref_output
			dat += "<hr>"
	if(!has_output)
		dat += "Нет игроков с включёнными префами на антагонистов. (ЭКСТА НЕИЗБЕЖНА)"
	dat += "</body></html>"
	show_browser(usr, jointext(dat, null), "window=antagprefs;size=400x500")

/client/proc/check_prefs_antag()
	set name = "Check Prefs Antag"
	set category = "Admin"
	if(holder)
		holder.check_prefs_antag()
		log_admin("[key_name(usr)] checked antagonist preferences.")

/client/add_admin_verbs()
	..()
	if(holder && (holder.rights & (R_ADMIN | R_MOD)))
		verbs += /client/proc/check_prefs_antag

/client/remove_admin_verbs()
	..()
	verbs -= /client/proc/check_prefs_antag
