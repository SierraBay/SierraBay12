// Fake station-wide announcements
/datum/hallucination/station_message
	abstract_hallucination = TRUE
	category = "announcement"
	base_weight = 1
	type_cooldown = 90 SECONDS
	category_cooldown = 45 SECONDS
	theme_tags = list("emergency")
	min_power = 50
	allow_duplicates = FALSE
	var/require_hearing = TRUE

/datum/hallucination/station_message/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(require_hearing && !C.can_hear())
		return "deaf"
	return null

/datum/hallucination/station_message/proc/send_fake_announcement(message, message_title, sound_path, announcement_type = /datum/announcement/priority)
	var/datum/announcement/announcement = new announcement_type(0, sound_path)
	to_chat(holder, announcement.FormMessage(message, message_title))
	if(sound_path && holder.client?.get_preference_value(/datum/client_preference/play_announcement_sfx) == GLOB.PREF_YES)
		sound_to(holder, sound(sound_path, volume = 30))
	qdel(announcement)

/datum/hallucination/station_message/blob_alert/start()
	feedback_details = " Announcement: Blob alert"
	send_fake_announcement("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK5)
	return TRUE

/datum/hallucination/station_message/shuttle_dock/start()
	var/message = replacetext(replacetext(GLOB.using_map.shuttle_docked_message, "%dock_name%", "[GLOB.using_map.dock_name]"), "%ETD%", "[pick("3", "4", "5")] minute\\s")
	feedback_details = " Announcement: Shuttle docked"
	send_fake_announcement(message, "Emergency Shuttle Arrival", GLOB.using_map.shuttle_docked_sound)
	return TRUE

/datum/hallucination/station_message/malf_ai/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	var/reason = ..()
	if(reason)
		return reason
	if(!(locate(/mob/living/silicon/ai) in SSmobs.mob_list))
		return "no active AI"
	return null

/datum/hallucination/station_message/malf_ai/start()
	feedback_details = " Announcement: Malf AI"
	send_fake_announcement("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", ANNOUNCER_SPANOMALIES)
	return TRUE

/datum/hallucination/station_message/heretic
	var/static/list/ascension_bodies = list(
		"Fear the blaze, for %FAKENAME% has ascended! The flames shall consume all!",
		"%FAKENAME% rises with silver blades in hand. Reality itself shudders before them!",
		"The lord of the night, %FAKENAME%, has ascended. Fear the ever-twisting hand!",
		"Fear the decay, for %FAKENAME% has ascended! None shall escape the corrosion!",
		"%FAKENAME% has arrived, stepping along the waltz that ends worlds!"
	)

/datum/hallucination/station_message/heretic/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	var/reason = ..()
	if(reason)
		return reason
	if(!C.random_non_sec_crewmember_name())
		return "no remote crew candidate"
	return null

/datum/hallucination/station_message/heretic/proc/generate_heretic_text()
	return pick("ANOMALOUS TRANSMISSION", "ELDRITCH WARNING", "REALITY BREACH", "UNAUTHORIZED ASCENSION")

/datum/hallucination/station_message/heretic/start()
	var/fake_name = holder.random_non_sec_crewmember_name()
	if(!fake_name)
		return FALSE
	var/message = replacetext(pick(ascension_bodies), "%FAKENAME%", fake_name)
	var/title = generate_heretic_text()
	feedback_details = " Announcement: Heretic ascension, Name: [fake_name]"
	send_fake_announcement("[generate_heretic_text()] [message] [generate_heretic_text()]", title, ANNOUNCER_SPANOMALIES)
	return TRUE

/datum/hallucination/station_message/cult_summon/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	var/reason = ..()
	if(reason)
		return reason
	if(!C.random_non_sec_crewmember_name())
		return "no remote crew candidate"
	return null

/datum/hallucination/station_message/cult_summon/start()
	var/fake_name = holder.random_non_sec_crewmember_name()
	if(!fake_name)
		return FALSE
	var/fake_area = holder.random_station_area_name()
	feedback_details = " Announcement: Cult summon, Name: [fake_name], Area: [fake_area]"
	send_fake_announcement("Figments from an eldritch god are being summoned by [fake_name] into [fake_area] from an unknown dimension. Disrupt the ritual at all costs!", "Central Command Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES)
	return TRUE

/datum/hallucination/station_message/meteors
	base_weight = 3
	min_power = 40

/datum/hallucination/station_message/meteors/start()
	feedback_details = " Announcement: Meteors"
	send_fake_announcement("Meteors have been detected on collision course with the station.", "Meteor Alert", ANNOUNCER_METEORS)
	return TRUE

/datum/hallucination/station_message/supermatter_delam
	require_hearing = FALSE

/datum/hallucination/station_message/supermatter_delam/start()
	feedback_details = " Announcement: Supermatter delamination"
	sound_to(holder, sound('sound/magic/charge.ogg', volume = 50))
	to_chat(holder, SPAN_CLASS("alert", FONT_HUGE("You feel reality distort for a moment...")))
	return TRUE
