/datum/category_item/player_setup_item/cyberware/gear_augments
	name = "Augments"
	sort_order = 2
	var/selected_region = null  // "HEAD"|"TORSO"|"ARM"|"HAND"|"GROIN"|"LEG"|"FOOT"|null

// ---------------------------------------------------------------------------
// Maps region key → AUGMENT_* flags.
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/gear_augments/proc/region_to_flags(region_key)
	switch(region_key)
		if("HEAD")  return AUGMENT_HEAD|AUGMENT_EYES|AUGMENT_FLUFF
		if("TORSO") return AUGMENT_CHEST|AUGMENT_ARMOR
		if("ARM")   return AUGMENT_ARM
		if("HAND")  return AUGMENT_HAND
		if("GROIN") return AUGMENT_GROIN
		if("LEG")   return AUGMENT_LEG
		if("FOOT")  return AUGMENT_FOOT
	return FLAGS_OFF

// Maps region key → display label.
/datum/category_item/player_setup_item/cyberware/gear_augments/proc/region_to_label(region_key)
	switch(region_key)
		if("HEAD")  return "Head"
		if("TORSO") return "Torso"
		if("ARM")   return "Arms"
		if("HAND")  return "Hands"
		if("GROIN") return "Groin"
		if("LEG")   return "Legs"
		if("FOOT")  return "Feet"
	return region_key

// ---------------------------------------------------------------------------
// Helper: determine which AUGMENT_* slot flags a gear item targets.
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/gear_augments/proc/get_gear_aug_slots(datum/gear/G)
	var/obj/item/organ/internal/augment/aug = G.path
	var/slots = initial(aug.augment_slots)
	if(slots)
		return slots

	for(var/datum/gear_tweak/path/pt in G.gear_tweaks)
		for(var/opt_name in pt.valid_paths)
			var/obj/item/organ/internal/augment/opt_aug = pt.valid_paths[opt_name]
			slots = initial(opt_aug.augment_slots)
			if(slots)
				return slots
		break

	var/parent = initial(aug.parent_organ)
	switch(parent)
		if(BP_HEAD)              return AUGMENT_HEAD
		if(BP_CHEST)             return AUGMENT_CHEST
		if(BP_GROIN)             return AUGMENT_GROIN
		if(BP_L_ARM, BP_R_ARM)   return AUGMENT_ARM
		if(BP_L_HAND, BP_R_HAND) return AUGMENT_HAND
		if(BP_L_LEG, BP_R_LEG)   return AUGMENT_LEG
		if(BP_L_FOOT, BP_R_FOOT) return AUGMENT_FOOT

	return FLAGS_OFF

// ---------------------------------------------------------------------------
// Helper: TRUE if any selected gear in current slot targets these region flags.
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/gear_augments/proc/region_has_selection(region_flags)
	if(!pref.gear_list || !pref.gear_list[pref.gear_slot])
		return FALSE
	var/list/slot_gear = pref.gear_list[pref.gear_slot]
	for(var/gear_name in slot_gear)
		var/datum/gear/augment/G = gear_datums[gear_name]
		if(!istype(G))
			continue
		if(get_gear_aug_slots(G) & region_flags)
			return TRUE
	return FALSE

// ---------------------------------------------------------------------------
// Body diagram cell — clickable, highlights when this region is selected.
// Clicking the already-selected region deselects (shows all).
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/gear_augments/proc/diag_cell(label, region_key)
	var/flags    = region_to_flags(region_key)
	var/has_aug  = region_has_selection(flags)
	var/is_sel   = (selected_region == region_key)
	var/bg       = is_sel ? COLOR_CYBERUI_BG_SEL  : (has_aug ? COLOR_CYBERUI_BG_AUG  : COLOR_CYBERUI_BORDER)
	var/brd_col  = is_sel ? COLOR_CYBERUI_GREEN_BRIGHT : (has_aug ? COLOR_CYBERUI_GREEN : COLOR_CYBERUI_GRAY_DARK)
	var/brd_w    = is_sel ? "2px" : "1px"
	var/txt_col  = is_sel ? COLOR_CYBERUI_GREEN_BRIGHT : COLOR_CYBERUI_TEXT_LIGHT
	return {"<td style="padding:2px;"><a href="?src=\ref[src];aug_region=[region_key]" style="text-decoration:none;display:block;background:[bg];border:[brd_w] solid [brd_col];color:[txt_col];padding:3px 4px;text-align:center;min-width:60px;font-size:11px;white-space:nowrap;">[label]</a></td>"}

/datum/category_item/player_setup_item/cyberware/gear_augments/proc/empty_cell()
	return "<td style=\"min-width:60px;\"></td>"

// ---------------------------------------------------------------------------
// Renders augment entries for a region.
// When focused = TRUE the header is more prominent and shows a back link.
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/gear_augments/proc/aug_section(region_key, focused)
	. = list()
	var/region_flags = region_to_flags(region_key)
	var/label        = region_to_label(region_key)

	// Section header — click label to deselect region
	. += {"<div style="background:[COLOR_CYBERUI_BG_GREEN];border-left:3px solid [COLOR_CYBERUI_GREEN];padding:4px 8px;margin-bottom:5px;font-size:11px;font-weight:bold;color:[COLOR_CYBERUI_GREEN_BRIGHT];letter-spacing:1px;">[label] <span style="font-size:9px;color:[COLOR_CYBERUI_TEXT_HINT];font-weight:normal;">(click region again to close)</span></div>"}

	var/list/slot_gear = (pref.gear_list && pref.gear_list[pref.gear_slot]) ? pref.gear_list[pref.gear_slot] : list()
	var/found_any = FALSE
//[SIERRA-ADD] HEIGHT
 	// Build job list from pref (same logic as loadout tab)
	var/list/jobs = list()
	for(var/job_title in (pref.job_medium | pref.job_low | pref.job_high))
		var/datum/job/J = SSjobs.get_by_title(job_title)
		if(J)
			jobs += J
//[/SIERRA-ADD] HEIGHT
	for(var/gear_name in gear_datums)
		var/datum/gear/augment/G = gear_datums[gear_name]
		if(!istype(G))
			continue
		if(!(get_gear_aug_slots(G) & region_flags))
			continue

		found_any = TRUE
		var/ticked     = (G.display_name in slot_gear)
		var/btn_label  = ticked ? "&#91;&#215;&#93;" : "&#91;+&#93;"
		var/btn_color  = ticked ? COLOR_CYBERUI_RED       : COLOR_CYBERUI_BTN_GREEN
//[SIERRA-ADD] HEIGHT
		// Determine name colour + job restriction label
		var/name_color = COLOR_GRAY80
		var/list/jobchecks = list()
		if(ticked)
			name_color = COLOR_CYBERUI_GREEN_SEL
		if(G.allowed_roles)
			if(length(jobs))
				// Player has jobs selected — show each with green/red
				var/any_good = FALSE
				for(var/datum/job/J in jobs)
					if(J.type in G.allowed_roles)
						jobchecks += SPAN_COLOR("#55cc55", J.title)
						any_good = TRUE
					else
						jobchecks += SPAN_COLOR("#cc5555", J.title)
				// Only colour name red when no job has access
				if(!ticked && !any_good)
					name_color = "#cc5555"
			else
				// No jobs selected — list allowed roles in neutral colour
				for(var/job_type in G.allowed_roles)
					var/datum/job/J = SSjobs.get_by_path(job_type)
					if(J)
						jobchecks += SPAN_COLOR(COLOR_CYBERUI_TEXT_MID, J.title)

		var/name_style = ticked ? "color:[name_color];font-weight:bold;" : "color:[name_color];"
//[/SIERRA-ADD] HEIGHT
		var/cost_color = ticked ? COLOR_CYBERUI_GREEN_SEL : COLOR_CYBERUI_TEXT_MID

		. += "<div style=\"margin:1px 0 1px 4px;\">"
		. += {"<a href="?src=\ref[src];aug_toggle=\ref[G]" style="font-family:monospace;color:[btn_color];text-decoration:none;">[btn_label]</a> "}
		. += {"<span style="[name_style]">[G.display_name]</span> "}
		. += {"<span style="font-size:10px;color:[cost_color];">[G.cost] pt[G.cost != 1 ? "s" : ""]</span>"}
//[SIERRA-ADD] HEIGHT
		if(length(jobchecks))
			. += {"<br><span style="font-size:10px;color:[COLOR_CYBERUI_TEXT_DIM];margin-left:20px;">[english_list(jobchecks)]</span>"}
//[/SIERRA-ADD] HEIGHT
		if(G.description)
			. += {"<br><span style="font-size:10px;color:[COLOR_CYBERUI_TEXT_DIM];margin-left:20px;">[G.description]</span>"}
//[SIERRA-ADD] HEIGHT
		if(ticked && length(G.gear_tweaks))
			for(var/datum/gear_tweak/tweak in G.gear_tweaks)
				var/tweak_meta = get_aug_tweak_metadata(G, tweak)
				var/contents = tweak.get_contents(tweak_meta)
				if(contents)
					. += {"<br><a href="?src=\ref[src];aug_gear=\ref[G];aug_tweak=\ref[tweak]" style="display:inline-block;margin:2px 0 0 20px;padding:1px 5px;background:#0e1e2c;border:1px solid [COLOR_CYBERUI_BLUE];border-radius:2px;color:[COLOR_CYBERUI_TEXT_SOFT];font-size:9px;text-decoration:none;">[contents]</a>"}
		. += "</div>"
//[/SIERRA-ADD] HEIGHT

	if(!found_any)
		. += "<div style=\"margin-left:4px;font-size:10px;color:[COLOR_CYBERUI_GRAY_DIM];\"><i>None available.</i></div>"

	. = jointext(., null)

// ---------------------------------------------------------------------------
// Tweak metadata helpers (mirrors loadout.dm get/set_tweak_metadata).
// pref.gear_list[slot] is a flat list of gear names; tweak metadata is stored
// as an associative value on the same list entry: slot_gear[G.display_name].
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/gear_augments/proc/get_aug_gear_metadata(datum/gear/G, readonly = FALSE)
	if(!pref.gear_list || !pref.gear_list[pref.gear_slot])
		return list()
	var/list/slot_gear = pref.gear_list[pref.gear_slot]
	. = slot_gear[G.display_name]
	if(!.)
		. = list()
		if(!readonly)
			slot_gear[G.display_name] = .

/datum/category_item/player_setup_item/cyberware/gear_augments/proc/get_aug_tweak_metadata(datum/gear/G, datum/gear_tweak/tweak)
	var/list/metadata = get_aug_gear_metadata(G)
	. = metadata["[tweak]"]
	if(isnull(.))
		. = tweak.get_default()
		metadata["[tweak]"] = .

/datum/category_item/player_setup_item/cyberware/gear_augments/proc/set_aug_tweak_metadata(datum/gear/G, datum/gear_tweak/tweak, new_metadata)
	var/list/metadata = get_aug_gear_metadata(G)
	metadata["[tweak]"] = new_metadata

// ---------------------------------------------------------------------------
// content()
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/gear_augments/content(mob/user)
	. = list()

	// Point budget header
	var/total_cost = 0
	if(pref.gear_list && pref.gear_list[pref.gear_slot])
		for(var/gear_name in pref.gear_list[pref.gear_slot])
			var/datum/gear/G = gear_datums[gear_name]
			if(G)
				total_cost += G.cost

	var/cost_color = (total_cost >= config.max_gear_cost) ? COLOR_CYBERUI_RED : COLOR_CYBERUI_ORANGE_COST
	. += "<div style=\"margin-bottom:6px;\">"
	. += "<b>Loadout slot:</b> "
	. += "<a href=\"?src=\ref[src];aug_slot_prev=1\">&#60;</a> "
	. += "<span style=\"font-weight:bold;color:[COLOR_GRAY80];\">[pref.gear_slot]</span> "
	. += "<a href=\"?src=\ref[src];aug_slot_next=1\">&#62;</a>"
	if(config.max_gear_cost < INFINITY)
		. += "&nbsp;&nbsp;<span style=\"color:[cost_color];font-size:11px;\">[total_cost] / [config.max_gear_cost] pts</span>"
	. += "</div>"

	// ── Body diagram (full width, clickable) ─────────────────────────────
	if(!selected_region)
		. += "<div style=\"font-size:10px;color:[COLOR_CYBERUI_TEXT_MUTED];margin-bottom:4px;\">&#9664; Click a body region to view available augments.</div>"

	. += "<table style=\"border-collapse:collapse;margin-bottom:6px;\">"
	. += "<tr>[empty_cell()][diag_cell("Head",   "HEAD") ][empty_cell()]</tr>"
	. += "<tr>[diag_cell("L Arm",  "ARM") ][diag_cell("Torso", "TORSO")][diag_cell("R Arm",  "ARM") ]</tr>"
	. += "<tr>[diag_cell("L Hand", "HAND")][empty_cell()                ][diag_cell("R Hand", "HAND")]</tr>"
	. += "<tr>[empty_cell()][diag_cell("Groin", "GROIN")][empty_cell()]</tr>"
	. += "<tr>[diag_cell("L Leg",  "LEG") ][empty_cell()][diag_cell("R Leg",  "LEG") ]</tr>"
	. += "<tr>[diag_cell("L Foot", "FOOT")][empty_cell()][diag_cell("R Foot", "FOOT")]</tr>"
	. += "</table>"

	// ── Augment list (below diagram, only when region selected) ───────────
	if(selected_region)
		. += aug_section(selected_region, TRUE)
	else
		. += {"<div style="color:[COLOR_GRAY20];font-size:11px;font-style:italic;"></div>"}

	. = jointext(., null)

// ---------------------------------------------------------------------------
// OnTopic
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/gear_augments/OnTopic(href, list/href_list, mob/user)

	if(href_list["aug_slot_prev"])
		pref.gear_slot = (pref.gear_slot > 1) ? pref.gear_slot - 1 : config.loadout_slots
		return TOPIC_REFRESH

	else if(href_list["aug_slot_next"])
		pref.gear_slot = (pref.gear_slot < config.loadout_slots) ? pref.gear_slot + 1 : 1
		return TOPIC_REFRESH

	else if(href_list["aug_region"])
		var/region = href_list["aug_region"]
		// Toggle: click the active region again to go back to all-regions view
		selected_region = (selected_region == region) ? null : region
		return TOPIC_REFRESH

	else if(href_list["aug_all"])
		selected_region = null
		return TOPIC_REFRESH

	else if(href_list["aug_gear"] && href_list["aug_tweak"])
		var/datum/gear/augment/G = locate(href_list["aug_gear"])
		var/datum/gear_tweak/tweak = locate(href_list["aug_tweak"])
		if(!istype(G) || !tweak || !(tweak in G.gear_tweaks))
			return TOPIC_NOACTION
		if(!pref.gear_list || !pref.gear_list[pref.gear_slot] || !(G.display_name in pref.gear_list[pref.gear_slot]))
			return TOPIC_NOACTION
		if(!CanUseTopic(user))
			return TOPIC_NOACTION
		var/metadata = tweak.get_metadata(user, get_aug_tweak_metadata(G, tweak))
		if(!metadata || !CanUseTopic(user))
			return TOPIC_NOACTION
		set_aug_tweak_metadata(G, tweak, metadata)
		return TOPIC_REFRESH

	else if(href_list["aug_toggle"])
		var/datum/gear/augment/G = locate(href_list["aug_toggle"])
		if(!istype(G))
			return TOPIC_NOACTION
		if(!CanUseTopic(user))
			return TOPIC_NOACTION

		if(!pref.gear_list)
			pref.gear_list = list()
		if(length(pref.gear_list) < pref.gear_slot)
			LIST_RESIZE(pref.gear_list, pref.gear_slot)
		if(!islist(pref.gear_list[pref.gear_slot]))
			pref.gear_list[pref.gear_slot] = list()

		var/list/slot_gear = pref.gear_list[pref.gear_slot]

		if(G.display_name in slot_gear)
			slot_gear -= G.display_name
		else
			var/total_cost = 0
			for(var/gear_name in slot_gear)
				var/datum/gear/existing = gear_datums[gear_name]
				if(existing)
					total_cost += existing.cost
			if(config.max_gear_cost < INFINITY && total_cost + G.cost > config.max_gear_cost)
				to_chat(user, "<span class='warning'>Not enough loadout points. ([total_cost + G.cost]/[config.max_gear_cost])</span>")
				return TOPIC_NOACTION
			slot_gear += G.display_name

		return TOPIC_REFRESH
