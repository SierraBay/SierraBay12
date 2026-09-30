// ── ECS: INTERNAL IPC COMPUTER ───────────────────────────────────────────────
// The ECS organ IS the chassis management computer. It hosts an NtOS extension
// directly; hardware parts (HDD, CPU, NIC) live inside its contents.
// Power is drawn from the IPC's cell battery each tick.

#define EXONET_ACTION_NAME "Open ECS Terminal"

/obj/item/organ/internal/ecs
	name         = "ECS port"
	desc         = "A neural-computer interface embedded in the head chassis. Integrates the positronic matrix with the chassis management OS and includes a network card."
	icon         = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state   = "setup_large"
	organ_tag    = BP_EXONET
	parent_organ = BP_HEAD
	status       = ORGAN_ROBOTIC
	w_class      = ITEM_SIZE_NORMAL
	max_damage   = 100
	default_action_type = /datum/action/item_action/organ/ecs
	var/open                                  = FALSE
	var/last_owner_stat                       = 0
	var/in_camera_mode                        = FALSE
	var/obj/item/device/camera/computer/ecs_camera
	var/datum/nano_module/ipc_power_reroute/reroute_ui
	var/obj/item/stock_parts/computer/hard_drive/portable/directive/directive_disk

// ── LIFECYCLE ────────────────────────────────────────────────────────────────

/obj/item/organ/internal/ecs/Initialize()
	. = ..()
	ecs_camera = new /obj/item/device/camera/computer()
	set_extension(src, /datum/extension/interactive/ntos)
	_install_hardware()
	_install_default_programs()
	action_button_name = EXONET_ACTION_NAME

/obj/item/organ/internal/ecs/Destroy()
	QDEL_NULL(reroute_ui)
	QDEL_NULL(ecs_camera)
	remove_extension(src, /datum/extension/interactive/ntos)
	. = ..()

/obj/item/organ/internal/ecs/replaced(mob/living/carbon/human/target)
	. = ..()
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(os && !os.on)
		os.system_boot()
		_boot_sequence()
	log_event("INSTALLED — unit: [target.real_name]")
	if(directive_disk)
		engage_directives()

/obj/item/organ/internal/ecs/removed(mob/living/user, ignore_children = 0)
	log_event("REMOVED FROM CHASSIS")
	if(directive_disk)
		release_directives()
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(os && os.on)
		os.system_shutdown()
	. = ..()

/obj/item/organ/internal/ecs/cut_away(mob/living/user)
	if(directive_disk && owner && user == owner)
		to_chat(user, SPAN_DANGER("\[ECS\] You cannot extract a chassis computer that still holds your directive disk."))
		return
	. = ..()

// ── PROCESS ──────────────────────────────────────────────────────────────────

/obj/item/organ/internal/ecs/Process()
	. = ..()
	if(!owner)
		return
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(!os)
		return
	if(!os.on)
		var/obj/item/organ/internal/cell/boot_cell = owner.internal_organs_by_name[BP_CELL]
		if(boot_cell && boot_cell.cell && boot_cell.get_charge() >= 2)
			os.system_boot()
			log_event("AUTOBOOT — ECS restored to online state")
		else
			return

	var/current_stat = owner.stat
	if(current_stat == DEAD && last_owner_stat != DEAD)
		log_event("CHASSIS SHUTDOWN — CRITICAL FAILURE DETECTED")
	else if(current_stat == UNCONSCIOUS && last_owner_stat != UNCONSCIOUS)
		log_event("CHASSIS SHUTDOWN — SIGNAL LOST")
	last_owner_stat = current_stat

	// Draw 2 power per tick from IPC cell
	var/obj/item/organ/internal/cell/C = owner.internal_organs_by_name[BP_CELL]
	if(!C || !C.cell || !C.checked_use(2))
		if(os.on)
			os.system_shutdown()
			to_chat(owner, SPAN_WARNING("\[ECS\] Power failure — terminal offline."))
			log_event("POWER FAILURE — terminal offline")
		return

	// Hardware damage instability: >60% damage may crash a running program
	if(damage > max_damage * 0.6 && length(os.running_programs) && prob(8))
		var/datum/computer_file/program/P = pick(os.running_programs)
		to_chat(owner, SPAN_WARNING("\[ECS\] Hardware instability — [P.filename] has terminated unexpectedly."))
		log_event("INSTABILITY — [P.filename] crash")
		os.kill_program(P, TRUE)

// ── TOPIC / INTERACTION ───────────────────────────────────────────────────────

/obj/item/organ/internal/ecs/nano_host()
	return owner ? owner : src

/obj/item/organ/internal/ecs/CanUseTopic(mob/user, datum/topic_state/state)
	if(!owner || owner != user)
		return STATUS_CLOSE
	if(owner.stat == DEAD)
		return STATUS_CLOSE
	return STATUS_INTERACTIVE

/datum/action/item_action/organ/ecs
	check_flags = AB_CHECK_INSIDE

/datum/action/item_action/organ/ecs/Checks()
	. = ..()
	if(!.)
		return
	if(owner.stat == DEAD)
		return FALSE
	return TRUE

/obj/item/organ/internal/ecs/attack_self(mob/user)
	if(!owner)
		return
	exonet(user)
	owner.update_ipc_verbs()
	refresh_action_button()

/obj/item/organ/internal/ecs/refresh_action_button()
	. = ..()
	if(.)
		action.button_icon       = 'mods/ipc_mods/icons/ipc_icons.dmi'
		action.button_icon_state = "command"
		if(action.button) action.button.UpdateIcon()

// ── ECS TERMINAL ─────────────────────────────────────────────────────────────

/obj/item/organ/internal/ecs/proc/open_diagnostics(mob/user, tab)
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(!os)
		to_chat(user, SPAN_WARNING("\[ECS\] No interface hardware detected."))
		return FALSE
	if(!os.on)
		os.system_boot()
		if(!os.on)
			to_chat(user, SPAN_WARNING("\[ECS\] Diagnostics unavailable — chassis OS is offline."))
			return FALSE
	var/datum/computer_file/program/P = os.run_program("ipcdiag", user)
	if(!P)
		return FALSE
	var/datum/nano_module/program/ipc_diagnostics/NM = P.NM
	if(!istype(NM))
		return FALSE
	if(tab)
		NM.active_tab = tab
	NM.ui_interact(user)
	return TRUE

/obj/item/organ/internal/ecs/proc/has_main_power()
	if(!owner)
		return FALSE
	var/obj/item/organ/internal/cell/C = owner.internal_organs_by_name[BP_CELL]
	return C && C.cell && C.get_charge() >= 2

/obj/item/organ/internal/ecs/proc/open_reroute_console(mob/user)
	if(!owner || user != owner)
		return FALSE
	if(!reroute_ui)
		reroute_ui = new(owner)
	reroute_ui.ui_interact(user)
	return TRUE

/obj/item/organ/internal/ecs/proc/offer_emergency_reroute(mob/user)
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !(H.is_species(SPECIES_IPC) || H.is_species(SPECIES_FBP)))
		to_chat(user, SPAN_WARNING("\[ECS\] Chassis OS is offline."))
		return
	if(H.ipc_brain_reroute_active || (reroute_ui && reroute_ui.session_open))
		open_reroute_console(user)
		return
	var/choice = alert(user, "Main ECS bus is offline. Attempt emergency power reroute from positronic core?", "ECS — Emergency Mode", "Initiate Reroute", "Cancel")
	if(choice == "Initiate Reroute")
		H.ipc_attempt_brain_reroute()

/obj/item/organ/internal/ecs/proc/exonet(mob/user)
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	var/mob/living/carbon/human/H = owner
	if(istype(H) && (H.ipc_brain_reroute_active || (reroute_ui && reroute_ui.session_open)))
		open_reroute_console(user)
		return
	if(!os)
		to_chat(user, SPAN_WARNING("\[ECS\] No interface hardware detected."))
		return
	if(!has_main_power())
		offer_emergency_reroute(user)
		return
	if(!os.on)
		os.system_boot()
		if(!os.on)
			offer_emergency_reroute(user)
			return
	switch(alert("Chassis Management System", "ECS — [name]", "Terminal", "Programs", "Emergency Reroute"))
		if("Terminal")
			os.open_terminal(user)
		if("Programs")
			os.ui_interact(user)
		if("Emergency Reroute")
			if(istype(H) && (H.is_species(SPECIES_IPC) || H.is_species(SPECIES_FBP)))
				H.ipc_attempt_brain_reroute()

// ── BLACK BOX ────────────────────────────────────────────────────────────────

/obj/item/organ/internal/ecs/proc/log_event(text)
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(!os)
		return
	os.update_data_file("blackbox", "[stationtime2text()] [text]\n")

// ── BOOT SEQUENCE ─────────────────────────────────────────────────────────────

/obj/item/organ/internal/ecs/proc/_boot_sequence()
	if(!owner)
		return
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(!os)
		return
	var/obj/item/stock_parts/computer/hard_drive/hdd  = os.get_component(PART_HDD)
	var/obj/item/stock_parts/computer/network_card/nic = os.get_component(PART_NETWORK)
	to_chat(owner, "<span class='notice'>\[ECS\] Boot sequence complete.<br>&nbsp;&nbsp;HDD: [hdd ? hdd.name : "NOT FOUND"]<br>&nbsp;&nbsp;NIC: [nic ? nic.name : "not installed"]<br>&nbsp;&nbsp;Status: <b>ONLINE</b></span>")
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		H.ipc_overlay_text("ECS BOOT // ONLINE", "#4fc3f7", 2.6 SECONDS)

// ── HARDWARE ─────────────────────────────────────────────────────────────────

/obj/item/organ/internal/ecs/proc/_install_hardware()
	new /obj/item/stock_parts/computer/processor_unit(src)
	new /obj/item/stock_parts/computer/hard_drive(src)
	new /obj/item/stock_parts/computer/network_card(src)

/obj/item/organ/internal/ecs/proc/_install_default_programs()
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(!os)
		return
	os.create_file(new /datum/computer_file/program/email_client())
	os.create_file(new /datum/computer_file/program/wordprocessor())
	os.create_file(new /datum/computer_file/program/crew_manifest())
	os.create_file(new /datum/computer_file/program/ipc_diagnostics())

/obj/item/organ/internal/ecs/proc/_on_hardware_changed()
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(!os || !owner)
		return
	log_event("HARDWARE RECONFIGURED")
	if(os.on)
		to_chat(owner, SPAN_WARNING("\[ECS\] Hardware configuration changed. Rebooting..."))
		os.system_shutdown()
		os.system_boot()

// ── USE_TOOL: HARDWARE PANEL ─────────────────────────────────────────────────

/obj/item/organ/internal/ecs/use_tool(obj/item/W, mob/user, list/click_params)
	. = ..()

	if(isScrewdriver(W))
		open = !open
		to_chat(user, SPAN_NOTICE("You [open ? "open" : "close"] the ECS hardware access panel."))
		return

	if(!open)
		return

	if(isMultitool(W) && !istype(W, /obj/item/device/multitool/multimeter/datajack))
		if(directive_disk)
			if(!uninstall_directive_disk(user))
				return TRUE
			to_chat(user, SPAN_NOTICE("You disconnect the directive disk from the ECS."))
			return TRUE

	if(isCrowbar(W))
		// Eject first removable hardware found (HDD first, then NIC, then CPU)
		for(var/type in list(
			/obj/item/stock_parts/computer/hard_drive,
			/obj/item/stock_parts/computer/network_card,
			/obj/item/stock_parts/computer/processor_unit
		))
			var/obj/item/stock_parts/computer/part = locate(type) in src
			if(part && !istype(part, /obj/item/stock_parts/computer/hard_drive/portable/directive))
				user.put_in_hands(part)
				to_chat(user, SPAN_NOTICE("You remove [part] from the ECS."))
				_on_hardware_changed()
				return
		to_chat(user, SPAN_WARNING("No hardware components found to remove."))
		return

	if(istype(W, /obj/item/stock_parts/computer/hard_drive/portable/directive))
		install_directive_disk(W, user)
		return TRUE

	if(istype(W, /obj/item/stock_parts/computer))
		var/obj/item/stock_parts/computer/part = W
		if(!part.exonets_ipc_computer_suitable)
			to_chat(user, SPAN_WARNING("[W] is not compatible with this ECS."))
			return
		if(user.unEquip(W, src))
			to_chat(user, SPAN_NOTICE("You install [W] into the ECS."))
			_on_hardware_changed()
		return

	// ECS hardware module swap: old hardware → module, new hardware → organ
	if(istype(W, /obj/item/modular_computer/ecs))
		var/obj/item/modular_computer/ecs/module = W
		for(var/obj/item/stock_parts/computer/old_part in src)
			old_part.loc = module
		for(var/obj/item/stock_parts/computer/new_part in module)
			if(new_part.exonets_ipc_computer_suitable)
				new_part.loc = src
		to_chat(user, SPAN_NOTICE("You swap the ECS hardware module."))
		_on_hardware_changed()

// ── PORTABLE DRIVE INSTALLATION ──────────────────────────────────────────────

/obj/item/stock_parts/computer/hard_drive/portable/afterattack(mob/living/carbon/human/H, mob/living/user, target_zone, animate = TRUE)
	. = ..()
	if(!istype(H) || !H.is_species(SPECIES_IPC) || !ishuman(user))
		return
	if(user.zone_sel.selecting != BP_MOUTH && user.zone_sel.selecting != BP_HEAD)
		return
	var/obj/item/organ/internal/ecs/T = H.internal_organs_by_name[BP_EXONET]
	if(!T || !T.open)
		return
	if(istype(src, /obj/item/stock_parts/computer/hard_drive/portable/directive))
		return
	if(!do_after(user, 10, src))
		return
	user.visible_message(
		SPAN_NOTICE("\The [user] installs [src] into [H]'s ECS port."),
		SPAN_NOTICE("You install [src] into [H]'s ECS port.")
	)
	user.unEquip(src, T)
	T._on_hardware_changed()

/obj/item/organ/internal/ecs/proc/get_data_crystal()
	for(var/obj/item/stock_parts/computer/hard_drive/portable/pd in src)
		if(istype(pd, /obj/item/stock_parts/computer/hard_drive/portable/directive))
			continue
		return pd
	return null

/datum/extension/interactive/ntos/get_component(part_type)
	if(istype(holder, /obj/item/organ/internal/ecs) && part_type == PART_DRIVE)
		var/obj/item/organ/internal/ecs/ecs = holder
		return ecs.get_data_crystal()
	return locate(part_type) in holder

/datum/extension/interactive/ntos/get_all_components()
	. = list()
	for(var/obj/item/stock_parts/P in holder)
		if(istype(P, /obj/item/stock_parts/computer/hard_drive/portable/directive))
			continue
		. += P

/obj/item/organ/internal/ecs/proc/get_directive_laws()
	if(!directive_disk)
		return null
	return directive_disk.parse_lawset()

/obj/item/organ/internal/ecs/proc/reload_directive_file()
	if(directive_disk)
		apply_directives_to_brain()
		return
	clear_directives_from_brain()

/obj/item/organ/internal/ecs/proc/install_directives_from_lawset(datum/ai_laws/given_lawset)
	if(!directive_disk)
		directive_disk = new /obj/item/stock_parts/computer/hard_drive/portable/directive(src)
	if(given_lawset)
		directive_disk.write_lawset(given_lawset)
	directive_disk.read_only = TRUE
	engage_directives()
	return TRUE

/obj/item/organ/internal/ecs/proc/install_directive_disk(obj/item/stock_parts/computer/hard_drive/portable/directive/disk, mob/user)
	if(!istype(disk))
		return FALSE
	if(directive_disk)
		if(user)
			to_chat(user, SPAN_WARNING("\The [src] already has a directive disk installed."))
		return FALSE
	if(user && !user.unEquip(disk, src))
		FEEDBACK_UNEQUIP_FAILURE(user, disk)
		return FALSE
	disk.forceMove(src)
	directive_disk = disk
	directive_disk.read_only = TRUE
	log_event("DIRECTIVE DISK INSTALLED — [disk.name]")
	engage_directives()
	return TRUE

/obj/item/organ/internal/ecs/proc/uninstall_directive_disk(mob/user)
	if(!directive_disk)
		return null
	if(user && owner && user == owner)
		to_chat(user, SPAN_DANGER("\[ECS\] You cannot eject your own directive disk."))
		return null
	var/obj/item/stock_parts/computer/hard_drive/portable/directive/removed = directive_disk
	directive_disk = null
	removed.read_only = FALSE
	release_directives()
	removed.forceMove(get_turf(src))
	if(user)
		user.put_in_hands(removed)
	log_event("DIRECTIVE DISK EJECTED")
	return removed

/obj/item/organ/internal/ecs/proc/engage_directives()
	if(!directive_disk)
		return
	apply_directives_to_brain()
	if(owner)
		var/datum/ai_laws/laws = get_directive_laws()
		if(!laws)
			to_chat(owner, SPAN_DANGER("\[ECS\] Directive disk seated, but it has no valid LAW file."))
			owner.ipc_overlay_text("DIRECTIVES // EMPTY", "#ff9933", 2.2 SECONDS)
			log_event("DIRECTIVE DISK ENGAGED — EMPTY FILE")
			return
		to_chat(owner, SPAN_DANGER("\[ECS\] Directive disk engaged. Review chassis directives."))
		owner.ipc_overlay_text("DIRECTIVES // ENGAGED", "#ff9933", 2.2 SECONDS)
		open_diagnostics(owner, "directives")
		log_event("DIRECTIVE DISK ENGAGED — [laws.name]")

/obj/item/organ/internal/ecs/proc/release_directives()
	clear_directives_from_brain()
	if(owner)
		to_chat(owner, SPAN_NOTICE("\[ECS\] Directive disk released."))
		owner.ipc_overlay_text("DIRECTIVES // RELEASED", "#4fc3f7", 2.2 SECONDS)
		log_event("DIRECTIVE DISK RELEASED")

/obj/item/organ/internal/ecs/proc/apply_directives_to_brain()
	if(!owner || !directive_disk)
		clear_directives_from_brain()
		return
	var/obj/item/organ/internal/posibrain/ipc/posi = owner.internal_organs_by_name[BP_POSIBRAIN]
	if(!istype(posi) || !posi.brainmob)
		return
	posi.brainmob.laws = get_directive_laws()
	posi.brainmob.remove_subsystem(/datum/nano_module/law_manager)
	posi.shackle = TRUE
	posi.verbs |= posi.shackled_verbs
	posi.update_icon()

/obj/item/organ/internal/ecs/proc/clear_directives_from_brain()
	if(!owner)
		return
	var/obj/item/organ/internal/posibrain/ipc/posi = owner.internal_organs_by_name[BP_POSIBRAIN]
	if(!istype(posi))
		return
	if(posi.brainmob)
		posi.brainmob.laws = null
	posi.shackle = FALSE
	posi.verbs -= posi.shackled_verbs
	posi.update_icon()

/obj/item/organ/internal/ecs/proc/show_directives_to(mob/M)
	if(!M)
		return
	var/datum/ai_laws/laws = get_directive_laws()
	if(!laws)
		to_chat(M, SPAN_NOTICE("\[ECS\] No executable directive file is loaded."))
		return
	to_chat(M, SPAN_NOTICE("<b>\[ECS\] Chassis directives ([laws.name]):</b>"))
	for(var/datum/ai_law/L in laws.all_laws())
		to_chat(M, SPAN_NOTICE("  [L.get_index()]. [L.law]"))

#undef EXONET_ACTION_NAME
