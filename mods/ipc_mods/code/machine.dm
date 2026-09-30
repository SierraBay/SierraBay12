#define SCREEN_CHANGE_BUTTON "Change Screen"
#define EXONET_ACTION_NAME "Open ECS Terminal"

// Per-mob heat gain for IPCs, replaces species singleton passive_temp_gain
/mob/living/carbon/human
	var/ipc_temp_gain = 0
	// Штраф: Hephaestus/Shellguard (боевые) в миксе с любой другой маркой
	var/ipc_brand_siemens_penalty = 0
	// Накопленная тепловая нагрузка от длительного бега без стамины (0–2, множитель нагрева = 1 + это значение)
	var/ipc_sprint_heat_buildup = 0
	// Режим овердрайва: разрешает бег при нулевой стамине ценой ускоренного перегрева
	var/ipc_overdrive_enabled = FALSE
	// Emergency brain-power rerouting state (used when cell is missing/depleted)
	var/ipc_brain_reroute_active = FALSE
	var/ipc_brain_reroute_next_drain = 0
	var/ipc_brain_reroute_cooldown_until = 0
	var/ipc_brain_reroute_last_report_bucket = 100
	// Terminator-style HUD text overlay toggle/state
	var/ipc_hud_overlay_enabled = TRUE
	var/ipc_overlay_next_temp_alert = 0
	var/list/ipc_overlay_critical_queue = list()
	var/ipc_overlay_critical_flush_scheduled = FALSE

/mob/living/carbon/human/proc/ipc_overlay_text(text, color = "#ff3333", hold_time = 3 SECONDS, typing = TRUE, delay_between_words = 0.04 SECONDS)
	if(!ipc_hud_overlay_enabled || !client || !text)
		return
	var/formatted_text = "\[[uppertext(trimtext(text))]\]"
	client.play_screentext_on_client_screen(
		input_text = formatted_text,
		holding_on_screen_time = hold_time,
		need_output_every_word = typing,
		delay_between_words = delay_between_words,
		text_color = color,
		input_shrift = "Bank Gothic",
		clear_screen = TRUE
	)

/mob/living/carbon/human/proc/ipc_queue_critical_alert(text)
	if(!ipc_hud_overlay_enabled || !text)
		return
	if(!(text in ipc_overlay_critical_queue))
		ipc_overlay_critical_queue += text
	if(!ipc_overlay_critical_flush_scheduled)
		ipc_overlay_critical_flush_scheduled = TRUE
		addtimer(new Callback(src, PROC_REF(ipc_flush_critical_alerts)), 2)

/mob/living/carbon/human/proc/ipc_flush_critical_alerts()
	ipc_overlay_critical_flush_scheduled = FALSE
	if(!ipc_hud_overlay_enabled || !length(ipc_overlay_critical_queue))
		ipc_overlay_critical_queue.Cut()
		return
	if(length(ipc_overlay_critical_queue) == 1)
		ipc_overlay_text("CRITICAL DAMAGE // [ipc_overlay_critical_queue[1]]", "#ff3333", 2.8 SECONDS)
	else
		var/list/parts = ipc_overlay_critical_queue.Copy()
		ipc_overlay_text("CRITICAL DAMAGE // [jointext(parts, " | ")]", "#ff3333", 3.2 SECONDS)
	ipc_overlay_critical_queue.Cut()

/mob/living/carbon/human/apply_damage(damage = 0, damagetype = DAMAGE_BRUTE, def_zone, damage_flags = FLAGS_OFF, obj/used_weapon, armor_pen, silent = FALSE, obj/item/organ/external/given_organ)
	. = ..()
	if(!(is_species(SPECIES_IPC) || is_species(SPECIES_FBP)))
		return
	if(!(damagetype in list(DAMAGE_BRUTE, DAMAGE_BURN)) || damage <= 0)
		return
	var/obj/item/organ/external/organ = given_organ
	if(!organ && def_zone)
		organ = isorgan(def_zone) ? def_zone : get_organ(check_zone(def_zone))
	if(!organ)
		return
	var/total_pct = round(((organ.brute_dam + organ.burn_dam) / max(1, organ.max_damage)) * 100)
	if(total_pct >= 70 || organ.is_broken() || (organ.status & ORGAN_BROKEN))
		ipc_queue_critical_alert(uppertext(organ.name))

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
	ipc_overlay_text("POWER REROUTING // DISENGAGED", "#ff9933", 2.2 SECONDS)
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
	ipc_overlay_text("POWER REROUTING // ENGAGED", "#ff3333", 3 SECONDS)
	to_chat(src, SPAN_WARNING("Emergency power rerouting engaged. Positronic matrix now feeding chassis bus."))
	return TRUE

/mob/living/carbon/human/proc/ipc_reroute_session_open()
	var/obj/item/organ/internal/ecs/ecs = internal_organs_by_name[BP_EXONET]
	return istype(ecs) && ecs.reroute_ui && ecs.reroute_ui.session_open

// ИПС не устаёт — стамина используется как "ресурс до перегрева", а не физическая усталость
/mob/living/carbon/human/adjust_stamina(amt)
	if(is_species(SPECIES_IPC) || is_species(SPECIES_FBP))
		var/last_stamina = stamina
		stamina = clamp(stamina + amt, 0, 100)
		if(last_stamina != stamina && hud_used)
			hud_used.update_stamina()
		return
	. = ..()

/mob/living/carbon/human/can_sprint()
	if(is_species(SPECIES_IPC) || is_species(SPECIES_FBP))
		if(ipc_overdrive_enabled)
			return TRUE
	. = ..()

/mob/living/carbon/human/movement_delay(singleton/move_intent/using_intent = move_intent)
	. = ..()
	// убираем штраф к скорости от кончившейся стамины — синтеты бегают бесконечно
	if((is_species(SPECIES_IPC) || is_species(SPECIES_FBP)) && ipc_overdrive_enabled && get_stamina() <= 0 && shock_stage < 10)
		. -= 3

/mob/living/carbon/human/stabilize_body_temperature()
	if(is_species(SPECIES_IPC) || is_species(SPECIES_FBP))
		if(ipc_temp_gain)
			bodytemperature += ipc_temp_gain
		if(robolimb_count)
			var/list/brands = list()
			var/total_limb_heat = 0
			var/base_limb_heat = 0
			var/sprinting = ipc_overdrive_enabled && istype(move_intent, /singleton/move_intent/run) && get_stamina() <= 0
			for(var/obj/item/organ/external/limb in organs)
				if(BP_IS_ROBOTIC(limb))
					if(limb.brand)
						brands |= limb.brand
					base_limb_heat += limb.heat_generation
					// нагрев только при беге с пустой стаминой
					if(sprinting)
						// повреждённые конечности греются сильнее (до +50% при максимальном уроне)
						var/damage_factor = 1 + ((limb.brute_dam + limb.burn_dam) / max(1, limb.max_damage)) * 0.5
						total_limb_heat += limb.heat_generation * damage_factor
			// боевые марки не дружат с чужими интерфейсами (и друг с другом)
			var/has_combat_brand = (("Hephaestus" in brands) || ("Shellguard" in brands))
			var/brand_conflict = has_combat_brand && length(brands) > 1
			ipc_brand_siemens_penalty = brand_conflict ? 0.1 : 0
			if(brand_conflict && base_limb_heat)
				bodytemperature += base_limb_heat * 0.15
			if(sprinting && total_limb_heat)
				// нарастающий перегрев: чем дольше бежишь без стамины, тем интенсивнее нагрев
				ipc_sprint_heat_buildup = min(ipc_sprint_heat_buildup + 0.1, 2.0)
				total_limb_heat *= (1 + ipc_sprint_heat_buildup)
				if(brand_conflict)
					total_limb_heat *= 1.15
					if(prob(2))
						to_chat(src, SPAN_WARNING("Thermal mismatch detected — combat-grade prosthetic interfaces are conflicting with the rest of the chassis."))
				bodytemperature += total_limb_heat
			else if(ipc_sprint_heat_buildup)
				// при остановке или восстановлении стамины нагрузка спадает постепенно
				ipc_sprint_heat_buildup = max(ipc_sprint_heat_buildup - 0.05, 0)
			// сбой протезов: шанс растёт вместе со Sprint Heat Load (0–2 → 0–10%)
			if(ipc_sprint_heat_buildup > 0)
				var/has_cheap_limb = FALSE
				for(var/obj/item/organ/external/limb in organs)
					if(BP_IS_ROBOTIC(limb) && limb.expensive == 0)
						has_cheap_limb = TRUE
						break
				var/overload_chance = round(ipc_sprint_heat_buildup * (has_cheap_limb ? 6 : 4))
				if(overload_chance && prob(overload_chance))
					if(prob(50))
						to_chat(src, SPAN_WARNING("Your prosthetic arms stutter from thermal overload!"))
						if(prob(50)) drop_l_hand(force = TRUE)
						else drop_r_hand(force = TRUE)
					else
						to_chat(src, SPAN_WARNING("Your prosthetic legs lock up momentarily!"))
						Weaken(3)
		else
			ipc_brand_siemens_penalty = 0
		if(bodytemperature >= getSpeciesOrSynthTemp(HEAT_LEVEL_1) && world.time >= ipc_overlay_next_temp_alert)
			ipc_overlay_next_temp_alert = world.time + 80
			ipc_overlay_text("CORE TEMP WARNING // [round(bodytemperature - T0C)]C", "#ff3333", 2.5 SECONDS)
		return
	. = ..()

// Электропроводимость протеза: siemens марки и конфликт боевых (Hephaestus/Shellguard) с чужими
/mob/living/carbon/human/get_siemens_coefficient_organ(obj/item/organ/external/def_zone)
	. = ..()
	if(!(is_species(SPECIES_IPC) || is_species(SPECIES_FBP)))
		return
	if(def_zone && BP_IS_ROBOTIC(def_zone) && def_zone.siemens_coefficient)
		. *= def_zone.siemens_coefficient
	. += ipc_brand_siemens_penalty

// ── HEPHAESTUS: SERVO GRIP (дизарм) ──────────────────────────────────────────
// Вызывается из species.dm на target (/mob/living/carbon/human) — безопасен для всех
/mob/living/carbon/human/proc/get_prosthetic_disarm_resistance()
	if(!(is_species(SPECIES_IPC) || is_species(SPECIES_FBP)))
		return 0
	var/obj/item/organ/external/active = get_organ(hand ? BP_L_HAND : BP_R_HAND)
	var/obj/item/organ/external/inactive = get_organ(hand ? BP_R_HAND : BP_L_HAND)
	for(var/obj/item/organ/external/H in list(active, inactive))
		if(H && BP_IS_ROBOTIC(H) && H.brand == "Hephaestus")
			return 15
	return 0

// ── HEPHAESTUS: LOCKOUT (ноги не ломаются до высокого порога) ────────────────
/obj/item/organ/external/fracture()
	if(BP_IS_ROBOTIC(src) && brand == "Hephaestus" && (brute_dam + burn_dam) < max_damage * 0.85)
		return  // Hephaestus servo-joints resist fracture until near-destruction
	. = ..()

// ── XION ECON: ВЗРЫВ ПРИ ОТРЫВЕ ─────────────────────────────────────────────
/obj/item/organ/external/attempt_dismemberment(brute, burn, sharp, edge, used_weapon, spillover, force_droplimb)
	. = ..()
	if(. && BP_IS_ROBOTIC(src) && brand == "Xion" && expensive == 0)
		explosion(get_turf(src), 1, EX_ACT_LIGHT)

// ── MORPHEUS MANTIS: QUICK STRIKE ────────────────────────────────────────────
/mob/living/get_attack_speed(obj/item/item)
	. = ..()
	if(!istype(src, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = src
	if(!(H.is_species(SPECIES_IPC) || H.is_species(SPECIES_FBP)))
		return
	var/obj/item/organ/external/l = H.get_organ(BP_L_ARM)
	var/obj/item/organ/external/r = H.get_organ(BP_R_ARM)
	if(l && r && BP_IS_ROBOTIC(l) && BP_IS_ROBOTIC(r) && l.model == "Morpheus Mantis" && r.model == "Morpheus Mantis")
		. = max(1, . - 2)

// ── XION/NT/W-T ECONOMY: АКУСТИЧЕСКИЙ ШУМ ───────────────────────────────────
/mob/living/carbon/human/handle_footsteps()
	. = ..()
	if(!(is_species(SPECIES_IPC) || is_species(SPECIES_FBP)))
		return
	// step_count инкрементируется ПОСЛЕ вызова handle_footsteps, поэтому сдвигаем на 1
	if(!MOVING_QUICKLY(src) || (step_count + 1) % 4)
		return
	for(var/part in list(BP_L_FOOT, BP_R_FOOT, BP_L_LEG, BP_R_LEG))
		var/obj/item/organ/external/E = get_organ(part)
		if(E && BP_IS_ROBOTIC(E) && E.expensive == 0 && (E.brand in list("Xion", "Ward-Takahashi", "NanoTrasen")))
			var/turf/T = get_turf(src)
			if(istype(T))
				playsound(T, pick('sound/effects/footstep/plating1.ogg','sound/effects/footstep/plating2.ogg','sound/effects/footstep/plating3.ogg'), 85, 1, 3)
			break

// ── SURGE PROTECTOR: ЭМИ на конечностях и органах ────────────────────────────
// Один импульс — одно срабатывание фильтра. Лёгкий ЭМИ глотается, тяжёлый слабеет до light.
/obj/item/organ/external/emp_act(severity)
	if(BP_IS_ROBOTIC(src))
		severity = ipc_try_surge_protect(severity)
		if(!severity)
			return
	. = ..(severity)

/mob/living/carbon/human/local_emp(list/limbs, severity = 2)
	if(is_species(SPECIES_IPC) || is_species(SPECIES_FBP))
		var/obj/item/organ/internal/surge_protector/SP = internal_organs_by_name[BP_SURGE_PROTECTOR]
		if(SP && !(SP.status & ORGAN_DEAD))
			severity = SP.filter_severity(severity)
			if(!severity)
				return
	. = ..(severity)

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
	products[BP_SURGE_PROTECTOR] = list(/obj/item/organ/internal/surge_protector, 30)
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
			var/obj/item/organ/internal/surge_protector/sp = machine.internal_organs_by_name[BP_SURGE_PROTECTOR]
			if(sp)
				var/sp_status = (sp.status & ORGAN_DEAD) ? "<font color='red'>FAILED</font>" : \
					"[round((1 - sp.damage / sp.max_damage) * 100)]%"
				to_chat(usr, SPAN_WARNING("Surge protector: [sp_status]"))

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
