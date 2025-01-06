/datum/language/simpskrell
	name = LANGUAGE_SIMPSKRELLIAN
	desc = "A simplified interpretation of skrellian language, designed specifically to be spoken by humans."
	speech_verb = "warbles"
	ask_verb = "warbles"
	exclaim_verb = "warbles"
	colour = "skrell"
	key = "&"
	syllables = list("qr","krr","xuq","qil","kvuum","ksum","vol","xrim","zaoo","ku-uu","kvix","qoo","zix","kzh")
	shorthand = "sSK"
	has_written_form = TRUE
	partial_understanding = list(LANGUAGE_SKRELLIAN = 80)

/datum/language/skrell/New()
	. = ..()
	partial_understanding += list(LANGUAGE_SIMPSKRELLIAN = 90)

/datum/language/primtajaran
	name = LANGUAGE_SIMPTAJARAN
	desc = "A crude and simplified interpretation of tajaran language spoken by humans."
	speech_verb = "мурчит"
	ask_verb = "мурчит"
	exclaim_verb = "воет"
	colour = "tajaran"
	key = "?"
	syllables = list("mrr","rr","tajr","kir","raj","kii","mir","kra","ahk","nal","vah","khaz","jri","ran","darr",
	"mi","jri","dynh","manq","rhe","zar","rrhaz","kal","chur","eech","taa","dra","ju-rl","mah","sanu","dra","ii'r",
	"ka","aasi","far","wa","baq","ara","qara","zir","sam","mak","hrar","nga","rir","khan","gun","dar","rik","kah",
	"hal","ket","jurl","mah","tul","cresh","azu","ragh","mro","mra","mrro","mrra")
	shorthand = "sTJ"
	has_written_form = TRUE
	partial_understanding = list(LANGUAGE_SIIK_MAAS = 80)

/datum/language/tajaran/New()
	. = ..()
	partial_understanding += list(LANGUAGE_SIMPTAJARAN = 90)

/datum/language/simpunathi
	name = LANGUAGE_SIMPUNATHI
	desc = "A derivative of Sinta'Unathi, this language has been created specifically to be spoken by humans. Vocal sounds and limb gestures that cannot be properly replicated by humans have been replaced with Iberian vowels. Iber'Unathi is primarily used by denizens of the Tersten Republic."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "roars"
	colour = "soghun"
	key = "!"
	space_chance = 40
	syllables = list(
		"za", "az", "ze", "ez", "zi", "iz", "zo", "oz", "zu", "uz", "zs", "sz",
		"ha", "ah", "he", "eh", "hi", "ih", "ho", "oh", "hu", "uh", "hs", "sh",
		"la", "al", "le", "el", "li", "il", "lo", "ol", "lu", "ul", "ls", "sl",
		"ka", "ak", "ke", "ek", "ki", "ik", "ko", "ok", "ku", "uk", "ks", "sk",
		"sa", "as", "se", "es", "si", "is", "so", "os", "su", "us", "ss", "ss",
		"ra", "ar", "re", "er", "ri", "ir", "ro", "or", "ru", "ur", "rs", "sr",
		"a",  "a",  "e",  "e",  "i",  "i",  "o",  "o",  "u",  "u",  "s",  "s"
	)
	shorthand = "iUT"
	has_written_form = TRUE
	partial_understanding = list(LANGUAGE_UNATHI_SINTA = 80, LANGUAGE_UNATHI_YEOSA = 40)

/datum/language/unathi/New()
	. = ..()
	partial_understanding += list(LANGUAGE_SIMPUNATHI = 90, LANGUAGE_UNATHI_YEOSA = 80)

/datum/language/yeosa/New()
	. = ..()
	partial_understanding += list(LANGUAGE_SIMPUNATHI = 60, LANGUAGE_UNATHI_SINTA = 80)

/singleton/cultural_info/culture/human
	secondary_langs = list(
		LANGUAGE_HUMAN_EURO,
		LANGUAGE_HUMAN_CHINESE,
		LANGUAGE_HUMAN_ARABIC,
		LANGUAGE_HUMAN_INDIAN,
		LANGUAGE_HUMAN_IBERIAN,
		LANGUAGE_HUMAN_RUSSIAN,
		LANGUAGE_SPACER,
		LANGUAGE_SIGN,
		LANGUAGE_SIMPTAJARAN
	)
