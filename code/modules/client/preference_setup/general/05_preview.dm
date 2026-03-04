/datum/preferences/var/list/background_states = list("000", "FFF", MATERIAL_STEEL, "white")

/datum/preferences/var/icon/bgstate = "000"

/datum/preferences/var/preview_job = TRUE

/datum/preferences/var/preview_gear = TRUE

/datum/preferences/var/icon/preview_icon

// [SIERRA-ADD] HEIGHT
/client/var/list/char_render_holders
/client/var/preview_active_map = ""
// [/SIERRA-ADD]

/datum/preferences/VV_static()
	return ..() + list(
		"background_states"
	)


/datum/preferences/proc/dress_preview_mob(mob/living/carbon/human/mannequin)
	// [SIERRA-ADD] - DON_LOADOUT - Mob preview
	// Не открывать до Рождества
	// if(!mannequin)
	// 	return
	// [/SIERRA-ADD]
	var/update_icon = FALSE
	copy_to(mannequin, TRUE)
	var/datum/job/previewJob
	if (preview_job || preview_gear)
		// Determine what job is marked as 'High' priority, and dress them up as such.
		if(GLOB.using_map.default_assistant_title in job_low)
			previewJob = SSjobs.get_by_title(GLOB.using_map.default_assistant_title)
		else
			previewJob = SSjobs.get_by_title(job_high)
	else
		return
	// [SIERRA-ADD] - DON_LOADOUT - Mob preview
	// Не открывать до Рождества
	// if(!previewJob && mannequin.icon)
	// 	update_icon = TRUE // So we don't end up stuck with a borg/AI icon after setting their priority to non-high
	// [/SIERRA-ADD]
	if(preview_job && previewJob)
		mannequin.job = previewJob.title
		var/datum/mil_branch/branch = GLOB.mil_branches.get_branch(branches[previewJob.title])
		var/datum/mil_rank/rank = GLOB.mil_branches.get_rank(branches[previewJob.title], ranks[previewJob.title])
		previewJob.equip_preview(mannequin, player_alt_titles[previewJob.title], branch, rank)
		update_icon = TRUE
	if(!(mannequin.species.appearance_flags && mannequin.species.appearance_flags & SPECIES_APPEARANCE_HAS_UNDERWEAR))
		if(all_underwear)
			all_underwear.Cut()
	if(preview_gear && !(previewJob && preview_job && (previewJob.type == /datum/job/ai || previewJob.type == /datum/job/cyborg)))
		// Equip custom gear loadout, replacing any job items
		var/list/loadout_taken_slots = list()
		var/list/accessories = list() // [SIERRA-ADD] — Collect slot_tie items (cloaks, armbands, etc.) to equip after suits/uniforms
		// [SIERRA-EDIT] - DON_LOADOUT - Trying gears
		for(var/thing in Gear()) // SIERRA-EDIT - ORIGINAL
		// var/list/orig_gears = Gear()
		// var/list/gears = orig_gears.Copy()
		// if(trying_on_gear)
		// 	gears[trying_on_gear] = trying_on_tweaks.Copy()
		//
		// for(var/thing in gears)
		// [/SIERRA-EDIT]
			var/datum/gear/G = gear_datums[thing]
			if(G)
				var/permitted = 0
				if(G.allowed_roles && length(G.allowed_roles))
					if(previewJob)
						for(var/job_type in G.allowed_roles)
							if(previewJob.type == job_type)
								permitted = 1
				else
					permitted = 1
				if(G.whitelisted && !(mannequin.species.name in G.whitelisted))
					permitted = 0
				if(!permitted)
					continue
				// [SIERRA-ADD] — Defer accessories to equip after suits/uniforms are on
				if(G.slot == slot_tie)
					accessories += G
					continue
				// [/SIERRA-ADD]
				if(G.slot && !(G.slot in loadout_taken_slots) && G.spawn_on_mob(mannequin, gear_list[gear_slot][G.display_name]))
					loadout_taken_slots.Add(G.slot)
					update_icon = TRUE
		// [SIERRA-ADD] — Equip accessories after other gear so they can attach to uniforms/suits
		for(var/datum/gear/G in accessories)
			if(G.spawn_on_mob(mannequin, gear_list[gear_slot][G.display_name]))
				update_icon = TRUE
		// [/SIERRA-ADD]
	if(update_icon)
		mannequin.update_icons()



/datum/preferences/proc/update_preview_icon(resize_only)
	var/mob/living/carbon/human/dummy/mannequin/mannequin = get_mannequin(client_ckey)
	mannequin.delete_inventory(TRUE)
	dress_preview_mob(mannequin)
	mannequin.ImmediateOverlayUpdate()

	// [SIERRA-ADD] HEIGHT — Update the MAP-based preview (TauCeti style)
	if(client)
		// Determine if this is a tall/large species
		var/is_tall = (mannequin.icon_height > 32) || (mannequin.mob_size == MOB_LARGE)
		client.show_character_previews(new /mutable_appearance(mannequin), is_tall, get_preview_floor_state())
		// Update MAP background color on the active map
		var/bg_color = get_preview_bgcolor()
		var/active_map = is_tall ? "character_preview_map" : "character_preview_map_compact"
		winset(client, active_map, "background-color=[bg_color]")
	// [/SIERRA-ADD]

	if (!resize_only || !preview_icon)
		var/icon/last_built_icon = icon('icons/effects/128x48.dmi', bgstate)
		last_built_icon.Scale(48+32, 16+32)
		mannequin.dir = SOUTH
		var/icon/character_icon = getFlatIcon(mannequin, SOUTH)
		last_built_icon.Blend(character_icon, ICON_OVERLAY, 25, 3)
		preview_icon = last_built_icon
	var/scale = client?.get_preference_value(/datum/client_preference/preview_scale)
	switch (scale)
		if (GLOB.PREF_LARGE)
			scale = 4
		if (GLOB.PREF_MEDIUM)
			scale = 3
		else
			scale = 2
	preview_icon = new (preview_icon) //[SIERRA-ADD]
	preview_icon.Scale(preview_icon.Width() * scale, preview_icon.Height() * scale)


/datum/category_item/player_setup_item/physical/preview
	name = "Preview"
	sort_order = 5


/datum/category_item/player_setup_item/physical/preview/load_character(datum/pref_record_reader/R)
	pref.bgstate = R.read("bgstate")
	pref.preview_icon = null


/datum/category_item/player_setup_item/physical/preview/save_character(datum/pref_record_writer/W)
	W.write("bgstate", pref.bgstate)


/datum/category_item/player_setup_item/physical/preview/sanitize_character()
	if(!pref.bgstate || !(pref.bgstate in pref.background_states))
		pref.bgstate = pref.background_states[1]


/datum/category_item/player_setup_item/physical/preview/OnTopic(query_text, list/query, mob/user)
	if (!query)
		return
	else if (query["cyclebg"])
		var/index = pref.background_states.Find(pref.bgstate)
		if (!index || index == length(pref.background_states))
			pref.bgstate = pref.background_states[1]
		else
			pref.bgstate = pref.background_states[index + 1]
		return TOPIC_REFRESH_UPDATE_PREVIEW
/*[SIERRA-REMOVE] - HEIGHT
	else if (query["resize"])
		pref.client?.cycle_preference(/datum/client_preference/preview_scale)
		return TOPIC_REFRESH_UPDATE_PREVIEW
*/
	else if (query["previewjob"])
		pref.preview_job = !pref.preview_job
		pref.preview_icon = null
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if (query["previewgear"])
		pref.preview_gear = !pref.preview_gear
		pref.preview_icon = null
		return TOPIC_REFRESH_UPDATE_PREVIEW
	return ..()


/datum/category_item/player_setup_item/physical/preview/content(mob/user)
	// [SIERRA-EDIT] — HEIGHT PREVIEW
	//if(!pref.preview_icon)
	//	pref.update_preview_icon()
	. = "<b>Preview:</b> (shown on the right panel)"
	. += "<br />[BTN("cyclebg", "Cycle Background")]"
	. += " - [BTN("previewgear", "[pref.preview_gear ? "Hide" : "Show"] Loadout")]"
	. += " - [BTN("previewjob", "[pref.preview_job ? "Hide" : "Show"] Uniform")]"
	//. += " - [BTN("resize", "Resize")]"
	// [/SIERRA-EDIT]
