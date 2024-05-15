/client
	// Runechat messages
	var/list/seen_messages

/datum/client_preference/runechat_mob
	description = "Enable mob runechat"
	key = "RUNECHAT_MOB"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)
	default_value = GLOB.PREF_YES

/datum/client_preference/runechat_obj
	description = "Enable obj runechat"
	key = "RUNECHAT_OBJ"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)
	default_value = GLOB.PREF_YES

/datum/client_preference/runechat_messages_length
	description = "Length of runechat messages"
	key = "RUNECHAT_MESSAGES_LENGTH"
	options = list(GLOB.PREF_SHORT, GLOB.PREF_LONG)
	default_value = GLOB.PREF_SHORT

/client/cmd_admin_visible_narrate(atom/A)
	set popup_menu = FALSE
	set category = null
	set name = "Visible Narrate"
	set desc = "Narrate to those who can see the given atom."

	if(!check_rights(R_MOD))
		return

	var/mob/M = mob

	if(!M)
		to_chat(src, "You must be in control of a mob to use this.")
		return

	var/result = cmd_admin_narrate_helper(src)
	if (!result)
		return

	var/runechat_message
	if(result[2] != "subtle")
		runechat_message = result[1]

	result[1] = replacetext(result[1], result[4], "<b>[A]</b> " + result[4])

	A.visible_message(result[1], result[1], runemessage = runechat_message)
	log_and_message_staff(" - VisibleNarrate [result[2]]/[result[3]] on [A]: [result[4]]")

/client/cmd_admin_audible_narrate(atom/A)
	set popup_menu = FALSE
	set category = null
	set name = "Audible Narrate"
	set desc = "Narrate to those who can hear the given atom."

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/mob/M = mob

	if(!M)
		to_chat(src, "You must be in control of a mob to use this.")
		return

	var/result = cmd_admin_narrate_helper(src)
	if (!result)
		return

	var/runechat_message
	if(result[2] != "subtle")
		runechat_message = result[1]

	result[1] = replacetext(result[1], result[4], "<b>[A]</b> " + result[4])

	A.audible_message(result[1], result[1], runemessage = runechat_message)
	log_and_message_staff(" - AudibleNarrate [result[2]]/[result[3]] on [A]: [result[4]]")
