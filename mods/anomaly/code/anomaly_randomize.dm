// Шансы и время спавна артефактов расписаны в anomaly\code\artifacts\anomaly_artifact_spawn.dm
//А так же отдельно у каждой аномалии

/obj/anomaly
	///Игра будет рандомить многое в аномалии, если TRUE
	var/ranzomize_with_initialize = FALSE
	var/min_coldown_time = 1 SECONDS
	var/max_coldown_time = 1 SECONDS
	var/min_effect_time = 1 SECONDS
	var/max_effect_time = 1 SECONDS
	//Аномалия может спавниться типа ПРЕДЗАРЯДКА?
	var/can_be_preloaded = FALSE
	//Шанс стать типом ПРЕДЗАРЯДКА при спавне
	var/being_preload_chance = 10
	var/min_preload_time
	var/max_preload_time



/obj/anomaly/proc/ranzomize_parameters()
	cooldown_time = rand(min_coldown_time, max_coldown_time)
	effect_time = rand(min_effect_time, max_effect_time)
	preload_time = rand(min_preload_time, max_preload_time)
	if(can_be_preloaded)
		if(prob(25))
			need_preload = TRUE
		else
			need_preload = FALSE
