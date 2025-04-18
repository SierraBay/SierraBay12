// Задача сторителлера - держать посетителей планеты в напряжении.
// Его уровень активности (накала) растет в зависимости от активности и прогресса ЭК
/datum/planet_storyteller
	var/list/rages_levels = list(
		"impotent" = list(level = 0, point_regeneration_time = 20 SECONDS),
		"active" = list(level = 1, point_regeneration_time = 10 SECONDS),
		"angry" = list(level = 2, point_regeneration_time = 5 SECONDS)
	)

	var/list/rages_levels_changes_prices = list(
		200,	// Цена перехода от impotent к active
		500	 // Цена перехода от active к angry
	)
	/// Текущий уровень активности рассказчика (индекс)
	var/current_angry_level = 1
	/// Текущее название уровня
	var/current_level_name = "impotent"
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
