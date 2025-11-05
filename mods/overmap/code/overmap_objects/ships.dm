/obj/overmap/visitable/ship
	name = "spacecraft"
	var/class = "spacefaring vessel"
	var/decl/ship_contact_class/contact_class = /decl/ship_contact_class

/obj/overmap/visitable/ship/sierra
	contact_class = /decl/ship_contact_class/dagon

/obj/overmap/visitable/ship/sierra/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = bluentlogo.png></center></br><b>Property of NanoTrasen Corporation:</b>")
		iff.set_registration("NSV Sierra")
		iff.set_faction("NanoTrasen")
		iff.set_transponder("Transmitting (SCI), NanoTrasen")
		iff.set_notice("A space object with wide of 121.2 meters, length of 214.5 meters and high near 14.3 meters. A Self Indentification Signal classifices the target as NanoTrasen Science Vessel, a property of NanoTrasen Corporation.")
	return .

/obj/overmap/visitable/ship/landable/exploration_shuttle
	contact_class = /decl/ship_contact_class/nt_sshuttle

/obj/overmap/visitable/ship/landable/exploration_shuttle/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = bluentlogo.png></center></br><b>Property of NanoTrasen Corporation:</b>")
		iff.set_registration("NSS Charon")
		iff.set_faction("NanoTrasen")
		iff.set_transponder("Transmitting (CIV), non-hostile")
		iff.set_contact_class(/decl/ship_contact_class/nt_sshuttle)
		iff.set_notice("NanoTrasen Shuttle")
	return .

/obj/overmap/visitable/ship/landable/petrov
	contact_class = /decl/ship_contact_class/nt_sshuttle

/obj/overmap/visitable/ship/landable/petrov/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = bluentlogo.png></center></br><b>Property of NanoTrasen Corporation:</b>")
		iff.set_registration("NSS Petrov")
		iff.set_faction("NanoTrasen")
		iff.set_transponder("Transmitting (CIV), non-hostile")
		iff.set_contact_class(/decl/ship_contact_class/nt_sshuttle)
		iff.set_notice("NanoTrasen Shuttle")
	return .

/obj/overmap/visitable/ship/landable/guppy
	contact_class = /decl/ship_contact_class/nt_sshuttle

/obj/overmap/visitable/ship/landable/guppy/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = bluentlogo.png></center></br><b>Property of NanoTrasen Corporation:</b>")
		iff.set_registration("NSS Guppy")
		iff.set_faction("NanoTrasen")
		iff.set_transponder("Transmitting (CIV), non-hostile")
		iff.set_contact_class(/decl/ship_contact_class/nt_sshuttle)
		iff.set_notice("NanoTrasen Shuttle")
	return .

// Crucian is defined under maps/sierra; add IFF population here
/obj/overmap/visitable/ship/landable/crucian/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = bluentlogo.png></center></br><b>Property of NanoTrasen Corporation:</b>")
		iff.set_registration("NSS Crucian")
		iff.set_faction("NanoTrasen")
		iff.set_transponder("Transmitting (CIV), non-hostile")
		iff.set_contact_class(/decl/ship_contact_class/nt_sshuttle)
		iff.set_notice("NanoTrasen Shuttle")
	return .

/obj/overmap/visitable/ship/landable/merc
	contact_class = /decl/ship_contact_class/shuttle

/obj/overmap/visitable/ship/casino
	contact_class = /decl/ship_contact_class/ship

/obj/overmap/visitable/ship/errant_pisces


/obj/overmap/visitable/ship/scavver_gantry

/obj/overmap/visitable/ship/landable/vox_ship

/obj/overmap/visitable/ship/yacht
	contact_class = /decl/ship_contact_class/ship

/obj/overmap/visitable/ship/farfleet
	contact_class = /decl/ship_contact_class/gagarin

/obj/overmap/visitable/ship/landable/snz
	contact_class = /decl/ship_contact_class/destroyer_escort

/obj/overmap/visitable/ship/liberia
	contact_class = /decl/ship_contact_class/merchant

/obj/overmap/visitable/ship/landable/mule

/obj/overmap/visitable/ship/patrol
	contact_class = /decl/ship_contact_class/nagashino

/obj/overmap/visitable/ship/landable/reaper

// --- IFF initialization for guest/away ships present on Sierra and connected maps --- //

/obj/overmap/visitable/ship/casino/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("Passenger liner")
		iff.set_transponder("Transmitting (CIV), non-hostile")
		iff.set_contact_class(/decl/ship_contact_class/ship)
		iff.set_notice("Sensors detect an undamaged vessel without any signs of activity")
	return .

/obj/overmap/visitable/ship/errant_pisces/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("XCV Ahab's Harpoon")
		iff.set_transponder("Transmitting (CIV)")
		iff.set_contact_class(/decl/ship_contact_class/ship)
		iff.set_notice("Sensors detect civilian vessel with unusual signs of life aboard")
	return .

/obj/overmap/visitable/ship/scavver_gantry/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("UNKNOWN")
		iff.set_transponder("None Detected")
		iff.set_faction("Unknown")
		iff.set_contact_class(/decl/ship_contact_class/ship)
		iff.set_notice("Sensor array detects a medium-sized vessel of irregular shape. Vessel origin is unidentifiable")
	return .

/obj/overmap/visitable/ship/landable/vox_ship/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("UNKNOWN")
		iff.set_transponder("None Detected")
		iff.set_faction("Vox")
		iff.set_contact_class(/decl/ship_contact_class/ship)
		iff.set_notice("Sensor array detects a medium-sized vessel of irregular shape. Unknown origin")
	return .

/obj/overmap/visitable/ship/yacht/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("Aronai Sieyes")
		iff.set_transponder("None Detected")
		iff.set_contact_class(/decl/ship_contact_class/ship)
		iff.set_notice("Many lifeforms lifesigns detected")
	return .

/obj/overmap/visitable/ship/farfleet/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("ICCGN Farfleet Reconnaissance Craft")
		iff.set_transponder("Transmitting (MIL), ICCG")
		iff.set_faction("ICCG")
		iff.set_contact_class(/decl/ship_contact_class/gagarin)
		iff.set_notice("Warning! Slight traces of a cloaking device are present. This Craft has ICCGN Farfleet designation. Future scanning of ship internals blocked.")
	return .

/obj/overmap/visitable/ship/landable/snz/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("ICCGN Speedboat")
		iff.set_transponder("Transmitting (MIL), ICCG")
		iff.set_faction("ICCG")
		iff.set_contact_class(/decl/ship_contact_class/destroyer_escort)
		iff.set_notice("SNZ-350 Speedboat. Space and atmosphere assault craft. The standard mass military production model of the Shipyards of Novaya Zemlya.")
	return .

/obj/overmap/visitable/ship/liberia/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("FTU Liberia")
		iff.set_transponder("Transmitting (CIV), non-hostile")
		iff.set_faction("Free Trader Union")
		iff.set_contact_class(/decl/ship_contact_class/merchant)
		iff.set_notice("Independent trader vessel")
	return .

/obj/overmap/visitable/ship/landable/mule/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("PRIVATE")
		iff.set_transponder("Transmitting (CIV), non-hostile")
		iff.set_faction("Unknown")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("Small private vessel")
	return .

/obj/overmap/visitable/ship/patrol/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = FleetLogo.png></center><br>")
		iff.set_registration("SCGDF Multipurpose Patrol Craft")
		iff.set_transponder("Transmitting (MIL), SCG")
		iff.set_faction("SCG")
		iff.set_contact_class(/decl/ship_contact_class/nagashino)
		iff.set_notice("Nagashino-class Multipurpose Patrol Craft. Fine example of human fleet brilliant technologies with 5th Fleet designation and massive heat footprint.")
	return .

/obj/overmap/visitable/ship/landable/reaper/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = FleetLogo.png></center><br>")
		iff.set_registration("SCGDF Shuttle")
		iff.set_transponder("Transmitting (MIL), SCG")
		iff.set_faction("SCG")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("A heavily modified military gunboat of particular design. More of the dropship now, scanner detects heavy alteration to the hull of the vessel and no designation")
	return .

/obj/overmap/visitable/ship/landable/merc/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("UNKNOWN")
		iff.set_transponder("None Detected")
		iff.set_faction("Unknown")
		iff.set_contact_class(/decl/ship_contact_class/shuttle)
		iff.set_notice("Unregistered vessel")
	return .
