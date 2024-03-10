/singleton/emote/do_emote(atom/user, extra_params)

	if(ismob(user) && check_restraints)
		var/mob/M = user
		if(M.restrained())
			to_chat(user, SPAN_WARNING("You are restrained and cannot do that."))
			return

	var/atom/target
	if(can_target() && extra_params)
		extra_params = lowertext(extra_params)
		for(var/atom/thing in view(user))
			if(extra_params == lowertext(thing.name))
				target = thing
				break

	if (targetted_emote && !target)
		to_chat(user, SPAN_WARNING("You can't do that to thin air."))
		return

	if (target && target != user && check_range)
		if (get_dist(user, target) > check_range)
			to_chat(user, SPAN_WARNING("\The [target] is too far away."))
			return

	var/datum/pronouns/user_pronouns = user.choose_from_pronouns()
	var/datum/pronouns/target_pronouns
	if(target)
		target_pronouns = target.choose_from_pronouns()

	var/use_3p
	var/use_1p


	var/runemessage = -1
	if(emote_message_1p)
		if(target && emote_message_1p_target)
			use_1p = get_emote_message_1p(user, target, extra_params)
			use_1p = replacetext(use_1p, "TARGET_THEM", target_pronouns.him)
			use_1p = replacetext(use_1p, "TARGET_THEIR", target_pronouns.his)
			use_1p = replacetext(use_1p, "TARGET_SELF", target_pronouns.self)
			use_1p = replacetext(use_1p, "TARGET", "<b>\the [target]</b>")
		else
			use_1p = get_emote_message_1p(user, null, extra_params)
		use_1p = capitalize(use_1p)

	if(emote_message_3p)
		if(target && emote_message_3p_target)
			use_3p = get_emote_message_3p(user, target, extra_params)
			use_3p = replacetext(use_3p, "TARGET_THEM", target_pronouns.him)
			use_3p = replacetext(use_3p, "TARGET_THEIR", target_pronouns.his)
			use_3p = replacetext(use_3p, "TARGET_SELF", target_pronouns.self)
			use_3p = replacetext(use_3p, "TARGET", "<b>\the [target]</b>")
		else
			use_3p = get_emote_message_3p(user, null, extra_params)
		use_3p = replacetext(use_3p, "USER_THEM", user_pronouns.him)
		use_3p = replacetext(use_3p, "USER_THEIR", user_pronouns.his)
		use_3p = replacetext(use_3p, "USER_SELF", user_pronouns.self)

		runemessage = replacetext(use_3p, "USER", "")

		use_3p = replacetext(use_3p, "USER", "<b>\the [user]</b>")
		use_3p = capitalize(use_3p)

	var/use_range = emote_range
	if (!use_range)
		use_range = world.view

	if(ismob(user))
		var/mob/M = user
		if(message_type == AUDIBLE_MESSAGE)
			M.audible_message(message = use_3p, self_message = use_1p, deaf_message = emote_message_impaired, hearing_distance = use_range, checkghosts = /datum/client_preference/ghost_sight, runemessage = runemessage)
		else
			M.visible_message(message = use_3p, self_message = use_1p, blind_message = emote_message_impaired, range = use_range, checkghosts = /datum/client_preference/ghost_sight, runemessage = runemessage)

	do_extra(user, target)

/mob/custom_emote(m_type = VISIBLE_MESSAGE, message = null)

	if((usr && stat) || (!use_me && usr == src))
		to_chat(src, "You are unable to emote.")
		return

	var/input
	if(!message)
		input = sanitize(input(src,"Choose an emote to display.") as text|null)
	else
		input = message

	if(input)
		message = format_emote(src, message)
	else
		return
	message = process_chat_markup(message)
	if (message)
		log_emote("[name]/[key] : [message]")
	//do not show NPC animal emotes to ghosts, it turns into hellscape
	var/check_ghosts = client ? /datum/client_preference/ghost_sight : null
	if(m_type == VISIBLE_MESSAGE)
		visible_message(message, checkghosts = check_ghosts, runemessage = input)
	else
		audible_message(message, checkghosts = check_ghosts, runemessage = input)
