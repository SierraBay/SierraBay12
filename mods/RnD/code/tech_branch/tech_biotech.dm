/datum/technology/bio
	name = "Basic Biotech"
	desc = "Basic Biotech"
	id = "basic_biotech"
	tech_type = RESEARCH_BIOTECH

	x = 0.1
	y = 0.5
	icon = "healthanalyzer"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list("health_scanner", "slime_scanner","plant_scanner")

/datum/technology/bio/basic_medical_machines
	name = "Basic Medical Machines"
	desc = "Basic Medical Machines"
	id = "basic_medical_machines"


	x = 0.2
	y = 0.5
	icon = "operationcomputer"

	required_technologies = list()
	required_tech_levels = list()
	cost = 250

	unlocks_designs = list("operating", "crewconsole", "vitals", "optable" )

/datum/technology/bio/hydroponics
	name = "Hydroponics"
	desc = "Hydroponics"
	id = "hydroponics"


	x = 0.1
	y = 0.4
	icon = "hydroponics"

	required_technologies = list()
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("biogenerator", "hydrotray", "seed_extractor")

/datum/technology/bio/adv_hydroponics
	name = "Advanced Hydroponics"
	desc = "Advanced Hydroponics"
	id = "adv_hydroponics"


	x = 0.1
	y = 0.3
	icon = "gene"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1200

	unlocks_designs = list("flora_disk", "flora_gun", "honey_extractor")

/datum/technology/bio/food_process
	name = "Food Processing"
	desc = "Food Processing"
	id = "food_process"


	x = 0.2
	y = 0.4
	icon = "microwave"

	required_technologies = list()
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("cooker", "microwave",  "gibber", "replicator", "microlathe", "washer", "vending")

/datum/technology/bio/implants
	name = "Implants"
	desc = "Implants"
	id = "implants"


	x = 0.2
	y = 0.6
	icon = "implant"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("implanter", "implant_pad", "implant_chem", "implant_death", "implant_tracking","implant_imprinting")

/datum/technology/bio/adv_med_machines
	name = "Advanced Medical Machines"
	desc = "Advanced Medical Machines"
	id = "adv_med_machines"


	x = 0.3
	y = 0.5
	icon = "sleeper"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("cryo_cell", "sleeper", "bodyscanner", "bodyscannerconsole", "bodyscannerdisplay","reagent_grinder","chemheater", "reagsubl","noreactsyringe", "microscope", "dnaforensics")

/datum/technology/bio/add_med_tools
	name = "Additional Medical Tools"
	desc = "Additional Medical Tools"
	id = "add_med_tools"


	x = 0.4
	y = 0.5
	icon = "medhud"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("mass_spectrometer", "reagent_scanner", "health_hud", "defibrillators", "mmi", "autopsy_scanner")

/datum/technology/bio/adv_add_med_tools
	name = "Advanced Additional Medical Tools"
	desc = "Advanced Additional Medical Tools"
	id = "adv_add_med_tools"


	x = 0.6
	y = 0.5
	icon = "adv_mass_spec"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list( "adv_reagent_scanner", "adv_mass_spectrometer", "defibrillators_compact", "mmi_radio", "scalpel_laser" )

/datum/technology/bio/hypospray
	name = "Hypospray"
	desc = "Hypospray"
	id = "hypospray"


	x = 0.6
	y = 0.4
	icon = "hypo"

	required_technologies = list()
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("hypospray", "freezer", "cryobag", "chemsprayer" )

/datum/technology/bio/scalpelmanager
	name = "Incision Management System"
	desc = "Incision Management System"
	id = "scalpelmanager"


	x = 0.7
	y = 0.5
	icon = "scalpelmanager"

	required_technologies = list()
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("scalpel_ims")

/datum/technology/bio/beakers
	name = "Special Beakers"
	desc = "Special Beakers"
	id = "beakers"


	x = 0.6
	y = 0.6
	icon = "blue_beaker"

	required_technologies = list()
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("splitbeaker", "bluespacebeaker", "rapidsyringe","bluespacesyringe")

/datum/technology/bio/reagent_tools_zh
	name = "REAGENT TOOLS AND MACHINERY (Zeng Hu)"
	desc = "Reagent handling, analysis and processing equipment from Zeng Hu Pharmaceuticals. Complete laboratory machinery suite."
	id = "reagent_tools_zh"
	tech_type = RESEARCH_BIOTECH

	x = 0.1
	y = 0.5
	icon = "adv_mass_spec"

	required_corp_id = RND_MISSION_CORP_ZENG_HU
	min_reputation = 0
	required_tech_levels = list()
	cost = 1800

	unlocks_designs = list(
		"reagent_grinder",
		"reagsubl",
		"chemheater",
		"noreactsyringe",
		"reagent_scanner",
		"mass_spectrometer"
	)

/datum/technology/bio/adv_reagent_tools_zh
	name = "ADVANCED REAGENT TOOLS (Zeng Hu)"
	desc = "Advanced reagent analysis and containment systems from Zeng Hu Pharmaceuticals. Premium laboratory components and data modules."
	id = "adv_reagent_tools_zh"
	tech_type = RESEARCH_BIOTECH

	x = 0.2
	y = 0.5
	icon = "adv_mass_spec"

	required_corp_id = RND_MISSION_CORP_ZENG_HU
	min_reputation = 10
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"adv_mass_spectrometer",
		"adv_reagent_scanner",
		"scan_reagent",
		"bluespacebeaker",
		"splitbeaker"
	)

/datum/technology/bio/implant_injection_zh
	name = "IMPLANT INJECTION SYSTEMS (Zeng Hu)"
	desc = "Advanced surgical implant injection and diagnostic systems from Zeng Hu Pharmaceuticals. Complete implant suite including monitoring and control equipment."
	id = "implant_injection_zh"
	tech_type = RESEARCH_BIOTECH

	x = 0.3
	y = 0.5
	icon = "implant"

	required_corp_id = RND_MISSION_CORP_ZENG_HU
	min_reputation = 15
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"implanter",
		"implant_pad",
		"implant_death",
		"implant_chem",
		"implant_tracking",
		"implant_imprinting"
	)

/datum/technology/bio/adv_injection_zh
	name = "ADVANCED INJECTION SYSTEMS (Zeng Hu)"
	desc = "Advanced high-speed injection and chemical dispersal systems from Zeng Hu Pharmaceuticals. Cutting-edge delivery equipment."
	id = "adv_injection_zh"
	tech_type = RESEARCH_BIOTECH

	x = 0.4
	y = 0.5
	icon = "hypo"

	required_corp_id = RND_MISSION_CORP_ZENG_HU
	min_reputation = 20
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"hypospray",
		"rapidsyringe",
		"bluespacesyringe",
		"chemsprayer"
	)

/datum/technology/bio/basic_biotech_veymed
	name = "BASIC BIOTECH (VeyMed)"
	desc = "Basic biotech and medical diagnostic systems from VeyMed. Foundation for advanced medical equipment."
	id = "basic_biotech_veymed"
	tech_type = RESEARCH_BIOTECH

	x = 0.1
	y = 0.5
	icon = "healthanalyzer"

	required_corp_id = RND_MISSION_CORP_VEYMED
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"health_scanner",
		"crewconsole",
		"operating",
		"vitals",
		"optable"
	)

/datum/technology/bio/basic_medical_tools_veymed
	name = "BASIC MEDICAL TOOLS (VeyMed)"
	desc = "Advanced diagnostic and resuscitation systems from VeyMed. Critical care equipment suite."
	id = "basic_medical_tools_veymed"
	tech_type = RESEARCH_BIOTECH

	x = 0.2
	y = 0.5
	icon = "medhud"

	required_corp_id = RND_MISSION_CORP_VEYMED
	min_reputation = 5
	required_tech_levels = list()
	cost = 1800

	unlocks_designs = list(
		"defibrillators",
		"autopsy_scanner",
		"mmi"
	)

/datum/technology/bio/adv_biotech_veymed
	name = "ADVANCED BIOTECH MACHINERY (VeyMed)"
	desc = "Advanced cryogenic and analytical systems from VeyMed. Complete laboratory and life support equipment."
	id = "adv_biotech_veymed"
	tech_type = RESEARCH_BIOTECH

	x = 0.3
	y = 0.5
	icon = "sleeper"

	required_corp_id = RND_MISSION_CORP_VEYMED
	min_reputation = 10
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"sleeper",
		"cryo_cell",
		"bodyscanner",
		"bodyscannerconsole",
		"bodyscannerdisplay",
		"dnaforensics",
		"microscope"
	)

/datum/technology/bio/adv_medical_tools_veymed
	name = "ADVANCED MEDICAL TOOLS (VeyMed)"
	desc = "High-advanced portable medical and surgical systems from VeyMed. Premium resuscitation and intervention equipment."
	id = "adv_medical_tools_veymed"
	tech_type = RESEARCH_BIOTECH

	x = 0.4
	y = 0.5
	icon = "medhud"

	required_corp_id = RND_MISSION_CORP_VEYMED
	min_reputation = 15
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"defibrillators_compact",
		"mmi_radio",
		"freezer",
		"scalpel_laser",
		"scan_medical"
	)
