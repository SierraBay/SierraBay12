/mob/living/carbon/human
	var/trait_stutter = FALSE

/mob/living/carbon/human/handle_speech_problems(list/message_data)
	. = ..()
	if(trait_stutter && !.)
		message_data[1] = stutter_trait_filter(message_data[1])
		return TRUE

/mob/proc/stutter_trait_filter(phrase)
	phrase = html_decode(phrase)
	var/list/words = splittext(phrase, " ")
	for(var/i = 1, i <= length(words), i++)
		if(!prob(25))
			continue
		var/word = words[i]
		if(!length_char(word))
			continue
		var/first_sound = copytext_char(word, 1, 3)
		var/first_letter = copytext_char(word, 1, 2)
		if(lowertext(first_sound) in list("ch", "th", "sh"))
			first_letter = first_sound
		words[i] = "[first_letter]-[word]"
	return sanitize(jointext(words, " "))

/datum/mod_trait/all/stutter_trait
	name = "Speech - Stutter"
	description = "Персонаж заикается: с 25% вероятностью первый звук каждого слова повторяется при речи."

/datum/mod_trait/all/stutter_trait/apply_trait(mob/living/carbon/human/H)
	H.trait_stutter = TRUE
