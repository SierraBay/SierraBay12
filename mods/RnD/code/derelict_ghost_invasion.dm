// Derelict Ghost Invasion System
// When a player first visits a derelict away site, eligible mobs are added to a
// shared pool. Ghosts can open the Ghost Invasion panel and occupy any free slot.

// ============================================================
// Global State
// ============================================================

var/global/list/derelict_z_visited = list()        // "[z]" -> TRUE (already visited)
var/global/list/derelict_z_to_mission = list()     // "[z]" -> /datum/derelict_mission (built during mission generation)
/// Available invasion slots: living mob -> away site display name
var/global/list/derelict_ghost_invasion_pool = list()

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
	if(istype(target, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = target
		if(animal.projectiletype)
			to_chat(target, SPAN_NOTICE("Click distant targets to fire."))
		if(!isnull(animal.special_attack_min_range))
			to_chat(target, SPAN_NOTICE("Middle-click (or Abilities → Special Ability) to use your special attack."))

/datum/ghosttrap/derelict_crew/assess_candidate(mob/observer/ghost/candidate, mob/target, feedback = TRUE, no_target = FALSE)
	if(!no_target)
		if(!target || !(target in derelict_ghost_invasion_pool) || ismech(target))
			if(feedback)
				to_chat(candidate, "This invasion slot is no longer available.")
			return FALSE
	return ..()

/datum/ghosttrap/derelict_crew/transfer_personality(mob/candidate, mob/target)
	if(!(target in derelict_ghost_invasion_pool) || ismech(target))
		return FALSE
	// Parent assess_candidate still requires the target to be in the pool,
	// so only remove the slot after a successful transfer.
	. = ..()
	if(!.)
		return
	derelict_ghost_invasion_pool -= target
	GLOB.destroyed_event.unregister(target, src, TYPE_PROC_REF(/datum/ghosttrap/derelict_crew, cleanup_invasion_slot))

/datum/ghosttrap/derelict_crew/proc/cleanup_invasion_slot(mob/living/target)
	derelict_ghost_invasion_pool -= target
	GLOB.destroyed_event.unregister(target, src, TYPE_PROC_REF(/datum/ghosttrap/derelict_crew, cleanup_invasion_slot))

/datum/ghosttrap/derelict_crew/Topic(href, href_list)
	if(href_list["invasion_refresh"])
		var/mob/observer/ghost/ghost = locate(href_list["invasion_refresh"])
		if(istype(ghost) && ghost == usr)
			ghost.derelict_ghost_invasion()
		return TRUE

	if(href_list["invasion_follow"])
		var/mob/observer/ghost/ghost = usr
		var/mob/living/target = locate(href_list["invasion_follow"])
		if(!istype(ghost) || !is_derelict_ghost_invasion_candidate(target, null) || !(target in derelict_ghost_invasion_pool))
			to_chat(usr, SPAN_WARNING("That invasion slot is no longer available."))
			if(istype(ghost))
				ghost.derelict_ghost_invasion()
			return TRUE
		ghost.start_following(target)
		return TRUE

	if(href_list["candidate"] && href_list["target"])
		var/mob/observer/ghost/candidate = locate(href_list["candidate"])
		var/mob/target = locate(href_list["target"])
		if(!target || !candidate)
			return TRUE
		if(candidate != usr)
			return TRUE
		if(!assess_candidate(candidate, target))
			if(istype(candidate))
				candidate.derelict_ghost_invasion()
			return TRUE
		var/site_name = derelict_ghost_invasion_pool[target] || "the derelict"
		if(alert(candidate, "Would you like to occupy \a [target] on [site_name]?", "Ghost Invasion", "Yes", "No") != "Yes")
			return TRUE
		if(!assess_candidate(candidate, target))
			if(istype(candidate))
				candidate.derelict_ghost_invasion()
			return TRUE
		close_browser(candidate, "window=ghost_invasion")
		transfer_personality(candidate, target)
		return TRUE

	return ..()

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
// Eligibility
// ============================================================

/// Returns TRUE if this living mob can be offered as a ghost invasion slot.
/proc/is_derelict_ghost_invasion_candidate(mob/living/M, list/allowed_types)
	if(!istype(M) || QDELETED(M))
		return FALSE
	if(M.stat == DEAD || M.key || M.client)
		return FALSE
	// Exosuits / power loaders are not possessable invasion roles.
	if(ismech(M))
		return FALSE
	if(length(allowed_types) && !(M.type in allowed_types))
		return FALSE
	return TRUE

// ============================================================
// Ghost Invasion Trigger
// ============================================================

/proc/trigger_derelict_ghost_invasion(datum/derelict_mission/mission)
	if(!istype(mission))
		return

	// Collect all z-levels for this mission
	var/list/mission_z_levels = list()
	for(var/z_key in derelict_z_to_mission)
		if(derelict_z_to_mission[z_key] == mission)
			mission_z_levels += text2num(z_key)

	if(!length(mission_z_levels))
		return

	var/datum/ghosttrap/derelict_crew/trap = get_ghost_trap("derelict crew")
	if(!trap)
		return

	// Find all eligible mobs on those z-levels.
	// Only mob types that were present at map-load time are allowed —
	// this prevents player-controlled mobs arriving on the derelict from
	// appearing as invasion candidates.
	var/list/allowed_types = mission.initial_mob_types
	var/list/eligible = list()
	for(var/mob/living/M in GLOB.alive_mobs)
		if(!(M.z in mission_z_levels))
			continue
		if(M in derelict_ghost_invasion_pool)
			continue
		if(!is_derelict_ghost_invasion_candidate(M, allowed_types))
			continue
		eligible += M

	if(!length(eligible))
		return

	eligible = shuffle(eligible)

	// Get configured mob count (0 = all)
	var/datum/derelict_mission_config/cfg = derelict_mission_configs[mission.away_site_id]
	var/max_count = cfg?.ghost_mob_count || 0
	var/count = max_count > 0 ? min(max_count, length(eligible)) : length(eligible)

	for(var/i = 1 to count)
		var/mob/living/target = eligible[i]
		derelict_ghost_invasion_pool[target] = mission.away_site_name
		GLOB.destroyed_event.register(target, trap, TYPE_PROC_REF(/datum/ghosttrap/derelict_crew, cleanup_invasion_slot))

/proc/prune_derelict_ghost_invasion_pool()
	var/list/stale = list()
	for(var/mob/living/M as anything in derelict_ghost_invasion_pool)
		if(!is_derelict_ghost_invasion_candidate(M, null))
			stale += M
	if(!length(stale))
		return
	var/datum/ghosttrap/derelict_crew/trap = get_ghost_trap("derelict crew")
	for(var/mob/living/M as anything in stale)
		if(trap)
			trap.cleanup_invasion_slot(M)
		else
			derelict_ghost_invasion_pool -= M

/proc/get_derelict_invasion_type_label(mob/living/M)
	if(!istype(M))
		return "unknown"
	var/type_label = "[M.type]"
	var/slash = findlasttext(type_label, "/")
	if(slash)
		type_label = copytext(type_label, slash + 1)
	return type_label

// ============================================================
// Ghost Panel UI
// ============================================================

/mob/observer/ghost/verb/derelict_ghost_invasion()
	set category = "Ghost"
	set name = "Ghost Invasion"
	set desc = "View and occupy available derelict crew roles."

	if(!client)
		return

	var/datum/ghosttrap/derelict_crew/trap = get_ghost_trap("derelict crew")
	if(!trap || !trap.assess_candidate(src, null, TRUE, TRUE))
		return

	prune_derelict_ghost_invasion_pool()

	var/list/entries = list()
	for(var/mob/living/M as anything in derelict_ghost_invasion_pool)
		if(!istype(M))
			continue
		entries += M

	var/src_ref = "\ref[src]"
	var/trap_ref = "\ref[trap]"
	var/html = {"
		<style type="text/css">
			body { overflow: hidden !important; margin: 0; padding: 10px; box-sizing: border-box; color: #e0e0e0; background: #1a1a1a; }
			.action-link { display: inline-block; font-weight: bold; margin-right: 8px; color: #5dade2; text-decoration: none; }
			.action-link:hover { color: #85c1e9; }
			table { border-collapse: collapse; border-spacing: 0; width: 100%; margin: 0; }
			th {
				position: -webkit-sticky;
				position: sticky;
				top: 0;
				background: #202020;
				z-index: 10;
				box-shadow: inset 0 -1px 0 #333;
				background-clip: padding-box;
				text-align: left;
				padding: 6px 8px;
			}
			td { padding: 6px 8px; border-top: 1px solid #333; vertical-align: middle; }
			.type-label { color: #f39c12; font-size: 11px; }
			.empty { color: #888; padding: 20px; text-align: center; }
			.btn {
				padding: 4px 12px;
				background: #3498db;
				color: #fff;
				text-decoration: none;
				border-radius: 4px;
				font-weight: bold;
				font-size: 13px;
			}
		</style>
		<div style="display: flex; gap: 10px; padding-bottom: 10px; align-items: center;">
			<div style="flex-grow: 1; color: #bbb;">Available derelict crew roles ([length(entries)]). First come, first served.</div>
			<a href="byond://?src=[trap_ref];invasion_refresh=[src_ref]" class="btn">Refresh</a>
		</div>
		<div style="height: calc(100vh - 90px); overflow-y: auto; border: 1px solid #333; border-radius: 4px;">
	"}

	if(!length(entries))
		html += {"<div class="empty">No invasion slots available right now.<br>Slots appear when a crew first arrives at a derelict.</div>"}
	else
		html += {"
			<table class="data hover" id="invasion_table">
				<thead>
					<tr>
						<th style="width: 40%;">Name</th>
						<th style="width: 30%;">Location</th>
						<th style="width: 30%;">Actions</th>
					</tr>
				</thead>
				<tbody>
		"}
		for(var/mob/living/M in entries)
			var/site_name = derelict_ghost_invasion_pool[M]
			var/mob_ref = "\ref[M]"
			var/display_name = html_encode(M.name)
			var/type_label = html_encode(get_derelict_invasion_type_label(M))
			html += {"
				<tr>
					<td>
						<div>[display_name]</div>
						<div class="type-label">[type_label]</div>
					</td>
					<td>[html_encode(site_name)]</td>
					<td>
						<a href='byond://?src=[trap_ref];candidate=[src_ref];target=[mob_ref]' class='action-link'>Occupy</a>
						<a href='byond://?src=[trap_ref];invasion_follow=[mob_ref]' class='action-link'>Follow</a>
					</td>
				</tr>
			"}
		html += {"
				</tbody>
			</table>
		"}

	html += "</div>"

	var/datum/browser/popup = new(src, "ghost_invasion", "Ghost Invasion", 650, 500)
	popup.set_content(html)
	popup.open()

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
		var/list/z_levels = list()
		for(var/z_offset = 0 to z_count - 1)
			var/z = M.away_z + z_offset
			derelict_z_to_mission["[z]"] = M
			z_levels += z

		// Snapshot all living mob types on the derelict at load time.
		// This whitelist prevents player-controlled mobs that arrive later
		// from appearing as ghost invasion candidates.
		M.initial_mob_types = list()
		for(var/mob/living/mob in GLOB.alive_mobs)
			if(!(mob.z in z_levels))
				continue
			if(ismech(mob))
				continue
			M.initial_mob_types[mob.type] = TRUE

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
