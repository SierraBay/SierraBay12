/obj/item/mech_component/passenger_compartment
	var/list/back_passengers
	var/list/left_back_passengers
	var/list/right_back_passengers
	var/datum/gas_mixture/air_contents = new
	var/mob/living/exosuit/owner

/obj/item/mech_component/passenger_compartment/Initialize()
	. = ..()
	owner = loc

/obj/item/mech_component/passenger_compartment/proc/check_passengers_status()
	var/mob/living/passenger
	if(LAZYLEN(back_passengers) > 0)
		passenger = back_passengers[1]
		if(passenger.incapacitated(INCAPACITATION_UNRESISTING) == TRUE)
			to_chat(passenger,SPAN_WARNING("You cant hold anymore yourself on mech."))
			owner.leave_passenger(passenger)
	if(LAZYLEN(left_back_passengers) > 0)
		passenger = left_back_passengers[1]
		if(passenger.incapacitated(INCAPACITATION_UNRESISTING) == TRUE)
			to_chat(passenger,SPAN_WARNING("You cant hold anymore yourself on mech."))
			owner.leave_passenger(passenger)
	if(LAZYLEN(right_back_passengers > 0))
		passenger = right_back_passengers[1]
		if(passenger.incapacitated(INCAPACITATION_UNRESISTING) == TRUE)
			to_chat(passenger,SPAN_WARNING("You cant hold anymore yourself on mech."))
			owner.leave_passenger(passenger)

/obj/item/mech_component/passenger_compartment/return_air()
	var/turf/T = get_turf(loc)
	if(istype(T))
		return T.return_air()

/obj/item/mech_component/passenger_compartment/proc/count_passengers()
	owner.passengers_ammount = owner.passengers_ammount = LAZYLEN(back_passengers) + LAZYLEN(left_back_passengers) + LAZYLEN(right_back_passengers)
