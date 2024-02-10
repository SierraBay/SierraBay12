/datum/client_preference/exposurelevel
	description = "Exposure strength"
	key = "EXPOSURELEVEL"
	options = list(GLOB.PREF_OFF, GLOB.PREF_LOW, GLOB.PREF_MED, GLOB.PREF_HIGH)
	default_value = GLOB.PREF_HIGH

/datum/client_preference/exposurelevel/changed(mob/preference_mob, new_value)
	if(!preference_mob?.client)
		return

	for(var/atom/movable/renderer/exposure/exposure_to_update in preference_mob.renderers)
		exposure_to_update.UpdateRenderer()

/datum/client_preference/bloomlevel
	description = "Bloom strength"
	key = "BLOOMLEVEL"
	options = list(GLOB.PREF_OFF, GLOB.PREF_LOW, GLOB.PREF_MED, GLOB.PREF_HIGH)
	default_value = GLOB.PREF_MED

/datum/client_preference/bloomlevel/changed(mob/preference_mob, new_value)
	if(!preference_mob?.client)
		return

	for(var/atom/movable/renderer/lamps/lamps_to_update in preference_mob.renderers)
		lamps_to_update.UpdateRenderer()

/datum/client_preference/glare
	description = "Show lamp glare"
	key = "GLARE"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)
	default_value = GLOB.PREF_YES

/datum/client_preference/glare/changed(mob/preference_mob, new_value)
	if(!preference_mob?.client)
		return

	for(var/atom/movable/renderer/lamps_glare/glare_to_update in preference_mob.renderers)
		glare_to_update.UpdateRenderer()
