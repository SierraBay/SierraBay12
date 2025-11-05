// IFF profile datum: stores public identity and scan-facing metadata

/datum/iff_profile
	// Public identity
	var/registration = null
	var/faction = null
	var/transponder = null

	// Classification and physicals
	var/decl/ship_contact_class/contact_class = /decl/ship_contact_class
	var/vessel_mass = null // tons, optional override

	// Presentation
	var/header_image = null // HTML img tag or path for visual header
	var/notice = null
	var/scanner_desc = ""
	var/distress = FALSE
