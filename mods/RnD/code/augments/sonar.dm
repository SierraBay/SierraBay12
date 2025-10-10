// Sonar, basically, resomi's ping

/obj/item/organ/internal/augment/active/sonar
	name = "cybersonar"
	augment_slots = AUGMENT_HEAD
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "sonar"
	desc = "Cyberaudio sonar system, capabale of tracking nearby moving objects via echolocation."
	augment_flags = AUGMENT_BIOLOGICAL | AUGMENT_MECHANICAL | AUGMENT_SCANNABLE
	origin_tech = list(TECH_DATA = 4, TECH_MAGNET = 4, TECH_BIO = 4)

/obj/item/organ/internal/augment/active/sonar/activate()
	owner.sonar_ping()

/obj/item/organ/internal/augment/active/sonar/emp_act(severity)
	if (istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		to_chat(M, SPAN_DANGER("Your [name] malfunctions, deafening you!"))
		M.ear_damage += rand(1, 10)
		M.ear_deaf = max(M.ear_deaf,15)
	..()

// Traitor section

/obj/item/device/augment_implanter/sonar
	augment = /obj/item/organ/internal/augment/active/sonar

/datum/uplink_item/item/augment/aug_sonar
	name = "Sonar Augment (head)"
	desc = "An integrated cyberaudio system that includes sonar capable of echolocating nearby sound sources. \
	Sonar is detected by analyzers due to extensive improvements to the auricles. It is suitable for both organic and prosthesis heads."
	item_cost = 24
	path = /obj/item/device/augment_implanter/sonar
