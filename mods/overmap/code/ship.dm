/obj/overmap/visitable/ship/get_scan_data(mob/user)
	. = list({"<b>Scan conducted at</b>: <br>[stationtime2text()] [stationdate2text()] <b>Grid coordinates</b>:<br> [x],[y]\n\n[scanner_desc]"})
	for(var/id in scans)
		var/datum/sector_scan/scan = scans[id]
		if (!scan.required_skill || user.skill_check(scan.required_skill, scan.required_skill_level))
			. += scan.description
		else if (scan.low_skill_description)
			. += scan.low_skill_description

	var/decl/ship_contact_class/class = contact_class
	. += "<br>Class: [class.class_long], mass [vessel_mass] tons."
	if(!is_still())
		. += "Heading: [get_heading_angle()], speed [get_speed() * 1000]"
	else
		. += {"\n\[i\]Vessel was stationary at time of scan.\[/i\]\n"}
	if(instant_contact)
		. += "<b>It is broadcasting a distress signal.</b>"
	//. += jointext(extra_data, "<br>")

	var/life = 0

	for(var/mob/living/L in GLOB.alive_mobs)
		if(L.z in map_z) //Things inside things we'll consider shielded, otherwise we'd want to use get_z(L)
			life++

	. += {"\[i\]Life Signs\[/i\]: [life ? life : "None"]"}