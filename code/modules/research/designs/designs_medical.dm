/datum/design/item/medical
	materials = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 20)
	category = list("Medical")

//[SIERRA-ADD] - MODPACK_RND
/datum/design/item/medical/health_scanner
	shortname = "Health Scanner"
	desc = "A hand-held scanner able to diagnose human health issues."
	id = "health_scanner"
	req_tech = list(TECH_MAGNET = 2, TECH_BIO = 3, TECH_ENGINEERING = 2)
	materials = list(MATERIAL_STEEL = 200, MATERIAL_GLASS = 100, MATERIAL_PLASTIC = 150)
	build_path = /obj/item/device/scanner/health
	sort_string = "MAABA"

/datum/design/item/medical/autopsy_scanner
	shortname = "Autopsy Scanner"
	desc = "Used to gather information on wounds."
	id = "autopsy_scanner"
	req_tech = list(TECH_MAGNET = 3, TECH_BIO = 4, TECH_ENGINEERING = 2)
	materials = list(MATERIAL_STEEL = 200, MATERIAL_GLASS = 200, MATERIAL_PLASTIC = 250)
	build_path = /obj/item/autopsy_scanner
	sort_string = "MAABB"
//[/SIERRA-ADD] - MODPACK_RND

/datum/design/item/medical/slime_scanner
	desc = "Multipurpose organic life scanner."
	id = "slime_scanner"
	req_tech = list(TECH_MAGNET = 2, TECH_BIO = 2)
	materials = list(MATERIAL_STEEL = 200, MATERIAL_GLASS = 100, MATERIAL_PLASTIC = 150)
	build_path = /obj/item/device/scanner/xenobio
	sort_string = "MACFA"

/datum/design/item/medical/robot_scanner
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "robot_scanner"
	req_tech = list(TECH_MAGNET = 3, TECH_BIO = 2, TECH_ENGINEERING = 3)
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200, MATERIAL_PLASTIC = 150)
	build_path = /obj/item/device/robotanalyzer
	sort_string = "MACFB"

/datum/design/item/medical/mass_spectrometer
	shortname = "Mass Spectrometer"
	desc = "A device for analyzing chemicals in blood."
	id = "mass_spectrometer"
	req_tech = list(TECH_BIO = 2, TECH_MAGNET = 2)
	build_path = /obj/item/device/scanner/spectrometer
	sort_string = "MACAA"

/datum/design/item/medical/adv_mass_spectrometer
	shortname = "Advanced Mass Spectrometer"
	desc = "A device for analyzing chemicals in blood and their quantities."
	id = "adv_mass_spectrometer"
	req_tech = list(TECH_BIO = 2, TECH_MAGNET = 4)
	build_path = /obj/item/device/scanner/spectrometer/adv
	sort_string = "MACAB"

/datum/design/item/medical/reagent_scanner
	desc = "A device for identifying chemicals."
	id = "reagent_scanner"
	req_tech = list(TECH_BIO = 2, TECH_MAGNET = 2)
	build_path = /obj/item/device/scanner/reagent
	sort_string = "MACBA"

/datum/design/item/medical/adv_reagent_scanner
	desc = "A device for identifying chemicals and their proportions."
	id = "adv_reagent_scanner"
	req_tech = list(TECH_BIO = 2, TECH_MAGNET = 4)
	build_path = /obj/item/device/scanner/reagent/adv
	sort_string = "MACBB"

/datum/design/item/medical/nanopaste
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	id = "nanopaste"
	req_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3)
	materials = list(MATERIAL_STEEL = 7000, MATERIAL_GLASS = 7000)
	build_path = /obj/item/stack/nanopaste
	sort_string = "MADAA"

/datum/design/item/medical/hypospray
	shortname = "Hypospray"
	desc = "A sterile, air-needle autoinjector for rapid administration of drugs."
	id = "hypospray"
	req_tech = list(TECH_MATERIAL = 4, TECH_BIO = 5)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_GLASS = 8000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/reagent_containers/hypospray/vial
	sort_string = "MAEAA"

/datum/design/item/weapon/storage/box/freezer
	name = "Portable Freezer"
	desc = "This nifty shock-resistant device will keep your 'groceries' nice and non-spoiled."
	id = "freezer"
	req_tech = list(TECH_MATERIAL = 3, TECH_POWER = 2)
	materials = list(MATERIAL_PLASTIC = 350)
	build_path = /obj/item/storage/box/freezer
	sort_string = "MAFAA"

/datum/design/item/medical/cryobag
	desc = "A folded, reusable bag designed to prevent additional damage to an occupant, especially useful if short on time or in \
	a hostile environment."
	id = "cryobag"
	req_tech = list(TECH_MATERIAL = 6, TECH_BIO = 6)
	materials = list(MATERIAL_PLASTIC = 15000, MATERIAL_GLASS = 15000, MATERIAL_SILVER = 5000, MATERIAL_GOLD = 1000)
	build_path = /obj/item/bodybag/cryobag
	sort_string = "MAGAA"

//[SIERRA-ADD] - MODPACK_RND
/datum/design/item/medical/defibrillator
	shortname = "Defibrillator"
	desc = "A portable device that can be used to perform a defibrillation procedure."
	id = "defibrillators"
	req_tech = list(TECH_MATERIAL = 2, TECH_BIO = 4)
	materials = list(MATERIAL_PLASTIC = 5000, MATERIAL_GLASS = 5000, MATERIAL_SILVER = 3000, MATERIAL_GOLD = 500)
	build_path = /obj/item/defibrillator
	sort_string = "MAGAB"


/datum/design/item/medical/defibrillators_compact
	shortname = "Compact Defibrillator"
	desc = "A portable device that can be used to perform a defibrillation procedure."
	id = "defibrillators_compact"
	req_tech = list(TECH_MATERIAL = 3, TECH_BIO = 4)
	materials = list(MATERIAL_PLASTIC = 3000, MATERIAL_GLASS = 3000, MATERIAL_SILVER = 5000, MATERIAL_GOLD = 1000)
	build_path = /obj/item/defibrillator/compact
	sort_string = "MAGAC"
//[/SIERRA-ADD] - MODPACK_RND
