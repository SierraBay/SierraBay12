// Attach an IFF transponder to ships and use it as the single source of scan truth

/obj/overmap/visitable/ship
	// Physical IFF device that stores scan-relevant data
	var/obj/machinery/overmap_iff/iff

/obj/overmap/visitable/ship/Initialize()
	. = ..()
	if(!iff)
		// Create and seed from existing ship vars for backward compatibility
		iff = new()
		iff.set_contact_class(contact_class)
		if(isnum(vessel_mass))
			iff.set_vessel_mass(vessel_mass)
		iff.set_scanner_desc(scanner_desc)
		iff.set_distress(instant_contact)
	return .

/obj/overmap/visitable/ship/get_scan_data(mob/user)
	// Header with time/date and coordinates; description comes from IFF if available
	. = list({"<b>Scan conducted at</b>: <br>[stationtime2text()] [stationdate2text()] <b>Grid coordinates</b>:<br> [x],[y]"})

	// Include sector scans with skill gating
	if(scans)
		for(var/id in scans)
			var/datum/sector_scan/scan = scans[id]
			if(!user || !scan.required_skill || user.skill_check(scan.required_skill, scan.required_skill_level))
				. += scan.description
			else if(scan.low_skill_description)
				. += scan.low_skill_description

	// Compose ship identity and kinematics from IFF when available; fallback to legacy
	if(iff && iff.broadcast_enabled)
		. += iff.get_scan_lines(user, src)
	else
		// Legacy scanner_desc displayed first for visual continuity
		if(scanner_desc && length(scanner_desc))
			. += scanner_desc
		var/decl/ship_contact_class/contact_decl = contact_class
		if(contact_decl)
			. += "<br>Class: [contact_decl.class_long], mass [vessel_mass] tons."
		if(is_moving())
			. += "Heading: [get_heading_angle()], speed [get_speed() * 1000]"
		else
			. += "\nVessel was stationary at time of scan.\n"
		if(instant_contact)
			. += "<b>It is broadcasting a distress signal.</b>"

	// Life signs summary (simple, potentially heavy on large populations)
	var/life = 0
	if(map_z)
		for(var/mob/living/L in GLOB.alive_mobs)
			if(L.z in map_z) // Things inside things we'll consider shielded
				life++
	. += {"Life Signs: [life ? life : "None"]"}