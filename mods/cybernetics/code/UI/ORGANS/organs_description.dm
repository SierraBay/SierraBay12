///Выводит описание выбранного органа
/datum/category_item/player_setup_item/cybernetics/proc/draw_choosed_organ_desc(user, input_list)
	var/result_text
	var/organ_type = pref.organ_list[choosed_organ_slot]
	if(organ_type == "Пусто")
		result_text = "<br> <span class='bad'> Кибернетический орган не выбран, будет выбран самый обычный биологический. </span>"
	else
		pref.choosed_organ_prototype = GET_SINGLETON(text2path(organ_type))
		if(pref.choosed_organ_prototype && pref.choosed_organ_prototype.aug_description_long)
			result_text = pref.choosed_organ_prototype.aug_description_long
		else
			result_text = "<span class='bad'> КОНДУКТОР, У НАС ПРОБЛЕМЫ!!! Код выкинул неожиданный для своей работы результат и не знает что с вами делать. Сообщите о ошибке разработчику или в #фича-репорт </span>"

	input_list += {"
	<div class='organ-desc-container' style='position: absolute; left: 600px; top: 150px; width: 400px;'>
		[result_text]
	</div>
	"}
