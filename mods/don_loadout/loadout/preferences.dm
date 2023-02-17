/datum/preferences
	var/datum/gear/trying_on_gear
	var/list/trying_on_tweaks = new

	// All these gear tweaks be slow as anything.
	// Let's just force things to yield, sparing us from sanitizing and resanitizing stuff.
	var/loadout_is_busy = FALSE

/datum/preferences/dress_preview_mob(mob/living/carbon/human/mannequin)
	if(!mannequin)
		return

	var/update_icon = FALSE
	copy_to(mannequin, TRUE)
	mannequin.update_icon = TRUE

	var/datum/job/previewJob
	if (preview_job || preview_gear)
		// Determine what job is marked as 'High' priority, and dress them up as such.
		if(GLOB.using_map.default_assistant_title in job_low)
			previewJob = SSjobs.get_by_title(GLOB.using_map.default_assistant_title)
		else
			previewJob = SSjobs.get_by_title(job_high)
	else
		return

	if(!previewJob && mannequin.icon)
		update_icon = TRUE // So we don't end up stuck with a borg/AI icon after setting their priority to non-high
	else if(preview_job && previewJob)
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
		var/list/accessories = list()

		var/list/gears = Gear().Copy()
		if(trying_on_gear)
			gears[trying_on_gear] = trying_on_tweaks.Copy()

		for(var/thing in gears)
			var/datum/gear/G = gear_datums[thing]
			if(G)
				var/permitted = 0
				if(G.allowed_roles && G.allowed_roles.len)
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

				if(G.slot == slot_tie)
					accessories.Add(G)
					continue

				if(G.slot && G.slot != slot_tie && !(G.slot in loadout_taken_slots) && G.spawn_on_mob(mannequin, gear_list[gear_slot][G.display_name]))
					loadout_taken_slots.Add(G.slot)
					update_icon = TRUE

		// equip accessories after other slots so they don't attach to a suit which will be replaced
		for(var/datum/gear/G in accessories)
			G.spawn_as_accessory_on_mob(mannequin, gears[G.display_name])

		if(accessories.len)
			update_icon = TRUE

	if(update_icon)
		mannequin.update_icons()
