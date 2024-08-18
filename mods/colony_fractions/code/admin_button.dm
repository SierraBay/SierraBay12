/datum/admins/proc/map_template_colony_spawn_settings()
	set category = "Fun"
	set desc = "Choose, which type will be next spawned colony."
	set name = "Map Template - Colony spawn settings"

	if(!check_rights(R_SPAWN))
		return
	var/list/options = list("Выбор типа следующей колонии", "Поведение при ошибке", "Вывести текущий тип")
	var/choose = input(usr, "Выберите, какой параметр требуется в настройке","Выберите настройку") as null|anything in options
	if(!choose)
		return
	else if(choose == "Выбор типа следующей колонии")
		var/list/types = list("ГКК","ЦПСС","НАНОТРЕЙЗЕН","НЕЗАВИСИМАЯ", "СЛУЧАЙНЫЙ")
		GLOB.choose_colony_type = input(usr, "Выберите, какой тип колонии будет при следующем спавне","Выберите тип колонии") as null|anything in types
		if (!GLOB.choose_colony_type)
			GLOB.choose_colony_type = "СЛУЧАЙНЫЙ"
		log_and_message_admins("выбрал тип колонии: [GLOB.choose_colony_type] как следующий тип колонии при её спавне.")
	else if(choose == "Поведение при ошибке")
		var/list/variants = list("Игнорировать", "Прервать спавн колонии")
		GLOB.error_colony_reaction = input(usr, "Выберите, как будет реагировать код на ошибку при выборе типа колонии","Выберите вариант действия") as null|anything in variants
		log_and_message_admins("выбрал поведение: [GLOB.error_colony_reaction] при ошибке спавна колонии.")
	else if(choose == "Вывести текущий тип")
		to_chat(usr, "Последний ЗАСПАВНЕННЫЙ тип: [GLOB.last_colony_type], последний ВЫБРАННЫЙ тип:[GLOB.choose_colony_type]")
