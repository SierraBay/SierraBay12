/datum/category_item/player_setup_item/cyberware/prosthetics
	name = "Prosthetics"
	sort_order = 1

// Returns a human-readable name for a given BP_* tag.
/datum/category_item/player_setup_item/cyberware/prosthetics/proc/aug_part_name(part_tag)
	switch(part_tag)
		if(BP_L_ARM)     return "left arm"
		if(BP_R_ARM)     return "right arm"
		if(BP_L_LEG)     return "left leg"
		if(BP_R_LEG)     return "right leg"
		if(BP_L_FOOT)    return "left foot"
		if(BP_R_FOOT)    return "right foot"
		if(BP_L_HAND)    return "left hand"
		if(BP_R_HAND)    return "right hand"
		if(BP_HEART)     return "heart"
		if(BP_EYES)      return "eyes"
		if(BP_BRAIN)     return "brain"
		if(BP_LUNGS)     return "lungs"
		if(BP_LIVER)     return "liver"
		if(BP_KIDNEYS)   return "kidneys"
		if(BP_STOMACH)   return "stomach"
		if(BP_CHEST)     return "upper body"
		if(BP_GROIN)     return "lower body"
		if(BP_HEAD)      return "head"
	return part_tag

// Returns a background color hex string for the given organ state.
/datum/category_item/player_setup_item/cyberware/prosthetics/proc/state_color(state)
	switch(state)
		if("amputated")  return COLOR_CYBERUI_RED
		if("cyborg")     return COLOR_CYBERUI_BLUE
		if("assisted")   return COLOR_CYBERUI_YELLOW
		if("mechanical") return COLOR_CYBERUI_GREEN
	return COLOR_CYBERUI_TEXT_MID

// Returns an HTML <td> cell containing a styled clickable button for a body part.
/datum/category_item/player_setup_item/cyberware/prosthetics/proc/part_cell(part_tag, display_label)
	var/state   = pref.organ_data[part_tag]
	var/bg      = state_color(state)
	var/label   = display_label
	if(state == "cyborg" && pref.rlimb_data[part_tag])
		label = "[display_label]<br /><small>[pref.rlimb_data[part_tag]]</small>"
	var/style = "background:[bg];color:[COLOR_WHITE];padding:4px 6px;display:block;text-align:center;text-decoration:none;min-width:72px;font-size:12px;"
	return "<td style=\"padding:2px;\">[VSBTN("aug_part", part_tag, label, style)]</td>"

// Returns an empty spacer <td> to preserve table grid alignment.
/datum/category_item/player_setup_item/cyberware/prosthetics/proc/empty_cell()
	return "<td style=\"min-width:72px;\"></td>"

// ---------------------------------------------------------------------------
// Returns a color for an armor value (0-100+).
/datum/category_item/player_setup_item/cyberware/prosthetics/proc/armor_color(val)
	if(!val || val <= 0) return COLOR_CYBERUI_GRAY_DARK
	if(val <= 10)        return COLOR_CYBERUI_TEXT_DIM
	if(val <= 25)        return COLOR_CYBERUI_YELLOW
	if(val <= 50)        return COLOR_CYBERUI_GREEN
	if(val <= 75)        return COLOR_CYBERUI_BLUE
	return COLOR_CYBERUI_GREEN_BRIGHT

// Returns a display string for an armor value.
/datum/category_item/player_setup_item/cyberware/prosthetics/proc/armor_text(val)
	if(!val || val <= 0) return "&#8212;"
	return "[val]"

// ---------------------------------------------------------------------------
// Renders a traits card for a single robolimb manufacturer.
// R              — the robolimb datum
// equipped_parts — list of BP_* tags that use this manufacturer
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/prosthetics/proc/robolimb_traits_card(datum/robolimb/R, list/equipped_parts)
	. = list()

	. += {"<div style="background:[COLOR_CYBERUI_BG_CARD];border:1px solid [COLOR_CYBERUI_BORDER];border-left:3px solid [COLOR_CYBERUI_BLUE];margin-bottom:8px;padding:6px 8px;">"}

	// Manufacturer name
	. += {"<div style="font-weight:bold;color:[COLOR_CYBERUI_TEXT_SOFT];font-size:12px;margin-bottom:2px;">[R.company]</div>"}

	// Equipped parts
	if(length(equipped_parts))
		var/parts_list = list()
		for(var/bp in equipped_parts)
			parts_list += aug_part_name(bp)
		. += {"<div style="font-size:10px;color:[COLOR_CYBERUI_TEXT_MUTED];margin-bottom:3px;">[jointext(parts_list, ", ")]</div>"}

	// Description
	if(R.desc)
		. += {"<div style="font-size:10px;color:[COLOR_CYBERUI_TEXT_MID];font-style:italic;margin-bottom:5px;">[R.desc]</div>"}

	. += {"<table style="font-size:10px;border-collapse:collapse;line-height:1.65;">"}

	// ── ARMOR ────────────────────────────────────────────────────────────
	. += {"<tr><td colspan="2" style="font-size:9px;color:[COLOR_CYBERUI_GRAY_DIM];letter-spacing:1px;padding:2px 0 1px 0;border-bottom:1px solid [COLOR_CYBERUI_SEPARATOR];">ARMOR</td></tr>"}

	if(R.armor)
		var/list/armor_types = list(
			"melee"  = "Melee",
			"bullet" = "Bullet",
			"laser"  = "Laser",
			"energy" = "Energy",
			"bomb"   = "Explosive",
			"bio"    = "Bio",
			"rad"    = "Radiation"
		)
		for(var/key in armor_types)
			var/val = R.armor[key]
			. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">[armor_types[key]]:</td><td style="color:[armor_color(val)];">[armor_text(val)]</td></tr>"}
	else
		. += {"<tr><td colspan="2" style="color:[COLOR_CYBERUI_GRAY_DARK];font-style:italic;">Standard</td></tr>"}

	// ── PROPERTIES ───────────────────────────────────────────────────────
	. += {"<tr><td colspan="2" style="font-size:9px;color:[COLOR_CYBERUI_GRAY_DIM];letter-spacing:1px;padding:4px 0 1px 0;border-bottom:1px solid [COLOR_CYBERUI_SEPARATOR];">PROPERTIES</td></tr>"}

	// Speed
	if(R.speed_modifier && R.speed_modifier != 0)
		var/spd_col  = R.speed_modifier > 0 ? COLOR_CYBERUI_RED : COLOR_CYBERUI_GREEN
		var/spd_sign = R.speed_modifier > 0 ? "+" : ""
		var/spd_note = R.speed_modifier > 0 ? " (slower)" : " (faster)"
		. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Speed:</td><td style="color:[spd_col];">[spd_sign][R.speed_modifier][spd_note]</td></tr>"}
	else
		. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Speed:</td><td style="color:[COLOR_CYBERUI_GRAY_DARK];">Standard</td></tr>"}

	// Cooling efficiency (lower = better)
	var/cool_val = R.coolingefficiency ? R.coolingefficiency : 0.5
	var/cool_text
	var/cool_col
	if(cool_val <= 0.35)      { cool_text = "Excellent"; cool_col = COLOR_CYBERUI_GREEN     }
	else if(cool_val <= 0.55) { cool_text = "Good";      cool_col = COLOR_CYBERUI_GREEN_MED }
	else if(cool_val <= 0.75) { cool_text = "Moderate";  cool_col = COLOR_CYBERUI_YELLOW    }
	else if(cool_val <= 1.0)  { cool_text = "Poor";      cool_col = COLOR_CYBERUI_ORANGE    }
	else                      { cool_text = "Very Poor";  cool_col = COLOR_CYBERUI_RED       }
	. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Cooling:</td><td style="color:[cool_col];">[cool_text]</td></tr>"}

	// Electricity (siemens_coefficient: lower = more resistant)
	if(R.siemens_coefficient)
		var/siem_col  = R.siemens_coefficient < 1 ? COLOR_CYBERUI_GREEN : COLOR_CYBERUI_RED
		var/siem_text = R.siemens_coefficient < 1 ? "Resistant" : "Vulnerable"
		. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Electricity:</td><td style="color:[siem_col];">[siem_text] ([R.siemens_coefficient]x)</td></tr>"}
	else
		. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Electricity:</td><td style="color:[COLOR_CYBERUI_GRAY_DARK];">Standard</td></tr>"}

	// Durability bonus
	if(R.addmax_damage)
		var/dur_col  = R.addmax_damage > 0 ? COLOR_CYBERUI_GREEN : COLOR_CYBERUI_RED
		var/dur_sign = R.addmax_damage > 0 ? "+" : ""
		. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Durability:</td><td style="color:[dur_col];">[dur_sign][R.addmax_damage] HP</td></tr>"}

	// ── FEATURES ─────────────────────────────────────────────────────────
	. += {"<tr><td colspan="2" style="font-size:9px;color:[COLOR_CYBERUI_GRAY_DIM];letter-spacing:1px;padding:4px 0 1px 0;border-bottom:1px solid [COLOR_CYBERUI_SEPARATOR];">FEATURES</td></tr>"}

	if(!R.has_eyes)
		. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Eye sockets:</td><td style="color:[COLOR_CYBERUI_RED];">No</td></tr>"}
	if(R.can_eat)
		. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Can eat:</td><td style="color:[COLOR_CYBERUI_GREEN];">Yes</td></tr>"}
	if(R.skintone || R.have_synth_skin)
		. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Skin tone:</td><td style="color:[COLOR_CYBERUI_GREEN];">Matches</td></tr>"}
	if(R.has_screen)
		. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Display:</td><td style="color:[COLOR_CYBERUI_BLUE];">Screen</td></tr>"}
	if(R.can_feel_pain)
		. += {"<tr><td style="color:[COLOR_CYBERUI_GRAY_DIM];padding:0 8px 0 0;">Feels pain:</td><td style="color:[COLOR_CYBERUI_YELLOW];">Yes</td></tr>"}

	. += "</table></div>"
	. = jointext(., null)

// ---------------------------------------------------------------------------
// content()
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/prosthetics/content(mob/user)
	. = list()

	// Outer two-column layout: traits on the left, body diagram on the right
	. += "<table style=\"border-collapse:collapse;\"><tr>"

	// ── Left column: equipped prosthetics traits ──────────────────────────
	. += "<td valign=\"top\" style=\"min-width:200px;padding-right:16px;padding-top:2px;\">"

	// Build map: manufacturer → list of body parts using it
	var/list/mfr_to_parts = list()
	for(var/bp in pref.rlimb_data)
		var/mfr = pref.rlimb_data[bp]
		if(!mfr)
			continue
		if(!(mfr in mfr_to_parts))
			mfr_to_parts[mfr] = list()
		mfr_to_parts[mfr] += bp

	if(!length(mfr_to_parts))
		. += {"<div style="font-size:11px;color:[COLOR_CYBERUI_GRAY_DIM];font-style:italic;margin-top:10px;">No prosthetics selected.</div>"}
		. += {"<div style="font-size:10px;color:[COLOR_CYBERUI_GRAY_DARK];margin-top:4px;">Click a body part to configure it.</div>"}
	else
		. += {"<div style="font-size:10px;color:[COLOR_GRAY40];letter-spacing:1px;margin-bottom:6px;">EQUIPPED PROSTHETICS</div>"}
		for(var/mfr in mfr_to_parts)
			var/datum/robolimb/R = all_robolimbs[mfr]
			if(!R)
				continue
			. += robolimb_traits_card(R, mfr_to_parts[mfr])

	. += "</td>"

	// ── Right column: body diagram ────────────────────────────────────────
	. += "<td valign=\"top\">"

	. += "<b>Body Parts</b> [TBTN("aug_reset", "Reset", "Body Parts")]"
	. += "<br />"

	// Limb diagram
	. += "<table style=\"border-collapse:collapse;margin:4px 0;\">"
	. += "<tr>[empty_cell()][part_cell(BP_HEAD, "Head")][empty_cell()]</tr>"
	. += "<tr>[part_cell(BP_L_ARM, "L Arm")][part_cell(BP_CHEST, "Torso")][part_cell(BP_R_ARM, "R Arm")]</tr>"
	. += "<tr>[part_cell(BP_L_HAND, "L Hand")][empty_cell()][part_cell(BP_R_HAND, "R Hand")]</tr>"
	. += "<tr>[empty_cell()][part_cell(BP_GROIN, "Groin")][empty_cell()]</tr>"
	. += "<tr>[part_cell(BP_L_LEG, "L Leg")][empty_cell()][part_cell(BP_R_LEG, "R Leg")]</tr>"
	. += "<tr>[part_cell(BP_L_FOOT, "L Foot")][empty_cell()][part_cell(BP_R_FOOT, "R Foot")]</tr>"
	. += "</table>"

	// Internal organs (2 rows of 3)
	. += "<br /><b>Internal Organs</b>"
	. += "<br /><table style=\"border-collapse:collapse;margin:4px 0;\">"
	. += "<tr>[part_cell(BP_HEART, "Heart")][part_cell(BP_EYES,    "Eyes")][part_cell(BP_LUNGS, "Lungs")]</tr>"
	. += "<tr>[part_cell(BP_LIVER, "Liver")][part_cell(BP_KIDNEYS, "Kidneys")][part_cell(BP_STOMACH, "Stomach")]</tr>"
	. += "</table>"

	// Color legend
	. += "<br /><small>"
	. += "<span style=\"color:[COLOR_CYBERUI_TEXT_MID]\">&#9632;</span> Normal &nbsp;"
	. += "<span style=\"color:[COLOR_CYBERUI_RED]\">&#9632;</span> Amputated &nbsp;"
	. += "<span style=\"color:[COLOR_CYBERUI_BLUE]\">&#9632;</span> Prosthesis &nbsp;"
	. += "<span style=\"color:[COLOR_CYBERUI_YELLOW]\">&#9632;</span> Assisted &nbsp;"
	. += "<span style=\"color:[COLOR_CYBERUI_GREEN]\">&#9632;</span> Synthetic"
	. += "</small>"

	. += "</td>"
	. += "</tr></table>"

	. = jointext(., null)

// ---------------------------------------------------------------------------
// OnTopic
// ---------------------------------------------------------------------------
/datum/category_item/player_setup_item/cyberware/prosthetics/OnTopic(href, list/href_list, mob/user)
	var/singleton/species/mob_species = GLOB.species_by_name[pref.species]
	if(pref.character_persist_is_locked())
		to_chat(user, SPAN_WARNING("Кибернетика заблокирована: у персонажа есть сохранённое состояние с прошлой смены. Отключите персистентность, чтобы сбросить его."))
		return TOPIC_NOACTION

	if(href_list["aug_reset"])
		pref.organ_data.Cut()
		pref.rlimb_data.Cut()
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["aug_part"])
		var/part = href_list["aug_part"]

		// Groin state is controlled by the Torso (Full Body Prosthetic) selection.
		if(part == BP_GROIN)
			to_chat(user, "<span class='notice'>Groin state is linked to the Torso. Click the Torso cell to configure full body prosthetics.</span>")
			return TOPIC_NOACTION

		// Head prosthetics are only available once a full body prosthetic is selected.
		if(part == BP_HEAD && pref.organ_data[BP_CHEST] != "cyborg")
			to_chat(user, "<span class='notice'>Head prosthetics are only available with a full body prosthesis. Select the Torso cell first.</span>")
			return TOPIC_NOACTION

		// --- Internal organs ---
		if(part in list(BP_HEART, BP_EYES, BP_LUNGS, BP_LIVER, BP_KIDNEYS, BP_STOMACH))
			var/list/organ_choices = list("Normal", "Assisted", "Synthetic")
			if(mob_species && (mob_species.spawn_flags & SPECIES_NO_ROBOTIC_INTERNAL_ORGANS))
				organ_choices -= "Assisted"
				organ_choices -= "Synthetic"
			if(pref.organ_data[BP_CHEST] == "cyborg")
				organ_choices = list("Synthetic")
			if(!length(organ_choices))
				return TOPIC_NOACTION
			var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in organ_choices
			if(!new_state || !CanUseTopic(user))
				return TOPIC_NOACTION
			switch(new_state)
				if("Normal")    pref.organ_data[part] = null
				if("Assisted")  pref.organ_data[part] = "assisted"
				if("Synthetic") pref.organ_data[part] = "mechanical"
			aug_sanitize_organs()
			return TOPIC_REFRESH

		// --- Limbs ---
		var/limb        = part
		var/second_limb = null
		var/third_limb  = null

		var/list/choice_options = list("Normal", "Amputated", "Prosthesis")
		if(pref.organ_data[BP_CHEST] == "cyborg")
			choice_options = list("Amputated", "Prosthesis")

		switch(part)
			if(BP_L_LEG)   second_limb = BP_L_FOOT
			if(BP_R_LEG)   second_limb = BP_R_FOOT
			if(BP_L_ARM)   second_limb = BP_L_HAND
			if(BP_R_ARM)   second_limb = BP_R_HAND
			if(BP_L_FOOT)  third_limb  = BP_L_LEG
			if(BP_R_FOOT)  third_limb  = BP_R_LEG
			if(BP_L_HAND)  third_limb  = BP_L_ARM
			if(BP_R_HAND)  third_limb  = BP_R_ARM
			if(BP_HEAD)
				choice_options = list("Prosthesis")
			if(BP_CHEST)
				third_limb     = BP_GROIN
				choice_options = list("Normal", "Prosthesis")
				// [SIERRA-ADD] — FBP whitelist check
				if((!whitelist_lookup(SPECIES_FBP, user.ckey) && mob_species?.name != SPECIES_IPC) && !user.client?.holder)
					choice_options -= "Prosthesis"
				// [/SIERRA-ADD]

		if(!length(choice_options))
			return TOPIC_NOACTION

		var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in choice_options
		if(!new_state || !CanUseTopic(user))
			return TOPIC_NOACTION

		switch(new_state)
			if("Normal")
				if(limb == BP_CHEST)
					for(var/other_limb in (BP_ALL_LIMBS - BP_CHEST))
						pref.organ_data[other_limb] = null
						pref.rlimb_data[other_limb] = null
					for(var/internal_organ in list(BP_HEART, BP_EYES, BP_LUNGS, BP_LIVER, BP_KIDNEYS, BP_STOMACH, BP_BRAIN))
						pref.organ_data[internal_organ] = null
				pref.organ_data[limb] = null
				pref.rlimb_data[limb] = null
				if(third_limb)
					pref.organ_data[third_limb] = null
					pref.rlimb_data[third_limb] = null

			if("Amputated")
				if(limb == BP_CHEST)
					return TOPIC_NOACTION
				pref.organ_data[limb] = "amputated"
				pref.rlimb_data[limb] = null
				if(second_limb)
					pref.organ_data[second_limb] = "amputated"
					pref.rlimb_data[second_limb] = null

			if("Prosthesis")
				var/singleton/species/temp_species = pref.species ? GLOB.species_by_name[pref.species] : GLOB.species_by_name[SPECIES_HUMAN]
				var/tmp_species = temp_species.get_bodytype(user)
				var/list/usable_manufacturers = list()
				for(var/company in chargen_robolimbs)
					var/datum/robolimb/M = chargen_robolimbs[company]
					if(tmp_species in M.species_cannot_use) continue
					if(length(M.restricted_to) && !(tmp_species in M.restricted_to)) continue
					if(length(M.applies_to_part) && !(limb in M.applies_to_part)) continue
					if(M.allowed_bodytypes && !(tmp_species in M.allowed_bodytypes)) continue
					usable_manufacturers[company] = M
				if(!length(usable_manufacturers))
					return TOPIC_NOACTION
				var/choice = input(user, "Which manufacturer do you wish to use for this limb?") as null|anything in usable_manufacturers
				if(!choice || !CanUseTopic(user))
					return TOPIC_NOACTION
				pref.rlimb_data[limb] = choice
				pref.organ_data[limb] = "cyborg"
				if(second_limb)
					pref.rlimb_data[second_limb] = choice
					pref.organ_data[second_limb] = "cyborg"
				if(third_limb && pref.organ_data[third_limb] == "amputated")
					pref.organ_data[third_limb] = null
				if(limb == BP_CHEST)
					for(var/other_limb in BP_ALL_LIMBS - BP_CHEST)
						pref.organ_data[other_limb] = "cyborg"
						pref.rlimb_data[other_limb] = choice
					if(!pref.organ_data[BP_BRAIN])
						pref.organ_data[BP_BRAIN] = "assisted"
					for(var/internal_organ in list(BP_HEART, BP_EYES, BP_LUNGS, BP_LIVER, BP_KIDNEYS))
						pref.organ_data[internal_organ] = "mechanical"

		return TOPIC_REFRESH_UPDATE_PREVIEW

// Mirrors sanitize_organs() from 02_body.dm to keep organ data consistent.
/datum/category_item/player_setup_item/cyberware/prosthetics/proc/aug_sanitize_organs()
	var/singleton/species/mob_species = GLOB.species_by_name[pref.species]
	if(mob_species?.spawn_flags & SPECIES_NO_ROBOTIC_INTERNAL_ORGANS)
		for(var/name in pref.organ_data)
			var/status = pref.organ_data[name]
			if(status in list("assisted", "mechanical"))
				pref.organ_data[name] = null
	if(pref.organ_data[BP_CHEST] == "cyborg" && pref.organ_data[BP_EYES] == "assisted")
		for(var/name in pref.organ_data)
			if(name in list("heart", "eyes", "lungs", "liver", "kidneys"))
				pref.organ_data[name] = "mechanical"
