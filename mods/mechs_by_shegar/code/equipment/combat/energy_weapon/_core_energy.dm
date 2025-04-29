/obj/item/gun/energy/get_hardpoint_maptext()
	if (charge_cost <= 0)
		return "INF"
	return "[round(power_supply.charge / charge_cost)]/[max_shots]"

/obj/item/gun/energy/get_hardpoint_status_value()
	var/obj/item/cell/C = get_cell()
	if(istype(C))
		return C.charge/C.maxcharge
	return null
