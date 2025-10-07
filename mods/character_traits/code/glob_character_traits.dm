GLOBAL_LIST_EMPTY(all_mod_traits)

/world/New()
	. = ..()
	InitializeModTraits()

/proc/InitializeModTraits()
	GLOB.all_mod_traits = list()
	for (var/T in subtypesof(/datum/mod_trait))
		var/datum/mod_trait/M = new T()
		if(M.name)
			GLOB.all_mod_traits[M.name] = M
