/material
	var/price = 1

/material/proc/Value()
	if(sale_price)
		return round(sale_price * CARGO_POINT_TO_THALLER)
	if(price)
		return round(price * CARGO_POINT_TO_THALLER)
	return round(value * CARGO_POINT_TO_THALLER)

/obj/item/stack/material/Value()
	if(!material)
		return ..()
	. = material.Value() * amount
	if(reinf_material)
		. += round(reinf_material.Value() * amount * 0.5)

/obj/machinery/status_display/supply_display/update()
	if(!..() && mode == STATUS_DISPLAY_CUSTOM)
		if(SSsupply && SSsupply.trade_network_active)
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
