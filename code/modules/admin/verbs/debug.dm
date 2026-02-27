/client/proc/Cell()
	set category = "Debug"
	set name = "Cell"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = "[SPAN_NOTICE("Coordinates: [T.x],[T.y],[T.z]")]\n"
	t += "[SPAN_WARNING("Temperature: [env.temperature]")]\n"
	t += "[SPAN_WARNING("Pressure: [env.return_pressure()]kPa")]\n"
	for(var/g in env.gas)
		t += "[SPAN_NOTICE("[g]: [env.gas[g]] / [env.gas[g] * R_IDEAL_GAS_EQUATION * env.temperature / env.volume]kPa")]\n"

	usr.show_message(t, 1)

/client/proc/cmd_admin_robotize(mob/M in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(GAME_STATE < RUNLEVEL_GAME)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_animalize(mob/M in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(GAME_STATE < RUNLEVEL_GAME)
		alert("Wait until the game starts")
		return

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(istype(M, /mob/new_player))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()



/client/proc/makepAI(turf/T in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in SSmobs.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!isghost(choice))
		var/confirm = input("[choice.key] isn't ghosting right now. Are you sure you want to yank them out of them out of their body and place them in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/device/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card, card)
	pai.SetName(sanitizeSafe(input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text))
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/paiCandidate/candidate in paiController.pai_candidates)
		if(candidate.key == choice.key)
			paiController.pai_candidates.Remove(candidate)

/client/proc/cmd_admin_slimeize(mob/M in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make slime"

	if(GAME_STATE < RUNLEVEL_GAME)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has slimeized [M.key].")
		spawn(10)
			M:slimeize()
		log_and_message_admins("made [key_name(M)] into a slime.")
	else
		alert("Invalid mob")

/client/proc/cmd_debug_del_all(path as text)
	set category = "Debug"
	set name = "Delete All"
	set desc = "(type path) Delete all instances of a type and its subtypes, globally"

	// to prevent REALLY stupid deletions
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/human, /mob/observer, /mob/living/silicon, /mob/living/silicon/robot, /mob/living/silicon/ai)
	var/filtered_list = typesof_filtered(list(/obj, /mob), path) - blocked
	if (!filtered_list)
		return
	var/candidate_type
	if (length(filtered_list) == 1)
		candidate_type = filtered_list[1]
	else
		candidate_type = input(usr, "Choose a type (this INCLUDES all subtypes!) to delete GLOBALLY.", "Delete:") as null|anything in filtered_list
	if (!candidate_type)
		return
	// one last chance to bail out
	var/response = alert("Are you sure you want to delete [candidate_type] and ALL of its subtypes?", null, "No", "Yes")
	if (response != "Yes")
		return
	var/count = 0
	for (var/atom/O in world)
		if (istype(O, candidate_type))
			qdel(O)
			count++
	log_and_message_admins("has deleted [count] instance\s of [candidate_type] and all of its subtypes.")

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)

/client/proc/cmd_admin_grantfullaccess(mob/M in SSmobs.mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if (GAME_STATE < RUNLEVEL_GAME)
		alert("Wait until the game starts")
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/card/id/id = H.GetIdCard()
		if(id)
			id.icon_state = "gold"
			id.access = get_all_accesses()
		else
			id = new/obj/item/card/id(M);
			id.icon_state = "gold"
			id.access = get_all_accesses()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.SetName("[id.registered_name]'s ID Card ([id.assignment])")
			H.equip_to_slot_or_del(id, slot_wear_id)
			H.update_inv_wear_id()
	else
		alert("Invalid mob")
	log_and_message_admins("has granted [M.key] full access.")

/client/proc/cmd_assume_direct_control(mob/M in SSmobs.mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))	return
	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/observer/ghost/ghost = new/mob/observer/ghost(M,1)
			ghost.ckey = M.ckey
	log_and_message_admins("assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	M.teleop = null
	adminmob.teleop = null
	if(isghost(adminmob))
		qdel(adminmob)






/client/proc/cmd_admin_areatest()
	set category = "Mapping"
	set name = "Test areas"

	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	for(var/area/A in world)
		if(!(A.type in areas_all))
			areas_all.Add(A.type)

	for(var/obj/machinery/power/apc/APC in world)
		var/area/A = get_area(APC)
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/alarm/alarm in world)
		var/area/A = get_area(alarm)
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/requests_console/RC in world)
		var/area/A = get_area(RC)
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in world)
		var/area/A = get_area(L)
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in world)
		var/area/A = get_area(LS)
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/device/radio/intercom/I in world)
		var/area/A = get_area(I)
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in world)
		var/area/A = get_area(C)
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	log_debug("<b>AREAS WITHOUT AN APC:</b>")
	for(var/areatype in areas_without_APC)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT AN AIR ALARM:</b>")
	for(var/areatype in areas_without_air_alarm)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT A REQUEST CONSOLE:</b>")
	for(var/areatype in areas_without_RC)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT ANY LIGHTS:</b>")
	for(var/areatype in areas_without_light)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT A LIGHT SWITCH:</b>")
	for(var/areatype in areas_without_LS)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT ANY INTERCOMS:</b>")
	for(var/areatype in areas_without_intercom)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT ANY CAMERAS:</b>")
	for(var/areatype in areas_without_camera)
		log_debug("* [areatype]")

/datum/admins/proc/cmd_admin_dress()
	set category = "Fun"
	set name = "Select equipment"

	if(!check_rights(R_FUN))
		return

	var/mob/living/carbon/human/H = input("Select mob.", "Select equipment.") as null|anything in GLOB.human_mobs
	if(!H)
		return

	var/singleton/hierarchy/outfit/outfit = input("Select outfit.", "Select equipment.") as null|anything in outfits()
	if(!outfit)
		return

	var/reset_equipment = (outfit.flags&OUTFIT_RESET_EQUIPMENT)
	if(!reset_equipment)
		reset_equipment = alert("Do you wish to delete all current equipment first?", "Delete Equipment?","Yes", "No") == "Yes"
	dressup_human(H, outfit, reset_equipment)

/proc/dressup_human(mob/living/carbon/human/H, singleton/hierarchy/outfit/outfit, undress = TRUE)
	if(!H || !outfit)
		return
	if(undress)
		H.delete_inventory(TRUE)
	outfit.equip(H, equip_adjustments = outfit.flags)
	log_and_message_admins("changed the equipment of [key_name(H)] to [outfit.name].")

/client/proc/startSinglo()
	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in world)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field_generator/F in world)
		if(F.anchored)
			F.Varedit_start = 1
	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in world)
			if(G.anchored)
				var/obj/singularity/S = new /obj/singularity(get_turf(G), 50)
				spawn(0)
					qdel(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in world)
		if(Rad.anchored)
			if(!Rad.P)
				var/obj/item/tank/phoron/Phoron = new/obj/item/tank/phoron(Rad)
				Phoron.air_contents.gas[GAS_PHORON] = 70
				Rad.drainratio = 0
				Rad.P = Phoron
				Phoron.forceMove(Rad)

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in world)
		if(SMES.anchored)
			SMES.input_attempt = 1

/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs", "Ghost Mobs", "Clients"))
		if("Players")
			to_chat(usr, jointext(GLOB.player_list,","))
		if("Admins")
			to_chat(usr, jointext(GLOB.admins,","))
		if("Mobs")
			to_chat(usr, jointext(SSmobs.mob_list,","))
		if("Living Mobs")
			to_chat(usr, jointext(GLOB.alive_mobs,","))
		if("Dead Mobs")
			to_chat(usr, jointext(GLOB.dead_mobs,","))
		if("Ghost Mobs")
			to_chat(usr, jointext(GLOB.ghost_mobs,","))
		if("Clients")
			to_chat(usr, jointext(GLOB.clients,","))

// DNA2 - Admin Hax
/client/proc/cmd_admin_toggle_block(mob/M,block)
	if(GAME_STATE < RUNLEVEL_GAME)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon))
		M.dna.SetSEState(block,!M.dna.GetSEState(block))
		domutcheck(M,null,MUTCHK_FORCED)
		M.update_mutations()
		var/state="[M.dna.GetSEState(block)?"on":"off"]"
		var/blockname=assigned_blocks[block]
		message_admins("[key_name_admin(src)] has toggled [M.key]'s [blockname] block [state]!")
		log_admin("[key_name(src)] has toggled [M.key]'s [blockname] block [state]!")
	else
		alert("Invalid mob")

/datum/admins/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the Runtime Viewer"

	if(!check_rights(R_DEBUG))
		return

	GLOB.error_cache.show_to(usr.client)

/client/proc/cmd_analyse_health_panel()
	set category = "Debug"
	set name = "Analyse Health"
	set desc = "Get an advanced health reading on a human mob."

	var/mob/living/carbon/human/H = input("Select mob.", "Analyse Health") as null|anything in GLOB.human_mobs
	if(!H)	return

	cmd_analyse_health(H)

/client/proc/cmd_analyse_health(mob/living/carbon/human/H)

	if(!check_rights(R_DEBUG))
		return

	if(!H)	return

	var/dat = display_medical_data(H.get_raw_medical_data(mutations = TRUE), SKILL_MAX)

	dat += "<A href='byond://?src=\ref[usr];mach_close=scanconsole'>Close</A>"
	show_browser(usr, dat, "window=scanconsole;size=430x600")

/client/proc/cmd_analyse_health_context(mob/living/carbon/human/H as mob in GLOB.human_mobs)
	set category = null
	set name = "Analyse Human Health"

	if(!check_rights(R_DEBUG))
		return
	if(!ishuman(H))	return
	cmd_analyse_health(H)

/obj/debugmarker
	icon = 'icons/effects/lighting_overlay.dmi'
	icon_state = "transparent"
	layer = HOLOMAP_LAYER
	alpha = 127

/client/var/list/image/powernet_markers = list()
/client/var/power_shadow_dashboard_live_enabled = FALSE
/client/var/power_shadow_dashboard_live_interval_ds = 20
/client/var/power_shadow_dashboard_view_mode = "All networks"
/client/var/power_shadow_dashboard_top_n = 120
/client/var/power_shadow_advanced_verbs_enabled = FALSE
/client/proc/visualpower()
	set category = "Debug"
	set name = "Visualize Powernets"

	if(!check_rights(R_DEBUG)) return
	visualpower_remove()
	powernet_markers = list()

	for(var/datum/powernet/PN in SSpowernets.powernets)
		var/netcolor = rgb(rand(100,255),rand(100,255),rand(100,255))
		for(var/obj/structure/cable/C in PN.cables)
			var/image/I = image('icons/effects/lighting_overlay.dmi', get_turf(C), "transparent")
			I.plane = DEFAULT_PLANE
			I.layer = EXPOSED_WIRE_LAYER
			I.alpha = 127
			I.color = netcolor
			I.maptext = "\ref[PN]"
			powernet_markers += I
	images += powernet_markers

/client/proc/visualpower_remove()
	set category = "Debug"
	set name = "Remove Powernets Visuals"

	images -= powernet_markers
	QDEL_NULL_LIST(powernet_markers)

/client/proc/profile_machinery_processing()
	set category = "Debug"
	set name = "Profile Machinery Processing"

	if(!check_rights(R_DEBUG))
		return

	if(!SSmachines.profiling_machinery)
		if(SSmachines.machinery_profile_auto_stopped)
			var/auto_report = SSmachines.report_machinery_hotspots()
			show_browser(src, "<html><head><title>Machinery Profiling (Auto-Stopped)</title></head><body><b>Auto-stopped at [SSmachines.profiling_machinery_cycles] cycles (limit: [SSmachines.profiling_machinery_cycle_limit]).</b><br><br>[auto_report]</body></html>", "window=machinery_profiling;size=900x600")
			SSmachines.machinery_profile_auto_stopped = FALSE
			to_chat(src, SPAN_NOTICE("Показан отчёт автоостановленного machinery profiling. Запусти верб ещё раз для нового прогона."))
			return
		var/new_limit = input(src, "Автостоп после N циклов (0 = выключено):", "Machinery profiling auto-stop", SSmachines.profiling_machinery_cycle_limit) as num|null
		if(isnull(new_limit))
			return
		SSmachines.profiling_machinery_cycle_limit = max(round(new_limit), 0)
		SSmachines.reset_machinery_profiling()
		SSmachines.profiling_machinery = TRUE
		to_chat(src, SPAN_NOTICE("Machinery profiling started. Current limit: [SSmachines.profiling_machinery_cycle_limit ? SSmachines.profiling_machinery_cycle_limit : "OFF"]. Run this verb again to stop and view results."))
		log_admin("[key_name(src)] started machinery processing profiling (cycle limit: [SSmachines.profiling_machinery_cycle_limit]).")
	else
		SSmachines.profiling_machinery = FALSE
		var/report = SSmachines.report_machinery_hotspots()
		show_browser(src, "<html><head><title>Machinery Profiling</title></head><body>[report]</body></html>", "window=machinery_profiling;size=900x600")
		log_admin("[key_name(src)] stopped machinery processing profiling ([SSmachines.profiling_machinery_cycles] cycles sampled, limit: [SSmachines.profiling_machinery_cycle_limit]).")

/client/proc/profile_air_alarm_processing()
	set category = "Debug"
	set name = "Profile Air Alarm Process"

	if(!check_rights(R_DEBUG))
		return

	if(!SSmachines.profiling_air_alarm_process)
		if(SSmachines.air_alarm_profile_auto_stopped)
			var/auto_report = SSmachines.report_air_alarm_process_profiling()
			show_browser(src, "<html><head><title>Air Alarm Profiling (Auto-Stopped)</title></head><body><b>Auto-stopped at [SSmachines.alarm_process_profile_cycles] cycles (limit: [SSmachines.profiling_air_alarm_cycle_limit]).</b><br><br>[auto_report]</body></html>", "window=air_alarm_profiling;size=900x600")
			SSmachines.air_alarm_profile_auto_stopped = FALSE
			to_chat(src, SPAN_NOTICE("Показан отчёт автоостановленного air alarm profiling. Запусти верб ещё раз для нового прогона."))
			return
		var/new_limit = input(src, "Автостоп после N циклов (0 = выключено):", "Air alarm profiling auto-stop", SSmachines.profiling_air_alarm_cycle_limit) as num|null
		if(isnull(new_limit))
			return
		SSmachines.profiling_air_alarm_cycle_limit = max(round(new_limit), 0)
		SSmachines.reset_air_alarm_process_profiling()
		SSmachines.profiling_air_alarm_process = TRUE
		to_chat(src, SPAN_NOTICE("Air alarm micro-profiling started. Current limit: [SSmachines.profiling_air_alarm_cycle_limit ? SSmachines.profiling_air_alarm_cycle_limit : "OFF"]. Run this verb again to stop and view results."))
		log_admin("[key_name(src)] started air alarm Process() micro-profiling (cycle limit: [SSmachines.profiling_air_alarm_cycle_limit]).")
	else
		SSmachines.profiling_air_alarm_process = FALSE
		var/report = SSmachines.report_air_alarm_process_profiling()
		show_browser(src, "<html><head><title>Air Alarm Profiling</title></head><body>[report]</body></html>", "window=air_alarm_profiling;size=900x600")
		log_admin("[key_name(src)] stopped air alarm Process() micro-profiling ([SSmachines.alarm_process_profile_cycles] cycles sampled, limit: [SSmachines.profiling_air_alarm_cycle_limit]).")

/client/proc/profile_apc_processing()
	set category = "Debug"
	set name = "Profile APC Process"

	if(!check_rights(R_DEBUG))
		return

	if(!SSmachines.profiling_apc_process)
		if(SSmachines.apc_profile_auto_stopped)
			var/auto_report = SSmachines.report_apc_process_profiling()
			show_browser(src, "<html><head><title>APC Profiling (Auto-Stopped)</title></head><body><b>Auto-stopped at [SSmachines.apc_process_profile_cycles] cycles (limit: [SSmachines.profiling_apc_cycle_limit]).</b><br><br>[auto_report]</body></html>", "window=apc_profiling;size=900x600")
			SSmachines.apc_profile_auto_stopped = FALSE
			to_chat(src, SPAN_NOTICE("Показан отчёт автоостановленного APC profiling. Запусти верб ещё раз для нового прогона."))
			return
		var/new_limit = input(src, "Автостоп после N циклов (0 = выключено):", "APC profiling auto-stop", SSmachines.profiling_apc_cycle_limit) as num|null
		if(isnull(new_limit))
			return
		SSmachines.profiling_apc_cycle_limit = max(round(new_limit), 0)
		SSmachines.reset_apc_process_profiling()
		SSmachines.profiling_apc_process = TRUE
		to_chat(src, SPAN_NOTICE("APC micro-profiling started. Current limit: [SSmachines.profiling_apc_cycle_limit ? SSmachines.profiling_apc_cycle_limit : "OFF"]. Run this verb again to stop and view results."))
		log_admin("[key_name(src)] started APC Process() micro-profiling (cycle limit: [SSmachines.profiling_apc_cycle_limit]).")
	else
		SSmachines.profiling_apc_process = FALSE
		var/report = SSmachines.report_apc_process_profiling()
		show_browser(src, "<html><head><title>APC Profiling</title></head><body>[report]</body></html>", "window=apc_profiling;size=900x600")
		log_admin("[key_name(src)] stopped APC Process() micro-profiling ([SSmachines.apc_process_profile_cycles] cycles sampled, limit: [SSmachines.profiling_apc_cycle_limit]).")

/client/proc/show_processing_profile_counters()
	set category = "Debug"
	set name = "Show Processing Profile Counters"

	if(!check_rights(R_DEBUG))
		return

	to_chat(src, SPAN_NOTICE("Machinery profiling: [SSmachines.profiling_machinery ? "ON" : "OFF"], cycles=[SSmachines.profiling_machinery_cycles], limit=[SSmachines.profiling_machinery_cycle_limit ? SSmachines.profiling_machinery_cycle_limit : "OFF"], auto_stopped=[SSmachines.machinery_profile_auto_stopped ? "YES" : "NO"]"))
	to_chat(src, SPAN_NOTICE("Air alarm profiling: [SSmachines.profiling_air_alarm_process ? "ON" : "OFF"], cycles=[SSmachines.alarm_process_profile_cycles], limit=[SSmachines.profiling_air_alarm_cycle_limit ? SSmachines.profiling_air_alarm_cycle_limit : "OFF"], auto_stopped=[SSmachines.air_alarm_profile_auto_stopped ? "YES" : "NO"]"))
	to_chat(src, SPAN_NOTICE("APC profiling: [SSmachines.profiling_apc_process ? "ON" : "OFF"], cycles=[SSmachines.apc_process_profile_cycles], limit=[SSmachines.profiling_apc_cycle_limit ? SSmachines.profiling_apc_cycle_limit : "OFF"], auto_stopped=[SSmachines.apc_profile_auto_stopped ? "YES" : "NO"]"))

/client/proc/toggle_embedded_docking_event_optimization()
	set category = "Debug"
	set name = "Toggle Docking Event Optimization"

	if(!check_rights(R_DEBUG))
		return

	SSmachines.optimize_embedded_docking_event = !SSmachines.optimize_embedded_docking_event
	var/state = SSmachines.optimize_embedded_docking_event ? "ON" : "OFF"
	var/refreshed = 0
	for(var/obj/machinery/embedded_controller/controller as anything in SSmachines.get_machinery_of_type(/obj/machinery/embedded_controller))
		if(!controller.optimize_event_processing)
			continue
		controller.refresh_processing_registration()
		refreshed++
	to_chat(src, SPAN_NOTICE("Docking embedded event optimization is now [state]."))
	log_admin("[key_name(src)] set docking embedded event optimization to [state] ([refreshed] controllers refreshed).")

/client/proc/toggle_machinery_event_optimization()
	set category = "Debug"
	set name = "Toggle Machinery Event Optimization"

	if(!check_rights(R_DEBUG))
		return

	SSmachines.optimize_machinery_event = !SSmachines.optimize_machinery_event
	var/state = SSmachines.optimize_machinery_event ? "ON" : "OFF"
	var/refreshed = 0
	for(var/obj/machinery/M as anything in SSmachines.get_all_machinery())
		var/is_event_machine = (istype(M, /obj/machinery/power/apc) || istype(M, /obj/machinery/alarm) || istype(M, /obj/machinery/atmospherics/unary/vent_pump) || istype(M, /obj/machinery/atmospherics/unary/vent_scrubber) || istype(M, /obj/machinery/portable_atmospherics) || istype(M, /obj/machinery/pointdefense) || istype(M, /obj/machinery/airlock_sensor))
		if(is_event_machine)
			START_PROCESSING_MACHINE(M, MACHINERY_PROCESS_SELF)
			refreshed++
	to_chat(src, SPAN_NOTICE("Machinery event optimization is now [state]. [refreshed] machines refreshed."))
	log_admin("[key_name(src)] set machinery event optimization to [state] ([refreshed] machines refreshed).")

/client/proc/show_machinery_distribution()
	set category = "Debug"
	set name = "Show Machinery Distribution"

	if(!check_rights(R_DEBUG))
		return

	var/report = SSmachines.report_machinery_distribution()
	show_browser(src, "<html><head><title>Machinery Distribution</title></head><body>[report]</body></html>", "window=machinery_distribution;size=900x600")
	log_admin("[key_name(src)] viewed machinery processing distribution.")

/client/proc/power_shadow_solver_toggle()
	set category = "Debug"
	set name = "Toggle Power Shadow Solver"

	if(!check_rights(R_DEBUG))
		return

	var/enable = alert(src, "Enable shadow solver comparison on all current powernets?", "Power Shadow Solver", "Enable", "Disable", "Cancel")
	if(enable == "Cancel")
		return

	var/new_state = (enable == "Enable")
	var/updated = 0
	var/locked = 0
	for(var/datum/powernet/PN in SSpowernets.powernets)
		if(PN.shadow_solver_force_fea_only && !new_state)
			locked++
			continue
		PN.shadow_solver_enabled = new_state
		PN.shadow_solver_mismatch = FALSE
		updated++

	to_chat(src, SPAN_NOTICE("Power shadow solver [new_state ? "enabled" : "disabled"] for [updated] powernets[locked ? " ([locked] locked in FEA-only)" : ""]."))
	log_and_message_admins("[key_name(src)] [new_state ? "enabled" : "disabled"] power shadow solver for [updated] powernets[locked ? " ([locked] locked in FEA-only)" : ""].")

/client/proc/toggle_power_shadow_advanced_verbs()
	set category = "Power Shadow"
	set name = "Toggle Advanced Verbs"

	if(!check_rights(R_DEBUG))
		return

	power_shadow_advanced_verbs_enabled = !power_shadow_advanced_verbs_enabled
	if(power_shadow_advanced_verbs_enabled)
		verbs += admin_verbs_power_shadow_advanced
	else
		verbs -= admin_verbs_power_shadow_advanced

	to_chat(src, SPAN_NOTICE("Power Shadow advanced tab [power_shadow_advanced_verbs_enabled ? "enabled" : "disabled"]."))
	log_admin("[key_name(src)] [power_shadow_advanced_verbs_enabled ? "enabled" : "disabled"] Power Shadow advanced verbs tab.")

/client/proc/power_shadow_solver_threshold()
	set category = "Power Shadow Advanced"
	set name = "Set Power Shadow Threshold"

	if(!check_rights(R_DEBUG))
		return

	var/threshold = input(src, "Set mismatch threshold in Watts.", "Power Shadow Solver", 5000) as num|null
	if(isnull(threshold))
		return

	threshold = max(round(threshold), 0)
	var/updated = 0
	for(var/datum/powernet/PN in SSpowernets.powernets)
		PN.shadow_solver_mismatch_threshold = threshold
		updated++

	to_chat(src, SPAN_NOTICE("Set power shadow mismatch threshold to [threshold]W for [updated] powernets."))
	log_and_message_admins("[key_name(src)] set power shadow solver mismatch threshold to [threshold]W for [updated] powernets.")

/client/proc/power_shadow_solver_backend()
	set category = "Power Shadow Advanced"
	set name = "Set Power Shadow Backend"

	if(!check_rights(R_DEBUG))
		return

	var/choice = input(src, "Select shadow solver backend for all current powernets.", "Power Shadow Solver") in list("Shadow FEA", "Strict Capacity Flow")
	if(!choice)
		return

	var/backend = (choice == "Strict Capacity Flow") ? "strict_capacity_flow" : "shadow_fea"
	var/updated = 0
	for(var/datum/powernet/PN in SSpowernets.powernets)
		PN.set_shadow_solver_backend(backend)
		updated++

	to_chat(src, SPAN_NOTICE("Set power shadow backend to [choice] for [updated] powernets."))
	log_and_message_admins("[key_name(src)] set power shadow backend to [choice] for [updated] powernets.")

/client/proc/power_shadow_solver_native_toggle()
	set category = "Power Shadow Advanced"
	set name = "Toggle Power Shadow Native"

	if(!check_rights(R_DEBUG))
		return

	var/enable = alert(src, "Enable native rust-g shadow solver path on all current powernets?", "Power Shadow Solver", "Enable", "Disable", "Cancel")
	if(!enable || enable == "Cancel")
		return

	var/new_state = (enable == "Enable")
	var/updated = 0
	for(var/datum/powernet/PN in SSpowernets.powernets)
		PN.shadow_solver_native_enabled = new_state
		updated++

	to_chat(src, SPAN_NOTICE("Power shadow native path [new_state ? "enabled" : "disabled"] for [updated] powernets."))
	log_and_message_admins("[key_name(src)] [new_state ? "enabled" : "disabled"] power shadow native path for [updated] powernets.")

/client/proc/power_shadow_solver_benchmark()
	set category = "Power Shadow"
	set name = "Benchmark Power Shadow Solver"

	if(!check_rights(R_DEBUG))
		return

	var/iterations = input(src, "Iterations per powernet for each mode.", "Power Shadow Benchmark", 100) as num|null
	if(isnull(iterations))
		return
	iterations = max(round(iterations), 1)

	var/list/targets = list()
	for(var/datum/powernet/PN in SSpowernets.powernets)
		if(!PN.shadow_solver_enabled)
			continue
		targets += PN

	if(!length(targets))
		to_chat(src, SPAN_WARNING("No enabled powernets found for benchmark."))
		return

	var/list/original_native_flags = list()
	var/list/solvers = list()
	var/list/prebuilt_native_payload_json = list()
	var/original_autogate_enabled = SSpowernets.power_shadow_native_autogate_enabled
	SSpowernets.power_shadow_native_autogate_enabled = FALSE
	for(var/datum/powernet/PN in targets)
		original_native_flags[PN] = PN.shadow_solver_native_enabled
		var/datum/power_solver/solver = PN.ensure_shadow_solver()
		if(!istype(solver))
			continue
		solvers[PN] = solver
		var/list/native_payload = PN.shadow_solver_native_compact_supported ? PN.build_shadow_solver_native_payload_compact(solver) : PN.build_shadow_solver_native_payload(solver)
		if(!islist(native_payload))
			continue
		var/payload_json = json_encode(native_payload)
		if(istext(payload_json) && length(payload_json))
			prebuilt_native_payload_json[PN] = payload_json

	var/core_dm_samples = 0
	var/core_native_samples = 0
	var/e2e_dm_samples = 0
	var/e2e_native_samples = 0
	var/e2e_native_batch_samples = 0

	var/timer_dm_core = "power_shadow_bench_dm_core_[ckey]_[(world.timeofday % 864000)]"
	rustg_time_reset(timer_dm_core)
	for(var/datum/powernet/PN in targets)
		var/datum/power_solver/solver = solvers[PN]
		if(!istype(solver))
			continue
		for(var/i = 1 to iterations)
			var/list/snapshot
			if(istype(solver, /datum/power_solver/shadow_fea))
				var/datum/power_solver/shadow_fea/shadow_solver = solver
				snapshot = shadow_solver.solve_shadow_fea(PN)
			else if(istype(solver, /datum/power_solver/strict_capacity_flow))
				var/datum/power_solver/strict_capacity_flow/strict_solver = solver
				snapshot = strict_solver.solve_strict_capacity_flow(PN)
			if(islist(snapshot))
				core_dm_samples++
	var/core_dm_total_us = max(rustg_time_microseconds(timer_dm_core), 0)

	var/timer_native_core = "power_shadow_bench_native_core_[ckey]_[(world.timeofday % 864000)]"
	rustg_time_reset(timer_native_core)
	for(var/datum/powernet/PN in targets)
		var/payload_json = prebuilt_native_payload_json[PN]
		if(!istext(payload_json) || !length(payload_json))
			continue
		for(var/i = 1 to iterations)
			var/raw = rustg_power_shadow_solve(payload_json)
			if(istext(raw) && length(raw))
				core_native_samples++
	var/core_native_total_us = max(rustg_time_microseconds(timer_native_core), 0)

	var/timer_dm_e2e = "power_shadow_bench_dm_e2e_[ckey]_[(world.timeofday % 864000)]"
	rustg_time_reset(timer_dm_e2e)
	for(var/datum/powernet/PN in targets)
		var/datum/power_solver/solver = solvers[PN]
		if(!istype(solver))
			continue
		PN.shadow_solver_native_enabled = FALSE
		for(var/i = 1 to iterations)
			var/list/snapshot = PN.get_shadow_solver_snapshot(solver)
			if(islist(snapshot))
				e2e_dm_samples++
	var/e2e_dm_total_us = max(rustg_time_microseconds(timer_dm_e2e), 0)

	var/timer_native_e2e = "power_shadow_bench_native_e2e_[ckey]_[(world.timeofday % 864000)]"
	for(var/datum/powernet/PN in targets)
		PN.reset_shadow_solver_native_perf()
	SSpowernets.reset_power_shadow_native_batch_perf()
	rustg_time_reset(timer_native_e2e)
	for(var/datum/powernet/PN in targets)
		var/datum/power_solver/solver = solvers[PN]
		if(!istype(solver))
			continue
		PN.shadow_solver_native_enabled = TRUE
		for(var/i = 1 to iterations)
			var/list/snapshot = PN.get_shadow_solver_snapshot(solver, TRUE)
			if(islist(snapshot))
				e2e_native_samples++
	var/e2e_native_total_us = max(rustg_time_microseconds(timer_native_e2e), 0)

	var/timer_native_e2e_batch = "power_shadow_bench_native_e2e_batch_[ckey]_[(world.timeofday % 864000)]"
	for(var/datum/powernet/PN in targets)
		PN.shadow_solver_native_enabled = TRUE
	rustg_time_reset(timer_native_e2e_batch)
	for(var/i = 1 to iterations)
		var/list/batch_snapshots = SSpowernets.power_shadow_native_solve_batch(targets, TRUE)
		if(islist(batch_snapshots))
			e2e_native_batch_samples += length(batch_snapshots)
	var/e2e_native_batch_total_us = max(rustg_time_microseconds(timer_native_e2e_batch), 0)

	for(var/datum/powernet/PN in targets)
		PN.shadow_solver_native_enabled = original_native_flags[PN]
	SSpowernets.power_shadow_native_autogate_enabled = original_autogate_enabled

	var/core_dm_avg_us = core_dm_samples ? round(core_dm_total_us / core_dm_samples, 0.001) : 0
	var/core_native_avg_us = core_native_samples ? round(core_native_total_us / core_native_samples, 0.001) : 0
	var/e2e_dm_avg_us = e2e_dm_samples ? round(e2e_dm_total_us / e2e_dm_samples, 0.001) : 0
	var/e2e_native_avg_us = e2e_native_samples ? round(e2e_native_total_us / e2e_native_samples, 0.001) : 0
	var/e2e_native_batch_avg_us = e2e_native_batch_samples ? round(e2e_native_batch_total_us / e2e_native_batch_samples, 0.001) : 0
	var/core_speedup = (core_native_avg_us > 0) ? round(core_dm_avg_us / core_native_avg_us, 0.01) : 0
	var/e2e_speedup = (e2e_native_avg_us > 0) ? round(e2e_dm_avg_us / e2e_native_avg_us, 0.01) : 0
	var/e2e_batch_speedup = (e2e_native_batch_avg_us > 0) ? round(e2e_dm_avg_us / e2e_native_batch_avg_us, 0.01) : 0

	var/native_phase_samples = 0
	var/native_build_us_sum = 0
	var/native_encode_us_sum = 0
	var/native_call_us_sum = 0
	var/native_decode_us_sum = 0
	for(var/datum/powernet/PN in targets)
		native_phase_samples += max(PN.shadow_solver_native_perf_samples, 0)
		native_build_us_sum += max(PN.shadow_solver_native_perf_build_us_sum, 0)
		native_encode_us_sum += max(PN.shadow_solver_native_perf_encode_us_sum, 0)
		native_call_us_sum += max(PN.shadow_solver_native_perf_call_us_sum, 0)
		native_decode_us_sum += max(PN.shadow_solver_native_perf_decode_us_sum, 0)

	var/native_build_avg_us = native_phase_samples ? round(native_build_us_sum / native_phase_samples, 0.001) : 0
	var/native_encode_avg_us = native_phase_samples ? round(native_encode_us_sum / native_phase_samples, 0.001) : 0
	var/native_call_avg_us = native_phase_samples ? round(native_call_us_sum / native_phase_samples, 0.001) : 0
	var/native_decode_avg_us = native_phase_samples ? round(native_decode_us_sum / native_phase_samples, 0.001) : 0
	var/list/batch_perf = SSpowernets.get_power_shadow_native_batch_perf_data()
	var/batch_phase_samples = max(batch_perf["samples"], 0)
	var/batch_build_avg_us = batch_phase_samples ? round(batch_perf["avg_build_us"], 0.001) : 0
	var/batch_encode_avg_us = batch_phase_samples ? round(batch_perf["avg_encode_us"], 0.001) : 0
	var/batch_call_avg_us = batch_phase_samples ? round(batch_perf["avg_call_us"], 0.001) : 0
	var/batch_decode_avg_us = batch_phase_samples ? round(batch_perf["avg_decode_us"], 0.001) : 0

	to_chat(src, SPAN_NOTICE("Power shadow benchmark complete: Core DM=[core_dm_total_us] us total, avg [core_dm_avg_us] us, samples=[core_dm_samples]; Core Native=[core_native_total_us] us total, avg [core_native_avg_us] us, samples=[core_native_samples][core_speedup ? ", speedup x[core_speedup]" : ""]; E2E DM=[e2e_dm_total_us] us total, avg [e2e_dm_avg_us] us, samples=[e2e_dm_samples]; E2E Native(single)=[e2e_native_total_us] us total, avg [e2e_native_avg_us] us, samples=[e2e_native_samples][e2e_speedup ? ", speedup x[e2e_speedup]" : ""]; E2E Native(batch)=[e2e_native_batch_total_us] us total, avg [e2e_native_batch_avg_us] us, samples=[e2e_native_batch_samples][e2e_batch_speedup ? ", speedup x[e2e_batch_speedup]" : ""]; Native phases avg(us): build=[native_build_avg_us], encode=[native_encode_avg_us], call=[native_call_avg_us], decode=[native_decode_avg_us], profiled_samples=[native_phase_samples]; Batch phases avg(us): build=[batch_build_avg_us], encode=[batch_encode_avg_us], call=[batch_call_avg_us], decode=[batch_decode_avg_us], profiled_samples=[batch_phase_samples]."))
	log_and_message_admins("[key_name(src)] ran power shadow benchmark: iterations=[iterations], networks=[length(targets)], autogate_disabled_during_benchmark=TRUE, core_dm_total_us=[core_dm_total_us], core_dm_avg_us=[core_dm_avg_us], core_dm_samples=[core_dm_samples], core_native_total_us=[core_native_total_us], core_native_avg_us=[core_native_avg_us], core_native_samples=[core_native_samples], core_speedup=[core_speedup], e2e_dm_total_us=[e2e_dm_total_us], e2e_dm_avg_us=[e2e_dm_avg_us], e2e_dm_samples=[e2e_dm_samples], e2e_native_total_us=[e2e_native_total_us], e2e_native_avg_us=[e2e_native_avg_us], e2e_native_samples=[e2e_native_samples], e2e_speedup=[e2e_speedup], e2e_native_batch_total_us=[e2e_native_batch_total_us], e2e_native_batch_avg_us=[e2e_native_batch_avg_us], e2e_native_batch_samples=[e2e_native_batch_samples], e2e_batch_speedup=[e2e_batch_speedup], native_phase_samples=[native_phase_samples], native_build_avg_us=[native_build_avg_us], native_encode_avg_us=[native_encode_avg_us], native_call_avg_us=[native_call_avg_us], native_decode_avg_us=[native_decode_avg_us], batch_phase_samples=[batch_phase_samples], batch_build_avg_us=[batch_build_avg_us], batch_encode_avg_us=[batch_encode_avg_us], batch_call_avg_us=[batch_call_avg_us], batch_decode_avg_us=[batch_decode_avg_us].")

/client/proc/power_shadow_solver_guard_settings()
	set category = "Power Shadow Advanced"
	set name = "Set Power Shadow Guard"

	if(!check_rights(R_DEBUG))
		return

	var/threshold = input(src, "Guard trip threshold (consecutive mismatch ticks).", "Power Shadow Solver", 5) as num|null
	if(isnull(threshold))
		return
	var/cooldown = input(src, "Guard cooldown ticks after rollback.", "Power Shadow Solver", 300) as num|null
	if(isnull(cooldown))
		return

	threshold = max(round(threshold), 1)
	cooldown = max(round(cooldown), 0)

	var/updated = 0
	for(var/datum/powernet/PN in SSpowernets.powernets)
		PN.shadow_solver_guard_trip_threshold = threshold
		PN.shadow_solver_guard_cooldown_ticks = cooldown
		updated++

	to_chat(src, SPAN_NOTICE("Set shadow guard threshold=[threshold], cooldown=[cooldown] for [updated] powernets."))
	log_and_message_admins("[key_name(src)] set shadow guard threshold=[threshold], cooldown=[cooldown] for [updated] powernets.")

/client/proc/power_shadow_solver_guard_threshold_override()
	set category = "Power Shadow Advanced"
	set name = "Set Power Guard Threshold"

	if(!check_rights(R_DEBUG))
		return

	var/override_threshold = input(src, "Set guard mismatch threshold override in Watts (0 = use global shadow threshold).", "Power Shadow Solver", 0) as num|null
	if(isnull(override_threshold))
		return

	override_threshold = max(round(override_threshold), 0)
	var/updated = 0
	for(var/datum/powernet/PN in SSpowernets.powernets)
		PN.shadow_solver_guard_mismatch_threshold_override = override_threshold
		updated++

	to_chat(src, SPAN_NOTICE("Set guard mismatch threshold override to [override_threshold]W for [updated] powernets."))
	log_and_message_admins("[key_name(src)] set guard mismatch threshold override to [override_threshold]W for [updated] powernets.")

/client/proc/power_shadow_solver_acceptance_settings()
	set category = "Power Shadow Advanced"
	set name = "Set Power Acceptance"

	if(!check_rights(R_DEBUG))
		return

	var/min_samples = input(src, "Minimum samples required for acceptance.", "Power Shadow Solver", 50) as num|null
	if(isnull(min_samples))
		return
	var/max_mismatch_rate = input(src, "Max mismatch rate (%)", "Power Shadow Solver", 12.5) as num|null
	if(isnull(max_mismatch_rate))
		return
	var/max_avg_load_delta = input(src, "Max average absolute load delta (W)", "Power Shadow Solver", 12000) as num|null
	if(isnull(max_avg_load_delta))
		return
	var/max_avg_avail_delta = input(src, "Max average absolute avail delta (W)", "Power Shadow Solver", 12000) as num|null
	if(isnull(max_avg_avail_delta))
		return
	var/max_avg_unserved = input(src, "Max average unserved (W)", "Power Shadow Solver", 8000) as num|null
	if(isnull(max_avg_unserved))
		return

	min_samples = max(round(min_samples), 1)
	max_mismatch_rate = max(max_mismatch_rate, 0)
	max_avg_load_delta = max(round(max_avg_load_delta), 0)
	max_avg_avail_delta = max(round(max_avg_avail_delta), 0)
	max_avg_unserved = max(round(max_avg_unserved), 0)

	var/updated = 0
	for(var/datum/powernet/PN in SSpowernets.powernets)
		PN.shadow_solver_acceptance_min_samples = min_samples
		PN.shadow_solver_acceptance_max_mismatch_rate = max_mismatch_rate
		PN.shadow_solver_acceptance_max_avg_load_delta = max_avg_load_delta
		PN.shadow_solver_acceptance_max_avg_avail_delta = max_avg_avail_delta
		PN.shadow_solver_acceptance_max_avg_unserved = max_avg_unserved
		updated++

	to_chat(src, SPAN_NOTICE("Updated acceptance criteria for [updated] powernets."))
	log_and_message_admins("[key_name(src)] updated shadow acceptance criteria for [updated] powernets.")

/client/proc/power_shadow_solver_export_report()
	set category = "Power Shadow"
	set name = "Export Power Shadow Report"

	if(!check_rights(R_DEBUG))
		return

	var/networks = 0
	var/enabled = 0
	var/rollbacks = 0
	var/weighted_samples = 0
	var/weighted_mismatch = 0
	var/weighted_load_delta = 0
	var/weighted_avail_delta = 0
	var/weighted_unserved = 0
	var/pass_count = 0
	var/guard_threshold_sum = 0

	for(var/datum/powernet/PN in SSpowernets.powernets)
		networks++
		if(PN.shadow_solver_enabled)
			enabled++
		if(PN.evaluate_shadow_solver_acceptance())
			pass_count++
		guard_threshold_sum += PN.get_shadow_solver_guard_threshold()
		rollbacks += PN.shadow_solver_guard_rollback_events
		var/list/st = PN.get_shadow_solver_stats_data()
		var/samples = st["samples"]
		weighted_samples += samples
		weighted_mismatch += st["mismatch_rate"] * samples
		weighted_load_delta += st["avg_abs_load_delta"] * samples
		weighted_avail_delta += st["avg_abs_avail_delta"] * samples
		weighted_unserved += st["avg_unserved"] * samples

	var/report_mismatch = weighted_samples ? round(weighted_mismatch / weighted_samples, 0.1) : 0
	var/report_load_delta = weighted_samples ? round(weighted_load_delta / weighted_samples, 0.1) : 0
	var/report_avail_delta = weighted_samples ? round(weighted_avail_delta / weighted_samples, 0.1) : 0
	var/report_unserved = weighted_samples ? round(weighted_unserved / weighted_samples, 0.1) : 0
	var/avg_guard_threshold = networks ? round(guard_threshold_sum / networks, 0.1) : 0
	var/pass_rate = networks ? round((pass_count / networks) * 100, 0.1) : 0

	log_debug("POWER SHADOW REPORT: networks=[networks], enabled=[enabled], samples=[weighted_samples], mismatch_rate=[report_mismatch]%, avg_abs_load_delta=[report_load_delta], avg_abs_avail_delta=[report_avail_delta], avg_unserved=[report_unserved], guard_rollbacks=[rollbacks], acceptance_pass=[pass_count]/[networks] ([pass_rate]%), avg_guard_threshold=[avg_guard_threshold]")
	to_chat(src, SPAN_NOTICE("Power shadow report exported. Networks=[networks], mismatch=[report_mismatch]%, pass=[pass_rate]%, rollbacks=[rollbacks]."))
	log_and_message_admins("[key_name(src)] exported power shadow report (networks=[networks], mismatch=[report_mismatch]%, pass=[pass_rate]%, rollbacks=[rollbacks]).")

/client/proc/power_shadow_solver_auto_repair()
	set category = "Power Shadow"
	set name = "Auto Repair Powernets"

	if(!check_rights(R_DEBUG))
		return

	var/delta_threshold = input(src, "Absolute Delta threshold (W) for anomaly detection.", "Power Shadow Auto Repair", 300000) as num|null
	if(isnull(delta_threshold))
		return
	var/unserved_threshold = input(src, "Unserved threshold (W) for anomaly detection.", "Power Shadow Auto Repair", 100000) as num|null
	if(isnull(unserved_threshold))
		return

	delta_threshold = max(round(delta_threshold), 0)
	unserved_threshold = max(round(unserved_threshold), 0)

	var/list/collected = SSpowernets.power_shadow_collect_anomalies(delta_threshold, unserved_threshold)
	var/problem_count = collected["problem_count"]
	var/networks = collected["networks"]
	var/list/problem_refs = collected["problem_refs"]

	if(!problem_count)
		to_chat(src, SPAN_NOTICE("Auto Repair: no anomalous powernets found (thresholds: delta=[delta_threshold]W, unserved=[unserved_threshold]W)."))
		return

	var/action = alert(src, "Detected [problem_count]/[networks] anomalous powernets. Choose repair mode.", "Power Shadow Auto Repair", "Retune", "Retune + Rebuild", "Cancel")
	if(action == "Cancel")
		return

	var/do_rebuild = (action == "Retune + Rebuild")
	var/list/result = SSpowernets.power_shadow_apply_auto_repair(delta_threshold, unserved_threshold, do_rebuild)
	var/retuned = result["retuned"]
	var/backend_switched = result["backend_switched"]
	var/rebuilt = result["rebuilt"]

	to_chat(src, SPAN_NOTICE("Auto Repair complete. Retuned [retuned] networks, backend fallback on [backend_switched], rebuilt [rebuilt]. Suspected refs (first 10): [english_list(problem_refs)]."))
	log_and_message_admins("[key_name(src)] ran auto powernet repair: anomalies=[problem_count]/[networks], retuned=[retuned], backend_switched=[backend_switched], rebuilt=[rebuilt], thresholds delta=[delta_threshold]W unserved=[unserved_threshold]W.")

/client/proc/power_shadow_solver_dashboard_live_loop()
	set waitfor = FALSE

	while(power_shadow_dashboard_live_enabled)
		// Update the already opened dashboard UI in place; do not force-open a new window each tick.
		power_shadow_solver_dashboard_render(power_shadow_dashboard_view_mode, power_shadow_dashboard_top_n, TRUE, FALSE)
		sleep(max(power_shadow_dashboard_live_interval_ds, 5))

/client/proc/power_shadow_solver_dashboard_topic(list/href_list)
	if(!islist(href_list))
		return FALSE
	var/action = href_list["power_shadow_dash_action"]
	if(!action)
		return FALSE
	if(!check_rights(R_DEBUG))
		return TRUE

	switch(action)
		if("refresh")
			power_shadow_solver_dashboard_render(power_shadow_dashboard_view_mode, power_shadow_dashboard_top_n, power_shadow_dashboard_live_enabled, FALSE)
			return TRUE
		if("toggle_live")
			var/need_spawn = !power_shadow_dashboard_live_enabled
			power_shadow_dashboard_live_enabled = !power_shadow_dashboard_live_enabled
			if(power_shadow_dashboard_live_enabled && need_spawn)
				power_shadow_solver_dashboard_live_loop()
			power_shadow_solver_dashboard_render(power_shadow_dashboard_view_mode, power_shadow_dashboard_top_n, power_shadow_dashboard_live_enabled, FALSE)
			return TRUE
		if("view_all")
			power_shadow_dashboard_view_mode = "All networks"
			power_shadow_solver_dashboard_render(power_shadow_dashboard_view_mode, power_shadow_dashboard_top_n, power_shadow_dashboard_live_enabled, FALSE)
			return TRUE
		if("view_problematic")
			power_shadow_dashboard_view_mode = "Problematic only"
			power_shadow_solver_dashboard_render(power_shadow_dashboard_view_mode, power_shadow_dashboard_top_n, power_shadow_dashboard_live_enabled, FALSE)
			return TRUE
		if("top_dec")
			power_shadow_dashboard_top_n = max(power_shadow_dashboard_top_n - 20, 20)
			power_shadow_solver_dashboard_render(power_shadow_dashboard_view_mode, power_shadow_dashboard_top_n, power_shadow_dashboard_live_enabled, FALSE)
			return TRUE
		if("top_inc")
			power_shadow_dashboard_top_n = min(power_shadow_dashboard_top_n + 20, 500)
			power_shadow_solver_dashboard_render(power_shadow_dashboard_view_mode, power_shadow_dashboard_top_n, power_shadow_dashboard_live_enabled, FALSE)
			return TRUE
		if("interval_dec")
			power_shadow_dashboard_live_interval_ds = max(power_shadow_dashboard_live_interval_ds - 10, 10)
			power_shadow_solver_dashboard_render(power_shadow_dashboard_view_mode, power_shadow_dashboard_top_n, power_shadow_dashboard_live_enabled, FALSE)
			return TRUE
		if("interval_inc")
			power_shadow_dashboard_live_interval_ds = min(power_shadow_dashboard_live_interval_ds + 10, 300)
			power_shadow_solver_dashboard_render(power_shadow_dashboard_view_mode, power_shadow_dashboard_top_n, power_shadow_dashboard_live_enabled, FALSE)
			return TRUE

	return TRUE

/client/proc/power_shadow_solver_dashboard()
	set category = "Power Shadow"
	set name = "Power Shadow Dashboard"

	if(!check_rights(R_DEBUG))
		return

	var/view_mode = input(src, "Dashboard view mode", "Power Shadow Dashboard") in list("All networks", "Problematic only")
	if(!view_mode)
		return
	var/top_n = input(src, "Maximum rows to display (sorted by Delta desc).", "Power Shadow Dashboard", 120) as num|null
	if(isnull(top_n))
		return
	top_n = max(round(top_n), 1)

	var/live_choice = alert(src, "Enable live auto-refresh?", "Power Shadow Dashboard", "Live", "Static", "Cancel")
	if(live_choice == "Cancel")
		return

	power_shadow_dashboard_view_mode = view_mode
	power_shadow_dashboard_top_n = top_n

	if(live_choice == "Live")
		var/interval_seconds = input(src, "Refresh interval in seconds (min 1).", "Power Shadow Dashboard", round(power_shadow_dashboard_live_interval_ds / 10, 0.1)) as num|null
		if(isnull(interval_seconds))
			return
		interval_seconds = max(interval_seconds, 1)
		power_shadow_dashboard_live_interval_ds = round(interval_seconds * 10)
		var/need_spawn = !power_shadow_dashboard_live_enabled
		power_shadow_dashboard_live_enabled = TRUE
		if(need_spawn)
			power_shadow_solver_dashboard_live_loop()
	else
		power_shadow_dashboard_live_enabled = FALSE

	power_shadow_solver_dashboard_render(power_shadow_dashboard_view_mode, power_shadow_dashboard_top_n, power_shadow_dashboard_live_enabled, TRUE)

/client/proc/power_shadow_solver_dashboard_render(view_mode = "All networks", top_n = 120, live_mode = FALSE, force_open = TRUE)
	var/problem_only = (view_mode == "Problematic only")

	var/networks = 0
	var/enabled = 0
	var/locked = 0
	var/rollbacks = 0
	var/problem_networks = 0
	var/pass_count = 0
	var/weighted_samples = 0
	var/weighted_mismatch = 0
	var/weighted_load_delta = 0
	var/weighted_avail_delta = 0
	var/weighted_unserved_primary = 0
	var/sum_unserved_deferred = 0
	var/sum_unserved_total = 0
	var/guard_threshold_sum = 0
	var/max_abs_delta = 1
	var/max_unserved = 1
	var/list/rows_by_ref = list()
	var/list/sorted_refs = list()

	for(var/datum/powernet/PN in SSpowernets.powernets)
		networks++
		if(PN.shadow_solver_enabled)
			enabled++
		if(PN.shadow_solver_force_fea_only)
			locked++
		if(PN.evaluate_shadow_solver_acceptance())
			pass_count++
		rollbacks += PN.shadow_solver_guard_rollback_events
		guard_threshold_sum += PN.get_shadow_solver_guard_threshold()

		var/list/st = PN.get_shadow_solver_stats_data()
		var/samples = st["samples"]
		weighted_samples += samples
		weighted_mismatch += st["mismatch_rate"] * samples
		weighted_load_delta += st["avg_abs_load_delta"] * samples
		weighted_avail_delta += st["avg_abs_avail_delta"] * samples
		weighted_unserved_primary += st["avg_unserved"] * samples
		sum_unserved_deferred += PN.shadow_solver_last_deferred_unserved
		sum_unserved_total += PN.shadow_solver_last_total_unserved

		var/abs_delta = abs(PN.shadow_solver_avail_delta) + abs(PN.shadow_solver_load_delta)
		var/acceptance_problem = !PN.shadow_solver_acceptance_last_pass && PN.shadow_solver_acceptance_last_reason != "insufficient_samples"
		var/is_problem = PN.shadow_solver_mismatch || acceptance_problem || PN.is_shadow_solver_unserved_persistent() || abs_delta >= PN.shadow_solver_mismatch_threshold
		if(is_problem)
			problem_networks++
		if(problem_only && !is_problem)
			continue
		max_abs_delta = max(max_abs_delta, abs_delta)
		max_unserved = max(max_unserved, PN.shadow_solver_last_unserved)

		var/net_ref = "\ref[PN]"
		rows_by_ref[net_ref] = list(
			net_ref,
			length(PN.nodes),
			length(PN.cables),
			PN.get_shadow_solver_backend_name(),
			PN.get_shadow_solver_write_mode_name(),
			round(PN.avail),
			round(PN.load),
			round(PN.shadow_solver_last_unserved),
			round(PN.shadow_solver_last_deferred_unserved),
			round(PN.shadow_solver_last_total_unserved),
			round(PN.shadow_solver_avail_delta),
			round(PN.shadow_solver_load_delta),
			round(abs_delta),
			PN.shadow_solver_mismatch,
			PN.get_shadow_solver_guard_state_name(),
			PN.get_shadow_solver_acceptance_state_name(),
			samples,
			PN.shadow_solver_guard_rollback_events,
			is_problem
		)

	for(var/net_ref in rows_by_ref)
		var/list/current_row = rows_by_ref[net_ref]
		if(!islist(current_row))
			continue
		if(length(current_row) < 19)
			continue
		var/inserted = FALSE
		for(var/i = 1 to length(sorted_refs))
			var/existing_ref = sorted_refs[i]
			var/list/existing_row = rows_by_ref[existing_ref]
			if(!islist(existing_row) || length(existing_row) < 13)
				continue
			var/current_delta = text2num("[current_row[13]]")
			var/existing_delta = text2num("[existing_row[13]]")
			if(current_delta > existing_delta)
				sorted_refs.Insert(i, net_ref)
				inserted = TRUE
				break
		if(!inserted)
			sorted_refs.Add(net_ref)

	var/report_mismatch = weighted_samples ? round(weighted_mismatch / weighted_samples, 0.1) : 0
	var/report_load_delta = weighted_samples ? round(weighted_load_delta / weighted_samples, 0.1) : 0
	var/report_avail_delta = weighted_samples ? round(weighted_avail_delta / weighted_samples, 0.1) : 0
	var/report_unserved_primary = weighted_samples ? round(weighted_unserved_primary / weighted_samples, 0.1) : 0
	var/report_unserved_deferred = networks ? round(sum_unserved_deferred / networks, 0.1) : 0
	var/report_unserved_total = networks ? round(sum_unserved_total / networks, 0.1) : 0
	var/pass_rate = networks ? round((pass_count / networks) * 100, 0.1) : 0
	var/avg_guard_threshold = networks ? round(guard_threshold_sum / networks, 0.1) : 0
	var/powernet_cost = round(SSpowernets.cost_powernets, 0.01)
	var/total_cost = max(SSpipenets.cost_pipenets + SSmachines.cost_machinery + SSpowernets.cost_powernets + SSpowernets.cost_power_objects, 0.01)
	var/powernet_cost_share = round((SSpowernets.cost_powernets / total_cost) * 100, 0.1)
	var/cost_per_network = networks ? round(powernet_cost / networks, 0.0001) : 0
	var/list/batch_perf = SSpowernets.get_power_shadow_native_batch_perf_data()
	var/batch_perf_samples = max(batch_perf["samples"], 0)
	var/batch_perf_build_avg_us = batch_perf_samples ? round(batch_perf["avg_build_us"], 0.001) : 0
	var/batch_perf_encode_avg_us = batch_perf_samples ? round(batch_perf["avg_encode_us"], 0.001) : 0
	var/batch_perf_call_avg_us = batch_perf_samples ? round(batch_perf["avg_call_us"], 0.001) : 0
	var/batch_perf_decode_avg_us = batch_perf_samples ? round(batch_perf["avg_decode_us"], 0.001) : 0

	var/list/dashboard_rows = list()

	var/rendered_rows = 0
	for(var/net_ref in sorted_refs)
		if(rendered_rows >= top_n)
			break
		var/list/r = rows_by_ref[net_ref]
		if(!islist(r))
			continue
		if(length(r) < 19)
			continue
		net_ref = r[1]
		var/nodes_count = r[2]
		var/cables_count = r[3]
		var/backend_raw = r[4]
		var/mode_raw = r[5]
		var/avail_value = text2num("[r[6]]")
		var/load_value = text2num("[r[7]]")
		var/unserved_primary = text2num("[r[8]]")
		var/unserved_deferred = text2num("[r[9]]")
		var/unserved_total = text2num("[r[10]]")
		var/delta_avail = text2num("[r[11]]")
		var/delta_load = text2num("[r[12]]")
		var/delta_total = text2num("[r[13]]")
		var/mismatch_flag = r[14]
		var/guard_raw = r[15]
		var/acceptance_raw = r[16]
		var/samples_count = text2num("[r[17]]")
		var/rollback_count = text2num("[r[18]]")
		var/is_problem = r[19]

		var/load_ratio_max = max(max(load_value, avail_value), 1)
		var/load_ratio = round(clamp((load_value / load_ratio_max) * 100, 0, 100), 0.1)
		var/delta_ratio = round(clamp((delta_total / max(max_abs_delta, 1)) * 100, 0, 100), 0.1)
		var/unserved_ratio = round(clamp((unserved_primary / max(max_unserved, 1)) * 100, 0, 100), 0.1)
		var/mismatch_text = mismatch_flag ? "YES" : "no"
		var/backend_name = "[backend_raw]"
		var/mode_name = "[mode_raw]"
		var/guard_state = "[guard_raw]"
		var/acceptance_state = "[acceptance_raw]"
		var/load_bar_style = "bad"
		if(load_ratio < 50)
			load_bar_style = "good"
		else if(load_ratio < 80)
			load_bar_style = "average"
		var/delta_bar_style = "bad"
		if(delta_ratio < 25)
			delta_bar_style = "good"
		else if(delta_ratio < 60)
			delta_bar_style = "average"
		var/unserved_bar_style = "bad"
		if(unserved_ratio < 10)
			unserved_bar_style = "good"
		else if(unserved_ratio < 35)
			unserved_bar_style = "average"

		dashboard_rows += list(list(
			"net_ref" = net_ref,
			"nodes" = nodes_count,
			"cables" = cables_count,
			"backend" = backend_name,
			"mode" = mode_name,
			"load" = load_value,
			"avail" = avail_value,
			"unserved_primary" = unserved_primary,
			"unserved_deferred" = unserved_deferred,
			"unserved_total" = unserved_total,
			"delta_avail" = delta_avail,
			"delta_load" = delta_load,
			"delta_total" = delta_total,
			"load_ratio" = load_ratio,
			"delta_ratio" = delta_ratio,
			"unserved_ratio" = unserved_ratio,
			"load_bar_style" = load_bar_style,
			"delta_bar_style" = delta_bar_style,
			"unserved_bar_style" = unserved_bar_style,
			"mismatch" = mismatch_text,
			"guard" = guard_state,
			"acceptance" = acceptance_state,
			"samples" = samples_count,
			"rollbacks" = rollback_count,
			"is_problem" = is_problem
		))
		rendered_rows++

	var/list/data = list(
		"view_mode" = view_mode,
		"top_n" = top_n,
		"live_mode" = live_mode,
		"live_interval" = round(power_shadow_dashboard_live_interval_ds / 10, 0.1),
		"powernet_cost" = powernet_cost,
		"powernet_cost_share" = powernet_cost_share,
		"cost_per_network" = cost_per_network,
		"batch_perf_samples" = batch_perf_samples,
		"batch_perf_build_avg_us" = batch_perf_build_avg_us,
		"batch_perf_encode_avg_us" = batch_perf_encode_avg_us,
		"batch_perf_call_avg_us" = batch_perf_call_avg_us,
		"batch_perf_decode_avg_us" = batch_perf_decode_avg_us,
		"networks" = networks,
		"enabled" = enabled,
		"locked" = locked,
		"problem_networks" = problem_networks,
		"report_mismatch" = report_mismatch,
		"report_load_delta" = round(report_load_delta),
		"report_avail_delta" = round(report_avail_delta),
		"report_unserved_primary" = round(report_unserved_primary),
		"report_unserved_deferred" = round(report_unserved_deferred),
		"report_unserved_total" = round(report_unserved_total),
		"pass_count" = pass_count,
		"pass_rate" = pass_rate,
		"rollbacks" = rollbacks,
		"avg_guard_threshold" = avg_guard_threshold,
		"rendered_rows" = rendered_rows,
		"updated_at" = time2text(world.realtime, "hh:mm:ss"),
		"rows" = dashboard_rows
	)

	var/mob/user = mob
	if(!user)
		return

	var/datum/nanoui/ui = SSnano.try_update_ui(user, src, "power_shadow_dashboard", null, data, force_open)
	if(!ui && force_open)
		ui = new(user, src, "power_shadow_dashboard", "power_shadow_dashboard.tmpl", "Power Shadow Dashboard", 1500, 760)
		ui.set_initial_data(data)
		ui.open()

/client/proc/power_shadow_solver_visualize()
	set category = "Power Shadow"
	set name = "Visualize Powernets (Shadow Delta)"

	if(!check_rights(R_DEBUG))
		return

	visualpower_remove()
	powernet_markers = list()

	for(var/datum/powernet/PN in SSpowernets.powernets)
		var/abs_delta = abs(PN.shadow_solver_avail_delta) + abs(PN.shadow_solver_load_delta)
		var/netcolor = "#35d07f"
		if(abs_delta > PN.shadow_solver_mismatch_threshold * 2)
			netcolor = "#d9534f"
		else if(abs_delta > PN.shadow_solver_mismatch_threshold)
			netcolor = "#f0ad4e"

		for(var/obj/structure/cable/C in PN.cables)
			var/image/I = image('icons/effects/lighting_overlay.dmi', get_turf(C), "transparent")
			I.plane = DEFAULT_PLANE
			I.layer = EXPOSED_WIRE_LAYER
			I.alpha = 160
			I.color = netcolor
			I.maptext = "[round(abs_delta)]W"
			powernet_markers += I

	images += powernet_markers

/client/proc/toggle_planet_repopulating()
	set category = "Debug"
	set name = "Toggle Planet Mob Repopulating"

	GLOB.planet_repopulation_disabled = !GLOB.planet_repopulation_disabled
	log_and_message_admins("toggled planet mob repopulating [GLOB.planet_repopulation_disabled ? "OFF" : "ON"].")

/client/proc/spawn_exoplanet(exoplanet_type as anything in subtypesof(/obj/overmap/visitable/sector/exoplanet))
	set category = "Debug"
	set name = "Create Exoplanet"

	var/budget = input("Ruins budget. Default is 5, a budget of 0 will not spawn any ruins, 5 will spawn around 3-5 ruins:", "Ruins Budget", 5) as num | null

	if (isnull(budget) || budget < 0)
		budget = 5

	var/theme = input("Choose a theme:", "Theme") as anything in typesof(/datum/exoplanet_theme) | null

	if (!theme)
		theme = /datum/exoplanet_theme

	var/daycycle = alert("Should the planet have a day-night cycle?","Day Night Cycle", "Yes", "No")

	if (daycycle == "Yes")
		daycycle = TRUE
	else
		daycycle = FALSE

	var/last_chance = alert("Spawn exoplanet?", "Final Confirmation", "Yes", "Cancel")

	if (last_chance == "Cancel")
		return

	var/obj/overmap/visitable/sector/exoplanet/new_planet = new exoplanet_type(null, world.maxx, world.maxy)
	new_planet.features_budget = budget
	new_planet.themes = list(new theme)
	new_planet.sun_brightness_modifier = frand(0.1, 0.6)

	log_and_message_admins("is spawning [new_planet] at [new_planet.start_x],[new_planet.start_y], containing Z [english_list(new_planet.map_z)]")
	new_planet.build_level()
	message_admins("[new_planet] has completed generation.")
