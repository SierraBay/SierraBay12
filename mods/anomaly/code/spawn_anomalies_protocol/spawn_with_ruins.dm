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
	var/min_anomalies_ammount = 10
	///Максимальное количество аномалий, которое заспавнит главный спавнер
	var/max_anomalies_ammount = 20
	var/min_artefacts_ammount
	var/max_artefacts_ammount

/obj/anomaly_spawner/electra
	name = "Electra spawner"
	icon_state = "electra_spawn"
	possible_anomalies = list(
		/obj/anomaly/electra/three_and_three = 5,
		/obj/anomaly/electra/three_and_three/tesla = 3,
		/obj/anomaly/electra/three_and_three/tesla_second = 1
		)

/obj/anomaly_spawner/Zharka
	name = "Hot spawner"
	icon_state = "zharka_spawn"
	possible_anomalies = list(
		/obj/anomaly/zharka = 5,
		/obj/anomaly/zharka/short_effect = 2,
		/obj/anomaly/zharka/long_effect = 1,
		/obj/anomaly/heater/multisize = 5,
		)

/obj/anomaly_spawner/commander/Initialize()
	. = ..()
	var/list/all_turfs_for_spawn = list()
	//Собираем спавнеры, расположенные у контроллера
	for(var/obj/anomaly_spawner/spawner in orange(15, src.loc))
		LAZYADD(all_turfs_for_spawn, spawner)
	generate_anomalies_in_turfs(
		anomalies_types = possible_anomalies,
		all_turfs_for_spawn = all_turfs_for_spawn,
		min_anomalies_ammount = 10,
		max_anomalies_ammount = 20,
		min_artefacts_ammount = 0,
		max_artefacts_ammount = 0,
		source =  "планетарная руина",
		visible_generation = FALSE,
		started_in = world.time)

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
