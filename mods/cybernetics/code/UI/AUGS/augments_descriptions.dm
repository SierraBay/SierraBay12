///Выводит описание выбранного аугмента
/datum/category_item/player_setup_item/cybernetics/proc/draw_choosed_augment_desc(user, input_list)
	var/result_text
	var/aug_type = pref.augments_list[choosed_augment_slot]
	if(aug_type == "Пусто")
		result_text = "<br><span class='bad'>Аугмент не выбран</span>"
	else
		pref.choosed_augment_prototype = GET_SINGLETON(text2path(aug_type))
		if(pref.choosed_augment_prototype && pref.choosed_augment_prototype.aug_description_long)
			result_text = pref.choosed_augment_prototype.aug_description_long
		else
			result_text = "<span class='bad'> КОНДУКТОР, У НАС ПРОБЛЕМЫ!!! Код выкинул неожиданный для своей работы результат и не знает что с вами делать. Сообщите о ошибке разработчику или в #фича-репорт </span>"

	input_list += {"
	<div class='augment-desc-container' style='position: absolute; left: 600px; top: 150px; width: 400px;'>
		[result_text]
	</div>
	"}
