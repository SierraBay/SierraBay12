/obj/item/paimod/special
	special_limit_tag = "special"

/obj/item/paimod/special/advanced_holo
	name = "advanced holo projector"
	desc = "This is an advanced 'DAIS-HoloEmulator(™)' hologram projector, which is used to modify PAI's appearance. It gives an ability to change PAI's hologram and choose premium holograms as well."
	icon_state = "holo_proj"

/obj/item/paimod/special/advanced_holo/on_recalculate(mob/living/silicon/pai/P)
	. = ..()
	P.is_advanced_holo = 1



/obj/item/paimod/special/hack_camo
	name = "hacking camouflage"
	desc = "This is an obsolete 'DAIS-PAI-Rip-EMD' hacking camouflage, still popular at the gray market of such PAImods. Used to cover any encrypted access, made by PAI, from central AI and control systems alike. In reality, it simply conceives your device's current location."
	icon_state = "camo"

/obj/item/paimod/special/hack_camo/on_recalculate(mob/living/silicon/pai/P)
	. = ..()
	P.is_hack_covered = 1



/obj/item/paimod/holoskins
	name = "PAI models' data card"
	desc = "This is PAI data card that stores hologram models for PAI."
	special_limit_tag = "skins"
	var/list/holochasises = list()

/obj/item/paimod/holoskins/on_recalculate(mob/living/silicon/pai/P)
	. = ..()
	var/is_chasises_in_possible = 0
	for(var/i in holochasises) is_chasises_in_possible = holochasises.Find(GLOB.possible_chassis, i)
	if(length(holochasises) && !is_chasises_in_possible) GLOB.possible_chassis.Add(holochasises)

/obj/item/paimod/holoskins/paiwoman
	name = "PAI women models' data card"
	desc = "This is a PAI data card that stores two additional hologram models, made by DAIS: Claire and Roxanne."
	holochasises = list(
		"Human Female" = "h_female",
		"Human Female Red" = "h_female_red"
	)

//доп. языки в переводчик - таярий, резомий + упрощённые ксеноязыки
/datum/pai_software/translator
	name = "Universal Translator"
	ram_cost = 35
	id = "translator"
	languages = list(
		LANGUAGE_SPACER,
		LANGUAGE_GUTTER,
		LANGUAGE_UNATHI_SINTA,
		LANGUAGE_SIMPUNATHI,
		LANGUAGE_RESOMI,
		LANGUAGE_SIIK_MAAS,
		LANGUAGE_SIMPTAJARAN,
		LANGUAGE_SIMPSKRELLIAN,
		LANGUAGE_SKRELLIAN,
		LANGUAGE_HUMAN_ARABIC,
		LANGUAGE_HUMAN_CHINESE,
		LANGUAGE_HUMAN_IBERIAN,
		LANGUAGE_HUMAN_INDIAN,
		LANGUAGE_HUMAN_RUSSIAN,
		LANGUAGE_HUMAN_SELENIAN)

/datum/pai_software/translator/toggle(mob/living/silicon/pai/user)
	user.translator_on = !user.translator_on
	if (user.translator_on)
		for (var/language in languages)
			user.add_language(language)
	else
		for (var/language in languages)
			user.remove_language(language)


/datum/pai_software/translator/is_active(mob/living/silicon/pai/user)
	return user.translator_on
