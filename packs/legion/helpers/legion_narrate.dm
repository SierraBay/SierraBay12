/// List of all radios (`/obj/item/device/radio`) in world. Populated and depopulated by radio initialization and destroy calls.
GLOBAL_LIST_EMPTY(all_radios)


/obj/item/device/radio/Initialize()
	. = ..()
	if (. == INITIALIZE_HINT_QDEL || QDELETED(src))
		return
	GLOB.all_radios += src


/obj/item/device/radio/Destroy()
	GLOB.all_radios -= src
	return ..()


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
 * Returns string.
 */
/proc/pick_legion_message()
	var/message

	// Choose a message to display
	if (rand(0, 100) <= 30)
		if (!length(GLOB.legion_last_words_player) || rand(0, 1))
			message = "A voice rises above the chorus, \"[pick(GLOB.legion_last_words_generic)]\""
		else
			var/list/chosen = pick(GLOB.legion_last_words_player)
			message = "[chosen[1]]'s voice rises above the chorus, \"[chosen[2]]\""
	else
		message = pick(GLOB.legion_narrations)

	return message


/**
 * Displays a legion message through all radios in the given z-levels.
 */
/proc/show_legion_broadcast(list/z_levels = list(), message)
	if (!islist(z_levels))
		z_levels = list(z_levels)
	if (!length(z_levels))
		return
	var/list/connected_z_levels = list()
	for (var/z_level in z_levels)
		if (z_level in connected_z_levels)
			continue
		connected_z_levels |= GetConnectedZlevels(z_level)
	var/sound_to_play = pick(GLOB.legion_voices_sounds)
	var/narrate_count = 0
	var/radio_count = 0
	/// List of mobs that have had messages displayed to them in a prior loop. Helps prevent multiple messages spamming the chat log.
	var/list/skip_players = list()

	// Synthetic narrations
	for (var/mob/player in GLOB.player_list)
		if (!(get_z(player) in connected_z_levels))
			continue
		if (!player.isSynthetic() && !isobserver(player))
			continue
		to_chat(player, SPAN_LEGION(message))
		sound_to(player, sound_to_play)
		narrate_count++
		skip_players += player

	// Radio broadcasts
	for (var/obj/item/device/radio/radio in GLOB.all_radios)
		if (!radio.on || !radio.listening)
			continue
		if (!(get_z(radio) in connected_z_levels))
			continue

		// Headsets - Some special handling for mobs wearing them
		if (istype(radio, /obj/item/device/radio/headset))
			if (!ishuman(radio.loc) || (radio.loc in skip_players))
				continue
			var/mob/living/carbon/human/human = radio.loc
			if (human.isSynthetic())
				continue // Synthetics are already getting the legion narration. This prevents doubling the message and audio.
			if (human.l_ear != radio && human.r_ear != radio)
				continue
			human.show_message(
				SPAN_LEGION("Your [radio.name] suddenly buzzes and crackles to life in your ear... [message]"),
				AUDIBLE_MESSAGE
			)
			sound_to(human, sound_to_play)
			radio_count++
			skip_players += human
			continue

		// Other radio types - They just broadcast loudly for everyone to hear
		radio.audible_message(
			SPAN_LEGION("\The [radio] suddenly buzzes and crackles to life... [message]"),
			exclude_mobs = skip_players
		)
		playsound(radio, sound_to_play, 10)
		radio_count++

	log_debug("Broadcast legion text to [narrate_count] mob\s and through [radio_count] radio\s across [length(connected_z_levels)] z-level\s.")



/client/proc/cmd_admin_legion_narrate()
	set category = "Special Verbs"
	set name = "Legion Narrate"
	set desc = "Manually triggers a legion broadcast on specific z-levels."

	if(!check_rights(R_ADMIN))
		return

	var/z_level = input(usr, "Which z-level? Your own z-level is entered by default.", "Legion Narrate", get_z(usr)) as null | num
	if (!z_level)
		return

	var/message = pick_legion_message()

	show_legion_broadcast(z_level, message)

	log_and_message_staff(" - Manual Legion Broadcast to z-levels connected to [z_level].")
