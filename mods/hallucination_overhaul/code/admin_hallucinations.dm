/datum/admins/proc/hallucination_panel(mob/living/carbon/M as null|mob in GLOB.player_list)
	set category = "Admin"
	set name = "Hallucination Panel"
	set desc = "Open an admin panel for forcing hallucinations on a target."

	if(!istype(src, /datum/admins))
		src = usr.client?.holder
	if(!istype(src, /datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!check_rights(R_ADMIN))
		return

	if(!M)
		var/list/carbon_targets = list()
		for(var/mob/living/carbon/C in GLOB.player_list)
			carbon_targets += C
		M = input("Select mob.", "Hallucination Panel") as null|anything in carbon_targets
	if(!istype(M))
		return

	show_hallucination_panel(M)

/datum/admins/proc/show_hallucination_panel(mob/living/carbon/M, dry_pick_type = null)
	if(!istype(src, /datum/admins))
		src = usr.client?.holder
	if(!istype(src, /datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!check_rights(R_ADMIN))
		return
	if(!istype(M))
		to_chat(usr, SPAN_WARNING("That mob is no longer a valid carbon target."))
		return

	var/datum/hallucination_context/context = M.build_hallucination_context()
	var/list/candidates = M.get_hallucination_candidates(TRUE, context)

	var/list/targets = list()
	for(var/mob/living/carbon/C in GLOB.player_list)
		targets["[C.real_name] ([C.ckey])"] = "\ref[C]"
	targets = sortList(targets)

	var/list/recent_history = list()
	for(var/type_path in M.hallucination_recent_types)
		recent_history += html_encode("[type_path]")

	var/list/category_cooldowns = list()
	for(var/category in M.hallucination_category_cooldowns)
		category_cooldowns += "[html_encode("[category]")]: [hallucination_seconds_left(M.hallucination_category_cooldowns[category])]s"
	category_cooldowns = sortList(category_cooldowns)

	var/list/candidate_lookup = list()
	for(var/datum/hallucination_candidate/candidate in candidates)
		candidate_lookup[candidate.type_name] = candidate
	var/list/sorted_type_names = list()
	for(var/type_name in candidate_lookup)
		sorted_type_names += type_name
	sorted_type_names = sortList(sorted_type_names)

	var/active_theme_text = "none"
	if(context.active_theme)
		active_theme_text = "[html_encode("[context.active_theme]")] ([hallucination_seconds_left(M.hallucination_theme_expires)]s, [M.hallucination_theme_hits]/3)"

	var/body = "<html><head><title>Hallucination Panel</title></head><body>"
	body += "<h2>Hallucination Panel</h2>"
	body += "<b>Target:</b> [M] ([M.type])<br>"
	body += "<b>Client:</b> [M.client ? M.client.ckey : "none"] | <b>Power:</b> [M.hallucination_power] | <b>Duration:</b> [M.hallucination_duration]<br>"
	body += "<b>Status:</b> [M.stat] | <b>Can hear:</b> [M.can_hear() ? "Yes" : "No"] | <b>Tier:</b> [context.tier]<br>"
	body += "<b>Darkness:</b> [round(context.darkness, 0.01)] (0=dark) | <b>Maintenance:</b> [context.is_maintenance ? "Yes" : "No"] | <b>Nearby living:</b> [context.nearby_living]<br>"
	body += "<b>Damage/ Shock:</b> brute [context.brute], fire [context.fire], oxy [context.oxy], tox [context.tox], hal [context.hal], total [context.total_damage], shock [context.shock]<br>"
	body += "<b>Active theme:</b> [active_theme_text]<br>"
	body += "<b>Recent history:</b> [length(recent_history) ? recent_history.Join(" -> ") : "none"]<br>"
	body += "<b>Category cooldowns:</b> [length(category_cooldowns) ? category_cooldowns.Join(", ") : "none"]<br>"
	if(dry_pick_type)
		body += "<b>Dry pick:</b> [html_encode("[dry_pick_type]")]<br>"
	body += "<br>"

	body += "<b>Change target:</b><br>"
	for(var/target_name in targets)
		body += "<a href='byond://?src=\ref[src];hallucination_panel=target;target=[targets[target_name]]'>[target_name]</a><br>"

	body += "<hr><b>Actions:</b> "
	body += "<a href='byond://?src=\ref[src];hallucination_panel=prime;target=\ref[M];power=80;duration=200'>Prime 80/200</a> | "
	body += "<a href='byond://?src=\ref[src];hallucination_panel=prime;target=\ref[M];power=100;duration=200'>Prime 100/200</a> | "
	body += "<a href='byond://?src=\ref[src];hallucination_panel=dry_pick;target=\ref[M]'>Dry Pick</a> | "
	body += "<a href='byond://?src=\ref[src];hallucination_panel=clear_runtime;target=\ref[M]'>Clear Runtime State</a> | "
	body += "<a href='byond://?src=\ref[src];hallucination_panel=clear;target=\ref[M]'>Clear</a><br><br>"

	body += "<table border='1' cellspacing='0' cellpadding='3'>"
	body += "<tr><th>Type</th><th>Eligible</th><th>Effective Weight</th><th>Category</th><th>Themes</th><th>Reason</th><th>Cast</th><th>Prime + Cast</th></tr>"

	for(var/type_name in sorted_type_names)
		var/datum/hallucination_candidate/candidate = candidate_lookup[type_name]
		if(!candidate)
			continue
		var/type_key = "[candidate.type_path]"
		var/highlight = candidate.type_path == dry_pick_type ? " style='background-color:#eef7ff;font-weight:bold;'" : ""
		body += "<tr[highlight]>"
		body += "<td>[html_encode(type_name)]</td>"
		body += "<td>[candidate.eligible ? "Yes" : "No"]</td>"
		body += "<td>[candidate.weight]</td>"
		body += "<td>[html_encode(candidate.category)]</td>"
		body += "<td>[html_encode(candidate.theme_text)]</td>"
		body += "<td>[html_encode(candidate.reason)]</td>"
		body += "<td><a href='byond://?src=\ref[src];hallucination_panel=cast;target=\ref[M];hall_type=[type_key]'>Cast</a></td>"
		body += "<td><a href='byond://?src=\ref[src];hallucination_panel=cast_prime;target=\ref[M];hall_type=[type_key];power=80;duration=200'>Prime + Cast</a></td>"
		body += "</tr>"

	body += "</table></body></html>"
	show_browser(usr, body, "window=hallucinationpanel;size=1250x780")
