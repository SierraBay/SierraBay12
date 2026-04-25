// Derelict Mission System (defines are in _RnD.dm)
// Missions are auto-generated based on which away sites loaded during world init.
// Each qualifying derelict maps to a corporation and provides research rewards.

var/global/list/derelict_missions_list = list()         // All generated missions
var/global/list/derelict_mission_configs = list()        // Config registry (away_site_id -> config)
var/global/list/loaded_away_site_ids = list()            // Filled by build_away_sites()
var/global/list/derelict_mission_objects = list()        // Registry of all mission-relevant atoms (self-register on New, unregister on Destroy)

// --- Mission Objective ---
/datum/derelict_mission_objective
	var/id
	var/description                    // Displayed to player
	var/objective_type                 // "retrieve_item", "retrieve_artifact", "scan_object", "photograph_object", "deploy_sensor"
	var/target_type                    // Type path of target (item, obj, mob)
	var/required_count = 1
	var/current_count = 0
	var/completed = FALSE

/datum/derelict_mission_objective/proc/check_complete()
	if(current_count >= required_count)
		completed = TRUE
	return completed

/datum/derelict_mission_objective/proc/advance(amount = 1)
	current_count = min(current_count + amount, required_count)
	check_complete()

/datum/derelict_mission_objective/proc/get_status_text()
	if(completed)
		return "Выполнено"
	return "[current_count]/[required_count]"

// --- Mission Datum ---
/datum/derelict_mission
	var/id                              // Unique mission ID
	var/title                           // Display name
	var/description                     // Full description for player
	var/away_site_id                    // e.g. "awaysite_lar_maria"
	var/away_site_name                  // Display name of derelict
	var/corporation_id                  // RND_MISSION_CORP_* define
	var/mission_type = DERELICT_MISSION_SIMPLE  // simple or complex
	var/state = RND_MISSION_STATE_AVAILABLE
	var/list/objectives = list()        // List of /datum/derelict_mission_objective
	var/target_item_type                // For simple missions: type of /obj/item to deliver via drone pad
	var/target_artifact_type            // For complex missions: type of /obj/structure/derelict_mission_artifact
	var/target_artifact_report_type     // For complex missions: type of /obj/item/paper/anomaly_scan/mission report to submit to R&D console
	var/require_antibodies = FALSE      // If TRUE, submitted reagent container must contain antibodies
	var/away_z = 0                      // Z-level of the derelict (0 = unknown, skip z-check)
	/// Set of mob types that were present on the derelict at map-load time.
	/// Only these types are eligible for ghost invasion offers.
	/// Populated by build_derelict_z_mapping() after the map loads.
	var/list/initial_mob_types = list()

/datum/derelict_mission/proc/check_all_objectives_complete()
	for(var/datum/derelict_mission_objective/O in objectives)
		if(!O.completed)
			return FALSE
	return TRUE

/datum/derelict_mission/proc/get_objective_by_type(objective_type)
	for(var/datum/derelict_mission_objective/O in objectives)
		if(O.objective_type == objective_type)
			return O
	return null

/datum/derelict_mission/proc/advance_objective(objective_type, amount = 1)
	var/datum/derelict_mission_objective/O = get_objective_by_type(objective_type)
	if(O)
		O.advance(amount)
		return TRUE
	return FALSE

/datum/derelict_mission/proc/try_submit_item(obj/item/I)
	if(state != RND_MISSION_STATE_AVAILABLE)
		return FALSE
	if(!target_item_type)
		return FALSE
	if(!istype(I, target_item_type))
		return FALSE

	// If mission requires antibodies, verify the container actually has them
	if(require_antibodies)
		if(!validate_has_antibodies(I))
			return FALSE

	// Check that prerequisite objectives (scan/photo/sensor) are done
	for(var/datum/derelict_mission_objective/O in objectives)
		if(O.objective_type == "retrieve_item")
			continue // This is the delivery objective itself
		if(!O.completed)
			return FALSE

	// Complete the retrieve_item objective
	var/datum/derelict_mission_objective/retrieve = get_objective_by_type("retrieve_item")
	if(retrieve)
		retrieve.advance()

	return TRUE

/// Check if a reagent container has antibodies reagent inside
/datum/derelict_mission/proc/validate_has_antibodies(obj/item/I)
	var/obj/item/reagent_containers/container = I
	if(!istype(container) || !container.reagents)
		return FALSE
	var/datum/reagent/antibodies/AB = locate(/datum/reagent/antibodies) in container.reagents.reagent_list
	if(!AB)
		return FALSE
	if(!islist(AB.data) || !LAZYLEN(AB.data["antibodies"]))
		return FALSE
	return TRUE

/datum/derelict_mission/proc/try_complete_artifact_research(obj/structure/derelict_mission_artifact/artifact)
	if(state != RND_MISSION_STATE_AVAILABLE)
		return FALSE
	if(mission_type != DERELICT_MISSION_COMPLEX)
		return FALSE
	if(!istype(artifact, target_artifact_type))
		return FALSE
	if(artifact.research_progress < 100)
		return FALSE

	// Complete the study_artifact objective
	var/datum/derelict_mission_objective/retrieve = get_objective_by_type("study_artifact")
	if(retrieve)
		retrieve.advance()

	return TRUE

/datum/derelict_mission/proc/finalize(datum/research/files)
	if(!files)
		return FALSE
	if(state != RND_MISSION_STATE_AVAILABLE)
		return FALSE
	if(!check_all_objectives_complete())
		return FALSE

	state = RND_MISSION_STATE_REWARDED

	// Grant rewards based on mission type
	var/list/all_corp_nodes = get_all_corp_node_ids(corporation_id)

	if(mission_type == DERELICT_MISSION_COMPLEX)
		// Complex: unlock ALL corporation nodes
		for(var/node_id in all_corp_nodes)
			var/datum/technology/tech = SSresearch.get_tech_node(node_id)
			if(tech)
				files.UnlockTechology(tech, force = TRUE)
		files.ChangeCorporationReputation(corporation_id, 50)
	else
		// Simple: unlock HALF corporation nodes (first half)
		var/half = max(round(LAZYLEN(all_corp_nodes) / 2), 1)
		for(var/i = 1 to half)
			var/datum/technology/tech = SSresearch.get_tech_node(all_corp_nodes[i])
			if(tech)
				files.UnlockTechology(tech, force = TRUE)
		files.ChangeCorporationReputation(corporation_id, 25)

	return TRUE

// --- Mission Config ---
// Subtype these per derelict to define mission parameters
/datum/derelict_mission_config
	var/away_site_id                    // e.g. "awaysite_lar_maria"
	var/away_site_name                  // Display name
	var/corporation_id                  // RND_MISSION_CORP_*
	var/mission_type = DERELICT_MISSION_SIMPLE
	var/title
	var/description
	var/target_item_type                // For simple missions
	var/target_artifact_type            // For complex missions
	var/target_artifact_report_type     // For complex missions: report paper type for study_artifact
	var/require_antibodies = FALSE      // If TRUE, submitted container must contain antibodies
	// Objectives to create (list of lists with keys: type, description, target_type, count)
	var/list/objective_templates = list()
	var/ghost_mob_count = 0                     // How many mobs to offer ghosts on first visit (0 = all)

/datum/derelict_mission_config/proc/create_mission()
	var/datum/derelict_mission/M = new()
	M.id = away_site_id
	M.title = title
	M.description = description
	M.away_site_id = away_site_id
	M.away_site_name = away_site_name
	M.corporation_id = corporation_id
	M.mission_type = mission_type
	M.target_item_type = target_item_type
	M.target_artifact_type = target_artifact_type
	M.target_artifact_report_type = target_artifact_report_type
	M.require_antibodies = require_antibodies

	for(var/list/tpl in objective_templates)
		var/datum/derelict_mission_objective/O = new()
		O.id = tpl["type"]
		O.objective_type = tpl["type"]
		O.description = tpl["description"]
		O.target_type = tpl["target_type"]
		O.required_count = tpl["count"] || 1
		M.objectives += O

	return M

// --- Helper: get ALL tech node IDs for a corporation across ALL categories ---
/proc/get_all_corp_node_ids(corp_id)
	var/list/result = list()
	if(!rnd_tech_categories)
		return result
	for(var/category_id in rnd_tech_categories)
		var/list/category = rnd_tech_categories[category_id]
		if(!category)
			continue
		var/list/trees = category["trees"]
		if(!trees || !(corp_id in trees))
			continue
		var/list/tree = trees[corp_id]
		if(!tree)
			continue
		var/list/nodes = tree["nodes"]
		if(nodes)
			result |= nodes
	return result

// Store loaded z-level on away_site templates so generate_derelict_missions() can read it.
// We override load_new_z() to capture initial_z before the parent increments world.maxz.
/datum/map_template/ruin/away_site
	var/loaded_z = 0

/datum/map_template/ruin/away_site/load_new_z(no_changeturf = TRUE)
	var/capture_z = world.maxz + 1
	. = ..()
	if(. && id)
		loaded_z = capture_z

// --- Mission Generation ---
/proc/generate_derelict_missions()
	// Register all configs
	for(var/config_type in subtypesof(/datum/derelict_mission_config))
		var/datum/derelict_mission_config/cfg = new config_type()
		if(cfg.away_site_id)
			derelict_mission_configs[cfg.away_site_id] = cfg

	// Generate missions for loaded away sites
	for(var/site_id in loaded_away_site_ids)
		if(site_id in derelict_mission_configs)
			var/datum/derelict_mission_config/cfg = derelict_mission_configs[site_id]
			var/datum/derelict_mission/M = cfg.create_mission()
			// Determine the derelict's z-level from the template's stored loaded_z
			for(var/tname in SSmapping.away_sites_templates)
				var/datum/map_template/ruin/away_site/T = SSmapping.away_sites_templates[tname]
				if(T.id == site_id && T.loaded_z > 0)
					M.away_z = T.loaded_z
					break
			derelict_missions_list += M

	if(LAZYLEN(derelict_missions_list))
		log_debug("Derelict Missions: Generated [LAZYLEN(derelict_missions_list)] missions for [LAZYLEN(loaded_away_site_ids)] away sites.")
	else
		log_debug("Derelict Missions: No qualifying away sites loaded, no missions generated.")

// --- Find mission by item type ---
/proc/find_derelict_mission_for_item(obj/item/I)
	for(var/datum/derelict_mission/M in derelict_missions_list)
		if(M.state != RND_MISSION_STATE_AVAILABLE)
			continue
		if(!M.target_item_type || !istype(I, M.target_item_type))
			continue
		if(M.require_antibodies && !M.validate_has_antibodies(I))
			continue
		return M
	return null

// --- Find mission by artifact type ---
/proc/find_derelict_mission_for_artifact(obj/A)
	for(var/datum/derelict_mission/M in derelict_missions_list)
		if(M.state != RND_MISSION_STATE_AVAILABLE)
			continue
		if(M.mission_type != DERELICT_MISSION_COMPLEX)
			continue
		if(M.target_artifact_type && istype(A, M.target_artifact_type))
			return M
	return null

// Photo mission objectives are now validated via R&D console submission (rdconsole.dm)

// --- Helper: spawn item/structure on random floor tile in z-level ---
// area_type: optional area type filter to restrict spawning to specific areas (e.g. /area/slavers_base)
/proc/spawn_derelict_mission_object(type_path, z_level, area_type = null)
	var/list/valid_turfs = list()
	for(var/turf/simulated/floor/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		if(T.density || (locate(/obj/structure) in T))
			continue
		if(area_type)
			var/area/A = get_area(T)
			if(!istype(A, area_type))
				continue
		valid_turfs += T
	if(LAZYLEN(valid_turfs))
		var/atom/A = new type_path(pick(valid_turfs))
		return A
	return null
