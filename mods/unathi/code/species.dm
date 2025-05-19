/singleton/species/unathi/yeosa/New()
	if (/datum/unarmed_attack/bite/venom in unarmed_types)
		unarmed_types -= /datum/unarmed_attack/bite/venom
	unarmed_types += /datum/unarmed_attack/bite/venom/yeosa
	inherent_verbs += list(/mob/living/carbon/human/unathi/yeosa/proc/decant_venom)
	. = ..()

/singleton/species/unathi
	inherent_verbs = list()

/singleton/species/unathi/skills_from_age(age)
	if(age in 0 to 45)
		. = ..()
	else if(age)
		// Если возраст выше 45 лет - один скиллпоинт за каждые 20 лет
		. = floor((age - 45) / 20) + 8
