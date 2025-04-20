/mob/living/exosuit
// В связи с кор механом, пассажиры будут помещены в отдельный обьект, для того чтобы пассажиры не курили воздух внутри меха!
	var/obj/item/mech_component/passenger_compartment/passenger_compartment = null
	var/list/passenger_places = list(
		"Левый бок",
		"Спина",
		"Правый бок"
	)
	/// Общее число пассажиров
	var/passengers_ammount = 0

	var/list/back_passengers_overlays // <- Изображение пассажира на спине
	var/list/left_back_passengers_overlays // <- Изображение пассажира на левом боку
	var/list/right_back_passengers_overlays // <- Изображение пассажира на правом боку

/obj/item/mech_component/passenger_compartment
	var/mob/living/carbon/human/left_back_passenger
	var/mob/living/carbon/human/back_passenger
	var/mob/living/carbon/human/right_back_passenger
	var/datum/gas_mixture/air_contents = new

/obj/item/mech_component/passenger_compartment/Initialize()
	. = ..()
	owner = loc

/obj/item/mech_component/passenger_compartment/proc/check_passengers_status()
	if(left_back_passenger && left_back_passenger.incapacitated(INCAPACITATION_UNRESISTING) == TRUE)
		to_chat(left_back_passenger, SPAN_WARNING("Больше не удержусь!"))
		owner.leave_passenger(left_back_passenger)
	if(back_passenger && back_passenger.incapacitated(INCAPACITATION_UNRESISTING) == TRUE)
		to_chat(back_passenger, SPAN_WARNING("Больше не удержусь!"))
		owner.leave_passenger(back_passenger)
	if(right_back_passenger && right_back_passenger.incapacitated(INCAPACITATION_UNRESISTING) == TRUE)
		to_chat(right_back_passenger, SPAN_WARNING("Больше не удержусь!"))
		owner.leave_passenger(right_back_passenger)

/obj/item/mech_component/passenger_compartment/return_air()
	var/turf/T = get_turf(src)
	return T.return_air()

/obj/item/mech_component/passenger_compartment/proc/count_passengers()
	owner.passengers_ammount = 0
	if(back_passenger)
		owner.passengers_ammount++
	if(left_back_passenger)
		owner.passengers_ammount++
	if(right_back_passenger)
		owner.passengers_ammount++

/mob/living/exosuit/proc/check_passenger(mob/user, choosed_place) // Выбираем желаемое место, проверяем можно ли его занять, стартуем прок занятия
	if(!user && !choosed_place)
		return
	if(choosed_place == "Левый бок")
		if(passenger_compartment.left_back_passenger)
			to_chat(user, SPAN_NOTICE("[choosed_place] занят."))
			return
		else if(L_arm.allow_passengers == FALSE)
			to_chat(user, SPAN_NOTICE("[choosed_place] недоступен для [L_arm.name]."))
			return
	else if(choosed_place == "Спина")
		if(passenger_compartment.back_passenger)
			to_chat(user, SPAN_NOTICE("[choosed_place] занят."))
			return
		else if(body.allow_passengers == FALSE)
			to_chat(user, SPAN_NOTICE("[choosed_place] недоступен для [body.name]."))
			return
	else if(choosed_place == "Правый бок")
		if(passenger_compartment.right_back_passenger)
			to_chat(user, SPAN_NOTICE("[choosed_place] занят."))
			return
		else if(R_arm.allow_passengers == FALSE)
			to_chat(user, SPAN_NOTICE("[choosed_place] недоступен для [R_arm.name]."))
			return
	if(check_hardpoint_passengers(choosed_place,user) == TRUE)
		enter_passenger(user, choosed_place)

/mob/living/exosuit/proc/check_hardpoint_passengers(place,mob/user)// Данный прок проверяет, доступна ли часть тела для занятия её пассажиром в данный момент
	var/obj/item/mech_equipment/checker
	if(place == "Левый бок" && hardpoints["left shoulder"] != null)
		checker = hardpoints["left shoulder"]
	else if(place == "Спина" && hardpoints["back"] != null)
		checker = hardpoints["back"]
	else if(place == "Правый бок" && hardpoints["right shoulder"] != null)
		checker = hardpoints["right shoulder"]
	if(checker.disturb_passengers == TRUE)
		to_chat(user, SPAN_NOTICE("[place] перекрыт из-за [checker]."))
		return FALSE
	return TRUE
