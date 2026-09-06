// Virology integration for the Lar Maria derelict mission.
// When the curer synthesizes a vaccine from a Lar Maria culture dish,
// advance the Zeng-Hu mission's study_artifact objective.

/obj/machinery/computer/curer/on_synthesis_complete(obj/item/virusdish/dish, obj/item/reagent_containers/vaccine)
	if(!istype(dish, /obj/item/virusdish/lar_maria))
		return

	// Advance the Zeng-Hu mission study_artifact objective
	for(var/datum/derelict_mission/M in derelict_missions_list)
		if(M.corporation_id != RND_MISSION_CORP_ZENG_HU)
			continue
		if(M.state != RND_MISSION_STATE_AVAILABLE)
			continue
		var/datum/derelict_mission_objective/study = M.get_objective_by_type("study_artifact")
		if(study && !study.completed)
			study.advance()
			state("\The [src] registers: mission objective updated - antidote synthesized.")
		break
