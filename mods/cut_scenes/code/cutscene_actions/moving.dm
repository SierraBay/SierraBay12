/datum/cutscene_action/move
	//Куда двигается
	var/moving_dir = NORTH
	//Кто двигается
	var/actor_key

/datum/cutscene_action/move/New(input_actor_key, input_dir)
	moving_dir = input_dir
	actor_key = input_actor_key

/datum/cutscene_action/move/execute(list/actors_list)
	var/atom/movable/movabler = actors_list[actor_key] // Получаем реальный объект по ключу
	if(movabler)
		var/turf/get_next_turf = get_step(movabler, moving_dir)
		movabler.forceMove(get_next_turf)
		return TRUE
	else
		return FALSE
