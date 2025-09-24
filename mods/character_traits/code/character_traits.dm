/datum/preferences
	var/list/mod_traits = list()

/datum/mod_trait
	var/name = ""
	var/description = ""
	var/list/incompatible_traits
	var/list/subspecies_allowed
	var/list/species_allowed

/datum/mod_trait/proc/apply_trait(mob/living/carbon/human/H)
	return FALSE

/datum/category_item/player_setup_item/physical/body/sanitize_character()
	. = ..()
	if(!istype(pref.mod_traits))
		pref.mod_traits = list()
	else
		pref.mod_traits &= GLOB.all_mod_traits

/datum/category_item/player_setup_item/physical/body/load_character(datum/pref_record_reader/R)
	. = ..()
	var/list/saved = R.read("mod_traits") || list()
	pref.mod_traits = list()
	for (var/name in saved)
		if (name in GLOB.all_mod_traits)
			pref.mod_traits += name


/datum/category_item/player_setup_item/physical/body/save_character(datum/pref_record_writer/W)
	. = ..()
	W.write("mod_traits", pref.mod_traits)

/datum/category_item/player_setup_item/physical/body/content(mob/user)
	. = ..()
	. += "<br />[BTN("add_mod_trait", "+ Add Race-Specific trait")]"
	for (var/name in pref.mod_traits)
		var/datum/mod_trait/M = GLOB.all_mod_traits[name]


		. += "<br />[VTBTN("remove_mod_trait", name, "-", M.name)] "

		if(M.description)
			. += M.description

	if (length(pref.mod_traits))
		. += "<br />"

/datum/category_item/player_setup_item/physical/body/OnTopic(href,list/href_list, mob/user)
	. = ..()
	if(href_list["set_species"])
		pref.mod_traits.Cut()

	if(href_list["add_mod_trait"])
		var/singleton/species/mob_species = GLOB.species_by_name[pref.species]
		var/list/disallowed_mod_traits = list()
		for (var/M in pref.mod_traits)
			var/datum/mod_trait/char_mod = GLOB.all_mod_traits[M]
			disallowed_mod_traits |= char_mod.incompatible_traits

		var/list/usable_char_mods = pref.mod_traits.Copy() ^ GLOB.all_mod_traits.Copy()
		for(var/M in usable_char_mods)
			var/datum/mod_trait/S = usable_char_mods[M]
			if(is_type_in_list(S, disallowed_mod_traits) || (S.species_allowed && !(mob_species.get_bodytype() in S.species_allowed)) || (S.subspecies_allowed && !(mob_species.name in S.subspecies_allowed)))
				usable_char_mods -= M

		if(!usable_char_mods || length(usable_char_mods) == 0)
			to_chat(user, SPAN_WARNING("Отсутствуют черты персонажа для выбора."))

		var/list/choice_map = list()
		for (var/M in usable_char_mods)
			var/datum/mod_trait/S = usable_char_mods[M]
			if (!S) continue
			choice_map[S.name] = M

		var/new_choice = input(user, "Choose a character modification:", CHARACTER_PREFERENCE_INPUT_TITLE) as null|anything in choice_map
		if(new_choice && CanUseTopic(user))
			var/selected_path = choice_map[new_choice]
			if (selected_path)
				var/datum/mod_trait/M = GLOB.all_mod_traits[selected_path]
				if (M)
					pref.mod_traits += M.name
				return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["remove_mod_trait"])
		var/varval = href_list["remove_mod_trait"]
		pref.mod_traits -= varval
		return TOPIC_REFRESH_UPDATE_PREVIEW

/datum/job/post_equip_rank(mob/person, alt_title)
	. = ..()
	if(istype(person, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = person
		for(var/name in person.client.prefs.mod_traits)
			var/datum/mod_trait/M = GLOB.all_mod_traits[name]
			M.apply_trait(H)
