/mob/living
	var/accent_tag_cache

/mob/living/proc/get_accent_tag(mob/user)
	return ""

/mob/living/carbon/get_accent_tag(mob/user)
	if(!user || !user.client || user.client.get_preference_value(/datum/client_preference/accent_tags) != GLOB.PREF_SHOW)
		return ""

	if(!accent_tag_cache)
		var/culture = client.prefs.cultural_info[TAG_CULTURE]
		accent_tag_cache = culture

	return icon2html(icon('mods/_fd/accent_labels/icons/accent_tags.dmi', accent_tag_cache), user, realsize = TRUE, class = "text_tag")

/datum/client_preference/accent_tags
	description = "Accent tags"
	key = "CHAT_SHOWACCENTICONS"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)
