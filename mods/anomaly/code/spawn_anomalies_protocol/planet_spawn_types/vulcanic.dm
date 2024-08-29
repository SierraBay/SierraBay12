//Данный код отвечает за размещение аномалий по всей планете.
/obj/overmap/visitable/sector/exoplanet/volcanic
	///Спавнятся ли на подобном типе планет аномалии
	can_spawn_anomalies = TRUE
	anomalies_type = list(
		/obj/anomaly/zjarka,
		/obj/anomaly/zjarka/short_effect,
		/obj/anomaly/zjarka/long_effect,
		/obj/anomaly/heater/three_and_three,
		/obj/anomaly/heater/two_and_two
		)
	min_anomalies_ammout = 250
	max_anomalies_ammout = 400
	min_anomaly_size = 1
	max_anomaly_size = 9
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_ELECTRA_ANOMALIES
