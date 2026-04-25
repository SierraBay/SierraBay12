// Debug panel for derelict mission items.
// Shows all active missions, their expected items/artifacts, and current world locations.
// Datum stored on /datum/admins to survive GC (same pattern as virus2_editor).

/datum/admins/var/datum/rnd_mission_debug_panel/rnd_mission_debug_datum = new

/client/proc/rnd_mission_debug()
	set name = "RnD Mission Debug"
	set category = "Debug"
	set desc = "Shows all derelict missions and the locations of their quest items/artifacts in the world."

	if(!holder || !check_rights(R_DEBUG))
		return

	holder.rnd_mission_debug_datum.show(src)

/datum/rnd_mission_debug_panel

/datum/rnd_mission_debug_panel/proc/show(client/C)
	if(!C || !C.holder || !check_rights(R_DEBUG, FALSE, C))
		return

	if(!LAZYLEN(derelict_missions_list))
		show_browser(C, "<b>No derelict missions generated.</b>", "window=rnd_mission_debug;size=800x600")
		return

	// --- Build lookup from global registry (no world iteration) ---
	var/list/artifact_lookup = list()  // mission id -> list of atoms
	var/list/item_lookup = list()      // mission id -> list of atoms

	for(var/datum/derelict_mission/M in derelict_missions_list)
		artifact_lookup[M.id] = list()
		item_lookup[M.id] = list()

	for(var/atom/A in derelict_mission_objects)
		for(var/datum/derelict_mission/M in derelict_missions_list)
			if(M.target_artifact_type && istype(A, M.target_artifact_type))
				var/list/L = artifact_lookup[M.id]
				L += A
			if(M.target_item_type && istype(A, M.target_item_type))
				var/list/L = item_lookup[M.id]
				if(!(A in L))
					L += A

	// --- Build HTML ---
	var/dat = {"<html><head><style>
		body { font-family: Verdana, sans-serif; font-size: 12px; background: #1a1a2e; color: #e0e0e0; padding: 8px; }
		h2 { color: #00d4ff; margin: 4px 0; }
		hr { border-color: #333; }
		.mission { margin-bottom: 8px; padding: 6px; background: #16213e; border: 1px solid #333; border-radius: 4px; }
		.available { border-left: 3px solid #00ff88; }
		.rewarded { border-left: 3px solid #888; }
		.obj-done { color: #00ff88; }
		.obj-pending { color: #ffaa00; }
		.btn { color: #00d4ff; text-decoration: none; padding: 1px 4px; border: 1px solid #00d4ff; border-radius: 3px; font-size: 11px; }
		.btn:hover { background: #00d4ff22; }
		.btn-green { color: #00ff88; border-color: #00ff88; }
		.btn-red { color: #ff4444; border-color: #ff4444; }
		.btn-orange { color: #ffaa00; border-color: #ffaa00; }
		.indent { margin-left: 16px; }
		.indent2 { margin-left: 32px; }
	</style></head><body>"}

	dat += "<h2>Derelict Mission Debug</h2>"
	dat += "<a class='btn' href='byond://?src=\ref[src];refresh=1'>Refresh</a>"
	dat += " <a class='btn btn-orange' href='byond://?src=\ref[src];advance_all=1'>Complete All Missions</a>"
	dat += "<hr>"

	// Ghost invasion status
	dat += "<div style='margin-bottom: 8px; padding: 4px; background: #0f3460; border-radius: 4px;'>"
	dat += "<b>Ghost Invasion:</b> "
	var/visited_count = 0
	for(var/z_key in derelict_z_to_mission)
		if(derelict_z_visited[z_key])
			visited_count++
	dat += "[visited_count]/[length(derelict_z_to_mission)] z-levels visited | "
	dat += "<a class='btn btn-red' href='byond://?src=\ref[src];reset_visits=1'>Reset All Visits</a>"
	dat += "</div>"

	for(var/datum/derelict_mission/M in derelict_missions_list)
		var/css_class = (M.state == RND_MISSION_STATE_AVAILABLE) ? "available" : "rewarded"
		var/state_text = (M.state == RND_MISSION_STATE_AVAILABLE) ? "AVAILABLE" : "REWARDED"
		dat += "<div class='mission [css_class]'>"
		dat += "<b>[M.title]</b> &mdash; [M.away_site_name] | [state_text] (z=[M.away_z])<br>"

		// Artifact (complex missions)
		if(M.mission_type == DERELICT_MISSION_COMPLEX && M.target_artifact_type)
			dat += "<div class='indent'><b>Artifact:</b> [M.target_artifact_type]</div>"
			var/list/artifacts = artifact_lookup[M.id]
			if(LAZYLEN(artifacts))
				for(var/atom/A in artifacts)
					var/turf/T = get_turf(A)
					var/loc_str = T ? "([T.x],[T.y],[T.z])" : "(no turf)"
					dat += "<div class='indent2'><font color='#88bbff'>[A]</font> @ [loc_str] "
					dat += "<a class='btn' href='byond://?src=\ref[src];jump=\ref[A]'>Jump</a> "
					dat += "<a class='btn btn-green' href='byond://?src=\ref[src];bring=\ref[A]'>Bring Here</a>"
					dat += "</div>"
			else
				dat += "<div class='indent2'><font color='#ffaa00'>Not in world.</font></div>"

		// Target item
		if(M.target_item_type)
			dat += "<div class='indent'><b>Target Item:</b> [M.target_item_type]</div>"
			var/list/items = item_lookup[M.id]
			if(LAZYLEN(items))
				for(var/atom/A in items)
					var/turf/T = get_turf(A)
					var/loc_str = T ? "([T.x],[T.y],[T.z])" : "(inside [A.loc ? "[A.loc]" : "?"])"
					dat += "<div class='indent2'><font color='#88bbff'>[A]</font> @ [loc_str] "
					dat += "<a class='btn' href='byond://?src=\ref[src];jump=\ref[A]'>Jump</a> "
					dat += "<a class='btn btn-green' href='byond://?src=\ref[src];bring=\ref[A]'>Bring Here</a>"
					dat += "</div>"
			else
				dat += "<div class='indent2'><font color='#888'>Not yet spawned.</font></div>"

		// Objectives
		dat += "<div class='indent'><b>Objectives:</b></div>"
		for(var/datum/derelict_mission_objective/O in M.objectives)
			var/css = O.completed ? "obj-done" : "obj-pending"
			dat += "<div class='indent2'>"
			dat += "<span class='[css]'>[O.get_status_text()]</span> [O.description]"
			if(!O.completed)
				dat += " <a class='btn btn-green' href='byond://?src=\ref[src];advance_obj=\ref[O];mission=\ref[M]'>Advance</a>"
				dat += " <a class='btn btn-orange' href='byond://?src=\ref[src];complete_obj=\ref[O];mission=\ref[M]'>Complete</a>"
			dat += "</div>"

		// Mission-level actions
		if(M.state == RND_MISSION_STATE_AVAILABLE)
			dat += "<div class='indent' style='margin-top: 4px;'>"
			dat += "<a class='btn btn-orange' href='byond://?src=\ref[src];complete_mission=\ref[M]'>Complete All Objectives</a> "
			dat += "<a class='btn btn-red' href='byond://?src=\ref[src];finalize_mission=\ref[M]'>Finalize (grant rewards)</a>"
			dat += "</div>"

		dat += "</div>"

	dat += "</body></html>"
	show_browser(C, dat, "window=rnd_mission_debug;size=900x700")
	onclose(C, "rnd_mission_debug")

/datum/rnd_mission_debug_panel/Topic(href, href_list)
	..()
	if(!usr || !usr.client || !usr.client.holder)
		return
	if(!check_rights(R_DEBUG, FALSE, usr.client))
		return

	var/client/C = usr.client

	if(href_list["jump"])
		var/atom/A = locate(href_list["jump"])
		if(A && C.mob)
			var/turf/T = get_turf(A)
			if(T && isturf(T))
				C.mob.jumpTo(T)

	else if(href_list["bring"])
		var/atom/movable/A = locate(href_list["bring"])
		if(A && C.mob)
			var/turf/T = get_turf(C.mob)
			if(T)
				A.forceMove(T)
				to_chat(C.mob, SPAN_NOTICE("Teleported [A] to your location."))

	else if(href_list["advance_obj"])
		var/datum/derelict_mission_objective/O = locate(href_list["advance_obj"])
		if(O && !O.completed)
			O.advance()
			to_chat(C.mob, SPAN_NOTICE("Advanced objective: [O.description] ([O.get_status_text()])"))

	else if(href_list["complete_obj"])
		var/datum/derelict_mission_objective/O = locate(href_list["complete_obj"])
		if(O && !O.completed)
			O.current_count = O.required_count
			O.check_complete()
			to_chat(C.mob, SPAN_NOTICE("Completed objective: [O.description]"))

	else if(href_list["complete_mission"])
		var/datum/derelict_mission/M = locate(href_list["complete_mission"])
		if(M)
			for(var/datum/derelict_mission_objective/O in M.objectives)
				if(!O.completed)
					O.current_count = O.required_count
					O.check_complete()
			to_chat(C.mob, SPAN_NOTICE("All objectives completed for: [M.title]"))

	else if(href_list["finalize_mission"])
		var/datum/derelict_mission/M = locate(href_list["finalize_mission"])
		if(M && M.state == RND_MISSION_STATE_AVAILABLE)
			for(var/datum/derelict_mission_objective/O in M.objectives)
				if(!O.completed)
					O.current_count = O.required_count
					O.check_complete()
			var/obj/machinery/computer/rdconsole/console = locate(/obj/machinery/computer/rdconsole) in world
			var/datum/research/console_files = console ? console.get_server_files() : null
			if(console && console_files)
				M.finalize(console_files)
				to_chat(C.mob, SPAN_NOTICE("Finalized mission: [M.title] — rewards granted!"))
			else
				to_chat(C.mob, SPAN_WARNING("No R&D console found to grant rewards."))

	else if(href_list["advance_all"])
		for(var/datum/derelict_mission/M in derelict_missions_list)
			if(M.state != RND_MISSION_STATE_AVAILABLE)
				continue
			for(var/datum/derelict_mission_objective/O in M.objectives)
				if(!O.completed)
					O.current_count = O.required_count
					O.check_complete()
			var/obj/machinery/computer/rdconsole/console = locate(/obj/machinery/computer/rdconsole) in world
			var/datum/research/console_files = console ? console.get_server_files() : null
			if(console && console_files)
				M.finalize(console_files)
		to_chat(C.mob, SPAN_NOTICE("All missions completed and finalized!"))

	// Auto-refresh after any action
	show(C)
