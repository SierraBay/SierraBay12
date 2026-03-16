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
		var/name_style = ticked ? "color:[COLOR_CYBERUI_GREEN_SEL];font-weight:bold;" : "color:[COLOR_GRAY80];"
		var/cost_color = ticked ? COLOR_CYBERUI_GREEN_SEL : COLOR_CYBERUI_TEXT_MID

		. += "<div style=\"margin:1px 0 1px 4px;\">"
		. += {"<a href="?src=\ref[src];aug_toggle=\ref[G]" style="font-family:monospace;color:[btn_color];text-decoration:none;">[btn_label]</a> "}
		. += {"<span style="[name_style]">[G.display_name]</span> "}
		. += {"<span style="font-size:10px;color:[cost_color];">[G.cost] pt[G.cost != 1 ? "s" : ""]</span>"}
		if(G.description)
			. += {"<br><span style="font-size:10px;color:[COLOR_CYBERUI_TEXT_DIM];margin-left:20px;">[G.description]</span>"}
		. += "</div>"

	if(!found_any)
		. += "<div style=\"margin-left:4px;font-size:10px;color:[COLOR_CYBERUI_GRAY_DIM];\"><i>None available.</i></div>"

	. = jointext(., null)

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
