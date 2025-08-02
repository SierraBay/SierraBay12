/datum/category_item/player_setup_item/cybernetics/OnTopic(href,list/href_list, mob/user)
	//В зависимости от того какие кнопки мы нажали из тех что в меню (Верхняя часть Кибернетики)
	//Мы и реагируем и сменяем тэг
	//ВЕРХНИЕ КНОПКИ
	if(href_list["limbs"])
		current_tab = "Протезирование"
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["organs"])
		current_tab = "Внутренние органы"
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["implants"])
		current_tab = "Импланты тела"
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["augments"])
		current_tab = "Аугменты"
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["СБРОС"])
		var/answer = input(usr, "Ты уверен? Сброшено будет вообще всё, протезы, аугменты, органы и импланты. Для подтверждения, введи имя своего персонажа: [pref.real_name])")
		if(answer == pref.real_name)
			wipe_all()
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["organ"])
		organ_button_pressed(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["select_organ"])
		organ_select_button_pressed(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["limb"])
		limbs_button_pressed(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["select_limb"])
		limb_select_button_pressed(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["set_limbs_corporation"])
		limb_set_corporation(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["augment"])
		augment_button_pressed(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["select_augment"])
		augment_select_button_pressed(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["set_augment_name"])
		augment_set_name(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["set_augment_desc"])
		augment_set_desc(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	
	else if(href_list["implant"])
		implant_button_pressed(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["submit_implant"])
		implant_sumbition_pressed(user, href_list)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	return TOPIC_REFRESH_UPDATE_PREVIEW
