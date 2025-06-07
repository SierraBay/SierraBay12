/datum/language/diona
	name = LANGUAGE_ROOTLOCAL
	desc = "Сложный язык, который Дионея инстинктивно понимает, \"разговаривая\" с помощью модулированных радиоволн. В этой версии используются высокочастотные волны для быстрой связи на коротких расстояниях"
	speech_verb = "скрипит и шуршит"
	ask_verb = "скрипит"
	exclaim_verb = "шуршит"
	colour = "iehib"
	key = "q"
	flags = RESTRICTED
	syllables = list("hs","zt","kr","st","sh")
	shorthand = "RT"
	machine_understands = FALSE

/datum/language/diona/global
	name = LANGUAGE_ROOTGLOBAL
	desc = "Сложный язык, который Дионея инстинктивно понимает, \"разговаривая\" с помощью модулированных радиоволн. В этой версии используются низкочастотные волны для медленной связи на больших расстояниях."
	key = "w"
	flags = RESTRICTED | HIVEMIND
	shorthand = "N/A"

 //AUTOHISS
/singleton/species/diona
	autohiss_basic_map = list(
			"а" = list("а-а-а"),
			"о" = list("о-о-о"),
		)
	autohiss_extra_map = list(
			"а" = list("а-а-а"),
			"о" = list("о-о-о"),
			"у" = list("у-у-у"),
			"э" = list("э-э-э"),
			"ы" = list("ы-ы-ы"),
			"я" = list("я-я-я"),
			"ё" = list("ё-ё-ё"),
			"ю" = list("ю-ю-ю"),
			"е" = list("е-е-е"),
			"и" = list("и-и-и"),

		)
	autohiss_exempt = list(LANGUAGE_ROOTLOCAL, LANGUAGE_ROOTGLOBAL)
