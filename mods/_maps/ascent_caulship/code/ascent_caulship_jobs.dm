/datum/submap/ascent
	var/gyne_name

/datum/submap/ascent/sync_cell(obj/overmap/visitable/cell)
	return

/mob/living/carbon/human/proc/gyne_rename_lineage()
	set name = "Name Nest-Lineage"
	set category = "IC"
	set desc = "Rename yourself and your alates."

	if(species.name == SPECIES_MANTID_GYNE && mind && istype(mind.assigned_job, /datum/job/submap/ascent))
		var/datum/job/submap/ascent/ascent_job = mind.assigned_job
		var/datum/submap/ascent/cutter = ascent_job.owner
		if(istype(cutter))

			var/new_number = input("What is your position in your lineage?", "Name Nest-Lineage") as num|null
			if(!new_number)
				return
			new_number = clamp(new_number, 1, 999)
			var/new_name = sanitize(input("What is the true name of your nest-lineage?", "Name Nest-Lineage") as text|null, MAX_NAME_LEN)
			if(!new_name)
				return

			if(species.name != SPECIES_MANTID_GYNE || !mind || mind.assigned_job != ascent_job)
				return

			// Rename ourselves.
			fully_replace_character_name("[new_number] [new_name]")

			// Rename our alates (and only our alates).
			cutter.gyne_name = new_name
			for(var/mob/living/carbon/human/H in SSmobs.mob_list)
				if(!H.mind || H.species.name != SPECIES_MANTID_ALATE)
					continue
				var/datum/job/submap/ascent/temp_ascent_job = H.mind.assigned_job
				if(!istype(temp_ascent_job) || temp_ascent_job.owner != ascent_job.owner)
					continue


				var/new_alate_number = is_species_whitelisted(H, SPECIES_MANTID_GYNE) ? random_id(/datum/species/mantid, 1000, 9999) : random_id(/datum/species/mantid, 10000, 99999)
				H.fully_replace_character_name("[new_alate_number] [new_name]")
				to_chat(H, SPAN_NOTICE("<font size = 3>Your gyne, [real_name], has awakened, and you recall your place in the nest-lineage: <b>[H.real_name]</b>.</font>"))

	verbs -= /mob/living/carbon/human/proc/gyne_rename_lineage

/mob/living/carbon/human/proc/serpentid_namepick()
	set name = "Choose a name"
	set category = "IC"
	set desc = "Rename yourself."

	if(mind && istype(mind.assigned_job, /datum/job/submap/ascent))
		var/datum/job/submap/ascent/ascent_job = mind.assigned_job
		var/datum/submap/ascent/cutter = ascent_job.owner
		if(istype(cutter))
			if(!mind || mind.assigned_job != ascent_job)
				return

			// Rename ourselves.
			if(species.name == SPECIES_MONARCH_QUEEN)
				var/new_name = sanitize(input("What is your name? Queen...", "Choose name") as text|null, MAX_NAME_LEN)
				if(!new_name)
					return
				fully_replace_character_name("["Queen"] [new_name]")

			else
				var/new_name = sanitize(input("What is your name?", "Choose name") as text|null, MAX_NAME_LEN)
				if(!new_name)
					return
				fully_replace_character_name("[new_name]")

	verbs -= /mob/living/carbon/human/proc/serpentid_namepick

// Jobs.
/datum/job/submap/ascent
	title = "Ascent Gyne"
	allowed_branches = list(/datum/mil_branch/alien)
	allowed_ranks = list(/datum/mil_rank/alien)
	total_positions = 1
	supervisors = "nobody but yourself"
	info = "You are a Gyne of the Ascent, fleeing the murderous Kharmaani political sphere after your first molt. Your search for safe harbour has brought you to this remote unsettled sector. Find a safe nest, and bring prosperity to your lineage."
	outfit_type = /singleton/hierarchy/outfit/job/ascent
	blacklisted_species = null
	whitelisted_species = list(SPECIES_MANTID_GYNE)
	loadout_allowed = FALSE
	is_semi_antagonist = TRUE
	min_skill = list(
		SKILL_EVA = SKILL_TRAINED,
		SKILL_PILOT = SKILL_TRAINED,
		SKILL_HAULING = SKILL_TRAINED,
		SKILL_COMBAT = SKILL_TRAINED,
		SKILL_WEAPONS = SKILL_TRAINED,
		SKILL_SCIENCE = SKILL_TRAINED,
		SKILL_MEDICAL = SKILL_BASIC
	)
	var/requires_supervisor = FALSE
	var/set_species_on_join = null

/datum/job/submap/ascent/handle_variant_join(mob/living/carbon/human/H, alt_title)

	if(ispath(set_species_on_join, /mob/living/silicon/robot))
		return H.Robotize(set_species_on_join)
	/*if(ispath(set_species_on_join, /mob/living/silicon/ai))
		return H.AIize(set_species_on_join, move = FALSE)*/

	var/datum/submap/ascent/cutter = owner

	if(!cutter.gyne_name)
		cutter.gyne_name = TYPE_PROC_REF(/singleton/cultural_info/culture/ascent, create_gyne_name)

/*	if(set_species_on_join)
		H.set_species(set_species_on_join)*/

	switch(H.species.name)
		if(SPECIES_MANTID_GYNE)
			H.real_name = "[random_id(/datum/species/mantid, 1, 99)] [cutter.gyne_name]"
			H.verbs |= /mob/living/carbon/human/proc/gyne_rename_lineage
		if(SPECIES_MANTID_ALATE)
			var/new_alate_number = is_species_whitelisted(H, SPECIES_MANTID_GYNE) ? random_id(/datum/species/mantid, 1000, 9999) : random_id(/datum/species/mantid, 10000, 99999)
			H.real_name = "[new_alate_number] [cutter.gyne_name]"
		if(SPECIES_MONARCH_WORKER)
			H.real_name = "[TYPE_PROC_REF(/singleton/cultural_info/culture/ascent, create_worker_name)]"
			H.verbs |= /mob/living/carbon/human/proc/serpentid_namepick
		if(SPECIES_MONARCH_QUEEN)
			H.real_name = "["Queen "][TYPE_PROC_REF(/singleton/cultural_info/culture/ascent, create_queen_name)]"
			H.verbs |= /mob/living/carbon/human/proc/serpentid_namepick
	H.name = H.real_name
	if(H.mind)
		H.mind.name = H.real_name
	return H

/datum/job/submap/ascent/alate
	title = "Ascent Alate"
	total_positions = 2
	supervisors = "the Gyne"
	info = "You are a young Alate of a new Gyne. She has led you to this remote sector to found a new nest. Follow her instructions and bring prosperity to your nest-lineage."
	outfit_type = /singleton/hierarchy/outfit/job/ascent/attendant
	whitelisted_species = list(SPECIES_MANTID_ALATE)
	min_skill = list(
		SKILL_EVA = SKILL_TRAINED,
		SKILL_HAULING = SKILL_TRAINED,
		SKILL_COMBAT = SKILL_TRAINED,
		SKILL_WEAPONS = SKILL_TRAINED,
		SKILL_MEDICAL = SKILL_BASIC
	)
	requires_supervisor = "Ascent Gyne"

/datum/job/submap/ascent/drone
	title = "Ascent Drone"
	supervisors = "the Gyne"
	total_positions = 1
	info = "You are a Machine Intelligence of an independent Ascent vessel. The Gyne you assist has fled her sisters, ending up in this sector full of primitive bioforms. Try to keep her alive, and assist where you can."
	set_species_on_join = /mob/living/silicon/robot/flying/ascent
	whitelisted_species = list(SPECIES_MANTID_ALATE)
	requires_supervisor = "Ascent Gyne"

/datum/job/submap/ascent/worker
	title = "Serpentid Adjunct"
	supervisors = "the Serpentid Queen and the Gyne"
	total_positions = 2
	info = "You are a Monarch Serpentid Worker serving as an attendant to your Queen on this vessel. Serve her however she requires."
	whitelisted_species = list(SPECIES_MONARCH_WORKER)
	outfit_type = /singleton/hierarchy/outfit/job/ascent/worker
	min_skill = list(SKILL_EVA = SKILL_TRAINED,
					SKILL_HAULING = SKILL_TRAINED,
					SKILL_COMBAT = SKILL_TRAINED,
					SKILL_WEAPONS = SKILL_TRAINED,
					SKILL_SCIENCE = SKILL_TRAINED,
					SKILL_MEDICAL = SKILL_BASIC
	)
	requires_supervisor = "Serpentid Queen"

/datum/job/submap/ascent/queen
	title = "Serpentid Queen"
	supervisors = "the Gyne"	
	total_positions = 1
	info = "You are a Monarch Serpentid Queen living on an independant Ascent vessel. Assist the Gyne in her duties and tend to your Workers."
	outfit_type = /singleton/hierarchy/outfit/job/ascent/queen
	whitelisted_species = list(SPECIES_MONARCH_QUEEN)
	min_skill = list(SKILL_EVA = SKILL_TRAINED,
					SKILL_HAULING = SKILL_TRAINED,
					SKILL_COMBAT = SKILL_TRAINED,
					SKILL_WEAPONS = SKILL_TRAINED,
					SKILL_MEDICAL = SKILL_BASIC
	)
	requires_supervisor = "Ascent Gyne"


// Spawn points.
/obj/submap_landmark/spawnpoint/ascent_caulship
	name = "Ascent Gyne"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/submap_landmark/spawnpoint/ascent_caulship/alate
	name = "Ascent Alate"

/obj/submap_landmark/spawnpoint/ascent_caulship/drone
	name = "Ascent Drone"

/obj/submap_landmark/spawnpoint/ascent_caulship/worker
	name = "Serpentid Adjunct"

/obj/submap_landmark/spawnpoint/ascent_caulship/queen
	name = "Serpentid Queen"
