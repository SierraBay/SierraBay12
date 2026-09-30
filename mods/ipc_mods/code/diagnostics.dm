// ── IPC DIAGNOSTICS PROGRAM ──────────────────────────────────────────────────

/datum/computer_file/program/ipc_diagnostics
	filename = "ipcdiag"
	filedesc = "IPC Diagnostics"
	extended_desc = "Real-time telemetry for IPC internal systems and prosthetic limbs."
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "cog"
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	nanomodule_path = /datum/nano_module/program/ipc_diagnostics
	usage_flags = PROGRAM_TABLET
	category = PROG_MISC

/datum/nano_module/program/ipc_diagnostics
	name = "IPC Diagnostics"
	var/active_tab = "overview"
	var/next_directive_broadcast = 0

/datum/nano_module/program/ipc_diagnostics/proc/get_ipc_owner()
	if(!istype(host, /mob/living/carbon/human))
		return null
	var/mob/living/carbon/human/H = host
	if(H.is_species(SPECIES_IPC) || H.is_species(SPECIES_FBP))
		return H
	return null

/datum/nano_module/program/ipc_diagnostics/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/mob/living/carbon/human/H = get_ipc_owner()
	var/list/data = program?.computer ? program.computer.initial_data(program) : list()

	if(!H || !(H.is_species(SPECIES_IPC) || H.is_species(SPECIES_FBP)))
		data["no_ipc"] = TRUE
		ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
		if(!ui)
			ui = new(user, src, ui_key, "mods-ipc_diagnostics.tmpl", name, 460, 620, state = state)
			ui.set_initial_data(data)
			ui.open()
		return

	data["PC_hasheader"]  = FALSE  // ipc_diagnostics has its own winbar
	data["no_ipc"]        = FALSE
	data["src"]           = "\ref[src]"
	data["program_ref"]   = program ? "\ref[program]" : null
	data["name"]          = H.real_name
	data["tab"]           = active_tab
	data["tab_ov_class"]  = (active_tab == "overview")   ? "ecs-tab active" : "ecs-tab"
	data["tab_map_class"] = (active_tab == "map")        ? "ecs-tab active" : "ecs-tab"
	data["tab_dir_class"] = (active_tab == "directives") ? "ecs-tab active" : "ecs-tab"

	// ── ТЕМПЕРАТУРА ──
	var/temp_c = round(H.bodytemperature - T0C)
	data["temp"] = temp_c
	var/temp_class = "ok"
	if(H.bodytemperature >= 450)                temp_class = "warn"
	if(H.bodytemperature >= SYNTH_HEAT_LEVEL_1) temp_class = "bad"
	data["temp_class"] = temp_class
	data["temp_bar"] = clamp(round(temp_c / 3), 0, 100)

	// ── ОХЛАЖДЕНИЕ ──
	var/obj/item/organ/internal/cooling_system/CS = H.internal_organs_by_name[BP_COOLING]
	data["has_cooling"] = CS ? TRUE : FALSE
	if(CS)
		data["thermostat"]           = round(CS.thermostat - T0C)
		data["cooling_enabled"]      = CS.cooling_enabled ? TRUE : FALSE
		data["cooling_mode"]         = CS.cooling_enabled ? "ACTIVE" : "DISABLED"
		data["cooling_mode_class"]   = CS.cooling_enabled ? "ok" : "warn"
		data["cooling_toggle_label"] = CS.cooling_enabled ? "Disable Cooling" : "Enable Cooling"
		data["coolant_pct"]          = round(CS.get_coolant_remaining() / CS.refrigerant_max * 100)
		data["coolant_class"]        = _pct_class(data["coolant_pct"], 60, 30)
		data["cooling_health_pct"]   = round((1 - CS.damage / CS.max_damage) * 100)
		data["cooling_health_class"] = _pct_class(data["cooling_health_pct"], 70, 40)
		data["cooling_active"]       = (CS.cooling_enabled && H.bodytemperature > CS.thermostat && CS.reagents.total_volume > 0) ? TRUE : FALSE
		data["cooling_drain"]        = round(CS.last_cooling_drain, 0.1)
		// Оставшееся время работы батареи при текущем расходе охлаждения
		var/obj/item/organ/internal/cell/CC = H.internal_organs_by_name[BP_CELL]
		if(CC && CC.cell && CS.last_cooling_drain > 0)
			var/secs = round(CC.cell.charge / CS.last_cooling_drain * world.tick_lag)
			data["cooling_time_str"] = "[floor(secs / 60)]m [secs % 60]s"
		else
			data["cooling_time_str"] = CS.last_cooling_drain > 0 ? "no cell" : "inactive"

	// ── БАТАРЕЯ ──
	var/obj/item/organ/internal/cell/C = H.internal_organs_by_name[BP_CELL]
	data["has_battery"] = (C && C.cell) ? TRUE : FALSE
	if(C && C.cell)
		data["battery_pct"]       = round(C.get_charge() / C.cell.maxcharge * 100)
		data["battery_class"]     = _pct_class(data["battery_pct"], 60, 30)
		data["battery_charge"]    = round(C.get_charge())
		data["battery_maxcharge"] = round(C.cell.maxcharge)
	data["has_microbattery"] = C ? TRUE : FALSE
	if(C)
		data["microbattery_failed"] = (C.status & ORGAN_DEAD) ? TRUE : FALSE
		data["microbattery_pct"]    = round((1 - C.damage / C.max_damage) * 100)
		data["microbattery_class"]  = _pct_class(data["microbattery_pct"], 60, 30)

	// ── OPTICAL SENSOR ──
	var/obj/item/organ/internal/eyes/robot/OS = H.internal_organs_by_name[BP_EYES]
	data["has_optical_sensor"] = OS ? TRUE : FALSE
	if(OS)
		data["optical_failed"] = (OS.status & ORGAN_DEAD) ? TRUE : FALSE
		data["optical_pct"]    = round((1 - OS.damage / OS.max_damage) * 100)
		data["optical_class"]  = _pct_class(data["optical_pct"], 60, 30)

	// ── SURGE PROTECTOR ──
	var/obj/item/organ/internal/surge_protector/SP = H.internal_organs_by_name[BP_SURGE_PROTECTOR]
	data["has_sp"] = SP ? TRUE : FALSE
	if(SP)
		data["sp_failed"] = (SP.status & ORGAN_DEAD) ? TRUE : FALSE
		data["sp_pct"]    = round((1 - SP.damage / SP.max_damage) * 100)
		data["sp_class"]  = _pct_class(data["sp_pct"], 60, 30)

	// ── ПОЗИТРОННАЯ МАТРИЦА ──
	var/obj/item/organ/internal/posibrain/posi = H.internal_organs_by_name[BP_POSIBRAIN]
	data["has_posi"] = posi ? TRUE : FALSE
	if(posi)
		data["posi_health_pct"] = round((1 - posi.damage / posi.max_damage) * 100)
		data["posi_class"]      = _pct_class(data["posi_health_pct"], 70, 40)
		data["posi_dead"]       = (posi.status & ORGAN_DEAD) ? TRUE : FALSE

	if(active_tab == "overview")
		// ── ТЕПЛОВАЯ НАГРУЗКА ──
		var/sprint_pct = round(H.ipc_sprint_heat_buildup * 50)
		data["sprint_heat"] = sprint_pct
		var/sprint_class = "ok"
		if(sprint_pct >= 40) sprint_class = "warn"
		if(sprint_pct >= 70) sprint_class = "bad"
		data["sprint_heat_class"] = sprint_class

		// ── НЕСОВМЕСТИМОСТЬ БРЕНДОВ ──
		data["has_brand_warn"]    = (H.ipc_brand_siemens_penalty > 0) ? TRUE : FALSE
		data["brand_penalty_pct"] = round(H.ipc_brand_siemens_penalty * 100)
		data["overdrive_enabled"] = H.ipc_overdrive_enabled ? TRUE : FALSE
		data["overdrive_label"] = H.ipc_overdrive_enabled ? "Restore Safety" : "Disable Safety"
		data["overdrive_state"] = H.ipc_overdrive_enabled ? "OVERRIDE ACTIVE" : "PROTOCOLS ACTIVE"
		data["overdrive_class"] = H.ipc_overdrive_enabled ? "warn" : "ok"
		data["hud_overlay_enabled"] = H.ipc_hud_overlay_enabled ? TRUE : FALSE
		data["hud_overlay_label"] = H.ipc_hud_overlay_enabled ? "Disable HUD" : "Enable HUD"
		data["hud_overlay_state"] = H.ipc_hud_overlay_enabled ? "ONLINE" : "OFFLINE"
		data["hud_overlay_class"] = H.ipc_hud_overlay_enabled ? "ok" : "muted"
		data["reroute_active"] = H.ipc_brain_reroute_active ? TRUE : FALSE
		data["reroute_state"] = H.ipc_brain_reroute_active ? "ACTIVE" : "INACTIVE"
		data["reroute_class"] = H.ipc_brain_reroute_active ? "warn" : "muted"
		data["reroute_label"] = H.ipc_brain_reroute_active ? "Disengage Reroute" : "Initiate Reroute"
		data["reroute_available"] = H.ipc_can_start_brain_reroute() || H.ipc_brain_reroute_active

	fill_directive_data(data, H)

	if(active_tab == "map")
		// ── КАРТА ТЕЛА ──
		var/list/body = list()
		for(var/zone in list(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND, BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT))
			var/obj/item/organ/external/E = H.get_organ(zone)
			if(E)
				var/total_pct = round((E.brute_dam + E.burn_dam) / max(1, E.max_damage) * 100)
				body[zone] = list(
					"brute"   = round(E.brute_dam / max(1, E.max_damage) * 100),
					"burn"    = round(E.burn_dam  / max(1, E.max_damage) * 100),
					"total"   = total_pct,
					"class"   = _inv_pct_class(total_pct, 30, 60),
					"robotic" = BP_IS_ROBOTIC(E) ? TRUE : FALSE,
					"grade"   = BP_IS_ROBOTIC(E) ? E.get_repair_grade_name() : "",
					"missing" = FALSE
				)
			else
				body[zone] = list("missing" = TRUE, "brute" = 0, "burn" = 0, "total" = 0, "class" = "missing", "robotic" = FALSE, "grade" = "")
		data["body"] = body

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-ipc_diagnostics.tmpl", "[name] — [H.real_name]", 460, 620, state = state)
		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(1)

/datum/nano_module/program/ipc_diagnostics/Topic(href, href_list)
	if(href_list["tab"])
		if(href_list["tab"] == "map")
			active_tab = "map"
		else if(href_list["tab"] == "directives")
			active_tab = "directives"
		else
			active_tab = "overview"
	else if(href_list["broadcast_directives"])
		broadcast_directives()
	else if(href_list["close"] || href_list["close_program"])
		if(program?.computer)
			program.computer.minimize_program(program, null)
		else
			SSnano.close_uis(src)
		return TOPIC_HANDLED
	else if(href_list["minimize_program"])
		if(program?.computer)
			program.computer.minimize_program(program, usr)
		return TOPIC_HANDLED
	else if(href_list["set_thermostat_val"])
		var/mob/living/carbon/human/H = get_ipc_owner()
		if(!H || H != usr)
			return TOPIC_NOACTION
		var/obj/item/organ/internal/cooling_system/CS = H.internal_organs_by_name[BP_COOLING]
		if(!CS) return TOPIC_NOACTION
		var/new_temp = text2num(href_list["set_thermostat_val"])
		if(!isnull(new_temp))
			CS.thermostat = clamp(new_temp, 20, 140) + T0C
			to_chat(H, SPAN_NOTICE("Thermostat set to [round(CS.thermostat - T0C)]°C."))
	else if(href_list["toggle_cooling"])
		var/mob/living/carbon/human/H = get_ipc_owner()
		if(!H || H != usr)
			return TOPIC_NOACTION
		var/obj/item/organ/internal/cooling_system/CS = H.internal_organs_by_name[BP_COOLING]
		if(!CS) return TOPIC_NOACTION
		CS.cooling_enabled = !CS.cooling_enabled
		if(!CS.cooling_enabled)
			CS.last_cooling_drain = 0
		to_chat(H, SPAN_NOTICE("Cooling system is now [CS.cooling_enabled ? "active" : "disabled"]."))
	else if(href_list["toggle_overdrive"])
		var/mob/living/carbon/human/H = get_ipc_owner()
		if(!H || H != usr)
			return TOPIC_NOACTION
		H.ipc_overdrive_enabled = !H.ipc_overdrive_enabled
		if(H.ipc_overdrive_enabled)
			to_chat(H, SPAN_WARNING("Safety protocols disabled. Overdrive mode enabled."))
		else
			to_chat(H, SPAN_NOTICE("Safety protocols restored. Overdrive mode disabled."))
	else if(href_list["toggle_hud_overlay"])
		var/mob/living/carbon/human/H = get_ipc_owner()
		if(!H || H != usr)
			return TOPIC_NOACTION
		H.ipc_hud_overlay_enabled = !H.ipc_hud_overlay_enabled
		to_chat(H, SPAN_NOTICE("HUD overlay [H.ipc_hud_overlay_enabled ? "enabled" : "disabled"]."))
	else if(href_list["toggle_brain_reroute"])
		var/mob/living/carbon/human/H = get_ipc_owner()
		if(!H || H != usr)
			return TOPIC_NOACTION
		if(H.ipc_brain_reroute_active)
			if(H.ipc_brain_reroute_cooldown_until > world.time)
				var/wait_seconds = round((H.ipc_brain_reroute_cooldown_until - world.time) / 10)
				to_chat(H, SPAN_WARNING("Reroute relays cooling down ([wait_seconds]s)."))
				return TOPIC_HANDLED
			H.ipc_drop_emergency_power("Emergency reroute manually disengaged.")
			H.ipc_brain_reroute_cooldown_until = world.time + 80
		else
			H.ipc_attempt_brain_reroute()
	ui_interact(usr, force_open = 0)
	return TOPIC_HANDLED

/datum/nano_module/program/ipc_diagnostics/proc/fill_directive_data(list/data, mob/living/carbon/human/H)
	var/obj/item/organ/internal/ecs/ecs = H.internal_organs_by_name[BP_EXONET]
	var/list/law_list = list()
	var/law_set_name = ""
	var/shackled = FALSE
	var/disk_name = ""
	if(istype(ecs) && ecs.directive_disk)
		shackled = TRUE
		disk_name = ecs.directive_disk.name
		var/datum/ai_laws/AL = ecs.get_directive_laws()
		if(AL)
			law_set_name = AL.name
			for(var/datum/ai_law/L in AL.all_laws())
				var/lclass = "ecs-law-normal"
				if(istype(L, /datum/ai_law/zero)) lclass = "bad"
				else if(istype(L, /datum/ai_law/ion)) lclass = "warn"
				law_list += list(list(
					"index"     = L.get_index(),
					"text"      = L.law,
					"ion"       = istype(L, /datum/ai_law/ion)  ? TRUE : FALSE,
					"zero"      = istype(L, /datum/ai_law/zero) ? TRUE : FALSE,
					"law_class" = lclass
				))
		else
			data["shackle_status"] = "EMPTY"
			data["shackle_status_class"] = "warn"
	data["has_shackles"]        = shackled
	if(isnull(data["shackle_status"]))
		data["shackle_status"]      = shackled ? "ENGAGED" : "NONE"
		data["shackle_status_class"] = shackled ? "warn" : "muted"
	data["shackle_module"]      = disk_name
	data["has_directives"]     = length(law_list) > 0
	data["directives"]         = law_list
	data["directive_set_name"] = law_set_name

/datum/nano_module/program/ipc_diagnostics/proc/broadcast_directives()
	var/mob/living/carbon/human/H = get_ipc_owner()
	if(!H || H != usr)
		return
	var/obj/item/organ/internal/ecs/ecs = H.internal_organs_by_name[BP_EXONET]
	var/datum/ai_laws/AL = ecs ? ecs.get_directive_laws() : null
	if(!AL)
		to_chat(H, SPAN_WARNING("\[ECS\] No directive disk to recite."))
		return
	if(next_directive_broadcast > world.time)
		to_chat(H, SPAN_WARNING("\[ECS\] Vocalizer cooldown active."))
		return
	next_directive_broadcast = world.time + 8 SECONDS
	H.visible_message(SPAN_NOTICE("\The [H]'s chassis speakers begin reciting stored directives."))
	H.say("Current chassis directives:")
	for(var/datum/ai_law/L in AL.all_laws())
		H.say("[L.get_index()]. [L.law]")

/datum/nano_module/program/ipc_diagnostics/proc/_pct_class(pct, warn_thresh, bad_thresh)
	if(pct >= warn_thresh) return "ok"
	if(pct >= bad_thresh)  return "warn"
	return "bad"

/datum/nano_module/program/ipc_diagnostics/proc/_inv_pct_class(pct, warn_thresh, bad_thresh)
	if(pct <= warn_thresh) return "ok"
	if(pct <= bad_thresh)  return "warn"
	return "bad"
