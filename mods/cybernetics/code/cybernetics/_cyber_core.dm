#include "limbs.dm"
#include "augments.dm"
#include "implants.dm"
#include "organs.dm"

/singleton/cyber_choose
	var/augment_name = "Название кибернетики"
	var/aug_description = "Краткое описание кибернетики, выводимое при наведении на него. Не растягивать"
	//Для изменения описания кибернетики требуется изменять только список из трёх особенностей и более ничего. (Шегар, пожалуйста, официальный стиль, а не стиль нижнего интернета. Спасибо. - LordNest)
	var/list/good_sides = list(
		"Первичная хорошая черта",
		"Вторичная хорошая черта",
		"Третичная хорошая черта"
	)
	var/list/neutral_sides = list()
	var/list/bad_sides = list()
	//В результате каких-то умнейших действий, список внизу соберётся из 3 списков сверху
	var/aug_description_long
	//Цена установки кибернетики в очках лодаута
	var/price = 2
	var/list/avaible_hardpoints = list()

/singleton/cyber_choose/proc/setup_description(max_line_length = 60)
	var/list/description_lines = list()

	// Добавляем положительные черты
	if(LAZYLEN(good_sides))
		description_lines += "<hr class='good'>"
		description_lines += "<div class='good' style='margin: 2px 0;'>"
		description_lines += format_list_items(good_sides, max_line_length, "good")
		description_lines += "</div>"

	// Добавляем нейтральные черты
	if(LAZYLEN(neutral_sides))
		description_lines += "<hr class='info'>"
		description_lines += "<div class='neutral' style='margin: 2px 0;'>"
		description_lines += format_list_items(neutral_sides, max_line_length, "info")
		description_lines += "</div>"

	// Добавляем отрицательные черты
	if(LAZYLEN(bad_sides))
		description_lines += "<hr class='bad'>"
		description_lines += "<div class='bad' style='margin: 2px 0;'>"
		description_lines += format_list_items(bad_sides, max_line_length, "bad")
		description_lines += "</div>"

	// Собираем все в одну строку
	aug_description_long = description_lines.Join("")

/singleton/cyber_choose/proc/format_list_items(list/strings, max_length, class_name)
	var/list/formatted_items = list()

	for(var/item in strings)
		// Разбиваем длинные строки на несколько
		var/list/chunks = split_text_by_length(item, max_length)
		for(var/chunk in chunks)
			formatted_items += "<span class='[class_name]'> [chunk] </span>"

	return formatted_items

/singleton/cyber_choose/proc/split_text_by_length(text, max_length)
	var/list/chunks = list()
	var/current_pos = 1
	var/text_length = LAZYLEN(text)

	while(current_pos <= text_length)
		var/chunk_end = min(current_pos + max_length - 1, text_length)
		// Не разбиваем слова посередине
		if(chunk_end < text_length && text[chunk_end+1] != " ")
			var/last_space = findlasttext(text, " ", chunk_end)
			if(last_space > current_pos)
				chunk_end = last_space - 1

		chunks += copytext(text, current_pos, chunk_end + 1)
		current_pos = chunk_end + 1

	return chunks

/singleton/cyber_choose/Initialize()
	setup_description(100)
	..()

// subtypesof(/datum/augment_choose)

/singleton/cyber_choose/proc/check_avaibility(datum/preferences/input_pref)
	return TRUE

/singleton/cyber_choose/proc/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Возникла непредвиденная ошибка. Пожалуйста, обратитесь к разработчикам")

/datum/controller/subsystem/character_setup/Initialize(start_uptime)
	.=..()
	var/list/augs = subtypesof(/singleton/cyber_choose)
	for(var/aug_type in augs)
		var/singleton/cyber_choose/spawned_aug_data = new aug_type
		spawned_aug_data.Initialize()
