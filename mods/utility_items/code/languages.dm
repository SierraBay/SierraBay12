/datum/preferences/proc/total_languages()
	return MAX_LANGUAGES + additional_languages

/datum/preferences
	var/additional_languages

/datum/category_item/player_setup_item/load_character(datum/pref_record_reader/R)
	. = ..()
	pref.additional_languages = R.read("additional_languages")

/datum/category_item/player_setup_item/save_character(datum/pref_record_writer/W)
	. = ..()
	W.write("additional_languages", pref.additional_languages)

/datum/preferences/copy_to(mob/living/carbon/human/character, is_preview_copy = FALSE)
	. = ..()
	additional_languages = character.species.additional_languages

/datum/species
	var/additional_languages = 0
