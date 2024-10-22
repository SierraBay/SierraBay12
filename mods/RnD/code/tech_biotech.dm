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

	required_technologies = list("basic_biotech")
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

	required_technologies = list("basic_biotech")
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

	required_technologies = list("hydroponics")
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

	required_technologies = list("hydroponics")
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

	required_technologies = list("basic_medical_machines")
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

	required_technologies = list("basic_medical_machines")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("cryo_cell", "sleeper", "bodyscanner", "bodyscannerconsole", "bodyscannerdisplay","reagent_grinder","chemheater", "reagsubl","noreactsyringe")

/datum/technology/bio/add_med_tools
	name = "Additional Medical Tools"
	desc = "Additional Medical Tools"
	id = "add_med_tools"

	x = 0.4
	y = 0.5
	icon = "medhud"

	required_technologies = list("adv_med_machines")
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

	required_technologies = list("add_med_tools")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list( "adv_reagent_scanner", "adv_mass_spectrometer", "defibrillators_compact", "mmi_radio", "scalpel_laser" )

/datum/technology/bio/hypospray
	name = "Hypospray"
	desc = "Hypospray"
	id = "hypospray"
	tech_type = RESEARCH_BIOTECH

	x = 0.6
	y = 0.4
	icon = "hypo"

	required_technologies = list("adv_add_med_tools")
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

	required_technologies = list("adv_add_med_tools")
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

	required_technologies = list("adv_add_med_tools")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("splitbeaker", "bluespacebeaker", "rapidsyringe","bluespacesyringe")
