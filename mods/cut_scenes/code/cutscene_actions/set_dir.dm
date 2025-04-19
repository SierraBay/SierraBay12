/datum/cutscene_action/set_dir
	//Куда двигается
	var/new_dir = NORTH
	//Кто двигается
	var/actor_key

/datum/cutscene_action/set_dir/New(input_actor_key, input_new_dir)
	new_dir = input_new_dir
	actor_key = input_actor_key

/datum/cutscene_action/set_dir/execute(list/actors_list)
	var/atom/setting_dir = actors_list[actor_key] // Получаем реальный объект по ключу
	if(setting_dir)
		setting_dir.set_dir(new_dir)
		return TRUE
	else
		return FALSE
