/obj/machinery/recharge_station/go_out()
	if(!occupant.MayMove())
		return
	.=..()
