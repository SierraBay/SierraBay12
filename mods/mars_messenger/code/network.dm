var/global/datum/mars_network/mars_network = new()

/datum/mars_network
	var/list/channels = list()
	var/list/clients = list()
	var/list/profiles = list()
	var/setup_complete = FALSE

/datum/mars_network/New()
	if(mars_network && mars_network != src)
		mars_network = src
	return ..()

/datum/mars_network/proc/setup_channels()
	if(setup_complete)
		return
	add_official_channel("common", "Общий Канал", "Common", PUB_FREQ, COMMS_COLOR_COMMON, TRUE)
	add_official_channel("command", "Командный Отдел", "Command", COMM_FREQ, COMMS_COLOR_COMMAND)
	add_official_channel("security", "Охранный Отдел", "Security", SEC_FREQ, COMMS_COLOR_SECURITY)
	add_official_channel("medical", "Медицинский Отдел", "Medical", MED_FREQ, COMMS_COLOR_MEDICAL)
	add_official_channel("engineering", "Инженерный Отдел", "Engineering", ENG_FREQ, COMMS_COLOR_ENGINEER)
	add_official_channel("science", "Научно-Исследовательский Отдел", "Science", SCI_FREQ, COMMS_COLOR_SCIENCE)
	add_official_channel("supply", "Отдел Снабжения", "Supply", SUP_FREQ, COMMS_COLOR_SUPPLY)
	add_official_channel("service", "Отдел Обслуживания", "Service", SRV_FREQ, COMMS_COLOR_SERVICE)
	add_official_channel("exploration", "Экспедиционный Отдел", "Exploration", EXP_FREQ, COMMS_COLOR_EXPLORER)
	add_official_channel("entertainment", "Развлечения", "Entertainment", ENT_FREQ, COMMS_COLOR_ENTERTAIN, TRUE)
	add_official_channel("hailing", "Канал Вызова", "Hailing", HAIL_FREQ, COMMS_COLOR_HAILING)
	add_official_channel("ai", "Закрытый Канал ИИ", "AI Private", AI_FREQ, COMMS_COLOR_AI)
	add_official_channel("ert", "Отряд Быстрого Реагирования", "ERT", ERT_FREQ, COMMS_COLOR_CENTCOMM)
	setup_complete = TRUE

/datum/mars_network/proc/add_official_channel(id, title, radio_name, frequency, color, ntnet_only = FALSE)
	if(channels[id])
		return channels[id]
	var/datum/mars_channel/channel = new
	channel.id = id
	channel.title = title
	channel.radio_name = radio_name
	channel.frequency = frequency
	channel.color = color
	channel.ntnet_only = ntnet_only
	channels[id] = channel
	return channel

/datum/mars_network/proc/telecomms_serves_frequency(frequency)
	if(!frequency)
		return FALSE
	for(var/obj/machinery/telecomms/server/server in telecomms_list)
		if(!server.on || server.overloaded_for)
			continue
		if(!length(server.freq_listening) || (frequency in server.freq_listening))
			return TRUE
	return FALSE

/datum/mars_network/proc/channel_is_online(datum/mars_channel/channel)
	if(!channel)
		return FALSE
	if(channel.direct || channel.ntnet_only)
		return TRUE
	return telecomms_serves_frequency(channel.frequency)

/datum/mars_network/proc/radio_mode_to_id(message_mode, atom/host)
	if(!message_mode)
		return null
	switch(message_mode)
		if("headset")
			return "common"
		if("department")
			return first_department_for(host)
		if("Command")
			return "command"
		if("Security")
			return "security"
		if("Medical")
			return "medical"
		if("Engineering")
			return "engineering"
		if("Science")
			return "science"
		if("Supply")
			return "supply"
		if("Service")
			return "service"
		if("Exploration")
			return "exploration"
		if("Entertainment")
			return "entertainment"
		if("Hailing")
			return "hailing"
		if("AI Private")
			return "ai"
		if("ERT")
			return "ert"
	return null

/datum/mars_network/proc/id_for_radio_name(radio_name)
	for(var/id in channels)
		var/datum/mars_channel/channel = channels[id]
		if(channel && channel.radio_name == radio_name)
			return id
	return null

/datum/mars_network/proc/collect_key_channels(atom/host)
	var/list/found = list("Common" = TRUE, "Entertainment" = TRUE)
	for(var/obj/item/device/encryptionkey/key in mars_get_host_keys(host))
		if(!istype(key))
			continue
		for(var/ch_name in key.channels)
			found[ch_name] = TRUE
	return found

/datum/mars_network/proc/first_department_for(atom/host)
	for(var/obj/item/device/encryptionkey/key in mars_get_host_keys(host))
		for(var/ch_name in key.channels)
			if(ch_name == "Common" || ch_name == "Hailing" || ch_name == "Entertainment")
				continue
			var/id = id_for_radio_name(ch_name)
			if(!id)
				continue
			var/datum/mars_channel/channel = channels[id]
			if(channel && channel_is_online(channel))
				return id
	return "common"

/datum/mars_network/proc/can_access_channel(atom/host, datum/mars_channel/channel)
	if(!channel)
		return FALSE
	// ЛС проверяются через participant_ids в can_see_channel.
	if(channel.direct)
		return FALSE
	if(!channel_is_online(channel))
		return FALSE
	if(channel.id == "common" || channel.radio_name == "Common")
		return TRUE
	if(channel.id == "entertainment" || channel.radio_name == "Entertainment")
		return TRUE
	if(!host)
		return FALSE
	var/list/names = collect_key_channels(host)
	return (channel.radio_name in names)

/datum/mars_network/proc/has_key_access(atom/host, datum/mars_channel/channel)
	if(!channel)
		return FALSE
	if(channel.direct)
		return FALSE
	if(channel.id == "common" || channel.radio_name == "Common")
		return TRUE
	if(channel.id == "entertainment" || channel.radio_name == "Entertainment")
		return TRUE
	if(!host)
		return FALSE
	var/list/names = collect_key_channels(host)
	return (channel.radio_name in names)

/datum/mars_network/proc/update_profile(datum/computer_file/program/mars/client)
	if(!client?.account_id)
		return
	profiles[client.account_id] = list(
		"id" = client.avatar_id,
		"photo" = client.avatar_photo,
		"stamp" = client.avatar_stamp,
		"name" = client.username
	)

/datum/mars_network/proc/register_client(datum/computer_file/program/mars/client)
	if(!client || (client in clients))
		return
	clients += client
	update_profile(client)

/datum/mars_network/proc/unregister_client(datum/computer_file/program/mars/client)
	clients -= client

/datum/mars_network/proc/find_client_on(mob/user)
	if(!user)
		return null
	var/list/held = user.get_contents()
	held |= user
	for(var/atom/candidate in held)
		if(istype(candidate, /obj/item/modular_computer) || istype(candidate, /obj/machinery/computer/modular))
			try_start_on(candidate)
	for(var/datum/computer_file/program/mars/client in clients)
		if(!client.computer)
			continue
		var/atom/host = client.computer.get_physical_host()
		if(!host)
			continue
		if(host == user || (host in held) || host.loc == user)
			if(client.is_online())
				return client
	return null

/datum/mars_network/proc/try_start_on(atom/host)
	var/datum/extension/interactive/ntos/os = get_extension(host, /datum/extension/interactive/ntos)
	if(!os)
		return
	os.try_autorun_mars()

/datum/mars_network/proc/get_or_create_dm(account_a, name_a, account_b, name_b)
	if(!account_a || !account_b || account_a == account_b)
		return null
	var/id
	var/list/pair = sortList(list(account_a, account_b))
	id = "dm-[pair[1]]-[pair[2]]"
	if(channels[id])
		return channels[id]
	var/datum/mars_channel/channel = new
	channel.id = id
	channel.title = "ЛС: [name_a] / [name_b]"
	channel.direct = TRUE
	channel.ntnet_only = TRUE
	channel.color = "#168acf"
	channel.participant_ids = list(account_a, account_b)
	channels[id] = channel
	return channel

/datum/mars_network/proc/post(datum/mars_channel/channel, datum/computer_file/program/mars/sender, text, verb_text = "пишет", datum/computer_file/attachment)
	if(!channel || !sender)
		return FALSE
	if(!text && !attachment)
		return FALSE
	if(!channel_is_online(channel))
		return FALSE
	sender.refresh_identity()
	var/datum/computer_file/payload
	if(istype(attachment))
		payload = attachment.clone()
	if(!text)
		text = "отправляет файл [payload.filename].[payload.filetype]"
	channel.add_message(sender.account_id, sender.username, text, payload)
	var/rendered = "<span style='color: [channel.color]'><span class='name'>[sender.username]</span> <b>\[[channel.title]\]</b> <span class='message'>[verb_text]: \"[text]\"</span></span>"
	for(var/datum/computer_file/program/mars/client in clients)
		if(!client.is_online())
			continue
		if(!client.can_see_channel(channel))
			continue
		client.receive_message(channel, sender, rendered)
	for(var/mob/observer/ghost/ghost in GLOB.player_list)
		if(ghost.get_preference_value(/datum/client_preference/ghost_radio) != GLOB.PREF_ALL_CHATTER)
			continue
		to_chat(ghost, rendered)
	var/mob/user = sender.get_user()
	log_say("[sender.username]/[user ? key_name(user) : "unknown"] MARS/[channel.title]: [text]")
	return TRUE
