/datum/technology/power
	name = "Basic Power"
	desc = "Basic Power"
	id = "basic_power"
	tech_type = RESEARCH_POWERSTORAGE

	x = 0.6
	y = 0.8
	icon = "cell"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list("basic_capacitor", "basic_cell", "device_cell_standard", "powermonitor", "pacman")

/datum/technology/power/adv_power
	name = "Advanced Power"
	desc = "Advanced Power"
	id = "adv_power"

	x = 0.6
	y = 0.6
	icon = "cell"

	required_technologies = list("basic_power")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("high_cell", "device_cell_high", "adv_capacitor")

/datum/technology/power/sup_power
	name = "Super Power"
	desc = "Super Power"
	id = "sup_power"

	x = 0.6
	y = 0.4
	icon = "cell"

	required_technologies = list("adv_power")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("super_cell", "super_capacitor","inducer")

/datum/technology/power/hyp_power
	name = "Hyper Power"
	desc = "Hyper Power"
	id = "hyp_power"

	x = 0.8
	y = 0.4
	icon = "cell"

	required_technologies = list("sup_power")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("hyper_cell")

/datum/technology/power/sol_power
	name = "Solar Power"
	desc = "Solar Power"
	id = "sol_power"

	x = 0.8
	y = 0.6
	icon = "solarcontrol"

	required_technologies = list("adv_power")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("solarcontrol")

/datum/technology/power/adv_power_gen
	name = "Advanced Power Generation"
	desc = "Advanced Power Generation"
	id = "adv_power_gen"

	x = 0.4
	y = 0.6
	icon = "generator"

	required_technologies = list("adv_power")
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list("superpacman","pacmanpotato")

/datum/technology/power/power_storage
	name = "Power Storage"
	desc = "Power Storage"
	id = "power_storage"

	x = 0.2
	y = 0.6
	icon = "batteryrack"

	required_technologies = list("adv_power_gen")
	required_tech_levels = list()
	cost = 1750

	unlocks_designs = list("batteryrack")

/datum/technology/power/adv_power_storage
	name = "Advanced Power Storage"
	desc = "Advanced Power Storage"
	id = "adv_power_storage"

	x = 0.2
	y = 0.5
	icon = "smes"

	required_technologies = list("power_storage")
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list("smes_cell", "smes_coil_standard", "smes_coil_super_capacity", "smes_coil_super_io")

/datum/technology/power/sup_power_gen
	name = "Super Power Generation"
	desc = "Super Power Generation"
	id = "sup_power_gen"

	x = 0.4
	y = 0.4
	icon = "generator"

	required_technologies = list("adv_power_gen","sup_power")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("mrspacman","pacmanreactor")

/datum/technology/power/fusion
	name = "R-UST Generator"
	desc = "R-UST Generator"
	id = "fusion"

	x = 0.2
	y = 0.4
	icon = "fusion"

	required_technologies = list("sup_power_gen")
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list("fusion_core_control", "fusion_fuel_compressor", "fusion_fuel_control", "gyrotron_control", "fusion_core", "fusion_injector", "fusion_kinetic_harvester")
