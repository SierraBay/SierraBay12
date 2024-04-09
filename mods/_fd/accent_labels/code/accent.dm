/mob/var/tmp/accent_tag_cache
/mob/proc/get_accent_tag(mob/speaker)
	if(client?.get_preference_value(/datum/client_preference/accent_tags) != GLOB.PREF_SHOW)
		return ""

	if(!speaker.client || !iscarbon(speaker))
		return ""

	if(!speaker.accent_tag_cache)
		var/static/list/culture2state = list(
			CULTURE_HUMAN_LUNAPOOR = "luna_low",
			CULTURE_HUMAN_LUNARICH = "luna_upper",
			CULTURE_HUMAN_VENUSIAN = "venus",
			CULTURE_HUMAN_VENUSLOW = "venus",
			CULTURE_HUMAN_MARTIAN  = "mars_surface",
			CULTURE_HUMAN_MARSTUN  = "mars_tunneller",
			CULTURE_HUMAN_BELTER   = "belter",
			CULTURE_HUMAN_PLUTO    = "pluto",
			CULTURE_HUMAN_EARTH    = "earth",
			CULTURE_HUMAN_CETI     = "ceti",
			CULTURE_HUMAN_SPACER   = "spacer",
			CULTURE_HUMAN_SPAFRO   = "spacer",
			CULTURE_HUMAN_CONFED   = "terran",
			CULTURE_HUMAN_MEOT	   = "meonian",
			CULTURE_HUMAN_REPUBL   = "republican"

		)

		var/culture = speaker.client.prefs.cultural_info[TAG_CULTURE]
		speaker.accent_tag_cache = (culture in culture2state) ? culture2state[culture] : "human_other"

	return icon2html(icon('mods/_fd/accent_labels/icons/accent_tags.dmi', speaker.accent_tag_cache), src, realsize = TRUE, class = "text_tag")

/datum/client_preference/accent_tags
	description = "Accent tags"
	key = "CHAT_SHOWACCENTICONS"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)
