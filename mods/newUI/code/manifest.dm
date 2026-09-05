GLOBAL_TYPED_NEW(manifest_state, /datum/topic_state/manifest)

/datum/topic_state/manifest/can_use_topic(src_object, mob/user)
	return STATUS_INTERACTIVE

/datum/nano_module/manifest
	var/ooc = FALSE

/datum/nano_module/manifest/CanUseTopic(mob/user, datum/topic_state/state = GLOB.manifest_state)
	. = ..()

/datum/nano_module/manifest/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.manifest_state)
	var/data[0]
	var/atom/host_atom = nano_host()
	// OOC / lobby views are global; in-game views follow the host vessel.
	var/atom/scope_host = ooc ? null : host_atom

	var/list/dept_data = get_crew_manifest_departments(scope_host)
	var/list/record_source = crew_records_for_host(scope_host)
	var/obj/overmap/visitable/host_sector = get_overmap_sector_for_atom(scope_host)
	var/flat_vessel_roster = host_sector && !HAS_FLAGS(host_sector.sector_flags, OVERMAP_SECTOR_BASE)

	var/list/misc //Special departments for easier access
	var/list/bot
	var/list/vessel_crew
	for(var/list/department in dept_data)
		if(department["flag"] == MSC)
			misc = department["names"]
			if(flat_vessel_roster)
				vessel_crew = misc
		if(isnull(department["flag"]))
			bot = department["names"]

	var/list/isactive = new()
	var/list/mil_ranks = list() // HTML to prepend to name
	// sort mobs
	for(var/datum/computer_file/report/crew_record/CR in record_source)
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

		if(flat_vessel_roster && vessel_crew)
			vessel_crew[LIST_PRE_INC(vessel_crew)] = list("name" = name, "rank" = rank, "active" = isactive[name])
			continue

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
		if(!atom_on_host_vessel(ai, scope_host))
			continue
		bot[LIST_PRE_INC(bot)] = list("name" = ai.name, "rank" = "Artificial Intelligence", "active" = "Active")

	for(var/mob/living/silicon/robot/robot in SSmobs.mob_list)
		// No combat/syndicate cyborgs, no drones.
		if(robot.module && robot.module.hide_on_manifest)
			continue
		if(!atom_on_host_vessel(robot, scope_host))
			continue
		bot[LIST_PRE_INC(bot)] = list("name" = robot.name, "rank" = "[robot.modtype] [robot.braintype]", "active" = "Active")

	data["manifest"] = dept_data
	data["ooc"] = ooc

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-manifest.tmpl", "Crew Manifest", 370, 420, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/manifest/Topic(href, href_list, state)
	if(..())
		return TRUE
