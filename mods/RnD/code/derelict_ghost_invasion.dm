// Derelict Ghost Invasion System
// When a player first visits a derelict away site, ghost observers are invited
// to possess random mobs on that derelict, turning PvE into potential PvP content.

// ============================================================
// Global State
// ============================================================

var/global/list/derelict_z_visited = list()        // "[z]" -> TRUE (already visited)
var/global/list/derelict_z_to_mission = list()     // "[z]" -> /datum/derelict_mission (built during mission generation)

// ============================================================
// Ghosttrap Datum
// ============================================================

/datum/ghosttrap/derelict_crew
	object = "derelict crew"
	ban_checks = list("Animal")
	ghost_trap_message = "They are now part of the derelict crew."
	ghost_trap_role = "Derelict Crew"
	can_set_own_name = FALSE

/datum/ghosttrap/derelict_crew/welcome_candidate(mob/target)
	to_chat(target, SPAN_BOLD(FONT_LARGE("You have been assigned to defend this location.")))
	to_chat(target, SPAN_BOLD("Attack any intruders on sight. You do not remember your past life."))

// ============================================================
// First-Visit Detection
// ============================================================

// Called from area/Entered() when a living mob enters any area.
// Quick early-exit for non-derelict z-levels via hash lookup.
/proc/check_derelict_first_visit(mob/living/L)
	if(!L?.client || isobserver(L))
		return
	var/z_key = "[L.z]"
	if(derelict_z_visited[z_key])
		return
	var/datum/derelict_mission/M = derelict_z_to_mission[z_key]
	if(!M)
		return
	derelict_z_visited[z_key] = TRUE
	// Mark all z-levels of this derelict as visited (multi-z support)
	for(var/other_z_key in derelict_z_to_mission)
		if(derelict_z_to_mission[other_z_key] == M)
			derelict_z_visited[other_z_key] = TRUE
	addtimer(new Callback(GLOBAL_PROC, /proc/trigger_derelict_ghost_invasion, M), 5 SECONDS)

// ============================================================
// Ghost Invasion Trigger
// ============================================================

/proc/trigger_derelict_ghost_invasion(datum/derelict_mission/mission)
	// Collect all z-levels for this mission
	var/list/mission_z_levels = list()
	for(var/z_key in derelict_z_to_mission)
		if(derelict_z_to_mission[z_key] == mission)
			mission_z_levels += text2num(z_key)

	if(!length(mission_z_levels))
		return

	// Find all eligible mobs on those z-levels
	var/list/eligible = list()
	for(var/mob/living/M in world)
		if(!(M.z in mission_z_levels))
			continue
		if(M.stat == DEAD || M.key || M.client)
			continue
		eligible += M

	if(!length(eligible))
		return

	eligible = shuffle(eligible)

	// Get configured mob count (0 = all)
	var/datum/derelict_mission_config/cfg = derelict_mission_configs[mission.away_site_id]
	var/max_count = cfg?.ghost_mob_count || 0
	var/count = max_count > 0 ? min(max_count, length(eligible)) : length(eligible)

	var/datum/ghosttrap/trap = get_ghost_trap("derelict crew")
	if(!trap)
		return

	for(var/i = 1 to count)
		var/mob/living/target = eligible[i]
		trap.request_player(target, \
			"Derelict crew on [mission.away_site_name] needs a mind! ([target.name])", \
			60 SECONDS)

// ============================================================
// Z-Level Mapping (called after generate_derelict_missions)
// ============================================================

/proc/build_derelict_z_mapping()
	derelict_z_to_mission.Cut()
	for(var/datum/derelict_mission/M in derelict_missions_list)
		if(M.away_z <= 0)
			continue
		// Determine how many z-levels this derelict spans
		var/z_count = 1
		for(var/tname in SSmapping.away_sites_templates)
			var/datum/map_template/ruin/away_site/T = SSmapping.away_sites_templates[tname]
			if(T.id == M.away_site_id)
				z_count = length(T.suffixes)
				break
		for(var/z_offset = 0 to z_count - 1)
			derelict_z_to_mission["[M.away_z + z_offset]"] = M

// ============================================================
// Human Ranged Attack Interfaces (for AI-controlled humans with guns)
// ============================================================

/mob/living/carbon/human/ICheckRangedAttack(atom/A)
	var/obj/item/gun/G = get_active_hand()
	if(istype(G))
		return TRUE
	return FALSE

/mob/living/carbon/human/IRangedAttack(atom/A)
	if(!canClick())
		return ATTACK_ON_COOLDOWN
	ClickOn(A)
	return TRUE
