/obj/anomaly/circus/process_long_effect()
	start_processing_long_effect()

	// Добавляем все объекты на аномалию
	for(var/atom/movable/AM in get_turf(src))
		if(can_be_activated(AM))
			add_victim(AM)

	// Для многотайловых аномалий
	if(multitile)
		for(var/obj/anomaly/part/part in list_of_parts)
			for(var/atom/movable/AM in get_turf(part))
				if(can_be_activated(AM))
					add_victim(AM)
