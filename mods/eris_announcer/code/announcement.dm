#define ANNOUNCER_NAME "Automated Announcement System"

/datum/announcement/proc/FormatErisRadioMessage(message as text, speaker = ANNOUNCER_NAME, verb = "states")
	speaker = html_encode(speaker)
	var/part_a = "<span style='color: [COMMS_COLOR_COMMON]'><b>\[[format_frequency(PUB_FREQ)]\]</b> <span class='name'>"
	var/part_b = "</span> <span class='message'>"
	var/part_c = "</span></span>"
	return "[part_a][speaker][part_b][verb], [SPAN_CLASS("body", "\"[message]\"")][part_c]"

/datum/announcement/proc/CanErisRadioAnnounce(zlevel, frequency = PUB_FREQ)
	var/datum/signal/signal = new
	signal.transmission_method = 2
	signal.frequency = frequency
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

/datum/announcement/proc/FallbackErisRadioMessage(message as text, zlevel, speaker = ANNOUNCER_NAME, frequency = PUB_FREQ)
	if(!radio_controller)
		return

	var/datum/radio_frequency/connection = radio_controller.return_frequency(frequency)
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
		frequency,
		"states",
		null,
		"[frequency]",
		COMMS_COLOR_COMMON
	)

/datum/announcement/proc/ErisRadioMessage(message as text, zlevel, speaker = ANNOUNCER_NAME)
	if(CanErisRadioAnnounce(zlevel))
		return FormatErisRadioMessage(message, speaker)

	FallbackErisRadioMessage(message, zlevel, speaker)
	return null

/////// ANNOUNCEMENT PROCS VIA RADIO ///////
/datum/announcement/proc/FormRadioMessage(message as text, message_title as text, zlevel)
	return ErisRadioMessage(SPAN_BOLD(FONT_LARGE("[SPAN_WARNING("[title]:")] [message]")), zlevel, announcer ? announcer : ANNOUNCER_NAME)

/datum/announcement/minor/FormRadioMessage(message as text, message_title as text, zlevel)
	return ErisRadioMessage(message, zlevel, ANNOUNCER_NAME)

/datum/announcement/priority/FormRadioMessage(message as text, message_title as text, zlevel)
	return ErisRadioMessage(SPAN_BOLD(FONT_LARGE("[SPAN_WARNING("[message_title]:")] [message]")), zlevel, announcer ? announcer : ANNOUNCER_NAME)

/datum/announcement/priority/command/FormRadioMessage(message as text, message_title as text, zlevel)
	return ErisRadioMessage(SPAN_BOLD(FONT_LARGE("[SPAN_WARNING("[GLOB.using_map.boss_name] Update[message_title ? " — [message_title]" : ""]:")] [message]")), zlevel, ANNOUNCER_NAME)

/datum/announcement/priority/security/FormRadioMessage(message as text, message_title as text, zlevel)
	return ErisRadioMessage(SPAN_BOLD(FONT_LARGE("[SPAN_WARNING("[message_title]:")] [message]")), zlevel, ANNOUNCER_NAME)

/////// ANNOUNCEMENT PROCS ///////
/datum/announcement/proc/Message(message as text, message_title as text)
	return FormatErisRadioMessage(FONT_LARGE("[SPAN_WARNING("[title]:")] [message]"), announcer ? announcer : ANNOUNCER_NAME)

/datum/announcement/minor/Message(message as text, message_title as text)
	return FormatErisRadioMessage(message, ANNOUNCER_NAME)

/datum/announcement/priority/Message(message as text, message_title as text)
	return FormatErisRadioMessage(FONT_LARGE("[SPAN_CLASS("alert", "[message_title]:")] [message]"), announcer ? announcer : ANNOUNCER_NAME)

/datum/announcement/priority/command/Message(message as text, message_title as text)
	return FormatErisRadioMessage(FONT_LARGE("[SPAN_WARNING("[GLOB.using_map.boss_name] [message_title]:")] [message]"), ANNOUNCER_NAME)

/datum/announcement/priority/security/Message(message as text, message_title as text)
	return FormatErisRadioMessage(FONT_LARGE("[SPAN_COLOR("red", "[message_title]:")] [message]"), ANNOUNCER_NAME)

#undef ANNOUNCER_NAME
