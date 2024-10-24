/obj/item/artefact
	name = "Что-то."
	desc = "Какой-то камень."
	icon = 'mods/anomaly/icons/artifacts.dmi'
	///Текущее количество энергии, которое хранит артефакт.
	var/stored_energy = 1000
	///Максимальное количество ЭНЕРГИИ, которое хранит артефакт.
	var/max_energy = 1000
	var/cargo_price = 100
	var/rnd_points = 2000
	var/obj/machinery/urm/stored_in_urm
	var/mob/living/carbon/human/current_user

/obj/item/artefact/use_tool(obj/item/item, mob/living/user, list/click_params)
	. = ..()
	if(istype(item, /obj/item/collector))
		collector_interaction(item, user)

/obj/item/artefact/is_damage_immune()
	return TRUE

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

//Все артефакты нельзя уничтожить взрывом.
/obj/item/artefact/ex_act(severity)
	return

///Добавляет указанное количество энергии к артефакту
/obj/item/artefact/proc/add_energy(amount)
	stored_energy += amount
	if(stored_energy >= max_energy)
		react_at_max_energy()
	stored_energy = clamp(stored_energy, 0, max_energy)
	energy_changed()

///Отнимает указанное количество энергии от артефакта
/obj/item/artefact/proc/sub_energy(amount)
	stored_energy -= amount
	if(stored_energy <= max_energy)
		react_at_min_energy()
	stored_energy = clamp(stored_energy, 0, max_energy)

///Вызывается, когда энергия артефакта достигает своих минимальных значений
/obj/item/artefact/proc/react_at_min_energy()
	return

///Вызывается, когда энергия артефакта достигает своих максимальных значений
/obj/item/artefact/proc/react_at_max_energy()
	return

///Энергия артефакта как-то изменилась
/obj/item/artefact/proc/energy_changed()
	return

/obj/item/artefact/proc/delete_artefact()
	if(is_processing)
		stop_process_by_ssanom()
	SSanom.artefacts_deleted_by_game++
	LAZYREMOVE(SSanom.artefacts_list_in_world , src)
	qdel(src)
