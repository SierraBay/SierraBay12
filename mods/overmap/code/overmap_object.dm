/obj/overmap
	var/scanner_desc = ""

/obj/overmap/get_scan_data(mob/user)
	var/temp_data = list({"<b>Scan conducted at</b>: <br>[stationtime2text()] [stationdate2text()] <b>Grid coordinates</b>:<br> [x],[y]\n\n[scanner_desc]"})
	for(var/id in scans)
		var/datum/sector_scan/scan = scans[id]
		if (!scan.required_skill || user.skill_check(scan.required_skill, scan.required_skill_level))
			temp_data += scan.description
		else if (scan.low_skill_description)
			temp_data += scan.low_skill_description

	return temp_data