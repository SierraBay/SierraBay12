//Как вы и догадались, эта часть кода спавнит аномалии согласно заранее замапленной карте, где установлены СПАВНЕРЫ и КОНТРОЛЛЕР/КОМАНДИР

//КАК ВСЁ РАБОТАЕТ???
/*
В мире размещается карта различными способами. В итоге, до инициализации, в мире оказываются СПАВНЕР и КОНТРОЛЛЕР/КОМАНДИР

Спавнер является лишь обозначением, куда НУЖНО контроллеру будет ставить аномалию.
Контроллер же является именно тем кто собирает всех в кучу и ставит аномалии.


КАК РАБОТАЕТ СПАВН АНОМАЛИЙ?
1.Вокруг контроллера собираются все спавнеры и заключаются в список spawners
2.Сперва код расчитывает минимальное количество аномалий, которое выделенное пространство точно должно выдержать. После,
Код выбирает количество аномалий, которое он будет спавнить. Итоговое число будет между min_anomalies_ammout и max_anomalies_ammout
3. Определившись с количеством аномалий, начинается цикл спавна.
В каждой итерации цикла, из списка спавнеров рандомно выбирается спавнер и рандомно выбирается аномалия (possible_anomalies) из самого спавнер,
которую игра попытается на нём заспавнить. Мы проверяем турф спавнера на то чтоб на нём уже не было аномалий, обьектов и прочего что
мешает движению.
ЕСЛИ что-то постороннее находится, спавнер удаляется из списка спавнеров, счётчик ошибок увеличивается на одну единицу
ЕСЛИ ничего постороннего нет, мы тестово размещаем аномалию на турфе спавнер. Аномалия сама спавнит свои вспомогательные части.

В случае если она мультитайтловая она сообщает нам, обнаружила ли её вспомогательные части на своих турфах аномалию/вспомогательные
части.
Если спавн аномалии произошёл штатно, спавн признаётся успешным, переменная i растёт на одну единицу, а счётчик ошибок обнуляется.
Если  спавн аномалии произошёл с ошибкой (Её вспомогательные части нашли что-то что мешает их спавну, обычно это пересечение с другой
аномалией или её вспомогательной частью), спавн признаётся ошибочным. Мы получаем лист неподходящих спавнеров, убираем их из нашего списка
спавнеров, добавляем + 1 ошибку.

В конце каждой итерации, код проверяет, ошибок не было == 50 единицам. Если ошибок 50, код заканчивает свою работу

Цикл сам закончит свою работу, как только i станет равным result_anomalies_ammount

*/




/obj/anomaly_spawner
	icon = 'mods/anomaly/icons/spawn_protocol_stuff.dmi'
	icon_state = "none"
	invisibility = INVISIBILITY_OBSERVER
	name = "Просто спавнер аномалий который спавнит аномалии, ахуеть"
	var/list/possible_anomalies = list(
		/obj/anomaly/electra/three_and_three
	)
	///ИД спавнера, чтоб в случае чего командиры между собой не путались
	var/spawner_id = 1
	var/controller = FALSE
	var/must_be_deleted = FALSE

/obj/anomaly_spawner/commander
	icon_state = "commander_spawn"
	invisibility = INVISIBILITY_OBSERVER
	///ИД ккомандира, чтоб он собрал только тех кто ему реально нужен
	name = "Центр и дерижор спавна аномалий, собирает все спавнеры в кучу и думает чё делать дальше"
	desc = "собирает все спавнеры в кучу и думает чё делать дальше"
	controller = TRUE
	var/random_ammount_of_anomalies = TRUE
	///Минимальное количество аномалий, которое заспавнит главный спавнер
	var/min_anomalies_ammout = 10
	///Максимальное количество аномалий, которое заспавнит главный спавнер
	var/max_anomalies_ammout = 20
	//Итоговое число аномалий, которое заспавнит спавнер
	var/result_anomalies_ammout
	//Честно указываем какой минимальный размер аномалий из нашего "набора"
	var/max_anomaly_size = 3
	//Лист подключённых спавнеров
	var/list/spawners = list()

/obj/anomaly_spawner/electra
	name = "Спавнер, который хочет спавнить лишь электрические аномалии"
	icon_state = "electra_spawn"
	possible_anomalies = list(
		/obj/anomaly/electra/three_and_three,
		/obj/anomaly/electra/three_and_three/tesla
		)

/obj/anomaly_spawner/zjarka
	name = "Спавнер, который хочет спавнить лишь огненные аномалии"
	icon_state = "zjarka_spawn"
	possible_anomalies = list(
		/obj/anomaly/zjarka,
		/obj/anomaly/zjarka/short_effect,
		/obj/anomaly/zjarka/long_effect
		)

/obj/anomaly_spawner/commander/Initialize()
	. = ..()
	//Собираем все спавнеры вокруг
	for(var/obj/anomaly_spawner/spawner in orange(15, src.loc))
		if(src.spawner_id == spawner.spawner_id)
			LAZYADD(spawners, spawner)
	var/blocks_ammount = LAZYLEN(spawners)



	//После того как мы собрали квадраты, мы посчитаем, а укладываемся ли мы вообще в минималку
	if(min_anomalies_ammout * max_anomaly_size > blocks_ammount)
		//если мы НЕ укладываемся даже в минималку, мы просто убиваем всех мелких спавнеров и коммандира
		for(var/obj/anomaly_spawner/spawner in spawners)
			spawner.delete_him()
		QDEL_NULL(src)
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
		if(!LAZYLEN(spawners))
			//Список пуст, сообщаем коду о завершении работы.
			i = result_anomalies_ammout
			break

		var/add = FALSE
		var/obj/anomaly_spawner/spawner = pick(spawners)
		//Если каким-то образом спавнер оказался в стене или на этом тайтле уже есть аномалия/её часть
		var/turf/spawner_turf = get_turf(spawner)
		var/obj/anomaly/anomaly_to_spawn = pick(spawner.possible_anomalies)
		if((locate(/obj/anomaly) in spawner_turf) || spawner_turf.density)
			failures++
			//Спавнер нам больше НЕ подходит, не будет лишний раз нагружать игру и избавимся от него
			LAZYREMOVE(spawners, spawner)
			spawner.delete_him()

		else
			add = TRUE
			if(anomaly_to_spawn.multitile)
				//Мы вызываем функцию, которая выдаст либо TRUE, либо список - лист
				var/list/result = try_spawn_anomaly_without_collision(spawner_turf, anomaly_to_spawn, TRUE, FALSE)
				if(LAZYLEN(result)) //Нам выдало список ошибочных спавнеров! Мы их вычищаем из списка спавнеров
					add = FALSE
					failures++
					for(var/obj/anomaly_spawner/bad_spawner in result)
						LAZYREMOVE(spawners, bad_spawner)
						spawner.delete_him()
			else
				new anomaly_to_spawn(spawner_turf)
				LAZYREMOVE(spawners, spawner)
				spawner.delete_him()
		if(add)
			i++
			failures = 0
		else if(failures > 100)
			//Ну пиздец, у нас слишком много неуспешных размещений аномалий, хватит пытаться.
			i = result_anomalies_ammout

	//Прописываем себе суицид
	for(var/obj/anomaly_spawner/spawner in spawners)
		if(spawner)
			LAZYREMOVE(spawners, spawner)
			spawner.delete_him()
	QDEL_NULL(src)


/obj/anomaly_spawner/proc/delete_him()
	must_be_deleted = TRUE
	if(!(atom_flags & ATOM_FLAG_INITIALIZED))
		return
	else
		QDEL_NULL(src)

/obj/anomaly_spawner/Initialize()
	.=..()
	if(must_be_deleted)
		QDEL_NULL(src)
		return
