//Как вы и догадались, эта часть кода спавнит рядом с большими артефактами (кристаллами) наши аномалии

//КАК ВСЁ РАБОТАЕТ???
/*
КАК АРТЕФАКТ ПОНИМАЕТ, ЧТО ОН БУДЕТ СПАВНИТЬ АНОМАЛИИ?
Сперва, артефакт при спавне проверяет, какая у него иконка, если это иконка нам УДОЛЕТВОРЯЕТ (0, 1, 7, 11 и 12 иконка)
В таком случае, он сам запускает спавн аномалий вокруг себя при инициализации


КАК РАБОТАЕТ СПАВН АНОМАЛИЙ?
1.Вокруг артефакта в области range_spawn код собирает турфы(тайлы, тайтлы) в лист turfs_for_spawn и подсчитывает их в переменную block_ammount
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
аномалией или её вспомогательной частью), спавн признаётся ошибочным. Мы получаем лист неподходящих турфов, убираем их из нашего списка
, добавляем+1 ошибку.

В конце каждой итерации, код проверяет, ошибок не было == 100 единицам. Если ошибок 50, код заканчивает свою работу

Цикл сам закончит свою работу, как только i станет равным result_anomalies_ammount

*/




/obj/machinery/artifact
	//Генерирует ли при спавне данный артефакт вокруг себя артефакты?
	var/can_born_anomalies = TRUE
	///Минимальное количество аномалий, которое заспавнит артефакт
	var/min_anomalies_ammout = 10
	///Максимальное количество аномалий, которое заспавнит артефакт
	var/max_anomalies_ammout = 20
	//Честно указываем какой минимальный размер аномалий, что могут быть заспавнены артефактом
	var/max_anomaly_size = 1
	///Область в которой будет спавнить аномалии
	var/range_spawn = 5
	//Лист возможных аномалий для спавна
	var/list/possible_anomalies = list(
		/obj/anomaly/electra/three_and_three,
		/obj/anomaly/electra/three_and_three/tesla,
		/obj/anomaly/thamplin/random,
		/obj/anomaly/zjarka/short_effect,
		/obj/anomaly/zjarka/long_effect,
		/obj/anomaly/rvach/three_and_three
		)

/obj/machinery/artifact/Initialize()
	. = ..()
	if(icon_num == 0 || icon_num == 1 || icon_num == 7 || icon_num == 11 || icon_num == 12)
		if(can_born_anomalies)
			born_anomalies()

/obj/machinery/artifact/no_anomalies
	can_born_anomalies = FALSE

///Функция, которая заспавнит вокруг большого артефакта сам артефакт
/obj/machinery/artifact/proc/born_anomalies(range, ammount)
	//Итоговое число аномалий, которое заспавнит спавнер
	var/result_anomalies_ammout
	var/list/turfs_for_spawn = list()
	//Собираем все турфы в определённом радиусе
	//У нас нет турфа?
	if(!src.loc)
		return
	for(var/turf/turfs in RANGE_TURFS(src.loc, range_spawn))
		LAZYADD(turfs_for_spawn, turfs)
	var/blocks_ammount = LAZYLEN(turfs_for_spawn)



	//После того как мы собрали квадраты, мы посчитаем, а укладываемся ли мы вообще в минималку
	if(min_anomalies_ammout * max_anomaly_size > blocks_ammount)
		//если мы НЕ укладываемся даже в минималку, мы просто ретурнимся
		return




	//Мы укладываемся в минималку, давайте выберем количество аномалий
	else
		max_anomalies_ammout = max_anomalies_ammout / (max_anomaly_size * max_anomaly_size)
		var/status = FALSE
		while(!status)
			result_anomalies_ammout = rand(min_anomalies_ammout, max_anomalies_ammout)
			if(result_anomalies_ammout * max_anomaly_size > blocks_ammount)
				status = FALSE
			else
				status = TRUE
		//Когда while закроется, мы всё таки смогли выбрать количество аномалий которое нам удолетворяет. Он рано или поздно закроется
		//т.к мы повесили раньше проверку



	//Собрав все спавнеры и определившись с числом аномалий, давайте начинать
	var/failures = 0
	for(var/i, i <= result_anomalies_ammout)
		//Перед началом проверим, что наш список просто не опустошил себя до установки всех аномалий
		if(!LAZYLEN(turfs_for_spawn))
			//Список пуст, сообщаем коду о завершении работы.
			i = result_anomalies_ammout

		var/add = FALSE
		var/turf/spawner_turf = pick(turfs_for_spawn)
		//Если каким-то образом спавнер оказался в стене или на этом тайтле уже есть аномалия/её часть
		var/obj/anomaly/anomaly_to_spawn = pick(possible_anomalies)
		if((locate(/obj/anomaly) in spawner_turf) || spawner_turf.density)
			failures++
			//Спавнер нам больше НЕ подходит, не будет лишний раз нагружать игру и избавимся от него
			LAZYREMOVE(turfs_for_spawn, spawner_turf)

		else
			add = TRUE
			if(anomaly_to_spawn.multitile)
				//Мы вызываем функцию, которая выдаст либо TRUE, либо список - лист
				var/list/result = try_spawn_anomaly_without_collision(spawner_turf, anomaly_to_spawn, TRUE, FALSE)
				if(LAZYLEN(result)) //Нам выдало список ошибочных турфов! Мы их вычищаем из списка турфов
					add = FALSE
					failures++
					for(var/turf/bad_turf in result)
						LAZYREMOVE(turfs_for_spawn, spawner_turf)
			else
				var/obj/anomaly/real_spawned_anomaly = new anomaly_to_spawn(spawner_turf)
				real_spawned_anomaly.try_born_artifact()
				LAZYREMOVE(turfs_for_spawn, spawner_turf)
		if(add)
			i++
			failures = 0
		else if(failures > 100)
			//Ну пиздец, у нас слишком много неуспешных размещений аномалий, хватит пытаться.
			i = result_anomalies_ammout
