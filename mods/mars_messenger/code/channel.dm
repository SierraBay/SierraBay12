/datum/mars_channel
	var/id
	var/title
	var/radio_name
	var/frequency
	var/color = COMMS_COLOR_COMMON
	var/direct = FALSE
	/// Канал живёт только на NTNet (ЛС, общий, развлечения) — telecomms не нужны.
	var/ntnet_only = FALSE
	/// Монотонный счётчик сообщений: last_seen не ломается при обрезке истории.
	var/message_seq = 0
	var/list/messages = list()
	var/list/participant_ids = list()

/datum/mars_channel/proc/add_message(account_id, username, text, datum/computer_file/attachment)
	message_seq++
	messages += list(list(
		"time" = stationtime2text(),
		"author" = username,
		"account" = account_id,
		"text" = text,
		"file" = attachment,
		"seq" = message_seq
	))
	if(length(messages) > 80)
		var/list/oldest = messages[1]
		var/datum/computer_file/old_file = oldest["file"]
		if(istype(old_file) && !old_file.holder)
			qdel(old_file)
		messages.Cut(1, 2)
