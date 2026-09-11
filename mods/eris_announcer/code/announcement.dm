#define ANNOUNCER_NAME "Automated Announcement System"

/datum/announcement
	var/frequency = PUB_FREQ

/datum/announcement/proc/get_frequency_color(freq)
	switch(freq)
		if(PUB_FREQ) return COMMS_COLOR_COMMON
		if(HAIL_FREQ) return COMMS_COLOR_HAILING
		if(SCI_FREQ) return COMMS_COLOR_SCIENCE
		if(COMM_FREQ) return COMMS_COLOR_COMMAND
		if(MED_FREQ) return COMMS_COLOR_MEDICAL
		if(ENG_FREQ) return COMMS_COLOR_ENGINEER
		if(SEC_FREQ) return COMMS_COLOR_SECURITY
		if(ERT_FREQ) return COMMS_COLOR_CENTCOMM
		if(DTH_FREQ) return COMMS_COLOR_SYNDICATE
		if(SYND_FREQ) return COMMS_COLOR_SYNDICATE
		if(RAID_FREQ) return COMMS_COLOR_VOX
		if(V_RAID_FREQ) return COMMS_COLOR_VOX
		if(EXP_FREQ) return COMMS_COLOR_EXPLORER
		if(SUP_FREQ) return COMMS_COLOR_SUPPLY
		if(SRV_FREQ) return COMMS_COLOR_SERVICE
		if(AI_FREQ) return COMMS_COLOR_AI
		if(ENT_FREQ) return COMMS_COLOR_ENTERTAIN
		if(MED_I_FREQ) return COMMS_COLOR_MEDICAL_I
		if(SEC_I_FREQ) return COMMS_COLOR_SECURITY_I
	return COMMS_COLOR_COMMON

/datum/announcement/proc/FormatErisRadioMessage(message as text, speaker = ANNOUNCER_NAME, verb = "states", freq = src.frequency)
	speaker = html_encode(speaker)
	var/part_a = "<span style='color: [get_frequency_color(freq)]'><b>\[[get_frequency_default_name(freq)]\]</b> <span class='name'>"
	var/part_b = "</span> <span class='message'>"
	var/part_c = "</span></span>"
	return "[part_a][speaker][part_b][verb], [SPAN_CLASS("body", "\"[message]\"")][part_c]"

/datum/announcement/proc/CanErisRadioAnnounce(zlevel, freq = src.frequency)
	var/datum/signal/signal = new
	signal.transmission_method = 2
	signal.frequency = freq
	signal.data = list(
		"slow" = 0,
		"message" = "TEST",
		"compression" = 0,
		"traffic" = 0,
		"type" = 4,
		"reject" = 0,
		"done" = 0,
		"level" = zlevel
	)

	for(var/obj/machinery/telecomms/receiver/R in telecomms_list)
		R.receive_signal(signal)

	var/levels = signal.data["level"]
	return signal.data["done"] && islist(levels) && (zlevel in levels)

/datum/announcement/proc/FallbackErisRadioMessage(message as text, zlevel, speaker = ANNOUNCER_NAME, freq = src.frequency)
	if(!radio_controller)
		return

	var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)
	if(!istype(connection))
		return

	Broadcast_Message(
		connection,
		null,
		FALSE,
		null,
		null,
		message,
		speaker,
		"AI",
		speaker,
		speaker,
		2,
		0,
		GetConnectedZlevels(zlevel),
		freq,
		"states",
		null,
		"[freq]",
		get_frequency_color(freq)
	)

/datum/announcement/proc/ErisRadioMessage(message as text, zlevel, speaker = ANNOUNCER_NAME, freq = src.frequency)
	if(CanErisRadioAnnounce(zlevel, freq))
		return FormatErisRadioMessage(message, speaker, "states", freq)

	FallbackErisRadioMessage(message, zlevel, speaker, freq)
	return null

/////// HELPER PROCS TO ENHANCE MAINTAINABILITY ///////
/datum/announcement/proc/GetSpeaker()
	return announcer ? announcer : ANNOUNCER_NAME

/datum/announcement/minor/GetSpeaker()
	return ANNOUNCER_NAME

/datum/announcement/priority/command/GetSpeaker()
	return ANNOUNCER_NAME

/datum/announcement/priority/security/GetSpeaker()
	return ANNOUNCER_NAME

/datum/announcement/proc/FormatBody(message as text, message_title as text)
	return FONT_LARGE("[SPAN_CLASS("warning", "[message_title]:")] [message]")

/datum/announcement/minor/FormatBody(message as text, message_title as text)
	return message

/datum/announcement/priority/command/FormatBody(message as text, message_title as text)
	return FONT_LARGE("[SPAN_CLASS("warning", "[GLOB.using_map.boss_name] Update[message_title && message_title != title ? " — [message_title]" : ""]:")] [message]")

/datum/announcement/priority/security/FormatBody(message as text, message_title as text)
	var/colored_title = message_title
	var/list/replacements = list(
		"зеленого кода" = "<span style='color: [COLOR_GREEN]'>зеленого кода</span>",
		"Зелёный код" = "<span style='color: [COLOR_GREEN]'>Зелёный код</span>",
		"code green" = "<span style='color: [COLOR_GREEN]'>code green</span>",
		"зеленого" = "<span style='color: [COLOR_GREEN]'>зеленого</span>",
		"Зелёный" = "<span style='color: [COLOR_GREEN]'>Зелёный</span>",
		"green" = "<span style='color: [COLOR_GREEN]'>green</span>",

		"Фиолетовый код" = "<span style='color: [COLOR_VIOLET]'>Фиолетовый код</span>",
		"Фиолетового" = "<span style='color: [COLOR_VIOLET]'>Фиолетового</span>",
		"code violet" = "<span style='color: [COLOR_VIOLET]'>code violet</span>",
		"code purple" = "<span style='color: [COLOR_VIOLET]'>code purple</span>",
		"violet" = "<span style='color: [COLOR_VIOLET]'>violet</span>",
		"purple" = "<span style='color: [COLOR_VIOLET]'>purple</span>",

		"Оранжевый код" = "<span style='color: [COLOR_ORANGE]'>Оранжевый код</span>",
		"Оранжевого" = "<span style='color: [COLOR_ORANGE]'>Оранжевого</span>",
		"Оражевого" = "<span style='color: [COLOR_ORANGE]'>Оражевого</span>",
		"code orange" = "<span style='color: [COLOR_ORANGE]'>code orange</span>",
		"orange" = "<span style='color: [COLOR_ORANGE]'>orange</span>",

		"Синий код" = "<span style='color: [COLOR_BLUE]'>Синий код</span>",
		"Синего" = "<span style='color: [COLOR_BLUE]'>Синего</span>",
		"code blue" = "<span style='color: [COLOR_BLUE]'>code blue</span>",
		"blue" = "<span style='color: [COLOR_BLUE]'>blue</span>",

		"Красный код" = "<span style='color: [COLOR_RED]'>Красный код</span>",
		"Красного" = "<span style='color: [COLOR_RED]'>Красного</span>",
		"code red" = "<span style='color: [COLOR_RED]'>code red</span>",
		"red" = "<span style='color: [COLOR_RED]'>red</span>",

		"Код Дельта" = "<span style='color: [COLOR_NAVY_BLUE]'>Код Дельта</span>",
		"Код дельта" = "<span style='color: [COLOR_NAVY_BLUE]'>Код дельта</span>",
		"code delta" = "<span style='color: [COLOR_NAVY_BLUE]'>code delta</span>",
		"Дельта" = "<span style='color: [COLOR_NAVY_BLUE]'>Дельта</span>",
		"delta" = "<span style='color: [COLOR_NAVY_BLUE]'>delta</span>"
	)

	for(var/key in replacements)
		if(findtext(colored_title, key))
			colored_title = replacetext(colored_title, key, replacements[key])
			break

	return FONT_LARGE("[SPAN_CLASS("warning", "[colored_title]:")] [message]")

/////// ANNOUNCEMENT PROCS VIA RADIO ///////
/datum/announcement/proc/FormRadioMessage(message as text, message_title as text, zlevel)
	return ErisRadioMessage(SPAN_BOLD(FormatBody(message, message_title)), zlevel, GetSpeaker())

/////// ANNOUNCEMENT PROCS ///////
/datum/announcement/proc/Message(message as text, message_title as text)
	return FormatErisRadioMessage(FormatBody(message, message_title), GetSpeaker())

#undef ANNOUNCER_NAME
