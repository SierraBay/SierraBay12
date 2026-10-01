// Generates a simple HTML crew manifest for use in various places.
// If host is set (computer / console running the app), only that vessel's crew is shown.
/proc/html_crew_manifest(monochrome, OOC, atom/host)
	var/list/dept_data = get_crew_manifest_departments(host)
	var/list/record_source = crew_records_for_host(host)
	var/obj/overmap/visitable/host_sector = get_overmap_sector_for_atom(host)
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
	// [SIERRA-ADD] // var for name_short_job_prefix
	var/list/mil_ranks_job_prefix = list()
	// [/SIERRA-ADD]
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;width:100%;}
		.manifest td, th {border:1px solid [monochrome?"black":"black; background-color:#272727; color:white"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #40628a; color:white"]}
		.manifest tr.head th { background-color: #013D3B; }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #373737; color:white"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Position</th>[OOC ? "" : "<th>Activity</th>"]</tr>
	"}
	// sort mobs
	for(var/datum/computer_file/report/crew_record/CR in record_source)
		var/status = CR.get_status()
		if (OOC && status == "Stored")
			continue
		var/name = CR.get_formal_name()
		var/rank = CR.get_job()
		mil_ranks[name] = ""

		if(GLOB.using_map.flags & MAP_HAS_RANK)
			var/datum/mil_branch/branch_obj = GLOB.mil_branches.get_branch(CR.get_branch())
			var/datum/mil_rank/rank_obj = GLOB.mil_branches.get_rank(CR.get_branch(), CR.get_rank())

			if(branch_obj && rank_obj)
				mil_ranks[name] = "<abbr title=\"[rank_obj.name], [branch_obj.name]\">[rank_obj.name_short]</abbr> "
				// [SIERRA-ADD] // Copies the value of the variable name_short_job_prefix from mil_ranks of CR
				mil_ranks_job_prefix[name] = rank_obj.name_short_job_prefix
				// [/SIERRA-ADD]

		isactive[name] = status

		if(flat_vessel_roster && vessel_crew)
			vessel_crew[name] = rank
			continue

		var/datum/job/job = SSjobs.get_by_title(rank)
		var/found_place = 0
		if(job)
			for(var/list/department in dept_data)
				var/list/names = department["names"]
				if(job.department_flag & department["flag"])
					names[name] = rank
					found_place = 1
		if(!found_place)
			misc[name] = rank

	// Synthetics don't have actual records, so we will pull them from here.
	for(var/mob/living/silicon/ai/ai in SSmobs.mob_list)
		if(!atom_on_host_vessel(ai, host))
			continue
		bot[ai.name] = "Artificial Intelligence"

	for(var/mob/living/silicon/robot/robot in SSmobs.mob_list)
		// No combat/syndicate cyborgs, no drones.
		if(robot.module && robot.module.hide_on_manifest)
			continue
		if(!atom_on_host_vessel(robot, host))
			continue

		bot[robot.name] = "[robot.modtype] [robot.braintype]"

	for(var/list/department in dept_data)
		var/list/names = department["names"]
		if(length(names) > 0)
			var/columns = OOC ? 2 : 3
			dat += "<tr><th colspan=[columns] style=background-color:[department["color"]]>[department["header"]]</th></tr>"
			for(var/name in names)
				var/status_cell = OOC ? "" : "<td>[isactive[name]]</td>"
				// [SIERRA-EDIT] If name_short_job_prefix of mil_rank is TRUE, place name_short before job name, not character
				if (!mil_ranks_job_prefix[name])
					dat += "<tr class='candystripe'><td>[mil_ranks[name]][name]</td><td>[names[name]]</td>[status_cell]</tr>"
				else
					dat += "<tr class='candystripe'><td>[name]</td><td>[mil_ranks[name]][names[name]]</td>[status_cell]</tr>"
				// [SIERRA-EDIT]

	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")
	return dat

/// Department sections used by HTML / nano crew manifests.
/// Away ships get a single crew section; BASE sectors keep Sierra-style departments.
/proc/get_crew_manifest_departments(atom/host)
	RETURN_TYPE(/list)
	var/obj/overmap/visitable/sector = get_overmap_sector_for_atom(host)
	if(sector && !HAS_FLAGS(sector.sector_flags, OVERMAP_SECTOR_BASE))
		return list(
			list("names" = list(), "header" = "[sector.name] Crew", "flag" = MSC, "color" = MANIFEST_COLOR_CIVILIAN),
			list("names" = list(), "header" = "Silicon", "color" = MANIFEST_COLOR_SILICON),
		)
	return list(
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

/proc/silicon_nano_crew_manifest(list/filter, atom/host)
	var/list/filtered_entries = list()

	for(var/mob/living/silicon/ai/ai in SSmobs.mob_list)
		if(!atom_on_host_vessel(ai, host))
			continue
		filtered_entries.Add(list(list(
			"name" = ai.name,
			"rank" = "Artificial Intelligence",
			"status" = ""
		)))
	for(var/mob/living/silicon/robot/robot in SSmobs.mob_list)
		if(robot.module && robot.module.hide_on_manifest)
			continue
		if(!atom_on_host_vessel(robot, host))
			continue
		filtered_entries.Add(list(list(
			"name" = robot.name,
			"rank" = "[robot.modtype] [robot.braintype]",
			"status" = ""
		)))
	return filtered_entries

/proc/filtered_nano_crew_manifest(list/filter, blacklist = FALSE, list/record_source)
	RETURN_TYPE(/list)
	var/list/filtered_entries = list()
	for(var/datum/computer_file/report/crew_record/CR in department_crew_manifest(filter, blacklist, record_source))
		if (CR.get_status() == "Stored")
			continue

		filtered_entries.Add(list(list(
			"name" = CR.get_name(),
			"rank" = CR.get_job(),
			"status" = CR.get_status(),
			"branch" = CR.get_branch(),
			"milrank" = CR.get_rank()
		)))
	return filtered_entries

/proc/nano_crew_manifest(atom/host)
	var/list/record_source = crew_records_for_host(host)
	var/obj/overmap/visitable/sector = get_overmap_sector_for_atom(host)
	if(sector && !HAS_FLAGS(sector.sector_flags, OVERMAP_SECTOR_BASE))
		return list(
			"heads" = list(),
			"spt" = list(),
			"sci" = list(),
			"sec" = list(),
			"eng" = list(),
			"med" = list(),
			"sup" = list(),
			"exp" = list(),
			"srv" = list(),
			"bot" = silicon_nano_crew_manifest(null, host),
			"civ" = filtered_nano_crew_manifest(null, TRUE, record_source)
		)
	return list(
		"heads" = filtered_nano_crew_manifest(SSjobs.titles_by_department(COM), FALSE, record_source),
		"spt" =   filtered_nano_crew_manifest(SSjobs.titles_by_department(SPT), FALSE, record_source),
		"sci" =   filtered_nano_crew_manifest(SSjobs.titles_by_department(SCI), FALSE, record_source),
		"sec" =   filtered_nano_crew_manifest(SSjobs.titles_by_department(SEC), FALSE, record_source),
		"eng" =   filtered_nano_crew_manifest(SSjobs.titles_by_department(ENG), FALSE, record_source),
		"med" =   filtered_nano_crew_manifest(SSjobs.titles_by_department(MED), FALSE, record_source),
		"sup" =   filtered_nano_crew_manifest(SSjobs.titles_by_department(SUP), FALSE, record_source),
		"exp" =   filtered_nano_crew_manifest(SSjobs.titles_by_department(EXP), FALSE, record_source),
		"srv" =   filtered_nano_crew_manifest(SSjobs.titles_by_department(SRV), FALSE, record_source),
		"bot" =   silicon_nano_crew_manifest(SSjobs.titles_by_department(MSC), host),
		"civ" =   filtered_nano_crew_manifest(SSjobs.titles_by_department(CIV), FALSE, record_source)
		)

/proc/flat_nano_crew_manifest(atom/host)
	RETURN_TYPE(/list)
	. = list()
	. += filtered_nano_crew_manifest(null, TRUE, crew_records_for_host(host))
	. += silicon_nano_crew_manifest(SSjobs.titles_by_department(MSC), host)
