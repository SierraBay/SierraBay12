/*У кат сцен есть определённые команды, как глобальные, так и для определённых обьектов, которые рассписываются списком
Сон [Длительность] - Вся кат сцена спит указанное время
*/

/datum/cut_scene
	//Сущности что будут учавстсовать в кат сцене
	var/list/actors = list()
	//Тут мы добавляем /datum/cutscene_action в каждую строку
	var/list/actions_list = list()
	var/my_landmark
	var/time_between_actions = 0.2 SECONDS
	var/delete_everyone_after_playing = FALSE

/datum/cut_scene/proc/start_cutscene(turf/input_turf)
	for(var/key in actors)
		var/list/actor_data = actors[key]
		var/mob_type = actor_data["type"]
		var/x_offset = actor_data["x_offset"] // Оффсет по X
		var/y_offset = actor_data["y_offset"] // Оффсет по Y
		var/turf/spawn_point = locate(input_turf.x + x_offset, input_turf.y + y_offset, input_turf.z)
		if(mob_type && spawn_point)
			var/mob/new_actor = new mob_type(spawn_point) // Создаём моба на точке спавна
			actors[key] = new_actor // Заменяем данные на созданный объект

	for(var/datum/cutscene_action/picked_action in actions_list)
		picked_action.execute(actors)
		sleep(time_between_actions)
	if(delete_everyone_after_playing)
		for(var/key in actors)
			var/atom/picked_atom = actors[key]
			if(istype (picked_atom, /obj/sctructure/titan_ghost))
				var/obj/sctructure/titan_ghost/picked_ghost = picked_atom
				picked_ghost.delete_ghost()
			else
				qdel(picked_atom)
	qdel(my_landmark)
	qdel(src)
