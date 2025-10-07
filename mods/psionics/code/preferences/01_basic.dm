/datum/preferences
	var/psi_threat_level = 0
	var/psi_openness     = TRUE

/datum/category_item/player_setup_item/psionics/basic
	name = "Basic"
	sort_order = 1

/datum/category_item/player_setup_item/psionics/basic/load_character(datum/pref_record_reader/R)
	pref.psi_threat_level = R.read("psi_threat_level")
	pref.psi_openness     = R.read("psi_openness")

/datum/category_item/player_setup_item/psionics/basic/save_character(datum/pref_record_writer/W)
	W.write("psi_threat_level", pref.psi_threat_level)
	W.write("psi_openness",     pref.psi_openness)

/datum/category_item/player_setup_item/psionics/basic/sanitize_character()
	pref.psi_threat_level = clamp(pref.psi_threat_level, 0, 4)

/datum/category_item/player_setup_item/psionics/basic/content(mob/user)
	. = list()
	if(!whitelist_lookup(SPECIES_PSI, user.ckey))
		. += "<b>You are not permitted to be Psionic</b><br>"
	else
		. += "Power: <a href='?src=\ref[src];select_psi_threat_level=1'><b>[pref.psi_threat_level]</b></a><br>"

		if(pref.psi_threat_level)
			. += "Implant: <a href='?src=\ref[src];toggle_psi_openness=1'><b>[pref.psi_openness ? "Yes" : "No"]</b></a><br>"

	. = jointext(.,null)

/datum/category_item/player_setup_item/psionics/OnTopic(href, list/href_list, mob/user)
	if(href_list["select_psi_threat_level"])
		pref.psi_threat_level = text2num(input("Select threat level", CHARACTER_PREFERENCE_INPUT_TITLE, pref.psi_threat_level) in list("0", "1", "2", "3", "4"))
		pref.psi_threat_level = clamp(pref.psi_threat_level, 0, 4)
		pref.sanitize_psi_abilities()
		return TOPIC_REFRESH

	else if(href_list["toggle_psi_openness"])
		pref.psi_openness = !pref.psi_openness
		return TOPIC_REFRESH

	return ..()
