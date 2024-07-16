GLOBAL_DATUM_INIT(joinpanel_state, /datum/topic_state/joinpanel, new)

/datum/topic_state/joinpanel/can_use_topic(src_object, mob/user)
	return istype(user, /mob/new_player) ? STATUS_INTERACTIVE : STATUS_CLOSE

/datum/nano_module/joinpanel

/datum/nano_module/joinpanel/CanUseTopic(mob/user, datum/topic_state/state = GLOB.joinpanel_state)
	. = ..()

/datum/nano_module/joinpanel/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.joinpanel_state)
	var/data[0]

	/// Основные должности

	var/list/mainJobs = list(
		list(name = "Command", jobs = list(), dep = COM, open = 0, color = "#aac1ee"),
		list(name = "Command Support", jobs = list(), dep = SPT, open = 0, color = "#aac1ee"),
		list(name = "Engineering", jobs = list(), dep = ENG, open = 0, color = "#ffd699"),
		list(name = "Security", jobs = list(), dep = SEC, open = 0, color = "#ff9999"),
		list(name = "Miscellaneous", jobs = list(), dep = CIV, open = 0, color = "#ffffff", colBreak = 1),
		list(name = "Synthetics", jobs = list(), dep = MSC, open = 0, color = "#ccffcc"),
		list(name = "Service", jobs = list(), dep = SRV, open = 0, color = "#cccccc"),
		list(name = "Medical", jobs = list(), dep = MED, open = 0, color = "#99ffe6"),
		list(name = "Research", jobs = list(), dep = SCI, open = 0, color = "#e6b3e6", colBreak = 1),
		list(name = "Supply", jobs = list(), dep = SUP, open = 0, color = "#ead4ae"),
		list(name = "Exploration", jobs = list(), dep = EXP, open = 0, color = "#ffd699")
	)
	var/list/otherJobs = list()

	for(var/category in mainJobs)
		var/list/jobs = list()
		for(var/datum/job/job in SSjobs.primary_job_datums)
			if(job.department_flag & category["dep"])
				category["open"] += job.total_positions - job.current_positions
				LAZYADD(jobs, list(list("title" = job.title, "head" = job.head_position, "positions" = job.current_positions, "total" = job.total_positions, "active" = job.get_active_count(), "canpick" = job.is_available(user.client) && !job.is_restricted(user.client.prefs))))
		if(LAZYLEN(jobs))
			LAZYADD(category["jobs"], jobs)

	/// Должности авеек

	if(SSmapping.submaps)
		for(var/datum/submap/submap in SSmapping.submaps)
			if(submap && submap.available())
				var/list/jobCategory = list(name = "[submap.name] ([submap.archetype.descriptor])", ref = "\ref[submap]", jobs = list(), color = "#ffffff")
				var/jobs = list()
				for(var/otherthing in submap.jobs)
					var/datum/job/job = submap.jobs[otherthing]
					LAZYADD(jobs, list(list("title" = job.title, "otherthing" = otherthing, "head" = job.head_position, "positions" = job.current_positions, "total" = job.total_positions, "active" = job.get_active_count(), "canpick" = job.is_available(user.client) && !job.is_restricted(user.client.prefs))))

				if(LAZYLEN(jobs))
					LAZYADD(jobCategory["jobs"], jobs)
				LAZYADD(otherJobs, list(jobCategory))

	data["jobs"] = mainJobs
	data["otherJobs"] = otherJobs
	if(evacuation_controller.has_evacuated())
		data["code"] = "\The [station_name()] has been evacuated."
	else if(evacuation_controller.is_evacuating())
		if(evacuation_controller.emergency_evacuation) // Emergency shuttle is past the point of no recall
			data["code"] = "\The [station_name()] is currently undergoing evacuation procedures."
		else                                           // Crew transfer initiated
			data["code"] = "\The [station_name()] is currently undergoing crew transfer procedures."

	data["duration"] = roundduration2text()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-joinpanel.tmpl", "Choose Profession", 950, 900, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/joinpanel/Topic(href, href_list, state)
	if(..())
		return TRUE
	if(istype(usr, /mob/new_player))
		var/mob/new_player/player = usr

		if(href_list["SelectedJob"])
			var/datum/job/job = SSjobs.get_by_title(href_list["SelectedJob"])

			if(!SSjobs.check_general_join_blockers(player, job))
				return FALSE

			var/datum/species/S = all_species[player.client.prefs.species]
			if(!player.check_species_allowed(S))
				return 0

			//[SIERRA-ADD] - XENO WHITELIST
			if(player.client.prefs.organ_data[BP_CHEST] == "cyborg")
				if(!whitelist_lookup(SPECIES_FBP, player.client.ckey) && player.client.prefs.species != SPECIES_IPC)
					to_chat(usr, "Нельзя зайти за ППТ без вайтлиста.")
					return FALSE
			//[/SIERRA-ADD]

			player.AttemptLateSpawn(job, player.client.prefs.spawnpoint)
			return TRUE

		if(href_list["join_as"])
			var/join_as = href_list["join_as"]
			var/datum/submap/submap = locate(href_list["submap"])
			if(submap.jobs[join_as])
				submap.join_as(player, submap.jobs[join_as])
				return TRUE
