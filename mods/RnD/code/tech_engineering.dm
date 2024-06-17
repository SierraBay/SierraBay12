/datum/technology/engineering
	name = "Basic Engineering"
	desc = "Basic"
	id = "basic_engineering"
	tech_type = RESEARCH_ENGINEERING

	x = 0.1
	y = 0.5
	icon = "wrench"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list("science_tool", "micro_mani", "basic_matter_bin", "basic_micro_laser", "light_replacer", "autolathe", "arcademachine", "oriontrail")

/datum/technology/engineering/gas_heat
	name = "Gas Heating and Cooling"
	desc = "Gas Heating and Cooling"
	id = "gas_heat"

	x = 0.2
	y = 0.6
	icon = "spaceheater"

	required_technologies = list("monitoring")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("gasheater", "gascooler", "stasis_clamp")

/datum/technology/engineering/adv_parts
	name = "Advanced Parts"
	desc = "Advanced Parts"
	id = "adv_parts"

	x = 0.2
	y = 0.4
	icon = "advmatterbin"

	required_technologies = list("monitoring")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("nano_mani", "adv_matter_bin", "high_micro_laser", "adv_sensor")

/datum/technology/engineering/super_parts
	name = "Super Parts"
	desc = "Super Parts"
	id = "super_parts"

	x = 0.6
	y = 0.5
	icon = "supermatterbin"

	required_technologies = list("adv_eng")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("pico_mani", "super_matter_bin", "ultra_micro_laser", "phasic_sensor")

/datum/technology/engineering/monitoring
	name = "Monitoring"
	desc = "Monitoring"
	id = "monitoring"

	x = 0.2
	y = 0.5
	icon = "monitoring"

	required_technologies = list("basic_engineering")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("atmosalerts", "air_management","oxycandle")

/datum/technology/engineering/res_tech
	name = "Research Technologies"
	desc = "Research Technologies"
	id = "res_tech"

	x = 0.3
	y = 0.5
	icon = "rd"

	required_technologies = list("monitoring")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("destructive_analyzer", "protolathe", "circuit_imprinter", "rdservercontrol", "rdserver", "rdconsole")

/datum/technology/engineering/xenoarch
	name = "Xenoarcheology"
	desc = "Xenoarcheology"
	id = "xenoarch"

	x = 0.3
	y = 0.6
	icon = "anom"

	required_technologies = list("res_tech")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("depth_scanner", "ano_scanner", "pick_set")

/datum/technology/engineering/excavation_drill
	name = "Excavation Drill"
	desc = "Excavation Drill"
	id = "excavation_drill"

	x = 0.6
	y = 0.6
	icon = "drill"

	required_technologies = list("xenoarch")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("xeno_drill")

/datum/technology/engineering/excavation_drill_diamond
	name = "Diamond Excavation Drill"
	desc = "Diamond Excavation Drill"
	id = "excavation_drill_diamond"

	x = 0.6
	y = 0.7
	icon = "diamond_drill"

	required_technologies = list("excavation_drill")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("xeno_cutter")

/datum/technology/engineering/basic_mining
	name = "Basic Mining"
	desc = "Basic Mining"
	id = "basic_mining"

	x = 0.3
	y = 0.4
	icon = "pickaxe"

	required_technologies = list("res_tech")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("drill", "jackhammer")

/datum/technology/engineering/adv_mining
	name = "Advanced Mining"
	desc = "Advanced Mining"
	id = "adv_mining"

	x = 0.6
	y = 0.4
	icon = "cutter"

	required_technologies = list("basic_mining")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("pick_diamond", "drill_diamond", "plasmacutter")

/datum/technology/engineering/mining_drill
	name = "Mining Drill"
	desc = "Mining Drill"
	id = "mining_ammo"

	x = 0.6
	y = 0.3
	icon = "drillhead"

	required_technologies = list("adv_mining")
	required_tech_levels = list()
	cost = 4000

	unlocks_designs = list("mining drill head", "mining drill brace")

/datum/technology/engineering/adv_eng
	name = "Advanced Engineering"
	desc = "Advanced Engineering"
	id = "adv_eng"

	x = 0.7
	y = 0.5
	icon = "rped"

	required_technologies = list("adv_mining", "excavation_drill")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("rped", "mesons", "mesons_material", "nanopaste")

/datum/technology/engineering/adv_tools
	name = "Advanced Tools"
	desc = "Advanced Tools"
	id = "adv_tools"

	x = 0.8
	y = 0.5
	icon = "jawsoflife"

	required_technologies = list("adv_eng")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("arc_welder", "power_drill", "jaws_of_life", "experimental_welder", "price_scanner")

/datum/technology/engineering/airlock_brace
	name = "Airlock Brace"
	desc = "Airlock Brace"
	id = "airlock_brace"

	x = 0.4
	y = 0.5
	icon = "brace"

	required_technologies = list("res_tech")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("brace", "bracejack")

/datum/technology/engineering/icprinter
	name = "Integrated Circuit Printer"
	desc = "Integrated Circuit Printer"
	id = "icprinter"

	x = 0.7
	y = 0.3
	icon = "icprinter"

	required_technologies = list("adv_eng")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("icprinter")

/datum/technology/engineering/icupgradv
	name = "Integrated Circuit Printer Upgrade Disk"
	desc = "Integrated Circuit Printer Upgrade Disk"
	id = "icupgradv"

	x = 0.7
	y = 0.2
	icon = "icupgradv"

	required_technologies = list("icprinter")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("icprinter")

/datum/technology/engineering/icupclo
	name = "Integrated Circuit Printer Clone Disk"
	desc = "Integrated Circuit Printer Clone Disk"
	id = "icupclo"

	x = 0.8
	y = 0.3
	icon = "icupclo"

	required_technologies = list("icprinter")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("icupclo")
