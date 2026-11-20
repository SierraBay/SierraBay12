#define PSI_CUSTOM_NAME_MAX 40
#define PSI_CUSTOM_DESC_MAX 300

/datum/preferences
	var/list/psi_disorders
	var/psi_custom_name = ""
	var/psi_custom_desc = ""

/datum/preferences/proc/sanitize_psi_disorders()
	psi_custom_name = copytext(sanitize_html(psi_custom_name || ""), 1, PSI_CUSTOM_NAME_MAX + 1)
	psi_custom_desc = copytext(sanitize_html(psi_custom_desc || ""), 1, PSI_CUSTOM_DESC_MAX + 1)

	var/list/fixed = list()
	var/custom_used = FALSE
	for(var/group in GLOB.psi_disorder_groups)
		var/id = PSI_DISORDER_NONE
		if(islist(psi_disorders))
			id = psi_disorders[group] || PSI_DISORDER_NONE
		if(id == PSI_DISORDER_CUSTOM)
			if(!length(psi_custom_name) || custom_used)
				id = PSI_DISORDER_NONE
			else
				custom_used = TRUE
		else if(id != PSI_DISORDER_NONE)
			var/singleton/psi_disorder/D = get_psi_disorder(id)
			if(!D || D.group != group)
				id = PSI_DISORDER_NONE
		fixed[group] = id
	psi_disorders = fixed

/datum/category_item/player_setup_item/psionics/disorders
	name = "Disorders"
	sort_order = 4

/datum/category_item/player_setup_item/psionics/disorders/load_character(datum/pref_record_reader/R)
	pref.psi_disorders = R.read("psi_disorders")
	pref.psi_custom_name = R.read("psi_custom_name")
	pref.psi_custom_desc = R.read("psi_custom_desc")

/datum/category_item/player_setup_item/psionics/disorders/save_character(datum/pref_record_writer/W)
	W.write("psi_disorders", pref.psi_disorders)
	W.write("psi_custom_name", pref.psi_custom_name)
	W.write("psi_custom_desc", pref.psi_custom_desc)

/datum/category_item/player_setup_item/psionics/disorders/sanitize_character()
	pref.sanitize_psi_disorders()
	return ..()

/datum/category_item/player_setup_item/psionics/disorders/content(mob/user)
	. = list()
	if(!whitelist_lookup(SPECIES_PSI, user.ckey) || !pref.psi_threat_level)
		return ..()

	if(!islist(pref.psi_disorders))
		pref.sanitize_psi_disorders()

	. += "<style>"
	. += ".Current{background: #2f943c}"
	. += ".Selectable{background: #40628a}"
	. += ".disorder { display: inline-block; margin: 2px; padding: 2px 8px; }"
	. += "</style>"

	for(var/group in GLOB.psi_disorder_groups)
		var/current = pref.psi_disorders[group]
		var/color = GLOB.psi_disorder_group_colors[group]
		. += "<font color='[color]'><b>[GLOB.psi_disorder_group_names[group]]</b></font><br>"

		var/none_class = (current == PSI_DISORDER_NONE) ? "Current" : "Selectable"
		. += "<a class='disorder [none_class]' href='?src=\ref[src];disorder_group=[group];disorder=[PSI_DISORDER_NONE]'>Нет</a>"

		for(var/singleton/psi_disorder/D in get_psi_disorders_in_group(group))
			var/css = (current == D.id) ? "Current" : "Selectable"
			. += "<a class='disorder [css]' title='[html_encode(D.description)]' href='?src=\ref[src];disorder_group=[group];disorder=[D.id]'>[D.name]</a>"

		var/custom_css = (current == PSI_DISORDER_CUSTOM) ? "Current" : "Selectable"
		. += "<a class='disorder [custom_css]' href='?src=\ref[src];disorder_group=[group];disorder=[PSI_DISORDER_CUSTOM]'>Своя</a>"

		if(current == PSI_DISORDER_CUSTOM)
			. += "<br><i>[html_encode(pref.psi_custom_name)]</i>: [html_encode(pref.psi_custom_desc)]"
		else if(current != PSI_DISORDER_NONE)
			var/singleton/psi_disorder/selected = get_psi_disorder(current)
			if(selected)
				. += "<br><i>[html_encode(selected.description)]</i>"

	. += "<hr><b>Своя:</b><br>"
	. += "Название: <a href='?src=\ref[src];edit_custom_name=1'>[length(pref.psi_custom_name) ? html_encode(pref.psi_custom_name) : "задать"]</a><br>"
	. += "Описание: <a href='?src=\ref[src];edit_custom_desc=1'>[length(pref.psi_custom_desc) ? html_encode(pref.psi_custom_desc) : "задать"]</a><br>"

	. = jointext(., null)

/datum/category_item/player_setup_item/psionics/disorders/OnTopic(href, list/href_list, mob/user)
	if(..())
		return TOPIC_HANDLED

	if(href_list["disorder"] && href_list["disorder_group"])
		var/group = href_list["disorder_group"]
		var/id = href_list["disorder"]
		if(!(group in GLOB.psi_disorder_groups))
			return TOPIC_HANDLED
		if(!islist(pref.psi_disorders))
			pref.sanitize_psi_disorders()

		if(id == PSI_DISORDER_CUSTOM)
			if(!length(pref.psi_custom_name))
				to_chat(user, SPAN_WARNING("Сначала задайте название собственного расстройства."))
				return TOPIC_HANDLED
			for(var/other in GLOB.psi_disorder_groups)
				if(pref.psi_disorders[other] == PSI_DISORDER_CUSTOM)
					pref.psi_disorders[other] = PSI_DISORDER_NONE
		else if(id != PSI_DISORDER_NONE)
			var/singleton/psi_disorder/D = get_psi_disorder(id)
			if(!D || D.group != group)
				return TOPIC_HANDLED

		pref.psi_disorders[group] = id
		return TOPIC_REFRESH

	else if(href_list["edit_custom_name"])
		var/new_name = input(user, "Название расстройства (до [PSI_CUSTOM_NAME_MAX] символов).", "Своя", pref.psi_custom_name) as null|text
		if(!isnull(new_name))
			pref.psi_custom_name = copytext(sanitize_html(new_name), 1, PSI_CUSTOM_NAME_MAX + 1)
			pref.sanitize_psi_disorders()
		return TOPIC_REFRESH

	else if(href_list["edit_custom_desc"])
		var/new_desc = input(user, "Описание расстройства (до [PSI_CUSTOM_DESC_MAX] символов). Игрок будет получать его в виде напоминаний.", "Своя", pref.psi_custom_desc) as null|message
		if(!isnull(new_desc))
			pref.psi_custom_desc = copytext(sanitize_html(new_desc), 1, PSI_CUSTOM_DESC_MAX + 1)
		return TOPIC_REFRESH

	return ..()
