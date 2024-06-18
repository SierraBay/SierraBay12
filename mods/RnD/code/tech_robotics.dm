/datum/technology/robo
	name = "Basic Robotech"
	desc = "Basic Robotech"
	id = "robo"
	tech_type = RESEARCH_MAGNETS

	x = 0.5
	y = 0.3
	icon = "modular_bat_advanced"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list()

/datum/technology/robo/basic_augments
	name = "Basic Augments"
	desc = "Basic Augments"
	id = "basic_augments"

	x = 0.4
	y = 0.4
	icon = "cpu_small"

	required_technologies = list("robo")
	required_tech_levels = list()
	cost = 250

	unlocks_designs = list()

/datum/technology/robo/basic_hardsuitmods
	name = "Basic Hardsuit Mods"
	desc = "Basic Hardsuit Mods"
	id = "basic_hardsuitmods"

	x = 0.5
	y = 0.4
	icon = "cpu"

	required_technologies = list("robo")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list()

/datum/technology/robo/basic_mech
	name = "Basic Mech Designs"
	desc = "Basic Mech Designs"
	id = "basic_mech"

	x = 0.6
	y = 0.4
	icon = "mech"

	required_technologies = list("robo")
	required_tech_levels = list()
	cost = 1200

	unlocks_designs = list()

/datum/technology/robo/adv_augments
	name = "Advanced Augments"
	desc = "Advanced Augments"
	id = "advanced_augments"

	x = 0.4
	y = 0.6
	icon = "pcpu_small"

	required_technologies = list("basic_augments")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list()

/datum/technology/robo/adv_hardsuits
	name = "Advanced Hardsuits Mods"
	desc = "Advanced Hardsuits Mods"
	id = "adv_hardsuits"

	x = 0.5
	y = 0.6
	icon = "pcpu"

	required_technologies = list("basic_hardsuitmods")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list()

/datum/technology/robo/adv_mechs
	name = "Advanced Mech Designs"
	desc = "Advanced Mech Designs"
	id = "adv_mechs"

	x = 0.6
	y = 0.6
	icon = "mechciv"

	required_technologies = list("basic_mech")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("cryo_cell", "sleeper", "bodyscanner", "bodyscannerdisplay","reagent_grinder","chemheater")

/datum/technology/robo/additional_mech_equipment
	name = "Additional Mech Equipment"
	desc = "Additional Mech Equipment"
	id = "dditional_mech_equipment"

	x = 0.7
	y = 0.4
	icon = "mechrcd"

	required_technologies = list("basic_mech")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list()

/datum/technology/robo/adv_mech_tools
	name = "Advanced Mech Tools"
	desc = "Advanced Mech Tools"
	id = "adv_mech_tools"

	x = 0.7
	y = 0.6
	icon = "mechweapon"

	required_technologies = list("adv_mechs")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list()

/datum/technology/robo/roboupgrade
	name = "Robots Upgrade"
	desc = "Robots Upgrade"
	id = "roboupgrade"

	x = 0.5
	y = 0.2
	icon = "aicircuit"

	required_technologies = list("robo")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list()

/datum/technology/robo/prothesis
	name = "Additional Prothesis Designs"
	desc = "Additional Prothesis Designs"
	id = "prothesis"

	x = 0.4
	y = 0.2
	icon = "circuit"

	required_technologies = list("robo")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list()
