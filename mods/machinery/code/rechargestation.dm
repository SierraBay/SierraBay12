/obj/machinery/recharge_station/go_out()
	//There is no usr on relaymove
	if(!occupant || !occupant.MayMove() && !usr)
		return
	.=..()
