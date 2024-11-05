//Контроллер передаёт на генерацию спавнеры, находящиеся возле него
/obj/anomaly_spawner
	icon = 'mods/anomaly/icons/spawn_protocol_stuff.dmi'
	icon_state = "none"
	invisibility = INVISIBILITY_OBSERVER
	name = "Просто спавнер аномалий который спавнит аномалии, ахуеть"
	var/list/possible_anomalies = list(
		/obj/anomaly/electra/three_and_three
	)
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
	var/min_artefacts_ammount
	var/max_artefacts_ammount
	//Итоговое число аномалий, которое заспавнит спавнер
	var/result_anomalies_ammout
	var/min_anomaly_size = 1
	//Честно указываем какой минимальный размер аномалий из нашего "набора"
	var/max_anomaly_size = 9

/obj/anomaly_spawner/electra
	name = "Electra spawner"
	icon_state = "electra_spawn"
	possible_anomalies = list(
		/obj/anomaly/electra/three_and_three = 5,
		/obj/anomaly/electra/three_and_three/tesla = 3,
		/obj/anomaly/electra/three_and_three/tesla_second = 1
		)

/obj/anomaly_spawner/zjarka
	name = "Hot spawner"
	icon_state = "zjarka_spawn"
	possible_anomalies = list(
		/obj/anomaly/zjarka = 5,
		/obj/anomaly/zjarka/short_effect = 2,
		/obj/anomaly/zjarka/long_effect = 1,
		/obj/anomaly/heater/three_and_three = 3,
		/obj/anomaly/heater/two_and_two = 5
		)

/obj/anomaly_spawner/commander/Initialize()
	. = ..()
	var/list/all_turfs_for_spawn = list()
	var/started_in = world.time
	//Собираем спавнеры, расположенные у контроллера
	for(var/obj/anomaly_spawner/spawner in orange(15, src.loc))
		LAZYADD(all_turfs_for_spawn, spawner)
	if(!min_artefacts_ammount)
		min_artefacts_ammount = 1
	if(!max_artefacts_ammount)
		max_artefacts_ammount = 1
	generate_anomalies_in_turfs(null, all_turfs_for_spawn, min_anomalies_ammout, max_anomalies_ammout, min_artefacts_ammount, max_artefacts_ammount,min_anomaly_size, max_anomaly_size, "direlict protocol", started_in)

	//Очистка и забытие всех спавнеров.
	for(var/obj/anomaly_spawner/spawner in all_turfs_for_spawn)
		if(spawner)
			LAZYREMOVE(all_turfs_for_spawn, spawner)
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
