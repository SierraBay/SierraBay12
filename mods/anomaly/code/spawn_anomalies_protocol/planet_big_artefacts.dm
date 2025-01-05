/obj/overmap/visitable/sector/exoplanet
	var/big_anomaly_artefacts_min_amount = 4 //Минимальное количество больших артефактов
	var/big_anomaly_artefacts_max_amount = 6 //Максимальное количество больших артефактов
	var/big_anomaly_artefacts_amount = 0 //Фиксированное количество больших артефактов
	//Какие большие артефакты будут заспавнены
	var/list/big_artefacts_types = list(
		)
	var/big_artefacts_zones_can_overlap = TRUE
	var/big_artefacts_can_be_close = TRUE
	var/big_artefacts_range_spawn = 30

/obj/overmap/visitable/sector/exoplanet/proc/generate_big_anomaly_artefacts()
	set background = 1
	var/started_in = world.time
	var/result_big_artefacts_amount = calculate_result_big_artefacts()

	if(result_big_artefacts_amount <= 0)
		return

	var/list/all_turfs = collect_good_turfs() //Все хорошие турфы на планете

	if(!LAZYLEN(all_turfs)) //если каким-то чудом у нас нет хороших турфов
		log_and_message_admins("ОШИБКА. Аномальная планета не смогла разместить аномальные артефакты.")
		CRASH("ОШИБКА. Аномальная планета не смогла разместить аномальные артефакты.")


	var/i = 1
	var/false_counter = 0
	var/spawned_big_artefacts = 0
	while(i <= result_big_artefacts_amount)

		if(!LAZYLEN(all_turfs))
			break

		var/status = TRUE
		var/turf/picked_turf = pick(all_turfs) //Выбираем турф
		if(!big_artefacts_can_be_close)
			for(var/obj/structure/big_artefact/artefact in range(big_artefacts_range_spawn))
				status = FALSE
				false_counter++
				LAZYREMOVE(all_turfs, picked_turf)
				break

		if(status)
			var/big_artefact_type_for_spawn = pick(big_artefacts_types)
			var/obj/structure/big_artefact/spawned_big_artefact = new big_artefact_type_for_spawn(picked_turf)
			LAZYADD(SSanom.big_anomaly_artefacts,spawned_big_artefact)
			spawned_big_artefacts++

		if(false_counter >= 100)
			break

		i++

	report_progress("Spawned [spawned_big_artefacts]  big anomaly artefacts (Tryed to spawn [result_big_artefacts_amount]) for anomaly planet. Spended [world.time - started_in] ticks ")


/obj/overmap/visitable/sector/exoplanet/proc/collect_good_turfs()
	var/list/temp_list = list()
	for(var/turf/choosed_turf in planetary_area)
		//Фильтруем
		if(!TurfBlocked(choosed_turf) && !TurfBlockedByAnomaly(choosed_turf))
			LAZYADD(temp_list, choosed_turf)
	return temp_list

/obj/overmap/visitable/sector/exoplanet/proc/calculate_result_big_artefacts()
	if(!big_anomaly_artefacts_amount && big_anomaly_artefacts_min_amount && big_anomaly_artefacts_max_amount)
		return rand(big_anomaly_artefacts_min_amount, big_anomaly_artefacts_max_amount)
	else
		return big_anomaly_artefacts_amount
