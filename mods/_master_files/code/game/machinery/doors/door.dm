/obj/machinery/door
	var/emag_proof = FALSE

/obj/machinery/door/emag_act(remaining_charges)
	if(emag_proof)
		return NO_EMAG_ACT
	return ..()
