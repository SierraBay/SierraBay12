#define LEVEL_IMPOTENT 1
#define LEVEL_ACTIVE 2
#define LEVEL_ANGRY 3

/datum/planet_storyteller
	// Данные о каждом уровне
	var/list/rage_levels = list(
		LEVEL_IMPOTENT = list(
			name = "impotent",
			point_regeneration_time = 5 MINUTES,
			upgrade_cost = 200,
			min_points = 0,
			// Параметры генерации
			evolution_points = 0.1,
			scam_points = 4,
			anomaly_points = 0,
			mob_points = 0
		),
		LEVEL_ACTIVE = list(
			name = "active",
			point_regeneration_time = 3 MINUTES,
			upgrade_cost = 500,
			min_points = 200,
			// Параметры генерации
			evolution_points = 2,
			scam_points = 10,
			anomaly_points = 5,
			mob_points = 5
		),
		LEVEL_ANGRY = list(
			name = "angry",
			point_regeneration_time = 1.5 MINUTES,
			upgrade_cost = null,
			min_points = 500,
			// Параметры генерации
			evolution_points = 0,
			scam_points = 50,
			anomaly_points = 50,
			mob_points = 25
		)
	)

	/// Текущий уровень активности рассказчика (индекс)
	var/current_angry_level = LEVEL_IMPOTENT
	/// Текущее название уровня
	var/current_level_name = "impotent"

/// Проверяет и выполняет повышение уровня, учитывая все возможные переходы
/datum/planet_storyteller/proc/check_level_up()
	var/max_possible_level = get_max_possible_level()
	if(current_angry_level >= max_possible_level)
		return

	// Повышаем уровень и сбрасываем очки
	current_angry_level = max_possible_level
	current_level_name = rage_levels[current_angry_level]["name"]
	current_evolution_points = rage_levels[current_angry_level]["min_points"]
	log_in_general("Режисёр получил повышение уровня. Текущий уровень - [current_level_name]")

/// Возвращает максимальный возможный уровень, который можно получить с текущими очками
/datum/planet_storyteller/proc/get_max_possible_level()
	var/max_level = current_angry_level
	var/points = current_evolution_points

	// Проверяем последовательно все уровни выше текущего
	for(var/i = current_angry_level + 1 to LAZYLEN(rage_levels))
		var/required_points = rage_levels[i]["min_points"]
		if(points >= required_points)
			max_level = i
		else
			break

	return max_level

/// Устанавливает уровень рассказчика и сбрасывает очки эволюции
/datum/planet_storyteller/proc/set_rage_level(new_level)
	if(new_level < LEVEL_IMPOTENT || new_level > LEVEL_ANGRY)
		CRASH("Попытка установить недопустимый уровень агрессии: [new_level]")
	current_angry_level = new_level
	current_level_name = rage_levels[new_level]["name"]
	current_evolution_points = rage_levels[new_level]["min_points"]
	log_in_general("Установлен уровень режисёра: [current_level_name]")
