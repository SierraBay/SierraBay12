// Все постеры должны идти в файл 'mods/nyc_posters/icons/custom_posters.dmi' иначе тесты ломаются. Файл с новым годом отдельно, потому что файл с новым годом требует зачистки - LordNest

// Misc posters by HonkEmo

/singleton/poster/custom
	icon = 'mods/nyc_posters/icons/custom_posters.dmi'
	name = "Custom Poster"
	desc = "You probably shouldn't be seeing this."
	abstract_type = /singleton/poster/custom

/singleton/poster/custom/pcrcposte
	icon_state = "pcrcposte"
	name = "PCRC Promo"
	desc = "Proxima Centauri Risk Control is a corporation that provides effective asset protection. \
	It actively monitors the skills and abilities of its employees, trains numerous specialists, and offers advantageous positions to workers based on their ranks.\
	Enroll in the introductory courses now! Test yourself! Get a lucrative job! Choose your own contract!"

/singleton/poster/custom/excelr2
	icon_state = "excelr2"
	name = "Fight!"
	desc = "The poster reveals the true meaning of the word 'FIGHT' \
	Every battle is followed by a struggle similar to the depicted nuclear mushroom cloud. \
	The poster illustrates all the horrors hidden in a struggle, such as the consequences of a nuclear war."

/singleton/poster/custom/paramedic
	icon_state = "paramedic"
	name = "VIP Medevac"
	desc = "Paramedics have always been an essential and indispensable part of healthcare, constantly required to respond promptly to calls. \
	But what if you're in a hard-to-reach and DANGEROUS location?! This question caught the interest of a relatively unknown corporation operating within the bounds of Mars and Pluto. \
	It was on Pluto where the concept of VIP services for clients was born, ensuring that high-tech, well-trained squads could rescue clients in hazardous environments. \
	Saving lives at all costs — and the cost is MONEY!"

/singleton/poster/custom/postersmoke
	icon_state = "postersmoke"
	name = "Smoke!"
	desc = "Cigarettes — many believe they are harmful, but with our advanced medical technology, smoking is no longer a death sentence. \
	Stop thinking in stereotypes and just grab a cigarette. \
	There are various flavors, different types of tobacco, and a wide range of cigarette options to choose from!"

/singleton/poster/custom/chromego
	icon_state = "chromego"
	name = "Augmentics Promo"
	desc = "Cybernetics! It's the pinnacle of progress humanity has reached, allowing you to install anything you can imagine! \
	Prosthetics can now feel, eat, and drink! What's especially awesome are the combat implants! \
	Have you seen the latest version of the MANTIS IMPLANT?! It's absolutely INSANE!!!"

/obj/structure/sign/poster/custom
	icon = 'mods/nyc_posters/icons/custom_posters.dmi'
	random_poster_base_type = /singleton/poster/custom

/obj/structure/sign/poster/custom/pcrcposte
	icon_state = "pcrcposte"
	poster_type = /singleton/poster/custom/pcrcposte

/obj/structure/sign/poster/custom/excelr2
	icon_state = "excelr2"
	poster_type = /singleton/poster/custom/excelr2

/obj/structure/sign/poster/custom/paramedic
	icon_state = "paramedic"
	poster_type = /singleton/poster/custom/paramedic

/obj/structure/sign/poster/custom/postersmoke
	icon_state = "postersmoke"
	poster_type = /singleton/poster/custom/postersmoke

/obj/structure/sign/poster/custom/chromego
	icon_state = "chromego"
	poster_type = /singleton/poster/custom/chromego
