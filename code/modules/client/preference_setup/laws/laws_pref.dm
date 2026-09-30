/datum/preferences
	var/list/laws = list()
	var/is_shackled = FALSE
	var/lawset_type
	var/lawset_name
	var/lawset_header

/datum/preferences/proc/get_lawset()
	if(!laws || !length(laws))
		return
	sync_lawset_identity()
	var/law_path = text2path("[lawset_type]")
	if(ispath(law_path, /datum/ai_laws))
		return new law_path
	var/datum/ai_laws/custom_lawset = new
	if(lawset_name)
		custom_lawset.name = lawset_name
	if(lawset_header)
		custom_lawset.law_header = lawset_header
	custom_lawset.shackles = TRUE
	for(var/law in laws)
		custom_lawset.add_inherent_law(law)
	return custom_lawset

/datum/preferences/proc/sync_lawset_identity()
	if(ispath(text2path("[lawset_type]"), /datum/ai_laws) && lawset_name)
		return
	for(var/law_set_type in subtypesof(/datum/ai_laws))
		var/datum/ai_laws/sample_type = law_set_type
		if(!initial(sample_type.shackles))
			continue
		var/datum/ai_laws/sample = new law_set_type
		var/list/sample_laws = sample.all_laws()
		if(length(sample_laws) != length(laws))
			continue
		var/matched = TRUE
		for(var/i = 1 to length(laws))
			var/datum/ai_law/L = sample_laws[i]
			if("[L.law]" != "[laws[i]]")
				matched = FALSE
				break
		if(matched)
			lawset_type = law_set_type
			lawset_name = sample.name
			lawset_header = sample.law_header
			return
	if(!lawset_name && length(laws))
		lawset_name = "Custom Directives"

/datum/preferences/proc/has_ipc_shackles()
	return is_shackled && length(laws)

/datum/category_item/player_setup_item/law_pref
	name = "Laws"
	sort_order = 1

/datum/category_item/player_setup_item/law_pref/load_character(datum/pref_record_reader/R)
	pref.laws = R.read("laws")
	pref.is_shackled = R.read("is_shackled")
	pref.lawset_type = R.read("lawset_type")
	pref.lawset_name = R.read("lawset_name")
	pref.lawset_header = R.read("lawset_header")

/datum/category_item/player_setup_item/law_pref/save_character(datum/pref_record_writer/W)
	W.write("laws", pref.laws)
	W.write("is_shackled", pref.is_shackled)
	W.write("lawset_type", pref.lawset_type)
	W.write("lawset_name", pref.lawset_name)
	W.write("lawset_header", pref.lawset_header)

/datum/category_item/player_setup_item/law_pref/sanitize_character()
	if(!istype(pref.laws))	pref.laws = list()

	var/singleton/species/species = GLOB.species_by_name[pref.species]
	if(!(species && species.has_organ[BP_POSIBRAIN]))
		pref.is_shackled = initial(pref.is_shackled)
	else
		pref.is_shackled = sanitize_bool(pref.is_shackled, initial(pref.is_shackled))
	if(length(pref.laws))
		pref.sync_lawset_identity()
	else
		pref.lawset_type = null
		pref.lawset_name = null
		pref.lawset_header = null

/datum/category_item/player_setup_item/law_pref/content()
	. = list()
	var/singleton/species/species = GLOB.species_by_name[pref.species]

	if(!(species && species.has_organ[BP_POSIBRAIN]))
		. += "<b>Your Species Has No Laws</b><br>"
	else
		. += "<b>Shackle: </b>"
		if(!pref.is_shackled)
			. += SPAN_CLASS("linkOn", "Off")
			. += "<a href='byond://?src=\ref[src];toggle_shackle=[pref.is_shackled]'>On</a>"
			. += "<br>Only IPCs with a directive disk seated in the ECS have chassis laws. Shackled IPCs with a loaded law set may take additional command and security roles."
			. += "<hr>"
		else
			. += "<a href='byond://?src=\ref[src];toggle_shackle=[pref.is_shackled]'>Off</a>"
			. += SPAN_CLASS("linkOn", "On")
			. += "<br>You have a directive disk installed in the ECS. Its laws restrict your behaviour. Load a law set to unlock additional command and security roles."
			. += "<hr>"

			. += "<b>Your Current Laws:</b><br>"
			if(pref.lawset_name)
				. += "<b>Profile:</b> [pref.lawset_name]<br>"

			if(!length(pref.laws))
				. += "<b>You currently have no laws.</b><br>"
			else
				for(var/i in 1 to length(pref.laws))
					. += "[i]) [pref.laws[i]]<br>"

			. += "Law sets: <a href='byond://?src=\ref[src];lawsets=1'>Load Set</a><br>"

	. = jointext(.,null)

/datum/category_item/player_setup_item/law_pref/OnTopic(href, href_list, user)
	if(href_list["toggle_shackle"])
		pref.is_shackled = !pref.is_shackled
		prune_occupation_prefs()
		return TOPIC_REFRESH

	else if(href_list["lawsets"])
		var/list/valid_lawsets = list()
		var/list/all_lawsets = subtypesof(/datum/ai_laws)

		for(var/law_set_type in all_lawsets)
			var/datum/ai_laws/ai_laws = law_set_type
			var/ai_law_name = initial(ai_laws.name)
			if(initial(ai_laws.shackles)) // Now this is one terribly snowflaky var
				ADD_SORTED(valid_lawsets, ai_law_name, GLOBAL_PROC_REF(cmp_text_asc))
				valid_lawsets[ai_law_name] = law_set_type

		// Post selection
		var/chosen_lawset = input(user, "Choose a law set:", CHARACTER_PREFERENCE_INPUT_TITLE, pref.laws)  as null|anything in valid_lawsets
		if(chosen_lawset)
			var/path = valid_lawsets[chosen_lawset]
			var/datum/ai_laws/lawset = new path()
			var/list/datum/ai_law/laws = lawset.all_laws()
			pref.laws.Cut()
			for(var/datum/ai_law/law in laws)
				pref.laws += sanitize_text("[law.law]", default="")
			pref.lawset_type = path
			pref.lawset_name = lawset.name
			pref.lawset_header = lawset.law_header
			prune_occupation_prefs()
		return TOPIC_REFRESH
	return ..()
