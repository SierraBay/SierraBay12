
///Функция попытается заспавнить аномалию без коллизии с другими обьектами или аномалиями
/proc/try_spawn_anomaly_without_collision(turf/T, obj/anomaly/path_to_spawn, anomaly_premade_type, anomaly_artefact_type)
	var/obj/anomaly/spawned_anomaly = new path_to_spawn(T)
	var/need_to_delete = FALSE
	var/list/list_of_bad_turfs
	var/list/list_of_bad_anomalies
	for(var/obj/anomaly/part/checked_part in spawned_anomaly.list_of_parts)
		var/anomaly_ammount = 0
		for(var/obj/anomaly/anomalies in checked_part.loc)
			anomaly_ammount++

		if(anomaly_ammount>1 || locate(/obj/structure) in get_turf(checked_part))
			need_to_delete = TRUE
			if(anomaly_premade_type)
				for(var/obj/anomaly_spawner/spawner in T)
					if(!spawner.controller)
						LAZYADD(list_of_bad_anomalies, spawner)

					else if(anomaly_artefact_type)
						LAZYADD(list_of_bad_turfs, get_turf(checked_part))

	//Теперь сносим все наши временные аномалии
	if(need_to_delete)
		for(var/obj/anomaly/part/checked_part in spawned_anomaly.list_of_parts)
			qdel(checked_part)
		qdel(spawned_anomaly)
		if(anomaly_premade_type)
			return list_of_bad_anomalies
		else
			return list_of_bad_turfs
	//значит нам НЕ нужно удалять, передадим FALSE
	else
		spawned_anomaly.try_born_artifact()
		return TRUE
