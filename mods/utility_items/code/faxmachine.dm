/obj/machinery/photocopier/faxmachine
	var/is_centcom = FALSE // Determines if the fax is intended for admin use. If so, ignores all restrictions on receiving messages, and will notify admins when a fax is received.
	var/tag_radio = null // Для уведомления на частоте.

/obj/machinery/photocopier/faxmachine/can_receive_fax()
	if(is_centcom == TRUE)
		return TRUE
	. = ..()

/obj/machinery/photocopier/faxmachine/recievefax(obj/item/incoming, origin_department = "Unknown")
	. = ..()
	if (incoming)
		var/fax_message = "На факс прибыло новое уведомление."
		GLOB.global_headset.autosay(fax_message, "Automated Fax System", tag_radio)
		return
