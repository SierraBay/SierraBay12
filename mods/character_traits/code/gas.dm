/datum/mod_trait/all/gas
	name = SPECIES_NABBER + " - Vision"
	description = "Позволяет приблизиться к восприятию мира подобному ГБСьему, акцентируя внимания на оранжевых оттенках огня и приглушая растительные-зелёные."
	species_allowed = list(SPECIES_NABBER)

/datum/mod_trait/all/gas/apply_trait(mob/living/carbon/human/H)
	H.gasvision()

/mob/proc/gasvision()
		add_client_color(/datum/client_color/gas)

/datum/client_color/gas
	client_color = list(
	0.6, 0.2, 0.1,
	0.1, 0.3, 0.1,
	0.15, 0.15, 0.4
	)
	order = 100
