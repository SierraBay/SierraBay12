//Данный код отвечает за размещение аномалий по всей планете.
/obj/overmap/visitable/sector/exoplanet/volcanic
	///Спавнятся ли на подобном типе планет аномалии
	can_spawn_anomalies = TRUE
	anomalies_type = list(
		/obj/anomaly/zjarka = 4,
		/obj/anomaly/zjarka/short_effect = 2,
		/obj/anomaly/zjarka/long_effect = 1,
		/obj/anomaly/heater/three_and_three = 3,
		/obj/anomaly/heater/two_and_two = 3
		)
	min_anomalies_ammout = 250
	max_anomalies_ammout = 400
	min_anomaly_size = 1
	max_anomaly_size = 9
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_ELECTRA_ANOMALIES
