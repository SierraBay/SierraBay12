/obj/anomaly
	///Аномалия может "Рожать" артефакты?
	var/can_born_artifacts = FALSE
	///Время, спустя которое аномалия опять попытается родить артефакт
	var/time_to_bort_artifact = 15 MINUTES
	///Время, когда в последний раз аномалия родила артефакт
	var/last_time_artefact_borned = 0
	//ANOTHER
	///Какие артефакты порождает аномалия. Справа пишем шанс выбора этого артефакта в процентах. (Сумма не должна быть больше 100)
	var/list/artefacts = list()
	///Аномалия выбрала, какой артефакт она в итоге выбрала
	var/choosed_artefact_type

	//Шансы спавна артефактов
	///Минимальный шанс
	var/min_spawn_chance = 25
	///Максимальный шанс
	var/max_spawn_chance = 75
	///Текущий шанс
	var/result_spawn_chance

	//Время спавна артефактов
	///Минимальное время
	var/min_spawn_time = 15 MINUTES
	///Максимальное  время
	var/max_spawn_time = 60 MINUTES
	///Текущий шанс
	var/result_spawn_time

///Выберем шанс спавна артефакта в следующий временной промежуток
/obj/anomaly/proc/calculate_artifact_spawn_chance()
	if(!result_spawn_chance)
		result_spawn_chance = rand(min_spawn_chance, max_spawn_chance)

///Выберем время до следующего спавна артефакта
/obj/anomaly/proc/calculate_artifact_spawn_time()
	if(!result_spawn_time)
		result_spawn_time = rand(min_spawn_time, max_spawn_time)

///Выберем, какой артефакт мы заспавним
/obj/anomaly/proc/choose_artifact_to_spawn()
	pickweight(artefacts)

/obj/anomaly/proc/try_born_artifact()
	if(can_born_artifacts)
		born_artifact()

///Кидаем кости, спавнит ли аномалия артефакт?
/obj/anomaly/proc/roll_artefact_spawn_chance()
	if(prob(result_spawn_chance))
		return TRUE
	else
		return FALSE

///Функция спавнит артефакт на территории аномалии
/obj/anomaly/proc/born_artifact()
	if(!check_artifacts_in_anomaly())
		if(roll_artefact_spawn_chance())
			choose_artifact_to_spawn()
			born_artifact_in_random_title()
	do_coldown_to_next_born()

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
/obj/anomaly/proc/born_artifact_in_random_title()
	var/list/possible_places = list()
	LAZYADD(possible_places, src.loc)
	if(multitile)
		if(LAZYLEN(list_of_parts))
			for(var/obj/anomaly/part/part in list_of_parts)
				LAZYADD(possible_places, part.loc)
	var/result = pick(possible_places)
	var/artifact = pick(artefacts)
	new artifact(result)

/obj/anomaly/proc/do_coldown_to_next_born()
	addtimer(new Callback(src, PROC_REF(born_artifact)), time_to_bort_artifact)
