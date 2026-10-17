/datum/tgui_module/crew_monitor
	name = "Crew monitor"

/datum/tgui_module/crew_monitor/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/nanomaps))

/datum/tgui_module/crew_monitor/tgui_act(action, params)
	if(..())
		return TRUE

	var/turf/T = get_turf(tgui_host())
	if(!T || !(T.z in GLOB.using_map.player_levels))
		to_chat(usr, "<span class='warning'><b>Unable to establish a connection</b>: You're too far away from the station!</span>")
		return FALSE

	switch(action)
		if("track")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/mob/living/carbon/human/H = locate(params["track"]) in SSmobs.mob_list
				if(hassensorlevel(H, SUIT_SENSOR_TRACKING))
					AI.ai_actual_track(H)
			return TRUE

/datum/tgui_module/crew_monitor/tgui_interact(mob/user, datum/tgui/ui, datum/tgui/parent_ui)
	var/z = get_z(tgui_host())
	var/list/map_levels = GetConnectedZlevels(z)

	if(!length(map_levels))
		to_chat(user, "<span class='warning'>The crew monitor doesn't seem like it'll work here.</span>")
		if(ui)
			ui.close()
		return null

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewMonitor", name, parent_ui)
		ui.set_map_z_level(z)
		ui.autoupdate = TRUE
		ui.open()


/datum/tgui_module/crew_monitor/tgui_data(mob/user)
	var/data[0]

	data["isAI"] = isAI(user)

	var/z = get_z(tgui_host())
	var/list/map_levels = GetConnectedZlevels(z)
	data["map_levels"] = map_levels

	data["crewmembers"] = list()
	for(var/zlevel in map_levels)
		data["crewmembers"] += crew_repository.health_data(zlevel)

	return data
