// Biotech technology branch — corporate nodes only

// ========== Zeng Hu Pharmaceuticals ==========

/datum/technology/bio
	name = "Reagent Tools & Machinery (Zeng Hu)"
	desc = "Reagent handling, analysis and processing equipment."
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

// Virology

/datum/technology/bio/virology_zh
	name = "Pathogen Research Machinery (Zeng Hu)"
	desc = "Virus research and vaccine development machinery."
	id = "virology_zh"
	tech_type = RESEARCH_BIOTECH

	x = 0.1
	y = 0.6
	icon = "gene"

	required_corp_id = RND_MISSION_CORP_ZENG_HU
	min_reputation = 0
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"diseaseanalyser",
		"antibodyanalyser",
		"incubator",
		"isolator",
		"curefab",
		"iso_centrifuge",
		"isplicer"
	)

/datum/technology/bio/adv_reagent_tools_zh
	name = "Advanced Reagent Tools (Zeng Hu)"
	desc = "Advanced reagent analysis and containment systems."
	id = "adv_reagent_tools_zh"
	tech_type = RESEARCH_BIOTECH

	x = 0.2
	y = 0.5
	icon = "bsbeaker"

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
	name = "Implant Injection Systems (Zeng Hu)"
	desc = "Advanced surgical implant injection and diagnostic systems."
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
		"implant_imprinting",
		"psi_damp"
	)

/datum/technology/bio/adv_injection_zh
	name = "Advanced Injection Systems (Zeng Hu)"
	desc = "Advanced high-speed injection and chemical dispersal systems."
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

// ========== VeyMed ==========

/datum/technology/bio/basic_biotech_veymed
	name = "Basic Biotech (VeyMed)"
	desc = "Basic biotech and medical diagnostic systems."
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
		"slime_scanner",
		"crewconsole",
		"operating",
		"vitals",
		"optable"
	)

/datum/technology/bio/basic_medical_tools_veymed
	name = "Basic Medical Tools (VeyMed)"
	desc = "Advanced diagnostic and resuscitation systems."
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
		"mmi",
		"health_hud"
	)

/datum/technology/bio/adv_biotech_veymed
	name = "Advanced Biotech Machinery (VeyMed)"
	desc = "Advanced cryogenic and analytical systems."
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
	name = "Advanced Medical Tools (VeyMed)"
	desc = "High-end portable medical and surgical systems."
	id = "adv_medical_tools_veymed"
	tech_type = RESEARCH_BIOTECH

	x = 0.4
	y = 0.5
	icon = "cryobag"

	required_corp_id = RND_MISSION_CORP_VEYMED
	min_reputation = 15
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"defibrillators_compact",
		"mmi_radio",
		"freezer",
		"scalpel_laser",
		"scan_medical",
		"cryobag",
		"scalpel_ims"
	)

// ========== Ward-Takahashi (Biotech) ==========

/datum/technology/bio/hydroponics_wt_bio
	name = "Hydroponics (Ward-Takahashi)"
	desc = "Hydroponics systems and plant science equipment."
	id = "hydroponics_wt_bio"
	tech_type = RESEARCH_BIOTECH

	x = 0.1
	y = 0.5
	icon = "hydroponics"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 0
	required_tech_levels = list()
	cost = 800

	unlocks_designs = list(
		"biogenerator",
		"hydrotray",
		"seed_extractor",
		"plant_scanner"
	)

/datum/technology/bio/food_processing_wt_bio
	name = "Food Processing (Ward-Takahashi)"
	desc = "Food processing and kitchen appliances."
	id = "food_processing_wt_bio"
	tech_type = RESEARCH_BIOTECH

	x = 0.2
	y = 0.5
	icon = "microwave"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 5
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list(
		"cooker",
		"microwave",
		"gibber",
		"replicator",
		"microlathe"
	)

/datum/technology/bio/advanced_hydroponics_wt_bio
	name = "Advanced Hydroponics (Ward-Takahashi)"
	desc = "Advanced botanical research and genetic modification tools."
	id = "advanced_hydroponics_wt_bio"
	tech_type = RESEARCH_BIOTECH

	x = 0.3
	y = 0.5
	icon = "gene"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 10
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"flora_disk",
		"flora_gun",
		"honey_extractor",
		"scan_flora"
	)
