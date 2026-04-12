/obj/item/stack/material/Value()
	if(!material)
		return ..()
	. = material.value * amount
	if(reinf_material)
		. += round(reinf_material.value * amount * 0.5)

/obj/machinery/status_display/supply_display/update()
	if(!..() && mode == STATUS_DISPLAY_CUSTOM)
		message1 = "TRADE"
		var/supply_timer = get_supply_shuttle_timer()
		message2 = supply_timer ? supply_timer : "NET"
		update_display(message1, message2)
		return TRUE
	return FALSE

/datum/event/mail/setup()
	kill(TRUE)

/datum/event/mail/announce()
	return

/datum/event/mail/tick()
	kill(TRUE)

/datum/event/shipping_error/start()
	kill(TRUE)
