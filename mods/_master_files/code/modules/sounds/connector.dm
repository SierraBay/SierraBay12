/obj/machinery/portable_atmospherics/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(isWrench(W))
		if(connected_port)
			disconnect()
			to_chat(user, SPAN_NOTICE("You disconnect \the [src] from the port."))
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			update_icon()
			return TRUE
		else
			var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector) in loc
			if(possible_port)
				if(connect(possible_port))
					to_chat(user, SPAN_NOTICE("You connect \the [src] to the port."))
					playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
					update_icon()
					return TRUE
				else
					to_chat(user, SPAN_NOTICE("\The [src] failed to connect to the port."))
					return TRUE
			else
				to_chat(user, SPAN_NOTICE("Nothing happens."))
				return TRUE

	return ..()
