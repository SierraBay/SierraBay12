// Overmap IFF transponder as a physical device holding scan data

/obj/machinery/overmap_iff
	name = "IFF transponder"
	desc = "A transponder that broadcasts vessel identity and status."
	icon = 'icons/obj/machines/shipsensors.dmi' // placeholder visual; replace with custom sprite later
	icon_state = "sensors"
	anchored = TRUE
	density = FALSE
	interact_offline = TRUE

	// Profile storing identity and classification
	var/datum/iff_profile/profile

	// Optional: associated overmap ship when placed on a ship map
	var/obj/overmap/visitable/ship/host

	// Whether the transponder is currently broadcasting
	var/broadcast_enabled = TRUE

	// Ensure profile exists
	// (moved to fully-qualified procs below to avoid relative path warnings)

/obj/machinery/overmap_iff/Initialize()
	. = ..()
	// If placed on a ship map, try to bind to its overmap ship by z-layer
	if(!host && z)
		for(var/obj/overmap/visitable/ship/S in world)
			if(S.map_z && (z in S.map_z))
				host = S
				break

	// Seed profile from host ship if available and fields are missing
	seed_from_host(FALSE)

/obj/machinery/overmap_iff/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/overmap_iff/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = list()
	var/datum/iff_profile/P = ensure_profile()
	
	data["broadcast_enabled"] = broadcast_enabled
	data["registration"] = P.registration
	data["faction"] = P.faction
	data["transponder"] = P.transponder
	data["notice"] = P.notice
	data["scanner_desc"] = P.scanner_desc
	data["distress"] = P.distress
	data["vessel_mass"] = P.vessel_mass
	data["header_image"] = P.header_image
	
	var/decl/ship_contact_class/cls = P.contact_class
	data["contact_class"] = cls ? cls.class_long : "Unknown"

	// Host binding info (read-only)
	if(host)
		data["host_name"] = "[host.name]"
		data["host_coords"] = "[host.x],[host.y]"
	else
		data["host_name"] = "None"
		data["host_coords"] = ""

	// Build a read-only preview of scan output
	var/list/preview_lines = get_scan_lines(user, host)
	var/preview_text = ""
	for(var/L in preview_lines)
		preview_text += "[L]\n"
	data["scan_preview"] = preview_text

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "overmap_iff.tmpl", "IFF Transponder Control", 600, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/machinery/overmap_iff/Topic(href, href_list)
	if(..())
		return TOPIC_HANDLED

	// Allow syncing from host (read action with controlled writes)
	if(href_list["sync_from_host_fill"]) // fill only missing fields
		seed_from_host(FALSE)
		return TOPIC_REFRESH
	if(href_list["sync_from_host_overwrite"]) // overwrite all fields from host
		seed_from_host(TRUE)
		return TOPIC_REFRESH

    // Editing is restricted: only scanner description can be changed by users.

	// Ignore attempts to toggle broadcast/distress or edit other fields
	if(href_list["toggle_broadcast"] || href_list["toggle_distress"] || href_list["edit_registration"] || href_list["edit_faction"] || href_list["edit_transponder"] || href_list["edit_notice"] || href_list["edit_vessel_mass"] || href_list["edit_header_image"]) 
		return TOPIC_NOACTION

	// Allow editing of scanner description only
	if(href_list["edit_scanner_desc"])
		var/new_val = input(usr, "Enter scanner description:", "Scanner Description", profile?.scanner_desc) as message|null
		if(new_val && CanInteract(usr, DefaultTopicState()))
			set_scanner_desc(new_val)
		return TOPIC_REFRESH

	// Compose additional scan lines coming from this IFF for a given ship host
/obj/machinery/overmap_iff/proc/get_scan_lines(mob/user, obj/overmap/visitable/ship/host)
	var/list/L = list()
	var/datum/iff_profile/P = ensure_profile()

	// Header image if present
	if(P.header_image && length(P.header_image))
		L += P.header_image

	// Class and mass
	var/decl/ship_contact_class/cls = P.contact_class
	if(cls)
		var/mass_to_show = isnull(P.vessel_mass) && host ? host.vessel_mass : P.vessel_mass
		var/line = "<br>Class: [cls.class_long]"
		if(mass_to_show)
			line += ", mass [mass_to_show] tons."
		L += line

	// Kinematics (from host)
	if(host)
		if(host.is_moving())
			L += "Heading: [host.get_heading_angle()], speed [host.get_speed() * 1000]"
		else
			L += "Vessel was stationary at time of scan."

	// Distress state
	if(P.distress)
		L += "<b>It is broadcasting a distress signal.</b>"

	// Prefer concise notice if present; otherwise fall back to rich description
	if(P.notice && length(P.notice))
		L += "Notice: [P.notice]"
	else if(P.scanner_desc && length(P.scanner_desc))
		L += P.scanner_desc

	// Basic identity lines if present
	if(P.registration)
		L += "Registration: [P.registration]"
	if(P.transponder)
		L += "Transponder: [P.transponder]"
	if(P.faction)
		L += "Affiliation: [P.faction]"

	return L

// Fully-qualified procs to avoid language server warnings about relative paths
/obj/machinery/overmap_iff/proc/ensure_profile()
	if(!src.profile)
		src.profile = new
	return src.profile

/obj/machinery/overmap_iff/proc/set_registration(val)
	var/datum/iff_profile/P = ensure_profile()
	P.registration = val

/obj/machinery/overmap_iff/proc/set_faction(val)
	var/datum/iff_profile/P = ensure_profile()
	P.faction = val

/obj/machinery/overmap_iff/proc/set_transponder(val)
	var/datum/iff_profile/P = ensure_profile()
	P.transponder = val

/obj/machinery/overmap_iff/proc/set_contact_class(val)
	var/datum/iff_profile/P = ensure_profile()
	P.contact_class = val

/obj/machinery/overmap_iff/proc/set_vessel_mass(val)
	var/datum/iff_profile/P = ensure_profile()
	P.vessel_mass = val

/obj/machinery/overmap_iff/proc/set_header_image(val)
	var/datum/iff_profile/P = ensure_profile()
	P.header_image = val

/obj/machinery/overmap_iff/proc/set_notice(val)
	var/datum/iff_profile/P = ensure_profile()
	P.notice = val

/obj/machinery/overmap_iff/proc/set_scanner_desc(val)
	var/datum/iff_profile/P = ensure_profile()
	P.scanner_desc = val

/obj/machinery/overmap_iff/proc/set_distress(val)
	var/datum/iff_profile/P = ensure_profile()
	P.distress = val

// Copy data from bound host into profile
/obj/machinery/overmap_iff/proc/seed_from_host(overwrite = FALSE)
	var/datum/iff_profile/P = ensure_profile()
	if(!host)
		return
	if(overwrite || !P.contact_class)
		if(host.contact_class)
			set_contact_class(host.contact_class)
	if(overwrite || isnull(P.vessel_mass))
		if(isnum(host.vessel_mass))
			set_vessel_mass(host.vessel_mass)
	if(overwrite || !P.scanner_desc)
		if(host.scanner_desc)
			set_scanner_desc(host.scanner_desc)
	if(overwrite || isnull(P.distress))
		set_distress(host.instant_contact)
	if(overwrite || !P.registration)
		set_registration("[host.name]")
