/obj/anomaly
	///Процедура выполнения вторичных операций при удалении аномалии выполнена
	var/anomaly_deleting_operation_completed = FALSE

/obj/anomaly/Destroy()
	delete_anomaly()
	.=..()


///Функция НЕ вызывает удаление самой аномалии - оно вызывает вторичные
///Функции по типу удаления вспомогательных частей, удаление из контроллера и т.д
/obj/anomaly/proc/delete_anomaly()
	//Удаление уже выполнено, что-то не тааак
	if(anomaly_deleting_operation_completed)
		return
	SSanom.remove_anomaly_from_cores(src)
	calculate_effected_turfs_from_deleting_anomaly(src)
	if(multitile)
		for(var/obj/anomaly/part in list_of_parts)
			part.Destroy()
	anomaly_deleting_operation_completed = TRUE

/obj/anomaly/part/delete_anomaly()
	if(anomaly_deleting_operation_completed)
		return
	SSanom.remove_anomaly_from_helpers(src)
	anomaly_deleting_operation_completed = TRUE


/obj/anomaly/part/shuttle_land_on()
	core.Destroy()

/obj/anomaly/proc/kill_later(time)
	addtimer(new Callback(src, PROC_REF(call_destroy)), time)

/obj/anomaly/proc/go_sleep(time)
	sleeping = TRUE
	if(time)
		addtimer(new Callback(src, PROC_REF(wake_up)), time)

/obj/anomaly/proc/wake_up()
	sleeping = FALSE

/obj/anomaly/proc/call_destroy()
	Destroy()
