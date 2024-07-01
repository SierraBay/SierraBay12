/datum/admins/proc/map_template_choose_colony_type()
	set category = "Fun"
	set desc = "Choose, which type will be next spawned colony."
	set name = "Map Template - Choose colony type"

	if(!check_rights(R_SPAWN))
		return

	var/list/types = list("ГКК","ЦПСС","НАНОТРЕЙЗЕН","НЕЗАВИСИМАЯ", "СЛУЧАЙНЫЙ")
	GLOB.choose_colony_type = input(usr, "Выберите, какой тип колонии будет при следующем спавне","Выберите тип колонии") as null|anything in types
	if (!GLOB.choose_colony_type)
		GLOB.choose_colony_type = "СЛУЧАЙНЫЙ"
	log_and_message_admins("выбрал тип колонии: [GLOB.choose_colony_type] как следующий тип колонии при её спавне.")
