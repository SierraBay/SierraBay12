/obj/item/artefact
	name = "Что-то."
	desc = "Какой-то камень."
	icon = 'mods/anomaly/icons/artifacts.dmi'
	///Текущее количество энергии, которое хранит артефакт
	var/stored_energy = 1000
	///Максимальное количество ЭНЕРГИИ, которое хранит артефакт
	var/max_stored_energy = 1000
	var/cargo_price = 100
	var/rnd_points = 2000
	var/can_be_throwed = FALSE
	var/obj/machinery/urm/stored_in_urm

/obj/item/artefact/use_tool(obj/item/item, mob/living/user, list/click_params)
	. = ..()
	if(istype(item, /obj/item/collector))
		collector_interaction(item, user)

/obj/item/artefact/proc/collector_interaction(obj/item/collector, mob/living/user)
	if(inmech_sec(user))
		to_chat(user, SPAN_WARNING("Вы недотягиваетесь."))
		return
	var/obj/item/collector/input_collector = collector
	if(input_collector.closed)
		to_chat(user, SPAN_BAD("Collector is closed"))
		return
	else if(connected_to_anomaly)
		if(AnomaliesAmmountInTurf(get_turf(src)) == 0)
			connected_to_anomaly = FALSE
			input_collector.try_insert_artefact(user, src)
		else
			for(var/obj/anomaly/anomka in src.loc.contents)
				if(prob(25 * user.get_skill_value(SKILL_SCIENCE)))
					to_chat(user, SPAN_GOOD("Вы аккуратно, при помощи специальных щупов, помещаете обьект в контейнер."))
					connected_to_anomaly = FALSE
					input_collector.try_insert_artefact(user, src)
				else
					to_chat(user, SPAN_WARNING("Обьект уплывает из хвата щупов"))
					if(istype(anomka, /obj/anomaly/part))
						var/obj/anomaly/part/anomka_part = anomka
						if(anomka_part.core.isready())
							anomka_part.core.activate_anomaly()
					else
						if(anomka.isready())
							anomka.activate_anomaly()
					return
	else if(!connected_to_anomaly)
		input_collector.try_insert_artefact(user, src)

/obj/item/artefact/ex_act(severity)
	return

/obj/item/artefact/throw_at(atom/target, range, speed, mob/thrower, spin, datum/callback/callback)
	if(!can_be_throwed)
		react_at_throw()
	. = ..()

///Вызывается для реагирования артефакта на тот факт, что им швыряются
/obj/item/artefact/proc/react_at_throw(atom/target, range, speed, mob/thrower, spin, datum/callback/callback)
	return

/obj/item/artefact/proc/react_to_touched(mob/living/user)
	return

/obj/item/artefact/emp_act(severity)
	. = ..()
	react_to_emp()

/obj/item/artefact/proc/react_to_emp()
	return

/obj/item/artefact/pickup(mob/user)
	. = ..()
	if(!is_processing)
		START_PROCESSING(SSanom, src)

/obj/item/artefact/proc/react_to_remove_from_collector()
	if(!is_processing)
		START_PROCESSING(SSanom, src)

/obj/item/artefact/proc/react_to_insert_in_collector()
	if(is_processing)
		STOP_PROCESSING(SSanom, src)

/obj/item/artefact/proc/delete_artefact()
	if(is_processing)
		STOP_PROCESSING(SSanom, src)
	qdel(src)


//Жар
/obj/item/artefact/zjar
	name = "Something"
	desc = "При поднятии вы чувствуете, словно по вашему телу распростаняется приятное тепло."
	icon_state = "fire_ball"

//Грави
/obj/item/artefact/gravi
	name = "Something"
	desc = "При поднятии вы чувствуете, словно сам воздух вокруг вас становится плотнее."
	icon_state = "gravi"

//Светлячок
/obj/item/artefact/svetlyak
	name = "Something"
	desc = "Невероятно яркий, вы с трудом смотрите на него даже с зажмуренными глазами."
	icon_state = "svetlyak"
