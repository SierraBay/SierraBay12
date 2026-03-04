/**
 * Trait: Stutter (заикание)
 * Поддерживает кириллицу и латиницу. С 25% вероятностью
 * для каждого слова первая буква (или диграф ch/th/sh) повторяется:
 *   "Привет" → "П-Привет", "ПРИВЕТ" → "П-ПРИВЕТ", "hello" → "h-hello"
 */

/mob/living
	var/has_stutter_trait = FALSE

// Пропускаем, если уже активна другая речевая проблема (заикание/невнятность)
/mob/living/handle_speech_problems(list/message_data)
	. = ..()
	if(has_stutter_trait && !.)
		message_data[1] = stutter_trait_filter(message_data[1])
		. = 1

/**
 * Применяет заикание к строке:
 * с 25% вероятностью на каждое слово добавляет повтор первого звука.
 * Регистр сохраняется: "Слово" → "С-Слово", "СЛОВО" → "С-СЛОВО"
 */
/proc/stutter_trait_filter(phrase)
	phrase = html_decode(phrase)
	var/list/words = splittext(phrase, " ")
	for(var/i = 1, i <= length(words), i++)
		if(!prob(25))
			continue
		var/word = words[i]
		if(!length_char(word))
			continue
		// Проверяем диграфы (ch, th, sh) -- для латиницы
		var/first_sound = copytext_char(word, 1, 3)
		var/first_letter = copytext_char(word, 1, 2)
		if(lowertext(first_sound) in list("ch", "th", "sh"))
			first_letter = first_sound
		words[i] = "[first_letter]-[word]"
	return sanitize(jointext(words, " "))

// ====== Датум трейта ======

/datum/mod_trait/all/stutter_trait
	name = "Speech - Stutter"
	description = "Персонаж заикается: с 25% вероятностью первый звук каждого слова повторяется при речи."

/datum/mod_trait/all/stutter_trait/apply_trait(mob/living/carbon/human/H)
	H.has_stutter_trait = TRUE
	to_chat(H, SPAN_NOTICE("Активирована черта персонажа <b>[name]</b>."))
