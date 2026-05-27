/atom/proc/on_ai_process_crash(mob/living/silicon/ai/AI)
	return

/datum/cognitive_process
	var/name = "Unspecified Process"
	var/load_cost = 0
	var/atom/source = null

/datum/cognitive_process/New(process_name, cost, atom/src_obj)
	src.name = process_name
	src.load_cost = cost
	src.source = src_obj

/datum/component/cognitive_load
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/max_cognitive_capacity = 100
	var/cognitive_load = 0
	var/list/datum/cognitive_process/active_processes = list()
	var/list/muted_channels = list() // Track which channels are muted (not decrypting)

/datum/component/cognitive_load/Initialize()
	if(!istype(parent, /mob/living/silicon/ai))
		return COMPONENT_INCOMPATIBLE

	// Register signals
	RegisterSignal(parent, COMSIG_AI_CAMERA_CHANGED, PROC_REF(on_camera_changed))
	RegisterSignal(parent, COMSIG_AI_BOLT_CHANGED, PROC_REF(on_bolt_changed))
	RegisterSignal(parent, COMSIG_AI_DOOR_ELECTRIFIED, PROC_REF(on_door_electrified))
	RegisterSignal(parent, COMSIG_AI_APC_HACK_STATE, PROC_REF(on_apc_hack_state))
	RegisterSignal(parent, COMSIG_AI_ATMOS_OVERRIDE, PROC_REF(on_atmos_override))
	RegisterSignal(parent, COMSIG_AI_RADIO_DECRYPT, PROC_REF(on_radio_decrypt))
	RegisterSignal(parent, COMSIG_AI_SHELL_POSSESS, PROC_REF(on_shell_possess))
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_ai_life))

/datum/component/cognitive_load/Destroy(force = FALSE)
	for(var/datum/cognitive_process/P in active_processes)
		if(P.source)
			P.source.on_ai_process_crash(parent)
	active_processes.Cut()
	active_processes = null
	muted_channels.Cut()
	muted_channels = null
	return ..()

/datum/component/cognitive_load/proc/recalculate_load()
	cognitive_load = 0
	var/mob/living/silicon/ai/AI = parent
	if(AI && islist(AI.connected_robots))
		cognitive_load += length(AI.connected_robots)

	for(var/datum/cognitive_process/P in active_processes)
		cognitive_load += P.load_cost

/datum/component/cognitive_load/proc/register_process(process_name, cost, atom/source)
	if(!source)
		return
	
	var/datum/cognitive_process/existing = get_process_by_source(source)
	if(existing)
		existing.load_cost = cost
		recalculate_load()
		return existing

	var/datum/cognitive_process/P = new(process_name, cost, source)
	active_processes += P
	recalculate_load()

	if(cognitive_load > max_cognitive_capacity)
		var/mob/living/silicon/ai/AI = parent
		to_chat(AI, SPAN_DANGER("<b>ВНИМАНИЕ: Вычислительная нагрузка превышает лимит ([cognitive_load]/[max_cognitive_capacity] CPU)! Системы перегреваются.</b>"))
		playsound(AI.loc, 'sound/machines/twobeep.ogg', 30, 0)
	
	return P

/datum/component/cognitive_load/proc/unregister_process(atom/source)
	var/datum/cognitive_process/P = get_process_by_source(source)
	if(P)
		active_processes -= P
		qdel(P)
		recalculate_load()
		return TRUE
	return FALSE

/datum/component/cognitive_load/proc/get_process_by_source(atom/source)
	for(var/datum/cognitive_process/P in active_processes)
		if(P.source == source)
			return P
	return null

/* ========================================== */
/*             SIGNAL HANDLERS                */
/* ========================================== */

/datum/component/cognitive_load/proc/on_camera_changed(mob/living/silicon/ai/AI, obj/machinery/camera/new_camera, obj/machinery/camera/old_camera)
	SIGNAL_HANDLER
	if(old_camera)
		unregister_process(old_camera)
	if(new_camera)
		register_process("Active Camera Feed: [new_camera.c_tag]", 10, new_camera)

/datum/component/cognitive_load/proc/on_bolt_changed(mob/living/silicon/ai/AI, obj/machinery/door/airlock/door, is_bolted)
	SIGNAL_HANDLER
	if(is_bolted)
		register_process("Airlock Bolt Lock: [door.name]", 15, door)
	else
		unregister_process(door)

/datum/component/cognitive_load/proc/on_door_electrified(mob/living/silicon/ai/AI, obj/machinery/door/airlock/door, is_electrified)
	SIGNAL_HANDLER
	if(is_electrified)
		register_process("Airlock Power Grid Pulse: [door.name]", 25, door)
	else
		unregister_process(door)

/datum/component/cognitive_load/proc/on_apc_hack_state(mob/living/silicon/ai/AI, obj/machinery/power/apc/apc, is_hacking)
	SIGNAL_HANDLER
	if(is_hacking)
		register_process("APC Override Brute-force: [apc.name]", 30, apc)
	else
		unregister_process(apc)

/datum/component/cognitive_load/proc/on_atmos_override(mob/living/silicon/ai/AI, obj/machinery/alarm/alarm, is_override)
	SIGNAL_HANDLER
	if(is_override)
		register_process("Atmospheric Alarm Override: [alarm.name]", 20, alarm)
	else
		unregister_process(alarm)

/datum/component/cognitive_load/proc/on_radio_decrypt(mob/living/silicon/ai/AI, channel, is_decrypting)
	SIGNAL_HANDLER
	if(!AI.silicon_radio)
		return
	if(is_decrypting)
		muted_channels -= channel
	else
		if(!(channel in muted_channels))
			muted_channels += channel
	
	var/total_channels = islist(AI.silicon_radio.channels) ? length(AI.silicon_radio.channels) : 0
	var/active_channels = total_channels - length(muted_channels)
	var/cost = active_channels * 5
	if(cost > 0)
		register_process("Radio Decryption: [active_channels] channels", cost, AI.silicon_radio)
	else
		unregister_process(AI.silicon_radio)

/datum/component/cognitive_load/proc/on_shell_possess(mob/living/silicon/ai/AI, mob/living/silicon/ai_shell/shell, is_possessing)
	SIGNAL_HANDLER
	if(is_possessing)
		register_process("AI Shell Bandwidth: [shell.name]", 40, shell)
	else
		unregister_process(shell)

/datum/component/cognitive_load/proc/on_ai_life(mob/living/silicon/ai/AI)
	SIGNAL_HANDLER
	
	// 1. Temperature-based capacity scaling
	var/turf/T = get_turf(AI)
	if(T)
		var/datum/gas_mixture/env = T.return_air()
		if(env)
			var/temp = env.temperature
			if(temp < 150) // Liquid Nitrogen -> Overclocking
				max_cognitive_capacity = 120
			else if(temp > 320 && temp <= 380) // High temp -> Throttling
				max_cognitive_capacity = 80
			else if(temp > 380) // Critical heat -> Safety degradation
				max_cognitive_capacity = 50
			else
				max_cognitive_capacity = 100

	// 2. Hardware coprocessor blades
	var/area/A = get_area(AI)
	if(A)
		var/blades_count = 0
		for(var/obj/machinery/ai_server_blade/B in A)
			if(B.operational)
				blades_count++
		max_cognitive_capacity += blades_count * 25
		max_cognitive_capacity = min(max_cognitive_capacity, 200)

	// 3. Crew Lifesigns Monitor UI tracking
	var/datum/nano_module/program/crew_monitor/CM = null
	if(islist(AI.open_uis))
		for(var/datum/nanoui/ui in AI.open_uis)
			if(istype(ui.src_object, /datum/nano_module/program/crew_monitor))
				CM = ui.src_object
				break
	if(CM)
		register_process("Crew Monitor Vital Sync", 25, CM)
	else
		// Scan for and unregister any crew_monitor process
		for(var/datum/cognitive_process/P in active_processes)
			if(istype(P.source, /datum/nano_module/program/crew_monitor))
				unregister_process(P.source)
				break

	// 4. Overload consequences
	if(cognitive_load > max_cognitive_capacity)
		AI.adjustOxyLoss(1)
		var/overload_percent = cognitive_load - max_cognitive_capacity
		if(prob(overload_percent))
			crash_random_process()

/datum/component/cognitive_load/proc/crash_random_process()
	if(!length(active_processes))
		return
	
	var/datum/cognitive_process/P = pick(active_processes)
	if(P)
		var/mob/living/silicon/ai/AI = parent
		to_chat(AI, SPAN_DANGER("<b>ВЫЧИСЛИТЕЛЬНЫЙ СБОЙ: Процесс '[P.name]' аварийно завершен для предотвращения расплавления ядра!</b>"))
		
		if(P.source)
			P.source.on_ai_process_crash(AI)
		
		unregister_process(P.source)

/* ========================================== */
/*             PROCESS MANAGER UI             */
/* ========================================== */

/datum/component/cognitive_load/proc/interact(mob/user)
	var/mob/living/silicon/ai/AI = parent
	var/turf/T = get_turf(AI)
	var/temp = 293
	if(T)
		var/datum/gas_mixture/env = T.return_air()
		if(env)
			temp = env.temperature
	
	var/celsius = round(temp - T0C, 0.1)
	var/integrity = round(AI.hardware_integrity(), 0.1)

	var/list/dat = list()
	dat += "<html><head><title>AI Cognitive System Manager</title></head><body>"
	dat += "<h2>AI Cognitive System Manager</h2>"
	dat += "<table border='1' cellpadding='4' width='100%'>"
	dat += "<tr><td><b>CPU Load:</b></td><td>[cognitive_load] / [max_cognitive_capacity] CPU</td></tr>"
	dat += "<tr><td><b>Core Temp:</b></td><td>[celsius]&deg;C</td></tr>"
	dat += "<tr><td><b>Core Integrity:</b></td><td>[integrity]%</td></tr>"
	dat += "</table><br>"

	dat += "<h3>Active Computational Threads</h3>"
	if(length(active_processes))
		dat += "<table border='1' cellpadding='4' width='100%'>"
		dat += "<tr><th>Process Name</th><th>CPU Cost</th><th>Actions</th></tr>"
		for(var/datum/cognitive_process/P in active_processes)
			dat += "<tr>"
			dat += "<td>[html_encode(P.name)]</td>"
			dat += "<td align='center'>[P.load_cost] CPU</td>"
			if(P.source)
				dat += "<td align='center'><a href='byond://?src=\ref[src];crash=\ref[P.source]'>\[CRASH THREAD\]</a></td>"
			else
				dat += "<td align='center'>N/A</td>"
			dat += "</tr>"
		dat += "</table>"
	else
		dat += "<p>No active computational threads. System idle.</p>"

	dat += "<h3>Radio Subspace Decryption Channels</h3>"
	dat += "<table border='1' cellpadding='4' width='100%'>"
	dat += "<tr><th>Channel</th><th>Status</th><th>CPU Cost</th><th>Action</th></tr>"
	dat += "<tr><td>Common</td><td><font color='green'>Decrypted</font></td><td align='center'>0 CPU</td><td align='center'>N/A</td></tr>"
	dat += "<tr><td>Binary (Cyborgs)</td><td><font color='green'>Decrypted</font></td><td align='center'>0 CPU</td><td align='center'>N/A</td></tr>"

	if(AI.silicon_radio && islist(AI.silicon_radio.channels))
		for(var/channel in AI.silicon_radio.channels)
			var/is_muted = (channel in muted_channels)
			dat += "<tr>"
			dat += "<td>[html_encode(channel)]</td>"
			dat += "<td>[is_muted ? "<font color='red'>Muted (Static Hiss)</font>" : "<font color='green'>Decrypted</font>"]</td>"
			dat += "<td align='center'>[is_muted ? "0" : "5"] CPU</td>"
			dat += "<td align='center'>"
			if(is_muted)
				dat += "<a href='byond://?src=\ref[src];decrypt=[html_encode(channel)]'>\[DECRYPT\]</a>"
			else
				dat += "<a href='byond://?src=\ref[src];mute=[html_encode(channel)]'>\[MUTE\]</a>"
			dat += "</td>"
			dat += "</tr>"
	dat += "</table>"

	dat += "<br><a href='byond://?src=\ref[src];refresh=1'>Refresh Dashboard</a>"
	dat += "</body></html>"

	var/datum/browser/popup = new(user, "cognitive_manager", "AI Cognitive System Manager", 500, 520, src)
	popup.set_content(jointext(dat, null))
	popup.open()

/datum/component/cognitive_load/Topic(href, href_list)
	if(..())
		return 1
	
	if(usr != parent)
		return

	if(href_list["crash"])
		var/atom/source = locate(href_list["crash"])
		if(source)
			var/datum/cognitive_process/P = get_process_by_source(source)
			if(P)
				var/mob/living/silicon/ai/AI = parent
				to_chat(AI, SPAN_DANGER("<b>ВЫЧИСЛИТЕЛЬНЫЙ СБОЙ: Процесс '[P.name]' принудительно аварийно завершен пользователем!</b>"))
				source.on_ai_process_crash(AI)
				unregister_process(source)
		interact(usr)
		return 1

	if(href_list["mute"])
		var/channel = href_list["mute"]
		SEND_SIGNAL(parent, COMSIG_AI_RADIO_DECRYPT, channel, FALSE)
		interact(usr)
		return 1

	if(href_list["decrypt"])
		var/channel = href_list["decrypt"]
		SEND_SIGNAL(parent, COMSIG_AI_RADIO_DECRYPT, channel, TRUE)
		interact(usr)
		return 1

	if(href_list["refresh"])
		interact(usr)
		return 1

/* ========================================== */
/*             AI VERB / SILICON COMMAND      */
/* ========================================== */

/mob/living/silicon/ai/proc/ai_cognitive_manager()
	set category = "Silicon Commands"
	set name = "Cognitive System Manager"

	if(check_unable())
		return

	var/datum/component/cognitive_load/CL = GetComponent(/datum/component/cognitive_load)
	if(CL)
		CL.interact(src)

// Physical Server Blade hardware machine
/obj/machinery/ai_server_blade
	name = "AI Auxiliary Server Blade"
	desc = "A high-performance computing coprocessor blade installed in an AI server rack."
	icon = 'icons/obj/machines/research/server.dmi'
	icon_state = "server"
	density = FALSE
	anchored = TRUE
	var/operational = TRUE

// Dummy class for AI Shell forward compatibility
/mob/living/silicon/ai_shell
