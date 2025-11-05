// IFF Initialize overrides for ship types defined outside this modpack

// ICCGN Hound (event)
/obj/overmap/visitable/ship/landable/icgnv_hound/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("ICGNV Hound")
		iff.set_faction("ICCG")
		iff.set_transponder("Transmitting (MIL), ICCG")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("ICCG Navy small craft")
	return .

// Vox raider (antag)
/obj/overmap/visitable/ship/landable/vox_raider/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("UNKNOWN")
		iff.set_faction("Vox")
		iff.set_transponder("None Detected")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("Unidentified raider craft")
	return .

// Lost Truck (insidiae pack)
/obj/overmap/visitable/ship/lost_truck/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("Lost Truck")
		iff.set_faction("Unknown")
		iff.set_transponder("Transmitting (CIV)")
		iff.set_contact_class(/decl/ship_contact_class/ship)
		iff.set_notice("Derelict civilian craft")
	return .

// Utyug (insidiae pack, landable)
/obj/overmap/visitable/ship/landable/utyug/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<b>Property of Grayson Manufactories:</b><br>")
		iff.set_registration("[name]")
		iff.set_faction("Grayson Manufactories")
		iff.set_transponder("Transmitting (IND), Grayson Terra")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("A Self Indentification Signal classifices the target as Grayson Terra Small Shuttle")
	return .

// Normandite (insidiae pack)
/obj/overmap/visitable/ship/normandite/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<b>Property of Grayson Manufactories:</b><br>")
		iff.set_registration("[name]")
		iff.set_faction("Grayson Manufactories")
		iff.set_transponder("Transmitting (IND), Grayson Terra")
		iff.set_contact_class(/decl/ship_contact_class/normandite)
		iff.set_notice("A space object with wide of 79.5 meters, length of 72 meters and high near 12.7 meters. A Self Indentification Signal classifices the target as Grayson Terra Mining Station, a property of Grayson Manufactories.")
	return .

// SFV Arbiter (event)
/obj/overmap/visitable/ship/landable/sfv_arbiter/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("SFV Arbiter")
		iff.set_faction("Unknown")
		iff.set_transponder("Transmitting (MIL)")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("Military shuttle")
	return .

// Scavver Gantry variants
/obj/overmap/visitable/ship/landable/scavver_gantry/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("UNKNOWN")
		iff.set_faction("Unknown")
		iff.set_transponder("None Detected")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("Irregular scavenger craft")
	return .

/obj/overmap/visitable/ship/landable/scavver_gantry/two/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("UNKNOWN")
		iff.set_faction("Unknown")
		iff.set_transponder("None Detected")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("Irregular scavenger craft")
	return .

/obj/overmap/visitable/ship/landable/scavver_gantry/three/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("UNKNOWN")
		iff.set_faction("Unknown")
		iff.set_transponder("None Detected")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("Irregular scavenger craft")
	return .

// Vox scavenger shuttle
/obj/overmap/visitable/ship/landable/vox_scavshuttle/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("UNKNOWN")
		iff.set_faction("Vox")
		iff.set_transponder("None Detected")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("Scavenger shuttle")
	return .

// Verne (pack verne)
/obj/overmap/visitable/ship/landable/verne/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = sollogo.png></center><br>")
		iff.set_registration("SRV Verne-1 Venerable Catfish, SSE-U17 long range shuttle")
		iff.set_faction("Sol Central Government")
		iff.set_transponder("Transmitting (SCI), SCGRV")
		iff.set_contact_class(/decl/ship_contact_class/srv_shuttle)
		iff.set_notice("Research shuttle attached to SRV Verne")
	return .

/obj/overmap/visitable/ship/verne/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = sollogo.png></center><br>")
		iff.set_registration("Sol Research Vessel Verne")
		iff.set_faction("Sol Central Government")
		iff.set_transponder("Transmitting (SCI), SCGRV")
		iff.set_contact_class(/decl/ship_contact_class/srv)
		iff.set_notice("Sensor array detects a medium-sized research vessel. It is owned by Ceti Institute of Technology and registered as Sol Central Government ship.")
	return .

// Phobos (pack phobos)
/obj/overmap/visitable/ship/phobos/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("Phobos")
		iff.set_faction("Unknown")
		iff.set_transponder("Transmitting (CIV)")
		iff.set_contact_class(/decl/ship_contact_class/ship)
		iff.set_notice("Exploration vessel")
	return .

/obj/overmap/visitable/ship/landable/interseptor/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("Interceptor")
		iff.set_faction("Unknown")
		iff.set_transponder("Transmitting (MIL)")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("Light interceptor")
	return .

// Hand pack pod
/obj/overmap/visitable/ship/landable/pod_hand_one/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("HAND Pod One")
		iff.set_faction("Unknown")
		iff.set_transponder("Transmitting (CIV)")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("Small personnel pod")
	return .
