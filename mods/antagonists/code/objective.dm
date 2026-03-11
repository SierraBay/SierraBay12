/datum/objective/traitor
	var/static/possible_items[] = list(
		"captain's final argument", // antique laser gun is long gone
		"bluespace rift generator",
		"RCD",
		"jetpack",
		"captain's jumpsuit",
		"functional AI",
		"pair of magboots",
		"[station_name()] blueprints",
		"28 moles of phoron (full tank)",
		"sample of slime extract",
		"piece of corgi meat",
		"chief science officer's jumpsuit",
		"chief engineer's jumpsuit",
		"chief medical officer's jumpsuit",
		"head of security's jumpsuit",
		"head of personnel's jumpsuit",
		"hypospray",
		"captain's pinpointer",
		"ablative armor vest",
		"\improper NT breacher chassis control module",
		"captain's HCM",
		"HoP's HCM",
		"CMO's HCM",
		"HoS' HCM",
		"research command HCM",
		"heavy exploration HCM",
		"hazard hardsuit control module",
		"nuclear instructions envelope",
		"DELTA protocol envelope",
		"ALPHA Protocol envelope",
		"UMBRA Protocol envelope",
		"RE: Regarding testing supplies envelope",
	)
	var/static/shuttles[] = list(
			"Charon",
			"GUP",
			"Petrov",
			"Phaeton"
		)

// list for loadout items with custom names
GLOBAL_LIST_EMPTY(custom_items)

/datum/gear_tweak/custom_name/tweak_item(user, obj/item/I, metadata)
	. = ..()
	if (metadata)
		var/new_entry = list(
			"item_name" = metadata,
			"owner" = user
		)
		GLOB.custom_items += list(new_entry)
/datum/mind
	var/list/used_renegade_targets = list() // renegades that are already used as targets for objectives, to avoid repetition
	var/generated_objectives = 0

/datum/objective/traitor/proc/get_available_renegade_target()
	var/list/all_renegades = get_antagonists_by_type(MODE_RENEGADE)
	var/list/available = list()

	for(var/datum/mind/renegade in all_renegades)
		if(!(renegade in owner?.used_renegade_targets) && renegade?.current)
			available += renegade

	return LAZYLEN(available) ? pick(available) : null

/datum/objective/traitor/find_target()
	var/objective
	var/max_attempts = 10

	for(var/i = 1 to max_attempts)
		objective = null
		switch (rand(1, 4))
			if (1, 2) // human - prioritize renegades
				var/list/renegades = get_antagonists_by_type(MODE_RENEGADE)
				var/datum/mind/renegade_target = LAZYLEN(renegades) ? pick(renegades) : null

				target = renegade_target?.current ? renegade_target : null

				if(!target)
					objective = ..()

				if(target?.current)
					objective = "[target.current.real_name], the [target.assigned_role]."
				else
					objective = get_random_custom_item() || get_random_objective_item()
			if (3)
				objective = get_random_shuttle()
			if (4) // custom item or static item if not found
				objective = get_random_custom_item() || get_random_objective_item()

		if(!validate_objective(objective))
			continue
		explanation_text = "My goal involves [objective]"
		return TRUE

	log_and_message_admins(SPAN_WARNING("Objective generation failed! Last attempt: [explanation_text]"), owner?.current)
	return FALSE

/datum/objective/traitor/proc/validate_objective(objective)
	if(!objective)
		return FALSE
	if(owner?.has_similar_objective(src))
		return FALSE
	return TRUE


/datum/objective/traitor/proc/get_random_custom_item()
	if(!LAZYLEN(GLOB.custom_items))
		return

	var/list/entry = pick(GLOB.custom_items)

	var/item_name = entry["item_name"]
	var/mob/item_owner = entry["owner"]
	if ("[item_owner]" == "[owner.current]")
		return
	return "[item_name] owned by [item_owner]"

/datum/objective/traitor/proc/get_random_objective_item()
	return pick(possible_items)

/datum/objective/traitor/proc/get_random_shuttle()
	return pick(shuttles)

/mob/living/proc/get_objective()
	set name = "Get Objective"
	set category = "IC"
	set src = usr

	if(!mind)
		return
	if(mind.generated_objectives >= 3)
		to_chat(mind.current, "You have already generated the maximum number of objectives for today.")
		return
	mind.generated_objectives++


	var/datum/objective/traitor/objective = new
	objective.owner = mind

	if(!objective.find_target())
		qdel(objective)
		to_chat(mind.current, SPAN_WARNING("Failed to find a valid objective."))
		return

	mind.objectives += objective

	mind.ShowMemory(mind.current)

/datum/objective/traitor/get_display_text()
	return explanation_text + " <a href='byond://?src=\ref[owner];remove_objective=\ref[src]'>\[Remove\]</a>"

/datum/mind/Topic(href, href_list)
	if(href_list["remove_objective"])
		var/datum/objective/traitor/objective = locate(href_list["remove_objective"]) in objectives
		if(objective && current && current == usr)
			objectives -= objective
			qdel(objective)
			to_chat(usr, SPAN_NOTICE("You have removed an objective."))
			log_admin("[key_name_admin(usr)] removed an objective from [key_name(current)].")
			ShowMemory(usr)
		return TRUE

	if(href_list["get_objective"])
		if(current && current == usr)
			current.get_objective()

		return TRUE

	return ..()

/datum/mind/proc/has_similar_objective(datum/objective/traitor/new_obj)
	for(var/datum/objective/traitor/existing in objectives)
		if(existing.explanation_text == new_obj.explanation_text)
			return TRUE
	return FALSE


/datum/objective/survive/traitor
	explanation_text = "Stay alive until the end."

/datum/objective/survive/traitor/get_display_text()
	if(owner.generated_objectives < 3)
		return explanation_text + " <a href='byond://?src=\ref[owner];get_objective=1'>\[Get Objective\]</a>"
	else
		return explanation_text


/datum/objective/hijack
	explanation_text = "Hijack a shuttle."

/datum/objective/hijack/New(shuttle)
	var/list/shuttles = shuttle ? list(shuttle) : list(
		"Charon",
		"GUP",
		"Petrov",
		"Phaeton"
	)
	explanation_text = "Hijack [pick(shuttles)]"

/datum/objective/renegade/New(datum/mind/new_target)
	if(new_target)
		set_target(new_target)

/datum/objective/renegade/proc/set_target(datum/mind/new_target)
	if(new_target)
		target = new_target

	if(!target)
		return FALSE

	if(target?.current)
		explanation_text = "[target.current.real_name], the [target.assigned_role] seems to be a threat."
	else
		explanation_text = "[target] seems to be a threat."
	return TRUE

/datum/objective/renegade/find_target()
	. = ..()
	if(target)
		set_target()
		return TRUE
	return FALSE
