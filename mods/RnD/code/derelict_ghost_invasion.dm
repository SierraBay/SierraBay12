// Derelict Ghost Invasion — first visit to a loaded away site offers ghost possession slots.
// Independent of the removed corporate mission/contract system.

var/global/list/derelict_z_visited = list()        // "[z]" -> TRUE
var/global/list/derelict_z_to_site = list()        // "[z]" -> /datum/derelict_site
var/global/list/derelict_sites_list = list()
/// Available invasion slots: living mob -> away site display name
var/global/list/derelict_ghost_invasion_pool = list()


/datum/derelict_site
	var/away_site_id
	var/away_site_name
	var/away_z = 0
	var/list/initial_mob_types = list()
	/// 0 = offer all eligible mobs.
	var/ghost_mob_count = 0


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
	. = ..()
	if(!.)
		return
	cleanup_invasion_slot(target)

/datum/ghosttrap/derelict_crew/proc/cleanup_invasion_slot(mob/living/M)
	if(!M)
		return
	derelict_ghost_invasion_pool -= M
	GLOB.destroyed_event.unregister(M, src, TYPE_PROC_REF(/datum/ghosttrap/derelict_crew, cleanup_invasion_slot))

/datum/ghosttrap/derelict_crew/Topic(href, href_list)
	if(href_list["invasion_refresh"])
		var/mob/observer/ghost/G = locate(href_list["invasion_refresh"])
		if(istype(G) && G == usr)
			G.derelict_ghost_invasion()
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
	return ..()


/proc/check_derelict_first_visit(mob/living/L)
	if(!L?.client || isobserver(L))
		return
	var/z_key = "[L.z]"
	if(derelict_z_visited[z_key])
		return
	var/datum/derelict_site/site = derelict_z_to_site[z_key]
	if(!site)
		return
	derelict_z_visited[z_key] = TRUE
	for(var/other_z_key in derelict_z_to_site)
		if(derelict_z_to_site[other_z_key] == site)
			derelict_z_visited[other_z_key] = TRUE
	addtimer(new Callback(GLOBAL_PROC, /proc/trigger_derelict_ghost_invasion, site), 5 SECONDS)


/proc/is_derelict_ghost_invasion_candidate(mob/living/M, list/allowed_types)
	if(!istype(M) || QDELETED(M))
		return FALSE
	if(M.stat == DEAD || M.key || M.client)
		return FALSE
	if(ismech(M))
		return FALSE
	if(length(allowed_types) && !(M.type in allowed_types))
		return FALSE
	return TRUE


/proc/trigger_derelict_ghost_invasion(datum/derelict_site/site)
	if(!istype(site))
		return

	var/list/mission_z_levels = list()
	for(var/z_key in derelict_z_to_site)
		if(derelict_z_to_site[z_key] == site)
			mission_z_levels += text2num(z_key)
	if(!length(mission_z_levels))
		return

	var/datum/ghosttrap/derelict_crew/trap = get_ghost_trap("derelict crew")
	if(!trap)
		return

	var/list/allowed_types = site.initial_mob_types
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
	var/max_count = site.ghost_mob_count || 0
	var/count = max_count > 0 ? min(max_count, length(eligible)) : length(eligible)

	for(var/i = 1 to count)
		var/mob/living/target = eligible[i]
		derelict_ghost_invasion_pool[target] = site.away_site_name
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
		if(istype(M))
			entries += M

	var/src_ref = "\ref[src]"
	var/trap_ref = "\ref[trap]"
	var/html = {"
		<style type="text/css">
			body { overflow: hidden !important; margin: 0; padding: 10px; box-sizing: border-box; color: #e0e0e0; background: #1a1a1a; }
			.action-link { display: inline-block; font-weight: bold; margin-right: 8px; color: #5dade2; text-decoration: none; }
			.action-link:hover { color: #85c1e9; }
			table { border-collapse: collapse; border-spacing: 0; width: 100%; margin: 0; }
			th { position: sticky; top: 0; background: #202020; z-index: 10; text-align: left; padding: 6px 8px; }
			td { padding: 6px 8px; border-top: 1px solid #333; vertical-align: middle; }
			.type-label { color: #f39c12; font-size: 11px; }
			.empty { color: #888; padding: 20px; text-align: center; }
			.btn { padding: 4px 12px; background: #3498db; color: #fff; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 13px; }
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
		html += {"<table class="data hover"><thead><tr><th style="width:40%;">Name</th><th style="width:30%;">Location</th><th style="width:30%;">Actions</th></tr></thead><tbody>"}
		for(var/mob/living/M in entries)
			var/site_name = derelict_ghost_invasion_pool[M]
			var/mob_ref = "\ref[M]"
			html += {"<tr><td><div>[html_encode(M.name)]</div><div class="type-label">[html_encode(get_derelict_invasion_type_label(M))]</div></td><td>[html_encode(site_name)]</td><td><a href='byond://?src=[trap_ref];candidate=[src_ref];target=[mob_ref]' class='action-link'>Occupy</a> <a href='byond://?src=[trap_ref];invasion_follow=[mob_ref]' class='action-link'>Follow</a></td></tr>"}
		html += {"</tbody></table>"}

	html += "</div>"
	var/datum/browser/popup = new(src, "ghost_invasion", "Ghost Invasion", 650, 500)
	popup.set_content(html)
	popup.open()


/proc/build_derelict_z_mapping()
	derelict_z_to_site.Cut()
	derelict_sites_list.Cut()
	for(var/site_id in loaded_away_site_ids)
		var/datum/map_template/ruin/away_site/matched
		for(var/tname in SSmapping.away_sites_templates)
			var/datum/map_template/ruin/away_site/T = SSmapping.away_sites_templates[tname]
			if(T.id == site_id)
				matched = T
				break
		if(!istype(matched) || matched.loaded_z <= 0)
			continue
		var/datum/derelict_site/site = new
		site.away_site_id = site_id
		site.away_site_name = matched.name || site_id
		site.away_z = matched.loaded_z
		var/z_count = max(length(matched.suffixes), matched.tallness, 1)
		var/list/z_levels = list()
		for(var/z_offset = 0 to z_count - 1)
			var/z = site.away_z + z_offset
			derelict_z_to_site["[z]"] = site
			z_levels += z
		site.initial_mob_types = list()
		for(var/mob/living/mob in GLOB.alive_mobs)
			if(!(mob.z in z_levels))
				continue
			if(ismech(mob))
				continue
			site.initial_mob_types[mob.type] = TRUE
		derelict_sites_list += site
	log_debug("Derelict Ghost Invasion: mapped [length(derelict_sites_list)] away sites.")


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
