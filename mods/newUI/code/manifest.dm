/datum/nano_module/manifest
	var/ooc = FALSE

/datum/nano_module/manifest/CanUseTopic(mob/user, datum/topic_state/state = GLOB.xeno_state)
	. = ..()

/datum/nano_module/manifest/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.xeno_state)
	var/data[0]

	var/list/dept_data = list(
		list("names" = list(), "header" = "Heads of Staff", "flag" = COM, "color" = MANIFEST_COLOR_COMMAND),
		list("names" = list(), "header" = "Command Support", "flag" = SPT, "color" = MANIFEST_COLOR_SUPPORT),
		list("names" = list(), "header" = "Research", "flag" = SCI, "color" = MANIFEST_COLOR_SCIENCE),
		list("names" = list(), "header" = "Security", "flag" = SEC, "color" = MANIFEST_COLOR_SECURITY),
		list("names" = list(), "header" = "Medical", "flag" = MED, "color" = MANIFEST_COLOR_MEDICAL),
		list("names" = list(), "header" = "Engineering", "flag" = ENG, "color" = MANIFEST_COLOR_ENGINEER),
		list("names" = list(), "header" = "Supply", "flag" = SUP, "color" = MANIFEST_COLOR_SUPPLY),
		list("names" = list(), "header" = "Exploration", "flag" = EXP, "color" = MANIFEST_COLOR_EXPLORER),
		list("names" = list(), "header" = "Service", "flag" = SRV, "color" = MANIFEST_COLOR_SERVICE),
		list("names" = list(), "header" = "Civilian", "flag" = CIV, "color" = MANIFEST_COLOR_CIVILIAN),
		list("names" = list(), "header" = "Miscellaneous", "flag" = MSC, "color" = MANIFEST_COLOR_MISC),
		list("names" = list(), "header" = "Silicon", "color" = MANIFEST_COLOR_SILICON),
	)

	var/list/misc //Special departments for easier access
	var/list/bot
	for(var/list/department in dept_data)
		if(department["flag"] == MSC)
			misc = department["names"]
		if(isnull(department["flag"]))
			bot = department["names"]

	var/list/isactive = new()
	var/list/mil_ranks = list() // HTML to prepend to name
	// sort mobs
	for(var/datum/computer_file/report/crew_record/CR in GLOB.all_crew_records)
		var/status = CR.get_status()
		if (status == "Stored")
			continue
		var/name = CR.get_formal_name()
		var/rank = CR.get_job()
		mil_ranks[name] = ""

		if(GLOB.using_map.flags & MAP_HAS_RANK)
			var/datum/mil_branch/branch_obj = GLOB.mil_branches.get_branch(CR.get_branch())
			var/datum/mil_rank/rank_obj = GLOB.mil_branches.get_rank(CR.get_branch(), CR.get_rank())

			if(branch_obj && rank_obj)
				mil_ranks[name] = "<abbr title=\"[rank_obj.name], [branch_obj.name]\">[rank_obj.name_short]</abbr> "

		isactive[name] = status

		var/datum/job/job = SSjobs.get_by_title(rank)
		var/found_place = 0
		if(job)
			for(var/list/department in dept_data)
				var/list/names = department["names"]
				if(job.department_flag & department["flag"])
					names[LIST_PRE_INC(names)] = list("name" = name, "rank" = rank, "active" = isactive[name])
					found_place = 1
		if(!found_place)
			misc[name] = rank

	// Synthetics don't have actual records, so we will pull them from here.
	for(var/mob/living/silicon/ai/ai in SSmobs.mob_list)
		bot[LIST_PRE_INC(bot)] = list("name" = ai.name, "rank" = "Artificial Intelligence", "active" = isactive[name])

	for(var/mob/living/silicon/robot/robot in SSmobs.mob_list)
		// No combat/syndicate cyborgs, no drones.
		if(robot.module && robot.module.hide_on_manifest)
			continue
		bot[LIST_PRE_INC(bot)] = list("name" = robot.name, "rank" = "[robot.modtype] [robot.braintype]", "active" = isactive[name])

	data["manifest"] = dept_data
	data["ooc"] = ooc

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-manifest.tmpl", "Crew Manifest", 350, 500, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/xenopanel/Topic(href, href_list, state)
	if(..())
		return TRUE
