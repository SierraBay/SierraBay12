
/obj/anomaly
	///Шанс, что при протоколе генерации, будет размещена именно эта аномалия
	var/anomaly_spawn_chance = 1
/*Функция попытается заспавнить аномалию без коллизии с другими обьектами или аномалиями.
Применяется мультитайтловыми аномалиями
all_turfs_for_spawn - Внешний список, из которого мы будем удалять турфы в случае удачного/неудачного
T - Турф предполагаемого ядра
path_to_spawn - Путь аномалии, которую мы хотим заспавнить
*/
/proc/try_spawn_anomaly_without_collision(all_turfs_for_spawn, turf/T, obj/anomaly/path_to_spawn)
	var/obj/anomaly/spawned_anomaly = new path_to_spawn(T)
	var/need_to_delete = FALSE
	var/list/list_of_bad_turfs = list()
	for(var/obj/anomaly/part/checked_part in spawned_anomaly.list_of_parts)
		if(TurfBlocked(checked_part.loc) || AnomaliesAmmountInTurf(checked_part.loc) > 1)
			need_to_delete = TRUE
			LAZYADD(list_of_bad_turfs, checked_part.loc)
	//Спавн неудачный, передадим null в ответ
	if(LAZYLEN(list_of_bad_turfs))
		for(var/turf/picked_turf in list_of_bad_turfs)
			LAZYREMOVE(all_turfs_for_spawn, picked_turf)
	if(need_to_delete)
		for(var/obj/anomaly/part/checked_part in spawned_anomaly.list_of_parts)
			qdel(checked_part)
			checked_part.delete_anomaly()
		spawned_anomaly.delete_anomaly()
		qdel(spawned_anomaly)
		return
	//значит нам НЕ нужно удалять, передадим ссылку на самого себя
	else
		return spawned_anomaly

/proc/TurfBlocked(turf/loc)
	if(loc.density)
		return 1
	for(var/obj/O in loc)
		if(O.density)
			return 1
	return 0

/proc/TurfBlockedByAnomaly(turf/loc)
	for(var/obj/O in loc)
		if(istype(O, /obj/anomaly))
			return 1
	return 0

/proc/AnomaliesAmmountInTurf(turf/loc)
	var/output = 0
	for(var/obj/O in loc)
		if(istype(O, /obj/anomaly))
			output++
	return output


/*
КАК РАБОТАЕТ СПАВН АНОМАЛИЙ?
1.В входных параметрах мы получаем список турфов/спавнеров, на которых хотим провести спавн
2.Сперва код расчитывает минимальное количество аномалий, которое выделенное пространство точно должно выдержать. После,
Код выбирает количество аномалий, которое он будет спавнить. Итоговое число будет между min_anomalies_ammout и max_anomalies_ammout
3. Определившись с количеством аномалий, начинается цикл спавна.
В каждой итерации цикла, из списка турфов рандомно выбирается ТУРФ и рандомно выбирается аномалия (possible_anomalies), которую игра попытается на
нём заспавнить. Мы проверяем выбранный турф на то чтоб на нём уже не было аномалий, обьектов и прочего что мешает движению
ЕСЛИ что-то постороннее находится, турф удаляется из списка турфов, счётчик ошибок увеличивается на одну единицу
ЕСЛИ ничего постороннего нет, мы тестово размещаем аномалию на данном турфе. Аномалия сама спавнит свои вспомогательные части в случае если
она мультитайтловая и сообщает нам, обнаружила ли её вспомогательные части на своих турфах аномалию/вспомогательную её часть, или нет.
Если спавн аномалии произошёл штатно, спавн признаётся успешным, переменная i растёт на одну единицу, а счётчик ошибок обнуляется.
проверяем чтоб количество
Если  спавн аномалии произошёл с ошибкой (Её вспомогательные части нашли что-то что мешает их спавну, обычно это пересечение с другой
аномалией или её вспомогательной частью), спавн признаётся ошибочным, турф аномалии удаляется из списка турфов, добавляем +1 ошибку

В конце каждой итерации, код проверяет, ошибок не было == 100 единицам. Если ошибок 100, код заканчивает свою работу

Цикл сам закончит свою работу, как только i станет равным result_anomalies_ammount

ПЕРЕМЕННЫе:
anomalies_types - Пути аномалий, которые будут спавниться на выбранных турфах
all_turfs_for_spawn - Список турфов, на которых будут размещаться аномалии
min_anomalies_ammout - Минимальное число аномалий, которые будут расположены на планете
max_anomalies_ammout - Максимальное число аномалий, которые будут расположены на планете(Если null, то ограничения нет)
min_artefacts_ammount - Минимальное количество артефактов, что разместится в игре
max_artefacts_ammount - Максимальное кличество артефактов, что разметится в игре
garanted_artefacts_ammount - Если нам нужно чёткое количество заспавненных артефактов - используем эту переменную
max_anomaly_size - Максимальный размер аномалий (anomalies_types)
source - Источник(Причина) генерации аномалий на турфах. Используется для отчёта
*/
/proc/generate_anomalies_in_turfs(list/anomalies_types, list/all_turfs_for_spawn, min_anomalies_ammout, max_anomalies_ammout, min_artefacts_ammount, max_artefacts_ammount, min_anomaly_size, max_anomaly_size, source, started_in)
	//Генерация аномалий - это ОЧЕНЬ тяжёлый прок, который без проблем вешает юнит тесты.
	set background = 1
	//Расчитываем мин и макс количество аномалий
	var/result_anomalies_ammout = 1
	if((!min_anomalies_ammout) || (min_anomalies_ammout * min_anomaly_size > LAZYLEN(all_turfs_for_spawn)))
		min_anomalies_ammout = 1
	if(!max_anomalies_ammout)
		max_anomalies_ammout = (LAZYLEN(all_turfs_for_spawn))
		max_anomalies_ammout /= max_anomaly_size

	result_anomalies_ammout = rand(min_anomalies_ammout, max_anomalies_ammout)
	if(result_anomalies_ammout * max_anomaly_size > LAZYLEN(all_turfs_for_spawn))
		result_anomalies_ammout = LAZYLEN(all_turfs_for_spawn)
		result_anomalies_ammout /= max_anomaly_size
	result_anomalies_ammout = Round(result_anomalies_ammout)


	//Собрав все турфы и определившись с числом аномалий, давайте начинать
	var/failures = 0
	//Список успешно размещённых в игре аномалий
	var/list/spawned_anomalies = list()
	var/critical_errors_ammount = 0
	for(var/i = 0, i <= result_anomalies_ammout)
		//Перед началом проверим, что наш список просто не опустошил себя до установки всех аномалий
		if(!LAZYLEN(all_turfs_for_spawn))
			//Список пуст, сообщаем коду о завершении работы.
			i = result_anomalies_ammout + 1
			break
		var/add = FALSE
		//Переменная обозначает что в обработке именно этого турфа используется спавнер.
		var/ruin_protocol = FALSE

		//В случае если нам передали в списке спавнер(а не турф), его нужно обработать чуть по другому
		var/turf/spawner_turf
		var/obj/anomaly/anomaly_to_spawn
		var/picked = pick(all_turfs_for_spawn)
		if(istype(picked, /obj/anomaly_spawner))
			spawner_turf = get_turf(picked)
			var/obj/anomaly_spawner/spawner = picked
			anomaly_to_spawn = pickweight(spawner.possible_anomalies)
			ruin_protocol = TRUE
		else if(isturf(picked))
			spawner_turf = picked
			anomaly_to_spawn = pickweight(anomalies_types)
		//В случае если код сделал фокус и выдал чудо - выходим из цикла генерации, сообщив администрации
		if(!spawner_turf)
			log_and_message_admins("Ошибка работы генератора: при выборе получилось spawner_turf оказалось null")
			critical_errors_ammount++
			continue
		else if(!anomaly_to_spawn)
			log_and_message_admins("Ошибка работы генератора: при выборе получилось anomaly_to_spawn оказалось null")
			critical_errors_ammount++
			continue
		if(critical_errors_ammount > 2)
			i = result_anomalies_ammout + 1
			log_and_message_admins("Генератор аномалий вышел из цикла с критической ошибкой. ")
			break
		//Если каким-то образом спавнер/турф оказался в стене или на этом тайтле уже есть аномалия/её часть
		if(TurfBlocked(spawner_turf) || TurfBlockedByAnomaly(spawner_turf))
			failures++
			//Турф/Спавнер нам больше НЕ подходит, не будет лишний раз нагружать игру и избавимся от него
			if(!ruin_protocol)
				LAZYREMOVE(all_turfs_for_spawn, spawner_turf)
			else
				LAZYREMOVE(all_turfs_for_spawn, picked)
				qdel(picked)
		else
			add = TRUE
			if(anomaly_to_spawn.multitile)
				//Мы вызываем функцию, которая выдаст либо null (аномалия не заспавнена, либо ссылку на обьект)
				var/obj/anomaly/spawned_anomaly = try_spawn_anomaly_without_collision(all_turfs_for_spawn, spawner_turf, anomaly_to_spawn, TRUE, FALSE)
				if(spawned_anomaly)
					LAZYADD(spawned_anomalies, spawned_anomaly)
					if(!ruin_protocol)
						LAZYREMOVE(all_turfs_for_spawn, spawner_turf)
					else
						LAZYREMOVE(all_turfs_for_spawn, picked)
						qdel(picked)
				if(!spawned_anomaly) //Мультитайтловая аномалия неудачно заспавнилась
					add = FALSE
					failures++
			else
				var/obj/anomaly/spawned_anomaly = new anomaly_to_spawn(spawner_turf)
				LAZYADD(spawned_anomalies, spawned_anomaly)
				if(!ruin_protocol)
					LAZYREMOVE(all_turfs_for_spawn, spawner_turf)
				else
					LAZYREMOVE(all_turfs_for_spawn, picked)
					qdel(picked)
		if(add)
			i++
			failures = 0
		else if(failures > 100)
			//У нас слишком много неуспешных размещений аномалий, хватит пытаться, нужно выйти из цикла
			i = result_anomalies_ammout + 1


	//Выбрав количество артов которые мы хотим заспавнить, мы начинаем спавн
	var/spawned_anomalies_ammount = LAZYLEN(spawned_anomalies)
	var/list/output_list = spawned_anomalies
	var/spawned_artifacts_ammount = generate_artefacts_in_anomalies(spawned_anomalies, min_artefacts_ammount, max_artefacts_ammount)

	var/spended_time = world.time - started_in
	//Отчитаемся
	if(spawned_anomalies_ammount > 0)
		report_progress("Spawned [spawned_anomalies_ammount] anomalies with [spawned_artifacts_ammount] artefacts by: [source], spended [spended_time] ticks ")
	return output_list

///Функция генерация артефактов в аномалиях. Спавнит количество артефактов, находящиеся в диапазоне между min_artefacts_ammoun и max_artefacts_ammount
/proc/generate_artefacts_in_anomalies(list/list_of_anomalies, min_artefacts_ammount, max_artefacts_ammount)
	var/artefacts_ammount = rand(min_artefacts_ammount, max_artefacts_ammount)
	//Санитайз, чтоб не требовали рождение артефактов от тех, кто их рожать не может физически
	for(var/obj/anomaly/picked_anomaly in list_of_anomalies)
		if(!picked_anomaly.can_born_artifacts || !LAZYLEN(picked_anomaly.artefacts))
			LAZYREMOVE(list_of_anomalies, picked_anomaly)
	//Санитайз, чтоб артефактов было не слишком много
	if(artefacts_ammount > LAZYLEN(list_of_anomalies))
		artefacts_ammount = LAZYLEN(list_of_anomalies)
	var/spawned_artefacts = 0
	//Пока игра не заспавнит все треуемые артефакты
	while(artefacts_ammount > spawned_artefacts)
		var/obj/anomaly/choosed_anomaly = pick(list_of_anomalies)
		if(!choosed_anomaly)
			return spawned_artefacts
		if(choosed_anomaly.try_born_artifact())
			spawned_artefacts++
		else
			LAZYREMOVE(list_of_anomalies, choosed_anomaly)
	return spawned_artefacts
