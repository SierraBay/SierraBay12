/datum/cutscene_action/say
	//Что говорят
	var/message
	//Кто говорит
	var/actor_key

/datum/cutscene_action/say/New(input_actor_key, input_message)
	message = input_message
	actor_key = input_actor_key

/datum/cutscene_action/say/execute(list/actors_list)
	var/atom/speaker = actors_list[actor_key] // Получаем реальный объект по ключу
	if(speaker && message)
		speaker.runechat_message(message)
		speaker.visible_message(message = message, range = 7)
		return TRUE
	else
		return FALSE
