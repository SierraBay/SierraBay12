///Выводит описание выбранной конечности
/datum/category_item/player_setup_item/cybernetics/proc/draw_choosed_limb_desc(user, input_list)
	var/result_text
	var/limb_type = pref.limb_list[choosed_limb_slot]
	if(limb_type == "Пусто")
		result_text = "<br><span class='bad'>Конечность останется органической.</span>"
	else
		pref.choosed_limb_prototype = GET_SINGLETON(text2path(limb_type))
		if(!pref.choosed_limb_prototype.check_avaibility(pref)) //Протез/аугмент/имплант недоступен
			result_text = pref.choosed_limb_prototype.get_reason_for_avaibility(pref)
		else if(pref.choosed_limb_prototype && pref.choosed_limb_prototype.aug_description_long)
			result_text = pref.choosed_limb_prototype.aug_description_long
		else
			result_text = "<span class='bad'> КОНДУКТОР, У НАС ПРОБЛЕМЫ!!! Код выкинул неожиданный для своей работы результат и не знает что с вами делать. Сообщите о ошибке разработчику или в #фича-репорт </span>"

	input_list += {"
	<div class='limb-desc-container' style='position: absolute; left: 420px; top: 150px; width: 680px;'>
		[result_text]
	</div>
	"}
