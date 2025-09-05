/mob/living/resist()
	set name = "Resist"
	set category = "IC"

	if(!incapacitated(INCAPACITATION_KNOCKOUT) && last_resist + 2 SECONDS <= world.time)
		last_resist = world.time
		resist_grab()
		if(resting)
			lay_down()
		if(!weakened)
			process_resist()

/mob/living/process_resist()
	//Getting out of someone's inventory.
	if(istype(src.loc, /obj/item/holder))
		escape_inventory(src.loc)
		return

	//unbuckling yourself
	if(buckled)
		escape_buckle()
		return TRUE

	//Breaking out of a structure?
	if(istype(loc, /obj/structure))
		var/obj/structure/C = loc
		if(C.mob_breakout(src))
			return TRUE

	if(istype(loc, /obj/item/mech_component/passenger_compartment)) // Если прожал resist пассажир меха
		var/mob/living/exosuit/M = loc.loc
		var/obj/item/mech_component/passenger_compartment/C = loc
		if((src == C.back_passenger) || (src == C.left_back_passenger) || (src == C.right_back_passenger))
			if(M.leave_passenger(src))
				return TRUE

	if(istype(loc, /mob/living/exosuit)) // Если прожал resist пилот меха
		var/mob/living/exosuit/C = loc
		if(C.passengers_ammount > 1)
			var/choose
			var/choosed_place = input(usr, "Choose passenger place which you want unload.", name, choose) as null|anything in C.passenger_places
			C.external_leaving_passenger(place = choosed_place)
		else
			C.external_leaving_passenger(mode = MECH_DROP_ANY_PASSENGER)
		return TRUE

/mob/living/carbon/human/Crossed(atom/movable/AM)
	if(istype(AM, /mob/living/bot/mulebot))
		var/mob/living/bot/mulebot/MB = AM
		MB.runOver(src)
	if(istype(AM, /mob/living/exosuit))
		var/mob/living/exosuit/MB = AM
		MB.runOver(src)
