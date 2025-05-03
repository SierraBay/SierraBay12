
/obj/anomaly
	///Шанс, что при протоколе генерации, будет размещена именно эта аномалия
	var/anomaly_spawn_chance = 1
/*Функция попытается заспавнить аномалию без коллизии с другими обьектами или аномалиями.
Применяется функция block() исходя из параметров(размеров) аномалии.
Если размеры подходящие для аномалии - протокол аномалию спавнит. Иначе собирает те турфы что не подходят и идёт дальше
Если нужно и зарандомить размеры аномалии, проток это тоже сделает.
T - Турфы на котором протокол попытается разместить аномалию
path_to_spawn - путь аномалии которую попытается заспавнить алгоритм
*/
/proc/try_spawn_anomaly_without_collision(turf/T, obj/anomaly/path_to_spawn, visible_generation = FALSE)
	var/x_width = initial(path_to_spawn.parts_x_width)
	var/y_width = initial(path_to_spawn.parts_y_width)
	var/min_x_size = initial(path_to_spawn.min_x_size)
	var/max_x_size = initial(path_to_spawn.max_x_size)
	var/min_y_size = initial(path_to_spawn.min_y_size)
	var/max_y_size = initial(path_to_spawn.max_y_size)
	//Если требуется рандомизация - рандомизируем размеры
	if(min_x_size && max_x_size && min_y_size && max_y_size)
		x_width = floor(rand(min_x_size, max_x_size))
		y_width = floor(rand(min_y_size, max_y_size))
	//Собираем турфы в выставленных размерах
	var/list/result_turfs = block_by_coordinates(input_turf = T, x = x_width, y = y_width, move_to_center = TRUE)
	var/placement_error = FALSE
	for(var/turf/turf in result_turfs)
		if(TurfBlockedByAnomaly(turf) || TurfBlocked(turf))
			placement_error = TRUE
	//Проблем нет - ставим аному исходя из выставленных размеров
	if(!placement_error)
		var/obj/anomaly/spawned_anomaly = new path_to_spawn(turf = T, input_x = x_width, input_y = y_width, called_by_generator = TRUE, visible_generation = visible_generation)
		return spawned_anomaly
	else
		return FALSE

/proc/TurfBlocked(turf/loc, space_allowed = TRUE)
	if(!loc) //Если входного турфа нет - автоматом сообщаем о заблокированном турфе
		return TRUE
	if(!space_allowed && (isspaceturf(loc) || isspace(get_area(loc))))
		return TRUE
	if(loc.density)
		return TRUE
	for(var/obj/O in loc)
		if(O.density && !istype(O, /obj/structure/railing))
			return TRUE
	return FALSE

/proc/TurfBlockedByAnomaly(turf/loc)
	for(var/obj/O in loc)
		if(istype(O, /obj/anomaly))
			return TRUE
	return FALSE

/proc/AnomaliesAmmountInTurf(turf/loc)
	var/output = FALSE
	for(var/obj/O in loc)
		if(istype(O, /obj/anomaly))
			output++
	return output


/*
КАК РАБОТАЕТ СПАВН АНОМАЛИЙ?
1.В входных параметрах мы получаем список турфов/спавнеров, на которых хотим провести спавн
2.Сперва код расчитывает минимальное количество аномалий, которое выделенное пространство точно должно выдержать. После,
Код выбирает количество аномалий, которое он будет спавнить. Итоговое число будет между min_anomalies_ammount и max_anomalies_ammount
3. Определившись с количеством аномалий, начинается цикл спавна.
В каждой итерации цикла, из списка турфов рандомно выбирается ТУРФ и рандомно выбирается аномалия (possible_anomalies), которую игра попытается на
нём заспавнить. Мы проверяем выбранный турф на то чтоб на нём уже не было аномалий, обьектов и прочего что мешает движению
ЕСЛИ что-то постороннее находится, турф удаляется из списка турфов, счётчик ошибок увеличивается на одну единицу
ЕСЛИ ничего постороннего нет, мы прикидываем размеры аномалии исходя из её параметров.
Если спавн аномалии произошёл штатно, спавн признаётся успешным, переменная i растёт на одну единицу, а счётчик ошибок обнуляется.
Если  спавн аномалии произошёл с ошибкой (После прикидывания размеров аномалий мы нашли в этом блоке что-то что нам мешает),
спавн признаётся ошибочным, турф аномалии удаляется из списка турфов, добавляем +1 ошибку

В конце каждой итерации, код проверяет, ошибок не было == 100 единицам. Если ошибок 100, код заканчивает свою работу выходя с ошибкой. Это прикроет нас от вечного
лаганного цикла.

Цикл сам закончит свою работу, как только i станет равным result_anomalies_ammount

ПЕРЕМЕННЫе:
anomalies_types - Пути аномалий, которые будут спавниться на выбранных турфах
all_turfs_for_spawn - Список турфов, на которых будут размещаться аномалии
min_anomalies_ammount - Минимальное число аномалий, которые будут расположены на планете
max_anomalies_ammount - Максимальное число аномалий, которые будут расположены на планете(Если null, то ограничения нет)
min_artefacts_ammount - Минимальное количество артефактов, что разместится в игре
max_artefacts_ammount - Максимальное кличество артефактов, что разметится в игре
garanted_artefacts_ammount - Если нам нужно чёткое количество заспавненных артефактов - используем эту переменную
source - Источник(Причина) генерации аномалий на турфах. Используется для отчёта
visible_generation - нужно ли рисовать анимацию размещения аномалии, или это не требуется т.к просто некому это видеть?
*/
/proc/generate_anomalies_in_turfs(list/anomalies_types, list/all_turfs_for_spawn, min_anomalies_ammount, max_anomalies_ammount, min_artefacts_ammount, max_artefacts_ammount, source, visible_generation = FALSE, started_in)
	set background = TRUE
	set waitfor = FALSE
	//Расчитываем мин и макс количество аномалий
	var/result_anomalies_ammount = 1
	if(!min_anomalies_ammount)
		min_anomalies_ammount = calculate_min_anomalies_ammount(min_anomalies_ammount, LAZYLEN(all_turfs_for_spawn), anomalies_types)
	if(!max_anomalies_ammount)
		max_anomalies_ammount = calculate_max_anomalies_ammount(max_anomalies_ammount, LAZYLEN(all_turfs_for_spawn), anomalies_types)
	result_anomalies_ammount = calculate_result_anomalies_ammount(min_anomalies_ammount, max_anomalies_ammount, result_anomalies_ammount, LAZYLEN(all_turfs_for_spawn))


	//Собрав все турфы и определившись с числом аномалий, давайте начинать
	var/failures = 0
	//Список успешно размещённых в игре аномалий
	var/list/spawned_anomalies = list()
	var/critical_errors_ammount = 0
	for(var/i = 0, i <= result_anomalies_ammount)
		//Перед началом проверим, что наш список просто не опустошил себя до установки всех аномалий
		if(!LAZYLEN(all_turfs_for_spawn))
			//Список пуст, сообщаем коду о завершении работы.
			i = result_anomalies_ammount + 1
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
			i = result_anomalies_ammount + 1
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
				var/obj/anomaly/spawned_anomaly = try_spawn_anomaly_without_collision(T = spawner_turf, path_to_spawn = anomaly_to_spawn, visible_generation = visible_generation)
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
				var/obj/anomaly/spawned_anomaly = new anomaly_to_spawn(spawner_turf, visible_generation)
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
			i = result_anomalies_ammount + 1


	//Выбрав количество артов которые мы хотим заспавнить, мы начинаем спавн
	var/spawned_anomalies_ammount = LAZYLEN(spawned_anomalies)
	var/spawned_artefacts_ammount = generate_artefacts_in_anomalies(spawned_anomalies.Copy(), min_artefacts_ammount, max_artefacts_ammount)

	var/spended_time = world.realtime - started_in
	//Отчитаемся
	if(spawned_anomalies_ammount > 0)
		report_progress("Создано [spawned_anomalies_ammount] аномалий, создано [spawned_artefacts_ammount] артефактов в них. Источник: [source], затрачено [spended_time] тиков. ")
		SSanom.AddImportantLog("Создано [spawned_anomalies_ammount] аномалий, создано [spawned_artefacts_ammount] артефактов в них. Источник: [source], затрачено [spended_time] тиков. ")
	return spawned_anomalies

///Функция генерация артефактов в аномалиях. Спавнит количество артефактов, находящиеся в диапазоне между min_artefacts_ammoun и max_artefacts_ammount
/proc/generate_artefacts_in_anomalies(list/list_of_anomalies, min_artefacts_ammount, max_artefacts_ammount)
	var/artefacts_ammount = rand(min_artefacts_ammount, max_artefacts_ammount)
	var/list/input_list = list_of_anomalies
	//Санитайз, чтоб не требовали рождение артефактов от тех, кто их рожать не может физически
	for(var/obj/anomaly/picked_anomaly in input_list)
		if(!picked_anomaly.can_born_artefacts || !LAZYLEN(picked_anomaly.artefacts))
			LAZYREMOVE(input_list, picked_anomaly)
	//Санитайз, чтоб артефактов было не слишком много
	if(artefacts_ammount > LAZYLEN(input_list))
		artefacts_ammount = LAZYLEN(input_list)
	var/spawned_artefacts = 0
	//Пока игра не заспавнит все треуемые артефакты
	while(artefacts_ammount > spawned_artefacts)
		var/obj/anomaly/choosed_anomaly = pick(input_list)
		if(!choosed_anomaly)
			return spawned_artefacts
		if(choosed_anomaly.try_born_artefact())
			spawned_artefacts++
		else
			LAZYREMOVE(input_list, choosed_anomaly)
	return spawned_artefacts













/proc/calculate_min_anomalies_ammount(min_anomalies_ammount, all_turfs_for_spawn_len, list/all_anomalies_types)
	var/min_anomaly_size = 100
	for(var/i in all_anomalies_types)
		var/obj/anomaly/anomaly_path = i
		var/local_anomaly_size = initial(anomaly_path.min_x_size) * initial(anomaly_path.min_y_size)
		if(local_anomaly_size < min_anomaly_size)
			min_anomaly_size = local_anomaly_size
	if((!min_anomalies_ammount) || (min_anomalies_ammount * min_anomaly_size > all_turfs_for_spawn_len))
		min_anomalies_ammount = 1
	return min_anomalies_ammount



/proc/calculate_max_anomalies_ammount(max_anomalies_ammount, all_turfs_for_spawn_len, all_anomalies_types)
	//Кодер уже выставил макс количество аном, пусть генератор попробует
	if(max_anomalies_ammount)
		return max_anomalies_ammount
	else
		//Тогда вычислим сами
		var/max_anomaly_size = 0
		for(var/i in all_anomalies_types)
			var/obj/anomaly/anomaly_path = i
			var/local_anomaly_size = initial(anomaly_path.max_x_size) * initial(anomaly_path.max_y_size)
			if(local_anomaly_size > max_anomaly_size)
				max_anomaly_size = local_anomaly_size
			max_anomalies_ammount = all_turfs_for_spawn_len
			max_anomalies_ammount /= max_anomaly_size //Здесь я поставил /= ибо при применениии max_anomalies_ammount = all_turfs_for_spawn_len/max_anomaly_size тут дохнет дебаг VS кода. Почему? хз
		return max_anomalies_ammount

/proc/calculate_result_anomalies_ammount(min_anomalies_ammount, max_anomalies_ammount)
	var/local_result = 0
	local_result = rand(min_anomalies_ammount, max_anomalies_ammount)
	local_result = Round(local_result)
	return local_result
