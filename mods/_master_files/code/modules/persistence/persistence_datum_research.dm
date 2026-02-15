/datum/persistent/research
	name = "mod_research_tree"

/datum/persistent/research/IsValidEntry(atom/entry)
	var/obj/machinery/r_n_d/server/core/server = entry
	return istype(server) && !MACHINE_IS_BROKEN(server)

/datum/persistent/research/FinalizeTokens(list/tokens)
	. = ..()
	for (var/list/entry in tokens)
		if(entry["type"] && !ispath(entry["type"]))
			entry["type"] = text2path(entry["type"])
	. = tokens

/datum/persistent/research/ProcessAndApplyTokens(list/tokens)
	for (var/list/entry in tokens)
		if (prob(10)) //small chance to keep all progress from previous round
			break

		var/reduce_levels = 0

		var/tech_type = entry["type"]

		var/tree_length = LAZYLEN(entry["tree"])

		if(tree_length)
			var/datum/tech/T = locate(tech_type) in SSresearch.all_tech_trees

			if(T)
				if (prob(60))
					reduce_levels = 1
				else if (prob(20))
					reduce_levels = pick(2, 3)

				if(reduce_levels)

					if(T.maxlevel > 12)
						if(prob(50))
							reduce_levels *= 2 // faster decay for large trees

					if(reduce_levels >= tree_length)
						entry["tree"] = list()
					else
						var/first_index = max(0, tree_length - reduce_levels)
						var/list/current_techs = entry["tree"]

						current_techs.Cut(first_index + 1, 0)

						entry["tree"] = current_techs


	for (var/list/entry in tokens)
		var/_z = entry["z"]
		if (_z in GLOB.using_map.station_levels)
			. = GetValidTurf(locate(entry["x"], entry["y"], _z), entry)
			if (.)
				CreateEntryInstance(., entry)

/datum/persistent/research/CheckTokenSanity(list/tokens)
	for (var/list/entry in tokens)
		if (!entry["type"] || !entry["tree"])
			return FALSE
	return TRUE

/datum/persistent/research/CheckTurfContents(turf/T, list/tokens)
	return (locate(/obj/machinery/r_n_d/server/core) in T)

/datum/persistent/research/CreateEntryInstance(turf/creating, list/tokens)
	var/obj/machinery/r_n_d/server/core/server = locate() in creating

	if (!server)
		return

	var/obj/machinery/r_n_d/server/robotics/second = locate(/obj/machinery/r_n_d/server/robotics) in range(5, server)

	var/tech_type = tokens["type"]
	var/list/id_tech_nodes = list()

	for(var/datum/technology/tech in SSresearch.all_tech_nodes)
		id_tech_nodes[tech.id] = tech

	var/datum/tech/T = locate(tech_type) in server.files.researched_tech

	if(T)
		for(var/tech_id in tokens["tree"])
			if(tech_id && id_tech_nodes[tech_id])
				server.files.UnlockTechology(id_tech_nodes[tech_id], force = TRUE)

				if(second)
					second.files.UnlockTechology(id_tech_nodes[tech_id], force = TRUE)

	SSpersistence.track_value(server, /datum/persistent/research)

/datum/persistent/research/CompileEntry(atom/entry)
	var/obj/machinery/r_n_d/server/core/server = entry
	var/list/techs = list()
	for (var/datum/tech/tech in server.files.researched_tech)
		if (tech.id == RESEARCH_ESOTERIC)
			continue

		var/list/tree_techs = list()

		for(var/datum/technology/tree_tech in server.files.researched_tech[tech])
			if(tree_tech.cost || LAZYLEN(tree_tech.required_technologies) || LAZYLEN(tree_tech.required_tech_levels))
				tree_techs += tree_tech.id

		if(!LAZYLEN(tree_techs))
			continue

		var/list/_entry = list()
		_entry["type"] = tech.type
		_entry["tree"] = tree_techs
		_entry["x"] = server.x
		_entry["y"] = server.y
		_entry["z"] = server.z
		techs += list(_entry)

	return techs

/hook/game_ready/proc/TrackResearchPersistence()
	for (var/obj/machinery/r_n_d/server/core/server in world)
		if (server.z in GLOB.using_map.station_levels)
			SSpersistence.track_value(server, /datum/persistent/research)

	return TRUE
