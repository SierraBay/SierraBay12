/obj/anomaly
	///Аномалия может "Рожать" артефакты?
	var/can_born_artefacts = FALSE
	//ANOTHER
	///Какие артефакты порождает аномалия. Справа пишем шанс выбора этого артефакта.
	var/list/artefacts = list()

	//Шанс спавна в аномалии артефакта
	var/artefact_spawn_chance = 25


/obj/anomaly/proc/try_born_artefact()
	//Может ли аномалия спавнить артефакты
	if(can_born_artefacts && !check_artifacts_in_anomaly())
		born_artefact()
		return TRUE
	else
		return FALSE


///Функция спавнит артефакт на территории аномалии
/obj/anomaly/proc/born_artefact()
	var/obj/artefact = pickweight(artefacts)
	if(artefact)
		born_artefact_in_random_title(artefact)

///Функция проверяет, есть ли на территории аномалии артефакты
/obj/anomaly/proc/check_artifacts_in_anomaly()
	var/found_artifact = FALSE
	//Проверим тайтл самой аномалии в поисках артефрукта.
	for(var/atom/movable/target in src.loc)
		if(istype(target, /obj/item/artefact))
			found_artifact = TRUE
	if(multitile && !found_artifact)
		if(LAZYLEN(list_of_parts))
			for(var/obj/anomaly/part/part in list_of_parts)
				if(part.check_artifacts_in_anomaly_part())
					found_artifact = TRUE
					continue
	if(found_artifact)
		return TRUE //На территории аномалии ЕСТЬ артефакт
	else
		return FALSE //На территории аномалии НЕТ артефакта

///Вспомогательная часть проверяет свой тайтл, есть ли на ней артефакт
/obj/anomaly/part/proc/check_artifacts_in_anomaly_part()
	//Проверим тайтл вспомогательной части  аномалии в поисках артефрукта.
	for(var/atom/movable/target in src.loc)
		if(istype(target, /obj/item/artefact))
			return TRUE
	return FALSE


///Создаёт артефакт в случайном тайтле аномалии, включая вспомогательные
/obj/anomaly/proc/born_artefact_in_random_title()
	var/list/possible_places = list()
	LAZYADD(possible_places, src.loc)
	if(multitile)
		if(LAZYLEN(list_of_parts))
			for(var/obj/anomaly/part/part in list_of_parts)
				LAZYADD(possible_places, part.loc)
	var/result = pick(possible_places)
	if(LAZYLEN(artefacts))
		var/artifact = pick(artefacts)
		var/obj/item/artefact/spawned_artefact =  new artifact(result)
		spawned_artefact.connected_to_anomaly = TRUE
		LAZYADD(SSanom.artefacts_list_in_world ,spawned_artefact)
		SSanom.artefacts_spawned_by_game++
