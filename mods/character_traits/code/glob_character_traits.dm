GLOBAL_LIST_EMPTY(all_mod_traits)

/hook/global_init/makeDatumRefLists()
	. = ..()
	var/paths = typesof(/datum/mod_trait) - /datum/mod_trait
	for(var/path in paths)
		var/datum/mod_trait/M = path
		if (!initial(M.name))
			continue
		M = new path()
		GLOB.all_mod_traits[M.name] = M