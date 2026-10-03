/datum/antagonist/get_check_antag_output(datum/admins/calling_admin)
	. = ..()
	var/pref_output = get_check_antag_preferences_output()
	if(pref_output)
		. += pref_output
		. += "<hr>"
	return .

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
