/singleton/species/proc/get_selectable_mod_traits()
	var/list/allowed_mod_traits = list()
	for (var/mod_trait_id in GLOB.all_mod_traits)
		var/datum/mod_trait/T = GLOB.all_mod_traits[mod_trait_id]
		if (!T.name)
			continue
		if (T.species_allowed && !(name in T.species_allowed))
			continue
		if (T.subspecies_allowed && !(get_bodytype() in T.subspecies_allowed))
			continue
		if (LAZYISIN(traits, T.type))
			continue
		allowed_mod_traits[T.name] = T
	return allowed_mod_traits


/datum/gear/dexalin_pen
	display_name = "Asthma Autoinjector"
	path = /obj/item/reagent_containers/hypospray/autoinjector/pouch_auto/dexalin
	cost = 1
	allowed_mod_traits = list(/datum/mod_trait/all/asthma)
