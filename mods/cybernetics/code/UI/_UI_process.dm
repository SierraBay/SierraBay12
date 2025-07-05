/datum/category_item/player_setup_item/cybernetics/OnTopic(href,list/href_list, mob/user)
	//В зависимости от того какие кнопки мы нажали из тех что в меню (Верхняя часть Кибернетики)
	//Мы и реагируем и сменяем тэг
	if(href_list["limbs"])
		current_tab = "Протезирование"
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["organs"])
		current_tab = "Внутренние органы"
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["implants"])
		current_tab = "Импланты тела"
		return TOPIC_REFRESH_UPDATE_PREVIEW
	return TOPIC_REFRESH_UPDATE_PREVIEW
