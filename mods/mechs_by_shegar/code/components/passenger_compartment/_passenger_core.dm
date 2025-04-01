/mob/living/exosuit
// В связи с кор механом, пассажиры будут помещены в отдельный обьект, для того чтобы пассажиры не курили воздух внутри меха!
	var/obj/item/mech_component/passenger_compartment/passenger_compartment = null
	var/list/passenger_places = list(
		"Back",
		"Left back",
		"Right back"
	)
	/// Общее число пассажиров
	var/passengers_ammount = 0
	/// На спине есть пассажир?
	var/have_back_passenger = FALSE
	/// На левом боку есть пассажир?
	var/have_left_passenger = FALSE
	/// На правом боку есть пассажир?
	var/have_right_passenger = FALSE

	var/list/back_passengers_overlays // <- Изображение пассажира на спине
	var/list/left_back_passengers_overlays // <- Изображение пассажира на левом боку
	var/list/right_back_passengers_overlays // <- Изображение пассажира на правом боку

/obj/item/mech_component/passenger_compartment
	var/list/back_passengers
	var/list/left_back_passengers
	var/list/right_back_passengers
	var/datum/gas_mixture/air_contents = new

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

/mob/living/exosuit/proc/check_passenger(mob/user) // Выбираем желаемое место, проверяем можно ли его занять, стартуем прок занятия
	var/local_dir = get_dir(src, user)
	if(local_dir != turn(dir, 90) && local_dir != turn(dir, -90) && local_dir != turn(dir, -135) && local_dir != turn(dir, 135) && local_dir != turn(dir, 180))
	// G G G
	// G M G  ↓ (Mech dir, look on SOUTH)
	// B B B
	// M - mech, B - cant climb ON mech from this side, G - can climb ON mech from this side
		to_chat(user, SPAN_WARNING("You cant climb in passenger place of [src ] from this side."))
		return FALSE
	var/choose
	var/choosed_place = input(usr, "Choose passenger place which you want to take.", name, choose) as null|anything in passenger_places
	if(!user.Adjacent(src)) // <- Мех рядом?
		return FALSE
	if(user.r_hand != null || user.l_hand != null)
		to_chat(user,SPAN_NOTICE("You need two free hands to take [choosed_place]."))
		return
	if(user.mob_size > MOB_MEDIUM)
		to_chat(user,SPAN_NOTICE("Looks like you too big to take [choosed_place]."))
		return
	if(choosed_place == "Back")
		if(LAZYLEN(passenger_compartment.back_passengers) > 0)
			to_chat(user,SPAN_NOTICE("[choosed_place] is busy"))
			return 0
		else if(body.allow_passengers == FALSE)
			to_chat(user,SPAN_NOTICE("[choosed_place] not able with [body.name]"))
			return 0
	else if(choosed_place == "Left back")
		if(LAZYLEN(passenger_compartment.left_back_passengers) > 0)
			to_chat(user,SPAN_NOTICE("[choosed_place] is busy"))
			return 0
		else if(L_arm.allow_passengers == FALSE)
			to_chat(user,SPAN_NOTICE("[choosed_place] not able with [L_arm.name]"))
			return 0
	else if(choosed_place == "Right back")
		if(LAZYLEN(passenger_compartment.right_back_passengers) > 0)
			to_chat(user,SPAN_NOTICE("[choosed_place] is busy"))
			return 0
		else if(R_arm.allow_passengers == FALSE)
			to_chat(user,SPAN_NOTICE("[choosed_place] not able with [R_arm.name]"))
			return 0
	else if(!choosed_place)
		return 0
	if(check_hardpoint_passengers(choosed_place,user) == TRUE)
		enter_passenger(user,choosed_place)

/mob/living/exosuit/proc/check_hardpoint_passengers(place,mob/user)// Данный прок проверяет, доступна ли часть тела для занятия её пассажиром в данный момент
	var/obj/item/mech_equipment/checker
	if(place == "Back" && hardpoints["back"] != null)
		checker = hardpoints["back"]
		if(checker.disturb_passengers == TRUE)
			to_chat(user,SPAN_NOTICE("[place] covered by [checker] and cant be taked."))
			return FALSE
	else if(place == "Left back" && hardpoints["left shoulder"] != null)
		checker = hardpoints["left shoulder"]
		if(checker.disturb_passengers == TRUE)
			to_chat(user,SPAN_NOTICE("[place] covered by [checker] and cant be taked."))
			return FALSE
	else if(place == "Right back" && hardpoints["right shoulder"] != null)
		checker = hardpoints["right shoulder"]
		if(checker.disturb_passengers == TRUE)
			to_chat(user,SPAN_NOTICE("[place] covered by [checker] and cant be taked."))
			return FALSE
	return TRUE
