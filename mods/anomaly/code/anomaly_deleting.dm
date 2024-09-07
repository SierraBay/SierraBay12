//В данном файле располагается код отвечающий за удаление аномалий из мира


/obj/anomaly/shuttle_land_on()
	delete_anomaly()

/obj/anomaly/proc/delete_anomaly()
	SSanom.remove_anomaly_from_list(src)
	calculate_effected_turfs_from_deleting_anomaly(src)
	if(multitile)
		for(var/obj/anomaly/part in list_of_parts)
			part.delete_anomaly()
	qdel(src)

/obj/anomaly/part/delete_anomaly()
	qdel(src)


/obj/anomaly/part/shuttle_land_on()
	core.delete_anomaly()

/obj/anomaly/proc/kill_later(time)
	addtimer(new Callback(src, PROC_REF(delete_anomaly)), time)
