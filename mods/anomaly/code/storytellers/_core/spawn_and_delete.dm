// Задача сторителлера - держать посетителей планеты в напряжении.
// Его уровень активности (накала) растет в зависимости от активности и прогресса ЭК
/datum/planet_storyteller
	var/area/my_area
	var/list/my_z = list()

/datum/planet_storyteller/New(obj/overmap/visitable/sector/exoplanet/input_planet, area/input_area)
	if(input_planet)
		my_area = input_planet.planetary_area
		my_z = input_planet.map_z
	else if(input_area)
		my_area = input_area
		LAZYADD(my_z, get_z(pick(input_area.contents)))
	SSanom.add_storyteller(src)
	calculate_activity_check()
	START_PROCESSING(SSanom, src)
	log_in_general("Рассказчик [src] успешно запущен")

/datum/planet_storyteller/proc/delete_storyteller()
	SSanom.remove_storyteller(src)

/obj/overmap/visitable/sector/exoplanet/proc/deploy_storyteller()
	storyteller = new storyteller_path(src)
