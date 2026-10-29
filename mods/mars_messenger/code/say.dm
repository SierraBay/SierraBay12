/proc/mars_try_replace_radio(mob/living/user, message_mode, message, verb_text, datum/language/speaking, list/used_radios)
	if(!user || !message_mode || !mars_network)
		return FALSE
	switch(message_mode)
		if("whisper", "intercom", "left ear", "right ear", "special", "Mercenary", "Raider", "Vox Raider")
			return FALSE
	if(speaking && (speaking.flags & (NONVERBAL | SIGNLANG)))
		return FALSE
	mars_network.setup_channels()
	var/datum/computer_file/program/mars/client = mars_network.find_client_on(user)
	if(!client)
		return FALSE
	var/atom/host = client.computer.get_physical_host()
	var/channel_id = mars_network.radio_mode_to_id(message_mode, host)
	if(!channel_id)
		return FALSE
	var/datum/mars_channel/channel = mars_network.channels[channel_id]
	if(!channel)
		return FALSE
	if(!client.can_see_channel(channel))
		var/atom/check_host = host
		if(!mars_network.channel_is_online(channel))
			to_chat(user, SPAN_WARNING("МАРС: канал «[channel.title]» недоступен — сервер связи отдела выключен или перегружен."))
		else if(!mars_network.has_key_access(check_host, channel))
			to_chat(user, SPAN_WARNING("МАРС: нет доступа к чату «[channel.title]». Вставь ключ шифрования в устройство."))
		else
			to_chat(user, SPAN_WARNING("МАРС: нет доступа к чату «[channel.title]»."))
		return TRUE
	if(!client.send_to_channel(channel, message, verb_text))
		if(!mars_network.channel_is_online(channel))
			to_chat(user, SPAN_WARNING("МАРС: канал «[channel.title]» недоступен — сервер связи отдела выключен или перегружен."))
			return TRUE
		return FALSE
	if(host)
		used_radios += host
		playsound(get_turf(host), 'sound/machines/twobeep.ogg', 20, 0, -1)
	return TRUE

/datum/computer_file/program/mars/proc/send_to_channel(datum/mars_channel/channel, text, verb_text = "пишет")
	if(!channel || !is_online())
		return FALSE
	if(!can_see_channel(channel))
		return FALSE
	text = sanitize(text, 512)
	if(!text)
		return FALSE
	open_channel = channel
	mark_seen(channel)
	return mars_network.post(channel, src, text, verb_text)

/mob/living/carbon/human/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	if(mars_try_replace_radio(src, message_mode, message, verb, speaking, used_radios))
		if(length(used_radios))
			return
		return 1
	switch(message_mode)
		if("intercom")
			if(!src.restrained())
				for(var/obj/item/device/radio/I in view(1))
					if(I.intercom_handling)
						I.talk_into(src, message, null, verb, speaking)
						I.add_fingerprint(src)
						used_radios += I
		if("headset")
			if(l_ear && istype(l_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = l_ear
				R.talk_into(src,message,null,verb,speaking)
				used_radios += l_ear
			else if(r_ear && istype(r_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = r_ear
				R.talk_into(src,message,null,verb,speaking)
				used_radios += r_ear
			else
				var/obj/item/device/radio/clipped = get_first_clipped_radio(src)
				if(clipped)
					clipped.talk_into(src, message, null, verb, speaking)
					used_radios += clipped
		if("right ear")
			var/obj/item/device/radio/R
			var/has_radio = 0
			if(r_ear && istype(r_ear,/obj/item/device/radio))
				R = r_ear
				has_radio = 1
			if(r_hand && istype(r_hand, /obj/item/device/radio))
				R = r_hand
				has_radio = 1
			if(has_radio)
				R.talk_into(src,message,null,verb,speaking)
				used_radios += R
		if("left ear")
			var/obj/item/device/radio/R
			var/has_radio = 0
			if(l_ear && istype(l_ear,/obj/item/device/radio))
				R = l_ear
				has_radio = 1
			if(l_hand && istype(l_hand,/obj/item/device/radio))
				R = l_hand
				has_radio = 1
			if(has_radio)
				R.talk_into(src,message,null,verb,speaking)
				used_radios += R
		if("whisper")
			whisper_say(html_decode(message), speaking, alt_name)
			return 1
		else
			if(message_mode)
				if(l_ear && istype(l_ear,/obj/item/device/radio))
					l_ear.talk_into(src,message, message_mode, verb, speaking)
					used_radios += l_ear
				else if(r_ear && istype(r_ear,/obj/item/device/radio))
					r_ear.talk_into(src,message, message_mode, verb, speaking)
					used_radios += r_ear
				else
					var/obj/item/device/radio/clipped = get_first_clipped_radio(src)
					if(clipped)
						clipped.talk_into(src, message, message_mode, verb, speaking)
						used_radios += clipped
/mob/living/silicon/robot/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	log_say("[key_name(src)] : [message]")
	if(mars_try_replace_radio(src, message_mode, message, verb, speaking, used_radios))
		if(length(used_radios))
			return
		return 1
	if(message_mode)
		if(!is_component_functioning("radio"))
			to_chat(src, "[SPAN_WARNING("Your radio isn't functional at this time.")]")
			return 0
		if(message_mode == "general")
			message_mode = null
		return silicon_radio.talk_into(src,message,message_mode,verb,speaking)

/mob/living/silicon/ai/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	log_say("[key_name(src)] : [message]")
	if(message_mode == "department")
		return holopad_talk(message, verb, speaking)
	if(mars_try_replace_radio(src, message_mode, message, verb, speaking, used_radios))
		if(length(used_radios))
			return
		return 1
	if(message_mode)
		if (ai_radio.disabledAi || !has_power() || stat)
			to_chat(src, "[SPAN_CLASS("danger", "System Error - Transceiver Disabled.")]")
			return 0
		if(message_mode == "general")
			message_mode = null
		return ai_radio.talk_into(src,message,message_mode,verb,speaking)

/mob/living/silicon/pai/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	log_say("[key_name(src)] : [message]")
	if(mars_try_replace_radio(src, message_mode, message, verb, speaking, used_radios))
		if(length(used_radios))
			return
		return 1
	if(message_mode)
		if(message_mode == "general")
			message_mode = null
		if(message_mode == "intercom")
			for(var/obj/item/device/radio/I in view(1))
				if(I.intercom_handling)
					I.talk_into(src, message, null, verb, speaking)
					used_radios += I
		return silicon_radio.talk_into(src,message,message_mode,verb,speaking)
