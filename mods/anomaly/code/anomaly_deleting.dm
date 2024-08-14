/obj/anomaly/shuttle_land_on()
	delete_anomaly()

/obj/anomaly/proc/delete_anomaly()
	if(multitile)
		for(var/obj/anomaly/part in list_of_parts)
			qdel(part)
	qdel(src)

/obj/anomaly/part/shuttle_land_on()
	core.delete_anomaly()

/obj/anomaly/proc/kill_later(time)
	addtimer(new Callback(src, PROC_REF(delete_anomaly)), time)
