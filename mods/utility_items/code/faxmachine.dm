/obj/machinery/photocopier/faxmachine
	var/is_centcom = FALSE // Determines if the fax is intended for admin use. If so, ignores all restrictions on receiving messages, and will notify admins when a fax is received.

/obj/machinery/photocopier/faxmachine/can_receive_fax()
	if(is_centcom == TRUE)
		return TRUE
	. = ..()
