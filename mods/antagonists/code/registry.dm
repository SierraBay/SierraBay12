var/global/datum/antagonist_registry/antagonist_registry = null

/datum/antagonist_registry
	var/list/registered_antagonists = list()
	var/antagonist_spawning_complete = FALSE

// only needed for traitor/renegade interactions, could be useful later
/datum/antagonist_registry/New()
	registered_antagonists = list(
		MODE_TRAITOR = list(),
		MODE_RENEGADE = list(),
	)

/datum/antagonist_registry/proc/spawning_complete()
	antagonist_spawning_complete = TRUE

/datum/antagonist_registry/proc/register(antag_type, mind)
	if(!istype(mind, /datum/mind))
		return

	if(!registered_antagonists[antag_type])
		registered_antagonists[antag_type] = list()

	registered_antagonists[antag_type] |= list(mind)

/datum/antagonist_registry/proc/unregister(antag_type, mind)
	if(!registered_antagonists[antag_type])
		return
	registered_antagonists[antag_type] -= mind

/datum/antagonist_registry/proc/get_antagonists(antag_type)
	if(!registered_antagonists[antag_type])
		return list()
	return registered_antagonists[antag_type]

// Global proc for easy access
/proc/get_antagonist_registry()
	RETURN_TYPE(/datum/antagonist_registry)
	if(!antagonist_registry)
		antagonist_registry = new /datum/antagonist_registry()
	return antagonist_registry

/proc/register_antagonist(antag_type, mind)
	var/datum/antagonist_registry/registry = get_antagonist_registry()
	registry.register(antag_type, mind)

/proc/unregister_antagonist(antag_type, mind)
	var/datum/antagonist_registry/registry = get_antagonist_registry()
	registry.unregister(antag_type, mind)

/proc/get_antagonists_by_type(antag_type)
	var/datum/antagonist_registry/registry = get_antagonist_registry()
	return registry.get_antagonists(antag_type)

/proc/get_all_antagonists()
	var/list/all_antagonists = list()
	var/datum/antagonist_registry/registry = get_antagonist_registry()
	for(var/antag_type in registry.registered_antagonists)
		var/list/type_antagonists = registry.registered_antagonists[antag_type]
		if(type_antagonists)
			all_antagonists += type_antagonists
	return all_antagonists

// В теории должно работать. Если не сработает - все ренегаты повиснут в цикле аддтаймеров без целей.
/datum/game_mode/create_antagonists()
	if(..())
		var/datum/antagonist_registry/registry = get_antagonist_registry()
		registry.spawning_complete()
		return TRUE
	return FALSE
