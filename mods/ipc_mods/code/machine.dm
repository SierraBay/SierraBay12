#define SCREEN_CHANGE_BUTTON "Change Screen"
#define EXONET_ACTION_NAME "Open ECS Terminal"

// Per-mob heat gain for IPCs, replaces species singleton passive_temp_gain
/mob/living/carbon/human
	var/ipc_temp_gain = 0
	// Emergency brain-power rerouting state (used when cell is missing/depleted)
	var/ipc_brain_reroute_active = FALSE
	var/ipc_brain_reroute_next_drain = 0
	var/ipc_brain_reroute_cooldown_until = 0
	var/ipc_brain_reroute_last_report_bucket = 100

/mob/living/carbon/human/proc/ipc_can_start_brain_reroute()
	if(!(is_species(SPECIES_IPC) || is_species(SPECIES_FBP)))
		return FALSE
	if(ipc_brain_reroute_active)
		return FALSE
	if(ipc_brain_reroute_cooldown_until > world.time)
		return FALSE
	var/obj/item/organ/internal/cell/C = internal_organs_by_name[BP_CELL]
	if(C && C.cell && C.get_charge() > 0)
		return FALSE
	var/obj/item/organ/internal/posibrain/ipc/P = internal_organs_by_name[BP_POSIBRAIN]
	if(!P || (P.status & ORGAN_DEAD))
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/ipc_close_reroute_session()
	var/obj/item/organ/internal/ecs/ecs = internal_organs_by_name[BP_EXONET]
	if(!istype(ecs) || !ecs.reroute_ui)
		return
	ecs.reroute_ui.session_open = FALSE
	ecs.reroute_ui.path = list("core")
	SSnano.close_uis(ecs.reroute_ui)

/mob/living/carbon/human/proc/ipc_apply_power_failure()
	var/obj/item/organ/internal/cell/C = internal_organs_by_name[BP_CELL]
	if(C && C.cell && C.get_charge() > 0)
		return
	if(!lying && !buckled)
		to_chat(src, SPAN_WARNING("You don't have enough energy to function!"))
	Weaken(3)
	Paralyse(3)

/mob/living/carbon/human/proc/ipc_drop_emergency_power(message = null)
	var/had_emergency = ipc_brain_reroute_active || ipc_reroute_session_open()
	ipc_close_reroute_session()
	ipc_brain_reroute_active = FALSE
	ipc_brain_reroute_next_drain = 0
	ipc_brain_reroute_last_report_bucket = 100
	if(!had_emergency && !message)
		ipc_apply_power_failure()
		return
	if(message)
		to_chat(src, SPAN_WARNING(message))
	ipc_apply_power_failure()

/mob/living/carbon/human/proc/ipc_stop_brain_reroute(message = null)
	ipc_drop_emergency_power(message)

/mob/living/carbon/human/proc/ipc_handle_brain_reroute_tick()
	if(!ipc_brain_reroute_active)
		return FALSE
	var/obj/item/organ/internal/cell/C = internal_organs_by_name[BP_CELL]
	if(C && C.cell && C.get_charge() > 0)
		ipc_stop_brain_reroute("External cell charge restored. Emergency reroute disengaged.")
		return FALSE
	var/obj/item/organ/internal/posibrain/ipc/P = internal_organs_by_name[BP_POSIBRAIN]
	if(!P || (P.status & ORGAN_DEAD))
		ipc_stop_brain_reroute("Positronic source offline. Emergency reroute aborted.")
		return FALSE
	if(world.time >= ipc_brain_reroute_next_drain)
		ipc_brain_reroute_next_drain = world.time + 40
		P.take_internal_damage(max(0.1, P.max_damage * 0.01))
		var/posi_health_pct = round((1 - P.damage / max(1, P.max_damage)) * 100)
		var/current_bucket = floor(posi_health_pct / 10) * 10
		if(current_bucket < ipc_brain_reroute_last_report_bucket)
			ipc_brain_reroute_last_report_bucket = current_bucket
			to_chat(src, SPAN_WARNING("Emergency reroute load spike. Positronic integrity: [posi_health_pct]%."))
		if(P.damage >= P.max_damage || (P.status & ORGAN_DEAD))
			ipc_stop_brain_reroute("Positronic matrix integrity failure. Emergency reroute terminated.")
			return FALSE
	return TRUE

/mob/living/carbon/human/proc/ipc_attempt_brain_reroute()
	if(!(is_species(SPECIES_IPC) || is_species(SPECIES_FBP)))
		return
	if(stat == DEAD)
		return
	if(ipc_brain_reroute_active)
		var/obj/item/organ/internal/ecs/ecs = internal_organs_by_name[BP_EXONET]
		if(istype(ecs))
			ecs.open_reroute_console(src)
		return
	if(ipc_brain_reroute_cooldown_until > world.time)
		var/wait_seconds = round((ipc_brain_reroute_cooldown_until - world.time) / 10)
		to_chat(src, SPAN_WARNING("Reroute relays cooling down ([wait_seconds]s)."))
		return
	var/obj/item/organ/internal/cell/C = internal_organs_by_name[BP_CELL]
	if(C && C.cell && C.get_charge() > 0)
		to_chat(src, SPAN_NOTICE("Main power cell available. Emergency reroute not required."))
		return
	var/obj/item/organ/internal/posibrain/ipc/P = internal_organs_by_name[BP_POSIBRAIN]
	if(!P || (P.status & ORGAN_DEAD))
		to_chat(src, SPAN_WARNING("Positronic source unavailable."))
		return

	var/obj/item/organ/internal/ecs/ecs = internal_organs_by_name[BP_EXONET]
	if(!istype(ecs))
		to_chat(src, SPAN_WARNING("No ECS interface to trace an alternate bus."))
		return
	if(!ecs.reroute_ui)
		ecs.reroute_ui = new(src)
	if(!ecs.reroute_ui.begin_session(src))
		return
	ecs.reroute_ui.ui_interact(src)

/mob/living/carbon/human/proc/ipc_engage_brain_reroute()
	if(ipc_brain_reroute_active)
		return FALSE
	if(!ipc_can_start_brain_reroute())
		return FALSE
	ipc_brain_reroute_active = TRUE
	ipc_brain_reroute_next_drain = world.time + 40
	ipc_brain_reroute_last_report_bucket = 100
	to_chat(src, SPAN_WARNING("Emergency power rerouting engaged. Positronic matrix now feeding chassis bus."))
	return TRUE

/mob/living/carbon/human/proc/ipc_reroute_session_open()
	var/obj/item/organ/internal/ecs/ecs = internal_organs_by_name[BP_EXONET]
	return istype(ecs) && ecs.reroute_ui && ecs.reroute_ui.session_open

// ИПС не устаёт как органик — стамина только ограничивает спринт, без штрафов усталости
/mob/living/carbon/human/adjust_stamina(amt)
	if(is_species(SPECIES_IPC) || is_species(SPECIES_FBP))
		var/last_stamina = stamina
		stamina = clamp(stamina + amt, 0, 100)
		if(last_stamina != stamina && hud_used)
			hud_used.update_stamina()
		return
	. = ..()

/mob/living/carbon/human/stabilize_body_temperature()
	if(is_species(SPECIES_IPC) || is_species(SPECIES_FBP))
		if(ipc_temp_gain)
			bodytemperature += ipc_temp_gain
		return
	. = ..()

/singleton/species/machine
	var/list/valid_jobs = list(
		/datum/job/adjutant,
		/datum/job/exploration_leader, /datum/job/explorer, /datum/job/explorer_pilot, /datum/job/explorer_medic, /datum/job/explorer_engineer,
		/datum/job/senior_engineer, /datum/job/engineer, /datum/job/infsys,
		/datum/job/senior_doctor, /datum/job/doctor, /datum/job/doctor_trainee, /datum/job/chemist, /datum/job/chaplain,
		/datum/job/qm, /datum/job/cargo_tech,  /datum/job/cargo_assistant, /datum/job/mining,
		/datum/job/janitor, /datum/job/cook, /datum/job/bartender, /datum/job/steward, /datum/job/chief_steward,
		/datum/job/senior_scientist, /datum/job/scientist, /datum/job/roboticist, /datum/job/scientist_assistant,
		/datum/job/ai, /datum/job/cyborg, /datum/job/assistant, /datum/job/vagabond,
		/datum/job/submap/scavver_pilot, /datum/job/submap/scavver_doctor, /datum/job/submap/scavver_engineer,
		/datum/job/submap/bearcat_captain, /datum/job/submap/bearcat_crewman,
		/datum/job/submap/CTI_pilot, /datum/job/submap/CTI_engineer,
		/datum/job/submap/merchant_leader, /datum/job/submap/merchant,
		/datum/job/submap/away_iccgn_farfleet, /datum/job/submap/away_iccgn_farfleet/iccgn_medic, /datum/job/submap/away_iccgn_farfleet/iccgn_gunner,
		/datum/job/submap/pod,
		/datum/job/submap/colonist/leader, /datum/job/submap/colonist, /datum/job/submap/colonist/scientist,
		/datum/job/submap/colonist/medic, /datum/job/submap/colonist/engineer,
		/datum/job/submap/colonist/leader/ship, /datum/job/submap/colonist/ship, /datum/job/submap/colonist/scientist/ship,
		/datum/job/submap/colonist/medic/ship, /datum/job/submap/colonist/engineer/ship
	)
	var/list/valid_jobs_shackled = list(
		/datum/job/hop, /datum/job/rd, /datum/job/cmo, /datum/job/chief_engineer,
		/datum/job/iaa, /datum/job/iso,
		/datum/job/warden, /datum/job/detective, /datum/job/officer
	)
	passive_temp_gain = 0  // This should cause IPCs to stabilize at ~80 C in a 20 C environment.(5 is default without organ)
	additional_languages = 1
	genders = list(MALE, FEMALE, PLURAL)
	appearance_flags = SPECIES_APPEARANCE_HAS_UNDERWEAR | SPECIES_APPEARANCE_HAS_EYE_COLOR | SPECIES_APPEARANCE_HAS_SKIN_TONE_NORMAL

/singleton/species/machine/skills_from_age(age)
	if(age)
		. = 8

/obj/machinery/organ_printer/robot/New()
	LAZYINITLIST(products)
	products[BP_COOLING] = list(/obj/item/organ/internal/cooling_system, 35)
	products[BP_EXONET] = list(/obj/item/organ/internal/ecs, 35)
	. = ..()

/obj/screen/bodytemp/Click(location, control, params)
	. = ..()
	if(istype(usr) && usr.bodytemp == src && usr.isSynthetic())
		var/mob/living/carbon/human/machine = usr
		to_chat(usr, SPAN_WARNING("Operating temperature: [round(machine.bodytemperature-T0C)]&deg;C"))
		if(usr.is_species(SPECIES_IPC))
			var/obj/item/organ/internal/cooling_system/coolant = machine.internal_organs_by_name[BP_COOLING]
			if(coolant)
				to_chat(usr, SPAN_WARNING("Coolant remaining: [coolant.get_coolant_remaining()]/[coolant.refrigerant_max]"))
				to_chat(usr, SPAN_WARNING("Thermostat: [round(coolant.thermostat - T0C)]&deg;C \
					<a href='?src=\ref[coolant];set_thermostat=1'>\[Adjust\]</a>"))

/obj/screen/cell/Click(location, control, params)
	. = ..()
	if(istype(usr))
		var/mob/living/carbon/human/machine = usr
		var/obj/item/organ/internal/cell/potato = machine.internal_organs_by_name[BP_CELL]
		if(!potato || !potato.cell)
			to_chat(usr, SPAN_WARNING("No internal battery."))
			return
		to_chat(usr, SPAN_WARNING("Battery charge: [potato.get_charge()]/[potato.cell.maxcharge]"))


/mob/living/carbon/human/proc/enter_exonet()
	set category = "Abilities"
	set name = "Enter Exonet"
	set desc = ""
	var/obj/item/organ/external/head/R = src.get_organ(BP_HEAD)
	var/obj/item/organ/internal/ecs/enter = src.internal_organs_by_name[BP_EXONET]

	if(!R)
		return
	if(R.is_stump() || R.is_broken())
		return
	if(!enter)
		to_chat(usr, "<span class='warning'>You have no exonet connection port</span>")
		return
	else
		enter.exonet(src)
	update_ipc_verbs()


/mob/living/carbon/human/OnSelfTopic(href_list, topic_status)
	.=..()
	if(href_list["showipcscreen"])
		var/obj/item/organ/internal/ecs/S = locate(href_list["showipcscreen"])
		if(S)
			var/datum/extension/interactive/ntos/os = get_extension(S, /datum/extension/interactive/ntos)
			if(os) os.open_terminal(src)
			return STATUS_UPDATE


/mob/living/carbon/human/proc/show_exonet_screen()
	set category = "Abilities"
	set name = "Show Exonet Screen"
	set desc = ""
	var/obj/item/organ/external/head/R = src.get_organ(BP_HEAD)
	var/obj/item/organ/internal/ecs/enter = src.internal_organs_by_name[BP_EXONET]

	if(!R)
		return
	if(R.is_stump() || R.is_broken())
		return

	var/datum/robolimb/robohead = all_robolimbs[R.model]
	if(!enter)
		to_chat(usr, "<span class='warning'>You have no exonet connection port</span>")
		return
	if(robohead.has_screen)
		enter.showscreen(src)
		facial_hair_style = "Database"
		update_hair()
	else
		to_chat(usr, "<span class='warning'>Your head has no screen!</span>")
	update_ipc_verbs()

/obj/item/proc/showscreen(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] changes image on his screen. <a HREF=?src=\ref[M];showipcscreen=\ref[src]>Take a closer look.</a>",1)

/mob/living/carbon/human/proc/update_ipc_verbs()
	var/obj/item/organ/external/head/R = src.get_organ(BP_HEAD)
	var/obj/item/organ/internal/ecs/enter = src.internal_organs_by_name[BP_EXONET]

	if(!R)
		src.verbs -= /mob/living/carbon/human/proc/show_exonet_screen
		src.verbs -= /mob/living/carbon/human/proc/ipc_eject_usb
		return

	var/datum/robolimb/robohead = all_robolimbs[R.model]

	if(robohead && robohead.has_screen)
		src.verbs |= /mob/living/carbon/human/proc/show_exonet_screen
		R.action_button_name = SCREEN_CHANGE_BUTTON
	else
		src.verbs -= /mob/living/carbon/human/proc/show_exonet_screen
		R.action_button_name = null

	// Keep ECS action button available even while unconscious.
	if(enter)
		enter.action_button_name = EXONET_ACTION_NAME
		enter.refresh_action_button()

	var/has_portable = enter && enter.get_data_crystal()
	if(has_portable)
		src.verbs |= /mob/living/carbon/human/proc/ipc_eject_usb
	else
		src.verbs -= /mob/living/carbon/human/proc/ipc_eject_usb

/mob/living/carbon/human/proc/ipc_eject_usb()
	set category = "Abilities"
	set name = "Eject Data Crystal"
	set desc = ""
	var/obj/item/organ/internal/ecs/enter = src.internal_organs_by_name[BP_EXONET]
	if(!enter)
		return
	var/obj/item/stock_parts/computer/hard_drive/portable/pd = enter.get_data_crystal()
	if(!pd)
		return
	src.put_in_hands(pd)
	enter._on_hardware_changed()
	update_ipc_verbs()



/singleton/species/machine/check_background(datum/job/job, datum/preferences/prefs)
	if(job.type in valid_jobs)
		return TRUE
	if(prefs.has_ipc_shackles() && (job.type in valid_jobs_shackled))
		return TRUE
	if(!length(valid_jobs) && !length(valid_jobs_shackled))
		return ..()
	return FALSE


/mob/living/silicon/laws_sanity_check()
	if(istype(src, /mob/living/silicon/sil_brainmob))
		var/mob/living/silicon/sil_brainmob/brain = src
		if(istype(brain.container, /obj/item/organ/internal/posibrain/ipc))
			return
	. = ..()

/obj/item/organ/external/head/attack_self(mob/user)
	. = ..()
	if(. && action_button_name == SCREEN_CHANGE_BUTTON && owner)
		owner.MachineChangeScreen()
		refresh_action_button()

/obj/item/organ/external/head/refresh_action_button()
	. = ..()
	if(. && istype(species, /singleton/species/machine))
		action.button_icon_state = "ipc_rgb"
		action.button_icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
		if(action.button) action.button.UpdateIcon()

/obj/item/organ/external/head/removed(mob/living/user, ignore_children = 0)
	var/mob/living/carbon/human/ipc = owner
	. = ..()
	if(istype(ipc) && ipc.is_species(SPECIES_IPC))
		ipc.update_ipc_verbs()

/obj/item/organ/external/head/replaced(mob/living/carbon/human/target)
	. = ..()
	if(istype(target) && target.is_species(SPECIES_IPC))
		target.update_ipc_verbs()
		refresh_action_button()
		var/obj/item/organ/internal/ecs/enter = target.internal_organs_by_name[BP_EXONET]
		if(enter)
			enter.refresh_action_button()

/mob/living/carbon/human/initial_data(datum/computer_file/program/program)
	. = ..()
	if(!is_species(SPECIES_IPC) && !is_species(SPECIES_FBP))
		return
	var/obj/item/organ/internal/ecs/ecs_organ = internal_organs_by_name[BP_EXONET]
	if(!ecs_organ)
		return
	var/datum/extension/interactive/ntos/os = get_extension(ecs_organ, /datum/extension/interactive/ntos)
	if(!os)
		return
	. += os.get_header_data(program)

#undef SCREEN_CHANGE_BUTTON
#undef EXONET_ACTION_NAME
