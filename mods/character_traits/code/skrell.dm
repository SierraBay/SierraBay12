/datum/mod_trait/all/skrell
	name = SPECIES_SKRELL + " - Vision"
	description = "Позволяет воспринимать мир в подобии зрения скреллов, смещая спектр в сторону синего."
	incompatible_traits = list(/datum/mod_trait/all/tritanopia, /datum/mod_trait/all/protanopia, /datum/mod_trait/all/deuteranopia)
	species_allowed = list(SPECIES_SKRELL)

/datum/mod_trait/all/skrell/apply_trait(mob/living/carbon/human/H)
	H.skrellvision()

/mob/proc/skrellvision()
		add_client_color(/datum/client_color/skrell)

/datum/client_color/skrell
	client_color = list(
	0.6, 0.15, 0.25,
	0.15, 0.4, 0.15,
	0.25, 0.15, 0.8
	)
	order = 100
