/datum/computer_file/program/email_client/proc/can_notify()
	if(!computer?.on || !computer.host_status() || program_state == PROGRAM_STATE_KILLED || !(src in computer.running_programs))
		return FALSE
	var/datum/nano_module/program/email_client/mail_client = NM
	if(!istype(mail_client) || !mail_client.current_account || mail_client.current_account.suspended)
		return FALSE
	if(!(mail_client in mail_client.current_account.connected_clients))
		return FALSE
	var/obj/item/modular_computer/device = computer.holder
	if(istype(device) && device.get_damage_value() > device.broken_damage)
		return FALSE
	return !!computer.get_ntnet_status()

/datum/computer_file/program/email_client/new_mail_notify(notification_sound)
	if(!can_notify())
		return
	var/datum/nano_module/program/email_client/mail_client = NM
	if(!mail_client.current_account.notification_mute)
		return ..()
	computer.visible_notification(notification_sound)

/datum/computer_file/program/email_client/process_tick()
	var/datum/nano_module/program/email_client/mail_client = NM
	var/last_message_count = mail_client?.last_message_count
	. = ..()
	if(!can_notify())
		return
	// The core tick already signals unmuted mail; add only the muted screen notification.
	if(mail_client.current_account.notification_mute && mail_client.last_message_count > last_message_count)
		new_mail_notify(mail_client.current_account.notification_sound)

/datum/nano_module/program/email_client/mail_received(datum/computer_file/data/email_message/received_message)
	if(!program)
		..()
		return !!get_holder_of_type(host, /mob/living)
	var/datum/computer_file/program/email_client/mail_program = program
	if(!istype(mail_program) || mail_program.NM != src || !mail_program.can_notify())
		return FALSE
	var/mob/living/holder = get_holder_of_type(host, /mob/living)
	if(!holder)
		return FALSE
	to_chat(holder, SPAN_NOTICE("Your [host] reports new mail from [html_encode(received_message.source)]. Subject: [html_encode(received_message.title)]"))
	return TRUE
