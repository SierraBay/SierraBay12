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
	pref.mod_traits = R.read("mod_traits")

/datum/category_item/player_setup_item/physical/body/save_character(datum/pref_record_writer/W)
	. = ..()
	W.write("mod_traits", pref.mod_traits)

/datum/category_item/player_setup_item/physical/body/content(mob/user)
	. = ..()
	. += "<br />[BTN("add_mod_trait", "+ Add trait")]"
	for (var/mod_trait in pref.mod_traits)
		var/datum/mod_trait/M = GLOB.all_mod_traits[mod_trait]

		. += "<br />[VTBTN("remove_mod_trait", mod_trait, "-", mod_trait)] "

		if(M.description)
			. += M.description

	if (length(pref.mod_traits))
		. += "<br />"

/datum/category_item/player_setup_item/physical/body/OnTopic(href,list/href_list, mob/user)
	. = ..()
	if(href_list["set_species"])
		pref.mod_traits.Cut()

	if(href_list["add_mod_trait"])
		var/datum/species/mob_species = all_species[pref.species]
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
		var/new_char_mod = input(user, "Choose a character modification:", CHARACTER_PREFERENCE_INPUT_TITLE)  as null|anything in usable_char_mods
		if(new_char_mod && CanUseTopic(user))
			pref.mod_traits[new_char_mod] = TRUE
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["remove_mod_trait"])
		var/M = href_list["remove_mod_trait"]
		pref.mod_traits -= M
		return TOPIC_REFRESH_UPDATE_PREVIEW

/datum/job/post_equip_rank(mob/person, alt_title)
	. = ..()
	if(istype(person, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = person
		for(var/char_mod in person.client.prefs.mod_traits)
			var/datum/mod_trait/M = GLOB.all_mod_traits[char_mod]
			M.apply_trait(H)