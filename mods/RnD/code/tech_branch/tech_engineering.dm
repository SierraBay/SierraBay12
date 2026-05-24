// Engineering technology branch — corporate nodes only

// ========== NanoTrasen ==========

/datum/technology/engineering
	name = "Basic Engineering (NanoTrasen)"
	desc = "Basic engineering tools and components from NanoTrasen."
	id = "basic_engineering_nt"
	tech_type = RESEARCH_ENGINEERING

	x = 0.1
	y = 0.5
	icon = "wrench"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 0
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list(
		"micro_mani",
		"basic_matter_bin",
		"basic_micro_laser",
		"basic_capacitor",
		"basic_cell",
		"device_cell_standard"
	)

/datum/technology/engineering/research_tech_nt
	name = "Research Technologies (NanoTrasen)"
	desc = "Advanced research equipment and machinery from NanoTrasen."
	id = "research_tech_nt"

	x = 0.2
	y = 0.5
	icon = "rd"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 5
	cost = 750

	unlocks_designs = list(
		"destructive_analyzer",
		"protolathe",
		"circuit_imprinter",
		"rdservercontrol",
		"rdserver",
		"rdconsole",
		"robocontrol",
		"urm"
	)

/datum/technology/engineering/xenoarch_nt
	name = "Xenoarcheology (NanoTrasen)"
	desc = "Xenoarchaeological research equipment and anomaly detection systems."
	id = "xenoarch_nt"

	x = 0.3
	y = 0.5
	icon = "anom"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 10
	cost = 500

	unlocks_designs = list(
		"depth_scanner",
		"ano_scanner",
		"pick_set",
		"collector",
		"anomaly_detector",
		"electro_beacon"
	)

/datum/technology/engineering/excavation_drill_nt
	name = "Anomaly Research (NanoTrasen)"
	desc = "Anomaly research equipment and tools."
	id = "excavation_drill_nt"

	x = 0.4
	y = 0.5
	icon = "drill"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 15
	cost = 750

	unlocks_designs = list(
		"suspension_gen",
		"anomaly_container",
		"stasis cage",
		"xeno_drill"
	)

/datum/technology/engineering/doppler_array_nt
	name = "Doppler Array (NanoTrasen)"
	desc = "Advanced Doppler radar array system."
	id = "doppler_array_nt"

	x = 0.5
	y = 0.5
	icon = "doppler"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 20
	cost = 1000

	unlocks_designs = list(
		"doppler"
	)

// ========== Ward-Takahashi ==========

/datum/technology/engineering/basic_engineering_wt
	name = "Janitorial & Safety (Ward-Takahashi)"
	desc = "Janitorial equipment and safety systems."
	id = "basic_engineering_wt"

	x = 0.1
	y = 0.5
	icon = "wrench"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 0
	cost = 750

	unlocks_designs = list(
		"advmop",
		"janitor_hud",
		"holosign",
		"price_scanner"
	)

/datum/technology/engineering/advanced_tools_wt
	name = "Miscellaneous Boards (Ward-Takahashi)"
	desc = "Assorted electronics and control boards."
	id = "advanced_tools_wt"

	x = 0.2
	y = 0.5
	icon = "arcade"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 5
	cost = 500

	unlocks_designs = list(
		"arcademachine",
		"oriontrail",
		"securedoor",
		"holo",
		"guestpass",
		"washer",
		"vending"
	)

/datum/technology/engineering/modular_computer_frames_wt
	name = "Modular Computer Frames (Ward-Takahashi)"
	desc = "Modular computer frame construction blueprints."
	id = "modular_computer_frames_wt"

	x = 0.3
	y = 0.5
	icon = "tablet_frame"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 10
	cost = 1500

	unlocks_designs = list(
		"pda_frame",
		"tablet_frame",
		"laptop_frame",
		"telescreen_frame"
	)

// ========== Grayson ==========

/datum/technology/engineering/basic_engineering_grayson
	name = "Basic Production & Recycling (Grayson)"
	desc = "Basic production equipment and recycling systems."
	id = "basic_engineering_grayson"

	x = 0.1
	y = 0.5
	icon = "circuitautolathe"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 0
	cost = 1250

	unlocks_designs = list(
		"autolathe",
		"pile_ripper",
		"crusher",
		"recycler"
	)

/datum/technology/engineering/industrial_processing_grayson
	name = "Airlock Bracing (Grayson)"
	desc = "Airlock bracing and maintenance equipment."
	id = "industrial_processing_grayson"

	x = 0.2
	y = 0.5
	icon = "brace"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 5
	cost = 1500

	unlocks_designs = list(
		"brace",
		"bracejack"
	)

/datum/technology/engineering/basic_mining_grayson
	name = "Basic Mining & Excavation (Grayson)"
	desc = "Mining and excavation equipment."
	id = "basic_mining_grayson"

	x = 0.3
	y = 0.5
	icon = "pickaxe"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 10
	cost = 1000

	unlocks_designs = list(
		"floodlight",
		"mining drill brace",
		"mining drill head",
		"drill",
		"jackhammer",
		"mesons"
	)

/datum/technology/engineering/mining_production_grayson
	name = "Mining Production (Grayson)"
	desc = "Automated mining ore processing systems."
	id = "mining_production_grayson"

	x = 0.4
	y = 0.5
	icon = "smelter"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 15
	cost = 1000

	unlocks_designs = list(
		"mining_console",
		"mining_processor",
		"mining_unloader",
		"mining_stacker"
	)

/datum/technology/engineering/advanced_mining_grayson
	name = "Advanced Mining (Grayson)"
	desc = "Diamond mining tools and plasma cutting equipment."
	id = "advanced_mining_grayson"

	x = 0.5
	y = 0.5
	icon = "cutter"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 20
	cost = 1500

	unlocks_designs = list(
		"pick_diamond",
		"drill_diamond",
		"plasmacutter",
		"xeno_cutter",
		"mesons_material"
	)

// ========== Aether ==========

/datum/technology/engineering/basic_engineering_aether
	name = "Atmosphere Monitoring (Aether)"
	desc = "Atmospheric monitoring and control systems."
	id = "basic_engineering_aether"

	x = 0.1
	y = 0.5
	icon = "monitoring"

	required_corp_id = RND_MISSION_CORP_AETHER
	min_reputation = 0
	cost = 700

	unlocks_designs = list(
		"atmosalertconsole",
		"air_management",
		"atmos_control"
	)

/datum/technology/engineering/gas_systems_aether
	name = "Gas Heating & Cooling (Aether)"
	desc = "Gas heating and cooling systems."
	id = "gas_systems_aether"

	x = 0.2
	y = 0.5
	icon = "spaceheater"

	required_corp_id = RND_MISSION_CORP_AETHER
	min_reputation = 5
	cost = 500

	unlocks_designs = list(
		"gasheater",
		"gascooler",
		"sauna"
	)

/datum/technology/engineering/portable_atmos_aether
	name = "Portable Atmospherics (Aether)"
	desc = "Portable atmospheric equipment."
	id = "portable_atmos_aether"

	x = 0.3
	y = 0.5
	icon = "pump"

	required_corp_id = RND_MISSION_CORP_AETHER
	min_reputation = 10
	cost = 1000

	unlocks_designs = list(
		"portascrubberstat",
		"portascrubberhuge",
		"portapump",
		"portascrubber",
		"area_atmos"
	)

/datum/technology/engineering/jetpack_aether
	name = "Atmosphere Machinery (Aether)"
	desc = "Advanced atmospheric machinery and propulsion."
	id = "jetpack_aether"

	x = 0.4
	y = 0.5
	icon = "jetpack"

	required_corp_id = RND_MISSION_CORP_AETHER
	min_reputation = 15
	cost = 1500

	unlocks_designs = list(
		"pipe_dispenser",
		"pipe_disposal",
		"rpd",
		"stasis_clamp",
		"oxyregen",
		"cracer",
		"jetpack"
	)

// ========== Einstein ==========

/datum/technology/engineering/basic_engineering_einstein
	name = "Portable Power Generation (Einstein)"
	desc = "Portable power generation and monitoring systems."
	id = "basic_engineering_einstein"

	x = 0.1
	y = 0.5
	icon = "generator"

	required_corp_id = RND_MISSION_CORP_EINSTEIN
	min_reputation = 0
	cost = 2000

	unlocks_designs = list(
		"pacman",
		"superpacman",
		"powermonitor",
		"pacmanpotato"
	)

/datum/technology/engineering/super_power_generation_einstein
	name = "Super Power Generation (Einstein)"
	desc = "Advanced power generation systems."
	id = "super_power_generation_einstein"

	x = 0.2
	y = 0.5
	icon = "advgenerator"

	required_corp_id = RND_MISSION_CORP_EINSTEIN
	min_reputation = 5
	cost = 2500

	unlocks_designs = list(
		"mrspacman",
		"pacmanreactor"
	)

/datum/technology/engineering/experimental_power_generation_einstein
	name = "Experimental Power Generation (Einstein)"
	desc = "Experimental fusion power generation and control."
	id = "experimental_power_generation_einstein"

	x = 0.3
	y = 0.5
	icon = "fusion"

	required_corp_id = RND_MISSION_CORP_EINSTEIN
	min_reputation = 10
	cost = 3500

	unlocks_designs = list(
		"supermatter_control",
		"injector",
		"fusion_core_control",
		"fusion_fuel_compressor",
		"gyrotron_control",
		"gyrotron",
		"fusion_core",
		"fusion_injector",
		"fusion_kinetic_harvester"
	)

// ========== Xion ==========

/datum/technology/engineering/basic_engineering_xion
	name = "Advanced Parts (Xion)"
	desc = "Advanced stock parts and components."
	id = "basic_engineering_xion"

	x = 0.1
	y = 0.5
	icon = "advmatterbin"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 0
	cost = 1200

	unlocks_designs = list(
		"nano_mani",
		"adv_matter_bin",
		"high_micro_laser",
		"adv_sensor"
	)

/datum/technology/engineering/integrated_circuits_xion
	name = "Integrated Circuitry (Xion)"
	desc = "Integrated circuit printer systems."
	id = "integrated_circuits_xion"

	x = 0.2
	y = 0.5
	icon = "icprinter"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 5
	cost = 1500

	unlocks_designs = list(
		"icprinter"
	)

/datum/technology/engineering/ic_upgrade_xion
	name = "IC Design Upgrade (Xion)"
	desc = "Integrated circuit printer upgrade and cloning systems."
	id = "ic_upgrade_xion"

	x = 0.3
	y = 0.5
	icon = "icupgradv"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 10
	cost = 1500

	unlocks_designs = list(
		"icupgradv",
		"icupclo"
	)

/datum/technology/engineering/advanced_engineering_xion
	name = "Advanced Tools (Xion)"
	desc = "Advanced engineering tools and nanomaterial repair."
	id = "advanced_engineering_xion"

	x = 0.4
	y = 0.5
	icon = "rped"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 15
	cost = 2000

	unlocks_designs = list(
		"rped",
		"nanopaste",
		"arc_welder",
		"jaws_of_life",
		"power_drill",
		"experimental_welder",
		"hand_rcd",
		"multimeter"
	)

/datum/technology/engineering/super_parts_xion
	name = "Super Parts (Xion)"
	desc = "Next-generation ultra-precise components."
	id = "super_parts_xion"

	x = 0.5
	y = 0.5
	icon = "supermatterbin"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 20
	cost = 2500

	unlocks_designs = list(
		"pico_mani",
		"super_matter_bin",
		"ultra_micro_laser",
		"phasic_sensor"
	)

// ========== Slate Sisters ==========

/datum/technology/engineering/ship_equipment_slate
	name = "Ship Monitoring (Slate Sisters)"
	desc = "Ship monitoring and alert systems."
	id = "ship_equipment_slate"

	x = 0.1
	y = 0.5
	icon = "monitoring"

	required_corp_id = RND_MISSION_CORP_SLATE
	min_reputation = 0
	cost = 800

	unlocks_designs = list(
		"alerts",
		"shipmap"
	)

/datum/technology/engineering/ship_coordination_slate
	name = "Ship Coordination (Slate Sisters)"
	desc = "Ship coordination, sensors, and beacon systems."
	id = "ship_coordination_slate"

	x = 0.2
	y = 0.5
	icon = "communications"

	required_corp_id = RND_MISSION_CORP_SLATE
	min_reputation = 5
	cost = 1500

	unlocks_designs = list(
		"sensors",
		"radio_beacon",
		"drone_pad",
		"nav",
		"nav_tele",
		"shipsensors"
	)

/datum/technology/engineering/ship_control_slate
	name = "Ship Control (Slate Sisters)"
	desc = "Ship control, shuttle, and propulsion systems."
	id = "ship_control_slate"

	x = 0.3
	y = 0.5
	icon = "nav"

	required_corp_id = RND_MISSION_CORP_SLATE
	min_reputation = 10
	cost = 2000

	unlocks_designs = list(
		"shuttle",
		"shuttle_long",
		"helms",
		"thruster",
		"shipengine"
	)

/datum/technology/engineering/ion_thrusters_slate
	name = "Ion Thrusting Systems (Slate Sisters)"
	desc = "Advanced ion propulsion systems."
	id = "ion_thrusters_slate"

	x = 0.4
	y = 0.5
	icon = "nav"

	required_corp_id = RND_MISSION_CORP_SLATE
	min_reputation = 15
	cost = 2500

	unlocks_designs = list(
		"ionengine"
	)

/datum/technology/engineering/shield_systems_slate
	name = "Shield Systems (Slate Sisters)"
	desc = "Shield generator and diffuser systems."
	id = "shield_systems_slate"

	x = 0.5
	y = 0.5
	icon = "shieldgen"

	required_corp_id = RND_MISSION_CORP_SLATE
	min_reputation = 20
	cost = 3000

	unlocks_designs = list(
		"shield_generator",
		"shield_diffuser"
	)

// ========== Focal Point ==========

/datum/technology/engineering/advanced_power_solar_focal
	name = "Advanced Power & Solar (Focal Point)"
	desc = "Advanced power generation and solar control."
	id = "advanced_power_solar_focal"

	x = 0.1
	y = 0.5
	icon = "highcell"

	required_corp_id = RND_MISSION_CORP_FOCAL
	min_reputation = 0
	cost = 1500

	unlocks_designs = list(
		"high_cell",
		"device_cell_high",
		"adv_capacitor",
		"solarcontrol"
	)

/datum/technology/engineering/super_power_storage_focal
	name = "Super Power Storage (Focal Point)"
	desc = "Super capacity power storage systems."
	id = "super_power_storage_focal"

	x = 0.2
	y = 0.5
	icon = "batteryrack"

	required_corp_id = RND_MISSION_CORP_FOCAL
	min_reputation = 5
	cost = 2000

	unlocks_designs = list(
		"super_cell",
		"super_capacitor",
		"inducer",
		"batteryrack"
	)

/datum/technology/engineering/hyper_power_induction_focal
	name = "Hyper Power & Induction (Focal Point)"
	desc = "Hyper capacity power and induction systems."
	id = "hyper_power_induction_focal"

	x = 0.3
	y = 0.5
	icon = "hypercell"

	required_corp_id = RND_MISSION_CORP_FOCAL
	min_reputation = 10
	cost = 2500

	unlocks_designs = list(
		"hyper_cell"
	)

/datum/technology/engineering/advanced_storage_focal
	name = "Advanced Power Storage (Focal Point)"
	desc = "Advanced power storage and magnetic systems."
	id = "advanced_storage_focal"

	x = 0.4
	y = 0.5
	icon = "smes"

	required_corp_id = RND_MISSION_CORP_FOCAL
	min_reputation = 15
	cost = 3000

	unlocks_designs = list(
		"smes_cell",
		"smes_coil_standard",
		"smes_coil_super_capacity",
		"smes_coil_super_io",
		"rcon_console"
	)
