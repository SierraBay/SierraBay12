/mob/living/process_resist()
	.=..()
	if(istype(loc, /obj/item/mech_component/passenger_compartment)) // Если прожал resist пассажир меха
		var/mob/living/exosuit/M = loc.loc
		var/obj/item/mech_component/passenger_compartment/C = loc
		if((src in C.back_passengers) || (src in C.left_back_passengers) || (src in C.right_back_passengers))
			if(M.leave_passenger(src))
				return TRUE

	if(istype(loc, /mob/living/exosuit)) // Если прожал resist пилот меха
		var/mob/living/exosuit/C = loc
		if(C.passengers_ammount > 1)
			var/choose
			var/choosed_place = input(usr, "Choose passenger place which you want unload.", name, choose) as null|anything in C.passenger_places
			C.forced_leave_passenger(choosed_place , null , C)
		else
			C.forced_leave_passenger(null , MECH_DROP_ANY_PASSENGER , C)
		return TRUE
