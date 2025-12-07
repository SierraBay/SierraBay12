//Данный код отвечает за размещение аномалий по всей планете.
/obj/overmap/visitable/sector/exoplanet
	///Спавнятся ли на подобном типе планет аномалии
	var/can_spawn_anomalies = FALSE
	var/list/anomalies_types = list(
		)
	///Минимальное количество заспавненных артов
	var/min_artefacts_ammount = 4
	///Максимальное количество заспавненных артов
	var/max_artefacts_ammount = 8

	var/min_anomalies_ammount = 40
	var/max_anomalies_ammount = 100
	var/storyteller_path
	var/datum/planet_storyteller/storyteller

/obj/overmap/visitable/sector/exoplanet/build_level()
	generate_atmosphere()
	for (var/datum/exoplanet_theme/T in themes)
		T.adjust_atmosphere(src)
	if (exterior_atmosphere)
		//Set up gases for living things
		if (!length(breathgas))
			var/list/goodgases = exterior_atmosphere.gas.Copy()
			var/gasnum = min(rand(1,3), length(goodgases))
			for (var/i = 1 to gasnum)
				var/gas = pick(goodgases)
				breathgas[gas] = round(0.4*goodgases[gas], 0.1)
				goodgases -= gas
		if (!badgas)
			var/list/badgases = gas_data.gases.Copy()
			badgases -= exterior_atmosphere.gas
			badgas = pick(badgases)
	generate_flora()
	generate_map()
	generate_features()
	for (var/datum/exoplanet_theme/T in themes)
		T.after_map_generation(src)
	//Спавним аномалии
	if(LAZYLEN(big_artefacts_types))
		generate_big_anomaly_artefacts()
	planetary_area.deploy_new_weather_manager(weather_manager_type, deploy_weather = TRUE)
	if(storyteller_path)
		deploy_storyteller()
	//Если у планеты есть погода - спавним погоду
	generate_landing(2)
	update_biome()
	generate_daycycle()
	generate_planet_image()
	if(ispath(initial_weather_state))
		generate_weather()
	START_PROCESSING(SSobj, src)
	generate_anomalies()
