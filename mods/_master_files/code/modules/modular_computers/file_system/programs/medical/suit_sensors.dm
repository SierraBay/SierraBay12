// Share CrewMonitor with Sierra's console, AI and computer program.
/datum/nano_module/program/crew_monitor/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE, datum/topic_state/state = GLOB.default_state)
	return tgui_interact(user)

/datum/nano_module/program/crew_monitor/tgui_host(mob/user)
	return nano_host()

/datum/nano_module/program/crew_monitor/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/nanomaps))

/datum/nano_module/program/crew_monitor/tgui_status(mob/user, datum/tgui_state/state)
	return min(..(), CanUseTopic(user, GLOB.default_state))

/datum/nano_module/program/crew_monitor/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewMonitor", name)
		ui.set_map_z_level(get_host_z())
		ui.open()

/datum/nano_module/program/crew_monitor/tgui_data(mob/user)
	// Keep Sierra's sensor visibility at the host's Z level.
	return list("isAI" = isAI(user), "map_levels" = list(get_host_z()), "crewmembers" = crew_repository.health_data(get_host_z()))

/datum/nano_module/program/crew_monitor/tgui_act(action, list/params)
	if(..())
		return TRUE
	if(action != "track" || !isAI(usr))
		return FALSE
	var/mob/living/carbon/human/target = locate(params["track"]) in SSmobs.mob_list
	if(!istype(target) || !hassensorlevel(target, SUIT_SENSOR_TRACKING) || get_z(target) != get_host_z())
		return FALSE
	Topic(null, list("track" = TGUI_REF(target)), GLOB.default_state)
	return TRUE
