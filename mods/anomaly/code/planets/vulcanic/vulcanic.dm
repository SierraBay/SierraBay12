/obj/overmap/visitable/sector/exoplanet/volcanic/anomaly
	name = "anomaly volcanic exoplanet"
	desc = "WARNING: high anomaly activity detected. A tectonically unstable planet, extremely rich in minerals."
	can_spawn_anomalies = TRUE
	anomalies_types = list(
		/obj/anomaly/zharka = 5,
		/obj/anomaly/zharka/short_effect = 3,
		/obj/anomaly/zharka/long_effect = 1
		)
	big_artefacts_types = list(
		/obj/structure/big_artefact/hot
		)
	///Минимальное количество заспавненных артов
	min_artefacts_ammount = 2
	///Максимальное количество заспавненных артов
	max_artefacts_ammount = 4
	big_anomaly_artefacts_min_amount = 1
	big_anomaly_artefacts_max_amount = 2
	min_anomalies_ammount = 100
	max_anomalies_ammount = 300
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_ELECTRA_ANOMALIES|RUIN_GRAVI_ANOMALIES|RUIN_CHUDO_ANOMALIES
