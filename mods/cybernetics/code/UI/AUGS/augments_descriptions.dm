///Выводит описание выбранного аугмента
/datum/category_item/player_setup_item/cybernetics/proc/draw_choosed_augment_desc(mob/user, list/input_list)
	var/result_text
	var/aug_type = pref.augments_list[choosed_augment_slot]
	if(aug_type == "Пусто")
		result_text = "<br><span class='bad'>Аугмент не выбран</span>"
	else
		pref.choosed_augment_prototype = GET_SINGLETON(text2path(aug_type))
		if(pref.augments_names[choosed_augment_slot] != "Пусто")
			result_text += SPAN_CLASS("highlight", "Уникальное название: [pref.augments_names[choosed_augment_slot]]")
		else
			result_text += SPAN_CLASS("highlight", "[pref.choosed_augment_prototype.augment_name]")


		if(pref.augments_descs[choosed_augment_slot] != "Пусто")
			result_text += SPAN_CLASS("highlight", " <br> Уникальное описание: [pref.augments_descs[choosed_augment_slot]]")

		if(pref.choosed_augment_prototype && pref.choosed_augment_prototype.aug_description_long)
			result_text += pref.choosed_augment_prototype.aug_description_long
		else
			result_text = "<span class='bad'> КОНДУКТОР, У НАС ПРОБЛЕМЫ!!! Код выкинул неожиданный для своей работы результат и не знает что с вами делать. Сообщите о ошибке разработчику или в #фича-репорт </span>"

	// Кастомизация
		var/custom_buttons = ""
		if(pref.choosed_augment_prototype.custom_name_avaible)
			custom_buttons += {"
			<a href='?src=\ref[src];set_augment_name=1'
				class='augment-button'
				style='display: inline-block; width: 200px; left: 110px'
				title='Позволяет выставить уникальное название аугменту'>
				Уникальное название
			</a>
			"}

		if(pref.choosed_augment_prototype.custom_desc_avaible)
			custom_buttons += {"
			<a href='?src=\ref[src];set_augment_desc=1'
				class='augment-button'
				style='display: inline-block; width: 200px;'
				title='Позволяет выставить уникальное описание аугменту'>
				Уникальное описание
			</a>
			"}

		if(custom_buttons != "")
			result_text += "<div style='margin-top: 20px;'>[custom_buttons]</div>"


	input_list += {"
	<div class='augment-desc-container' style='position: absolute; left: 420px; top: 150px; width: 680px;'>
		[result_text]
	</div>
	"}

/datum/category_item/player_setup_item/cybernetics/proc/augment_set_name(mob/user)
	var/input_name = input(user, "Введите уникальное название (Если оставить пустым, название сотрётся):", "Название аугмента") as text|null
	if(input_name)
		pref.augments_names[choosed_augment_slot] = input_name
	else
		pref.augments_names[choosed_augment_slot] = "Пусто"

/datum/category_item/player_setup_item/cybernetics/proc/augment_set_desc(mob/user)
	var/input_desc = input(user, "Введите уникальное описание (Если оставить пустым, описание сотрётся):", "Описание аугмента") as message|null
	if(input_desc)
		pref.augments_descs[choosed_augment_slot] = input_desc
	else
		pref.augments_descs[choosed_augment_slot] = "Пусто"
