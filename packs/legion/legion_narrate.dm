/**
 * Adds a player's last words to the legion's pool. `origin` can be a living mob, a mind datum, or a brain.
 */
/proc/legion_add_voice(datum/origin)
	var/origin_name
	var/message

	if (is_type_in_list(origin, list(/obj/item/organ/internal/brain, /obj/item/organ/internal/posibrain)))
		var/obj/item/organ/internal/brain/brain = origin
		if (!brain.brainmob?.mind)
			return
		origin = brain.brainmob.mind

	if (isliving(origin))
		var/mob/living/living = origin
		if (!living.mind)
			return
		origin = living.mind

	if (istype(origin, /datum/mind))
		var/datum/mind/mind = origin
		if (!mind.last_words)
			return
		origin_name = mind.name
		message = mind.last_words

	if (!origin_name || !message)
		return

	GLOB.legion_last_words_player += list(origin_name, message)
	log_debug("Added [origin_name]'s last words of '[message]' to the legion message pool.")


/**
 * Randomly chooses a legion message to broadcast.
 *
 * Returns list containing `"full"`, `"origin"`, and `"contents"` keys.
 */
/proc/pick_legion_message()
	var/message
	var/message_origin = ""
	var/message_contents
	// Choose a message to display
	if (rand(0, 100) <= 20)
		if (!length(GLOB.legion_last_words_player) || rand(0, 1))
			message_contents = "A voice rises above the chorus, \"[pick(GLOB.legion_last_words_generic)]\""
			message = message_contents
		else
			var/list/chosen = pick(GLOB.legion_last_words_player)
			message_origin = chosen[1]
			message_contents = chosen[2]
			message = "[message_origin]'s voice rises above the chorus, \"[message_contents]\""
			message_contents = "cries out above the chorus, \"[message_contents]\""
	else
		message_contents = pick(GLOB.legion_narrations)
		message = message_contents

	return list(
		"full" = message,
		"origin" = message_origin,
		"contents" = message_contents
	)


/**
 * Displays a randomly chosen legion message to synthetic mobs in z-levels connected to the given level(s)
 */
/proc/show_legion_messages(list/z_levels = list(), message)
	if (!islist(z_levels))
		z_levels = list(z_levels)
	if (!length(z_levels))
		return

	var/list/connected_z_levels = list()
	for (var/z_level in z_levels)
		if (z_level in connected_z_levels)
			continue
		connected_z_levels |= GetConnectedZlevels(z_level)

	var/count = 0
	var/sound_to_play = pick(GLOB.legion_voices_sounds)
	for (var/mob/player in GLOB.player_list)
		if (!(get_z(player) in connected_z_levels))
			continue
		if (!player.isSynthetic() && !isobserver(player))
			continue
		to_chat(player, SPAN_LEGION(message))
		sound_to(player, sound_to_play)
		count++

	log_debug("Displayed legion message to [count] mob\s across [length(connected_z_levels)] z-level\s.")


/client/proc/cmd_admin_legion_narrate()
	set category = "Special Verbs"
	set name = "Legion Narrate"
	set desc = "Manually triggers a legion narration on specific z-levels."

	if(!check_rights(R_ADMIN))
		return

	var/z_level = input(usr, "Which z-level? Your own z-level is entered by default.", "Legion Narrate", get_z(usr)) as null | num
	if (!z_level)
		return

	var/list/message_data = pick_legion_message()

	show_legion_messages(z_level, message_data["full"])

	var/mob/legion_broadcaster/broadcaster = new(get_turf(usr))
	broadcaster.z = z_level
	broadcaster.legion_broadcast(message_data["origin"], SPAN_LEGION(message_data["contents"]))
	QDEL_NULL(broadcaster)

	log_and_message_staff(" - Manual Legion Narrate to z-levels connected to [z_level].")
