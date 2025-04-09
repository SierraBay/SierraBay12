//Функции сбора обьектов вокруг
/proc/get_anomalies_in_view_fast(turf/T, range, list/anomalies, checkghosts = null)

	var/list/hear = list()
	DVIEW(hear, range, T, INVISIBILITY_MAXIMUM)
	var/list/hearturfs = list()

	for(var/atom/movable/AM in hear)
		if(isanomaly(AM))
			hearturfs += get_turf(AM)

	for(var/obj/anomaly/detected_anomaly in SSanom.all_anomalies_cores)
		if(get_turf(detected_anomaly) in hearturfs)
			LAZYADD(anomalies, detected_anomaly)

	for(var/obj/anomaly/picked_anomaly in anomalies) //Очистим от списка аномалий второстепенные части.
		if(!picked_anomaly.is_helper)
			LAZYREMOVE(anomalies, picked_anomaly.list_of_parts)
