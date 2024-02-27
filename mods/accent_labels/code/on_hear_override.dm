/mob/hear_say(message, verb = "says", datum/language/language, alt_name, italics, mob/speaker, sound/speech_sound, sound_vol)
	verb = "[get_accent_tag(speaker)] [verb]"
	. = ..(message, verb, language, alt_name, italics, speaker, speech_sound, sound_vol)
