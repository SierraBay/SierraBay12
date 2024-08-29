//В данном файле располагается код отвечающий за удаление аномалий из мира


/obj/anomaly/shuttle_land_on()
	delete_anomaly()

/obj/anomaly/proc/delete_anomaly()
	if(!detectable_effect_range)
		return
	if(multitile)
		for(var/obj/anomaly/part in list_of_parts)
			if(AnomaliesAmmountInTurf(part.loc) == 1)
				var/turf/part_turf = get_turf(part)
				part_turf.in_anomaly_effect_range = FALSE
			qdel(part)
	if(AnomaliesAmmountInTurf(src.loc) == 1)
		var/turf/part_turf = get_turf(src)
		part_turf.in_anomaly_effect_range = FALSE
	qdel(src)

/obj/anomaly/part/shuttle_land_on()
	core.delete_anomaly()

/obj/anomaly/proc/kill_later(time)
	addtimer(new Callback(src, PROC_REF(delete_anomaly)), time)
