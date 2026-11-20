/singleton/modpack/chemistry_additions/initialize()
	var/singleton/trait/malus/allergy/allergy = GET_SINGLETON(/singleton/trait/malus/allergy)
	allergy.metaoptions[/datum/reagent/metorapan] = 2
	allergy.metaoptions[/datum/reagent/cortolin] = 2
