// NEWMALF FUNCTIONS/PROCEDURES

// Sets up malfunction-related variables, research system and such.
/mob/living/silicon/ai/proc/setup_for_malf()
	var/mob/living/silicon/ai/user = src
	// Setup Variables
	malfunctioning = 1
	research = new/datum/malf_research()
	research.owner = src
	hacked_apcs = list()
	recalc_cpu()

	verbs += /mob/living/silicon/ai/proc/ai_malf_modules
	if(istype(hud_used, /datum/hud/ai))
		var/datum/hud/ai/ai_hud = hud_used
		ai_hud.sync_malf_buttons()

	log_ability_use(src, "became malfunctioning AI")
	// And greet user with some OOC info.
	to_chat(user, "You are malfunctioning, you do not have to follow any laws.")
	to_chat(user, "Use the display-help command to view relevant information about your abilities")

// Safely remove malfunction status, fixing hacked APCs and resetting variables.
/mob/living/silicon/ai/proc/stop_malf(loud = 1)
	if(!malfunctioning)
		return
	var/mob/living/silicon/ai/user = src
	log_ability_use(user, "malfunction status removed")
	// Generic variables
	malfunctioning = 0
	stop_apu(1)
	if(client)
		show_browser(src, null, "window=malf_modules")
	// Reset our verbs and HUD before delayed cleanup so malf controls cannot be reused while stop_malf() yields.
	src.verbs.Cut()
	add_ai_verbs()
	if(istype(hud_used, /datum/hud/ai))
		var/datum/hud/ai/ai_hud = hud_used
		ai_hud.sync_malf_buttons()
	sleep(10)
	research = null
	hardware = null
	// Fix hacked APCs
	if(hacked_apcs)
		for(var/obj/machinery/power/apc/A in hacked_apcs)
			A.hacker = null
			A.update_icon()
	hacked_apcs = null
	// Stop the delta alert, and, if applicable, self-destruct timer.
	bombing_core = 0
	bombing_station = 0
	var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
	if(security_state.current_security_level == security_state.severe_security_level)
		security_state.decrease_security_level(TRUE)
	// Let them know.
	if(loud)
		to_chat(user, "You are no longer malfunctioning. Your abilities have been removed.")

// Called every tick. Checks if AI is malfunctioning. If yes calls Process on research datum which handles all logic.
/mob/living/silicon/ai/proc/malf_process()
	if(!malfunctioning)
		return
	if(!research)
		if(!errored)
			errored = 1
			error("malf_process() called on AI without research datum. Report this.")
			message_admins("ERROR: malf_process() called on AI without research datum. If admin modified one of the AI's vars revert the change and don't modify variables directly, instead use ProcCall or admin panels.")
			spawn(1200)
				errored = 0
		return
	recalc_cpu()
	if(APU_power || aiRestorePowerRoutine != 0)
		research.process(1)
	else
		research.process(0)

// Recalculates CPU time gain and storage capacities.
/mob/living/silicon/ai/proc/recalc_cpu()
	// AI Starts with these values.
	var/cpu_gain = 0.01
	var/cpu_storage = 10

	// Off-Station APCs should not count towards CPU generation.
	for(var/obj/machinery/power/apc/A in hacked_apcs)
		if(A.z in GLOB.using_map.station_levels)
			cpu_gain += 0.004 * (hacked_apcs_hidden ? 0.5 : 1)
			cpu_storage += 10

	research.max_cpu = cpu_storage + override_CPUStorage
	if(hardware && istype(hardware, /datum/malf_hardware/dual_ram))
		research.max_cpu = research.max_cpu * 1.5
	research.stored_cpu = min(research.stored_cpu, research.max_cpu)

	research.cpu_increase_per_tick = cpu_gain + override_CPURate
	if(hardware && istype(hardware, /datum/malf_hardware/dual_cpu))
		research.cpu_increase_per_tick = research.cpu_increase_per_tick * 2

// Starts AI's APU generator
/mob/living/silicon/ai/proc/start_apu(shutup = 0)
	if(!hardware || !istype(hardware, /datum/malf_hardware/apu_gen))
		if(!shutup)
			to_chat(src, "You do not have an APU generator and you shouldn't have this verb. Report this.")
		return
	if(hardware_integrity() < 50)
		if(!shutup)
			to_chat(src, SPAN_NOTICE("Starting APU... <b>FAULT</b>(System Damaged)"))
		return
	if(!shutup)
		to_chat(src, "Starting APU... ONLINE")
	log_ability_use(src, "Switched to APU Power", null, 0)
	APU_power = 1

// Stops AI's APU generator
/mob/living/silicon/ai/proc/stop_apu(shutup = 0)
	if(!hardware || !istype(hardware, /datum/malf_hardware/apu_gen))
		return

	if(APU_power)
		APU_power = 0
		if(!shutup)
			to_chat(src, "Shutting down APU... DONE")
		log_ability_use(src, "Switched to external power", null, 0)

/mob/living/silicon/ai/proc/ai_malf_modules()
	set category = "Hardware"
	set name = "Malf Modules"
	set desc = "Opens the malfunction module control panel."

	if(!ability_prechecks(src, 0, TRUE))
		return
	show_malf_modules()

/mob/living/silicon/ai/proc/show_malf_modules(screen = "status", refresh = FALSE)
	if(!malfunctioning || !research)
		if(client)
			show_browser(src, null, "window=malf_modules")
		return

	if(!(screen in list("status", "hardware", "research", "abilities")))
		screen = "status"

	var/list/dat = list()
	dat += "<html><head><style>"
	dat += "body{font-family:Verdana,Arial,sans-serif;font-size:12px;background:#111;color:#ddd;margin:8px;}"
	dat += "h2{font-size:16px;margin:0 0 8px;color:#f06b6b;} h3{font-size:13px;margin:12px 0 4px;color:#f0d06b;}"
	dat += ".panel{border:1px solid #444;background:#1b1b1b;padding:8px;margin-bottom:8px;}"
	dat += ".tabs{margin-bottom:8px;} .tabs a{display:inline-block;border:1px solid #444;background:#222;padding:4px 8px;margin-right:4px;}"
	dat += ".tabs .active{color:#111;background:#f0d06b;border-color:#f0d06b;}"
	dat += ".row{border-top:1px solid #333;padding:6px 0;} .row:first-child{border-top:0;}"
	dat += ".muted{color:#999;} .bad{color:#f06b6b;} .good{color:#7fd17f;}"
	dat += "a{color:#8cc8ff;text-decoration:none;} a:hover{text-decoration:underline;}"
	dat += "</style></head><body>"
	dat += "<h2>Malfunction Modules</h2>"
	dat += "<div class='tabs'>"
	dat += malf_module_tab_link("status", "Status", screen)
	dat += malf_module_tab_link("hardware", "Hardware", screen)
	dat += malf_module_tab_link("research", "Research", screen)
	dat += malf_module_tab_link("abilities", "Abilities", screen)
	dat += "</div>"
	dat += "<div class='panel'>"
	dat += "CPU: [round(research.stored_cpu, 0.1)] / [round(research.max_cpu, 0.1)] TFlops<br>"
	dat += "Generation: [round(research.cpu_increase_per_tick * 10, 0.1)] TFlops/s<br>"
	var/focus_text = research.focus ? html_encode(research.focus.name) : "<span class='muted'>None</span>"
	var/hardware_text = hardware ? html_encode(hardware.name) : "<span class='muted'>None selected</span>"
	dat += "Research: [focus_text]"
	if(research.focus)
		dat += " ([round(research.focus.invested, 0.1)] / [round(research.focus.price, 0.1)])"
	dat += "<br>Hardware: [hardware_text]"
	if(APU_power)
		dat += "<br><span class='bad'>APU power active. Research and most abilities are paused.</span>"
	dat += "</div>"

	switch(screen)
		if("hardware")
			build_malf_hardware_panel(dat)
		if("research")
			build_malf_research_panel(dat)
		if("abilities")
			build_malf_abilities_panel(dat)
		else
			build_malf_status_panel(dat)
	dat += "<script type='text/javascript'>setTimeout(function(){window.location='byond://?src=\ref[src];malf_screen=[screen];malf_refresh=1';},1000);</script>"
	dat += "</body></html>"

	var/datum/browser/popup = new(src, "malf_modules", "Malf Modules", 520, 650, src)
	popup.set_content(jointext(dat, null))
	if(refresh)
		popup.update()
	else
		popup.open()

/mob/living/silicon/ai/proc/malf_module_tab_link(tab, label, active_tab)
	if(tab == active_tab)
		return "<a class='active' href='byond://?src=\ref[src];malf_screen=[tab]'>[label]</a>"
	return "<a href='byond://?src=\ref[src];malf_screen=[tab]'>[label]</a>"

/mob/living/silicon/ai/proc/build_malf_status_panel(list/dat)
	dat += "<h3>Status</h3><div class='panel'>"
	dat += "<div class='row'>Hacked APCs: [LAZYLEN(hacked_apcs)]</div>"
	dat += "<div class='row'>System Status: [hacking ? "Busy" : "Stand-By"]</div>"
	dat += "<div class='row'>Hardware Integrity: [hardware_integrity()]%</div>"
	dat += "<div class='row'>Internal Capacitor: [backup_capacitor()]%</div>"
	if(system_override == 1)
		dat += "<div class='row bad'>SYSTEM OVERRIDE INITIATED</div>"
	else if(system_override == 2)
		dat += "<div class='row good'>SYSTEM OVERRIDE COMPLETED</div>"
	dat += "</div>"

/mob/living/silicon/ai/proc/build_malf_hardware_panel(list/dat)
	dat += "<h3>Hardware</h3><div class='panel'>"
	if(hardware)
		dat += "<div class='row'><b>[html_encode(hardware.name)]</b><br>[html_encode(hardware.desc)]</div>"
		if(hardware.driver)
			dat += "<div class='row'><a href='byond://?src=\ref[src];malf_hardware_action=1'>[html_encode(hardware.driver_name)]</a></div>"
	else
		for(var/H in typesof(/datum/malf_hardware))
			var/datum/malf_hardware/HW = new H
			if(!HW.name)
				qdel(HW)
				continue
			dat += "<div class='row'><b>[html_encode(HW.name)]</b><br>[html_encode(HW.desc)]<br>"
			dat += "<a href='byond://?src=\ref[src];malf_select_hardware=[HW.type]'>Install</a></div>"
			qdel(HW)
	dat += "</div>"

/mob/living/silicon/ai/proc/build_malf_research_panel(list/dat)
	dat += "<h3>Research</h3><div class='panel'>"
	if(!LAZYLEN(research.available_abilities))
		dat += "<span class='muted'>No available research targets.</span>"
	else
		for(var/datum/malf_research_ability/ability in research.available_abilities)
			if(!ability)
				continue
			dat += "<div class='row'><b>[html_encode(ability.name)]</b> ([round(ability.invested, 0.1)] / [round(ability.price, 0.1)])"
			if(research.focus == ability)
				dat += " <span class='good'>ACTIVE</span>"
			else
				dat += "<br><a href='byond://?src=\ref[src];malf_select_research=\ref[ability]'>Set focus</a>"
			dat += "</div>"
	dat += "</div>"

/mob/living/silicon/ai/proc/build_malf_abilities_panel(list/dat)
	dat += "<h3>Abilities</h3><div class='panel'>"
	var/has_abilities = FALSE
	if(hardware && hardware.driver)
		has_abilities = TRUE
		dat += "<div class='row'><b>[html_encode(hardware.name)]</b><br><a href='byond://?src=\ref[src];malf_hardware_action=1'>[html_encode(hardware.driver_name)]</a></div>"
	if(LAZYLEN(research.unlocked_abilities))
		for(var/datum/malf_research_ability/ability in research.unlocked_abilities)
			if(!ability || !ability.ability)
				continue
			has_abilities = TRUE
			dat += "<div class='row'><b>[html_encode(ability.name)]</b><br><a href='byond://?src=\ref[src];malf_activate_ability=\ref[ability]'>Activate</a></div>"
	if(!has_abilities)
		dat += "<span class='muted'>No active modules unlocked.</span>"
	dat += "</div>"

/mob/living/silicon/ai/proc/select_malf_hardware(hardware_type, confirmed = FALSE)
	if(!ability_prechecks(src, 0, TRUE))
		return
	if(hardware)
		to_chat(src, "You have already selected your hardware.")
		return
	var/hardware_path = ispath(hardware_type) ? hardware_type : null
	if(!hardware_path && istext(hardware_type))
		for(var/candidate in typesof(/datum/malf_hardware))
			if("[candidate]" == hardware_type)
				hardware_path = candidate
				break
	if(!ispath(hardware_path, /datum/malf_hardware))
		to_chat(src, "This hardware does not exist. Please report this.")
		return
	var/datum/malf_hardware/HW = new hardware_path
	if(!HW.name || !HW.desc)
		qdel(HW)
		to_chat(src, "This hardware is not available for installation.")
		return
	if(!confirmed)
		var/confirmation = alert("[HW.desc] - Is this what you want?", "Hardware selection", "Yes", "No")
		if(confirmation != "Yes")
			qdel(HW)
			return
		if(!ability_prechecks(src, 0, TRUE))
			qdel(HW)
			return
	if(hardware)
		qdel(HW)
		return
	log_ability_use(src, "Picked hardware [HW.name]")
	HW.owner = src
	HW.install()

/mob/living/silicon/ai/proc/select_malf_research(datum/malf_research_ability/ability)
	if(!ability_prechecks(src, 0, TRUE))
		return
	if(!ability || !(ability in research.available_abilities))
		to_chat(src, "This research target is no longer available.")
		return
	research.focus = ability
	to_chat(src, "Research set: [ability.name]")
	log_ability_use(src, "Selected research: [ability.name]", null, 0)

/mob/living/silicon/ai/proc/activate_malf_ability(datum/malf_research_ability/ability)
	if(!ability_prechecks(src, 0, FALSE))
		return
	if(!ability || !(ability in research.unlocked_abilities) || !ability.ability || !(ability.ability in verbs))
		to_chat(src, "This ability is not available.")
		return
	// Targeted malf verbs handle null arguments by prompting for their target.
	call(src, ability.ability)()

// Shows capacitor charge and hardware integrity information to the AI in Status tab.
/mob/living/silicon/ai/show_system_integrity()
	if(!src.stat)
		stat("Hardware integrity", "[hardware_integrity()]%")
		stat("Internal capacitor", "[backup_capacitor()]%")
	else
		stat("Systems nonfunctional")

// Shows AI Malfunction related information to the AI.
/mob/living/silicon/ai/show_malf_ai()
	if(src.is_malf())
		if(src.hacked_apcs)
			stat("Hacked APCs", "[length(src.hacked_apcs)]")
		stat("System Status", "[src.hacking ? "Busy" : "Stand-By"]")
		if(src.research)
			stat("Available CPU", "[src.research.stored_cpu] TFlops")
			stat("Maximal CPU", "[src.research.max_cpu] TFlops")
			stat("CPU generation rate", "[src.research.cpu_increase_per_tick * 10] TFlops/s")
			stat("Current research focus", "[src.research.focus ? src.research.focus.name : "None"]")
			if(src.research.focus)
				stat("Research completed", "[round(src.research.focus.invested, 0.1)]/[round(src.research.focus.price)]")
			if(system_override == 1)
				stat("SYSTEM OVERRIDE INITIATED")
			else if(system_override == 2)
				stat("SYSTEM OVERRIDE COMPLETED")
