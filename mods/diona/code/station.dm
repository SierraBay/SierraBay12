
/datum/category_item/player_setup_item/background/languages/proc/total_languages()
	return MAX_LANGUAGES + pref.additional_languages

/datum/preferences
	var/additional_languages

/datum/preferences/copy_to(mob/living/carbon/human/character, is_preview_copy = FALSE)
	. = ..()
	additional_languages = character.species.additional_languages

/datum/species
	var/additional_languages = 0

/datum/species/diona
	slowdown = 2
	thirst_factor = 0.06
	additional_languages = 2

/datum/species/diona/skills_from_age(age)
	if(age)
		. = 16
