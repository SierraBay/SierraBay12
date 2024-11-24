/datum/submap/ascent_inf
	var/gyne_name

/datum/submap/ascent_inf/sync_cell(obj/overmap/visitable/cell)
	return

// Rename procs are already implemented in Ascent Caulship
/mob/living/carbon/human/proc/gyne_rename_lineage_inf()
	set name = "Name Nest-Lineage — Seedship"
	set category = "IC"
	set desc = "Rename yourself and your alates."

	if(species.name == SPECIES_MANTID_GYNE && mind && istype(mind.assigned_job, /datum/job/submap/ascent_inf))
		var/datum/job/submap/ascent_inf/ascent_job = mind.assigned_job
		var/datum/submap/ascent_inf/cutter = ascent_job.owner
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
				var/datum/job/submap/ascent_inf/temp_ascent_job = H.mind.assigned_job
				if(!istype(temp_ascent_job) || temp_ascent_job.owner != ascent_job.owner)
					continue


				var/new_alate_number = is_species_whitelisted(H, SPECIES_MANTID_GYNE) ? random_id(/datum/species/mantid, 1000, 9999) : random_id(/datum/species/mantid, 10000, 99999)
				H.fully_replace_character_name("[new_alate_number] [new_name]")
				to_chat(H, SPAN_NOTICE("<font size = 3>Your gyne, [real_name], has awakened, and you recall your place in the nest-lineage: <b>[H.real_name]</b>.</font>"))

	verbs -= /mob/living/carbon/human/proc/gyne_rename_lineage_inf

/mob/living/carbon/human/proc/serpentid_namepick_inf()
	set name = "Choose a name — Seedship"
	set category = "IC"
	set desc = "Rename yourself."

	if(mind && istype(mind.assigned_job, /datum/job/submap/ascent_inf))
		var/datum/job/submap/ascent_inf/ascent_job = mind.assigned_job
		var/datum/submap/ascent_inf/cutter = ascent_job.owner
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

	verbs -= /mob/living/carbon/human/proc/serpentid_namepick_inf

// Jobs.
/datum/job/submap/ascent_inf
	title = "Ascent gyne"
	allowed_branches = list(/datum/mil_branch/alien)
	allowed_ranks = list(/datum/mil_rank/alien)
	total_positions = 1
	supervisors = "youself"
	info = "Вы Кхармаани Гиина на вашем независимом корабле. Твой путь привел тебя к этим землям, насыщенными низшими формами жизни. \
	\
	Покажи всем свое величие, распространи свой улей в этом секторе, приготовься к очередному приступу размножения и укрепи тут свою власть. \
	Твои радары показали, что в этом секторе присутствует огромный корабль с скрелльским блюспейс двигателем на борту. Нападение на этот корабль, может привести к еще одной войной со скреллами"
	outfit_type = /singleton/hierarchy/outfit/job/ascent
	blacklisted_species = null
	whitelisted_species = list(SPECIES_MANTID_GYNE)
	loadout_allowed = FALSE
	is_semi_antagonist = TRUE
	var/requires_supervisor = FALSE
	var/set_species_on_join = null
	min_skill = list(SKILL_EVA = SKILL_MASTER,
					SKILL_PILOT = SKILL_EXPERIENCED,
					SKILL_HAULING = SKILL_TRAINED,
					SKILL_COMBAT = SKILL_TRAINED,
					SKILL_WEAPONS = SKILL_MASTER,
					SKILL_SCIENCE = SKILL_TRAINED,
					SKILL_MEDICAL = SKILL_TRAINED,
					SKILL_ANATOMY = SKILL_TRAINED)

/datum/job/submap/ascent_inf/handle_variant_join(mob/living/carbon/human/H, alt_title)

	if(ispath(set_species_on_join, /mob/living/silicon/robot))
		return H.Robotize(set_species_on_join)
	/*if(ispath(set_species_on_join, /mob/living/silicon/ai))
		return H.AIize(set_species_on_join, move = FALSE)*/

	var/datum/submap/ascent_inf/cutter = owner

	if(!cutter.gyne_name)
		cutter.gyne_name = TYPE_PROC_REF(/singleton/cultural_info/culture/ascent, create_gyne_name)

	if(set_species_on_join)
		H.set_species(set_species_on_join)

	switch(H.species.name)
		if(SPECIES_MANTID_GYNE)
			H.real_name = "[random_id(/datum/species/mantid, 1, 99)] [cutter.gyne_name]"
			H.verbs |= /mob/living/carbon/human/proc/gyne_rename_lineage_inf
		if(SPECIES_MANTID_ALATE)
			var/new_alate_number = is_species_whitelisted(H, SPECIES_MANTID_GYNE) ? random_id(/datum/species/mantid, 1000, 9999) : random_id(/datum/species/mantid, 10000, 99999)
			H.real_name = "[new_alate_number] [cutter.gyne_name]"
		if(SPECIES_MONARCH_WORKER)
			H.real_name = "[TYPE_PROC_REF(/singleton/cultural_info/culture/ascent, create_worker_name)]"
			H.verbs |= /mob/living/carbon/human/proc/serpentid_namepick_inf
		if(SPECIES_MONARCH_QUEEN)
			H.real_name = "["Queen "][TYPE_PROC_REF(/singleton/cultural_info/culture/ascent, create_queen_name)]"
			H.verbs |= /mob/living/carbon/human/proc/serpentid_namepick_inf
	H.name = H.real_name
	if(H.mind)
		H.mind.name = H.real_name
	return H

/datum/job/submap/ascent_inf/is_position_available()
	. = ..()
	if(. && requires_supervisor)
		for(var/mob/M in GLOB.player_list)
			if(!M.client || !M.mind || !M.mind.assigned_job || M.mind.assigned_job.title != requires_supervisor)
				continue
			var/datum/job/submap/ascent_inf/ascent_job = M.mind.assigned_job
			if(istype(ascent_job) && ascent_job.owner == owner)
				return TRUE
		return FALSE

/datum/job/submap/ascent_inf/alate
	title = "Ascent alate"
	total_positions = 3
	supervisors = "Гиине"
	info = "Ты Кхармаани Алат независимого корабля Восхождения. Гиина направила вас в этот сектор, полный ползущих примитивов. Верь в нее, до конца своей жизни и возведи новое гнездо, чтобы стать подобным ей или слится с ее телом."
	outfit_type = /singleton/hierarchy/outfit/job/ascent/attendant
	whitelisted_species = list(SPECIES_MANTID_ALATE)
	requires_supervisor = "Ascent gyne"
	min_skill = list(SKILL_EVA = SKILL_EXPERIENCED,
					SKILL_HAULING = SKILL_MASTER,
					SKILL_COMBAT = SKILL_MASTER,
					SKILL_WEAPONS = SKILL_MASTER,
					SKILL_MEDICAL = SKILL_TRAINED)

/datum/job/submap/ascent_inf/drone
	title = "Ascent drone"
	supervisors = "Гиине"
	total_positions = 1
	info = "Ты дрон Контролирущего Разума на отдаленном секторе. Гиина, направила вас с ее выводком, в этот сектор, полным примитивных созданий. Постарайся сохранить им жизнь и помочь во всем, чем можешь."
	set_species_on_join = /mob/living/silicon/robot/flying/ascent
	requires_supervisor = "Ascent gyne"
	whitelisted_species = list(SPECIES_MANTID_ALATE)

/datum/job/submap/ascent_inf/monarch_worker
	title = "Serpentid adjunct"
	supervisors = "вашей Королевой"
	total_positions = 3
	info = "Ты Серпентид-Монарх Рабочий, который служит своей королеве. Услужи ей и не заставь стыдится за тебя."
	whitelisted_species = list(SPECIES_MANTID_ALATE, SPECIES_NABBER)
	set_species_on_join = SPECIES_MONARCH_WORKER
	outfit_type = /singleton/hierarchy/outfit/job/ascent/worker
	min_skill = list(SKILL_EVA = SKILL_TRAINED,
					SKILL_HAULING = SKILL_TRAINED,
					SKILL_COMBAT = SKILL_TRAINED,
					SKILL_WEAPONS = SKILL_TRAINED,
					SKILL_SCIENCE = SKILL_TRAINED,
					SKILL_MEDICAL = SKILL_BASIC)

/datum/job/submap/ascent_inf/monarch_queen
	title = "Serpentid queen"
	supervisors = "другими Королевами и Гииной"
	total_positions = 1
	info = "Ты СМ-Королева, на независимом корабле Восхождения. Твоя родственная душа, Гиина, надеется на тебя и твоих прислуг."
	whitelisted_species = list(SPECIES_NABBER, SPECIES_MANTID_GYNE)
	set_species_on_join = SPECIES_MONARCH_QUEEN
	outfit_type = /singleton/hierarchy/outfit/job/ascent/queen
	min_skill = list(SKILL_EVA = SKILL_TRAINED,
					SKILL_HAULING = SKILL_TRAINED,
					SKILL_COMBAT = SKILL_TRAINED,
					SKILL_WEAPONS = SKILL_TRAINED,
					SKILL_MEDICAL = SKILL_BASIC)

// Spawn points.
/obj/submap_landmark/spawnpoint/ascent_seedship_inf
	name = "Ascent gyne"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/submap_landmark/spawnpoint/ascent_seedship_inf/alate
	name = "Ascent alate"

/obj/submap_landmark/spawnpoint/ascent_seedship_inf/drone
	name = "Ascent drone"

/obj/submap_landmark/spawnpoint/ascent_seedship_inf/adjunct
	name = "Serpentid adjunct"

/obj/submap_landmark/spawnpoint/ascent_seedship_inf/queen
	name = "Serpentid queen"

/*
/datum/job/submap/ascent_inf/control_mind
	title = "Ascent Control Mind"
	supervisors = "Гииной"
	total_positions = 1
	info = "You are a Machine Intelligence of an independent Ascent vessel. The Gyne you assist, and her children, have wandered into this sector full of primitive bioforms. Try to keep them alive, and assist where you can."
	set_species_on_join = /mob/living/silicon/ai/ascent

/obj/submap_landmark/spawnpoint/ascent_seedship/control
	name = "Ascent Control Mind"

/mob/living/silicon/ai/ascent
	name = "TODO"
*/
