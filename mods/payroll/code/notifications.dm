/datum/computer_file/data/email_account/service/payroll
	login = "payroll@internal-services.net"
	fullname = "Payroll Service"

/datum/payroll_record/proc/notify(message, subject = "Payroll notification")
	var/datum/mind/mind = employee?.resolve()
	var/address = mind?.initial_email_login?["login"]
	if(!istext(address) || !length(address) || !ntnet_global)
		return FALSE
	var/datum/computer_file/data/email_account/recipient = ntnet_global.find_email_by_name(address)
	var/datum/computer_file/data/email_account/sender = ntnet_global.find_email_by_name("payroll@internal-services.net")
	if(!recipient || recipient.suspended || !sender || sender.suspended)
		return FALSE
	var/datum/computer_file/data/email_message/mail = new
	mail.source = sender.login
	mail.recipient = recipient.login
	mail.title = sanitize(subject, MAX_MESSAGE_LEN)
	mail.stored_data = sanitize(message, MAX_MESSAGE_LEN, FALSE)
	if(sender.send_mail(recipient.login, mail))
		return TRUE
	qdel(mail)
	return FALSE
