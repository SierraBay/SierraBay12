/datum/technology/engineering
	name = "Basic Engineering (NanoTrasen)"
	desc = "Basic engineering tools and components from NanoTrasen. Foundation of all further research."
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
		"science_tool",
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
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.5
	icon = "rd"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 5
	required_tech_levels = list()
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
	desc = "Xenoarchaeological research equipment and anomaly detection systems from NanoTrasen."
	id = "xenoarch_nt"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.5
	icon = "anom"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 10
	required_tech_levels = list()
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
	desc = "Anomaly research equipment and tools from NanoTrasen."
	id = "excavation_drill_nt"
	tech_type = RESEARCH_ENGINEERING

	x = 0.4
	y = 0.5
	icon = "anom"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 15
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list(
		"suspension_gen",
		"anomaly_container",
		"stasis cage"
	)


/datum/technology/engineering/doppler_array_nt
	name = "Doppler Array (NanoTrasen)"
	desc = "Advanced Doppler radar array system from NanoTrasen."
	id = "doppler_array_nt"
	tech_type = RESEARCH_ENGINEERING

	x = 0.5
	y = 0.5
	icon = "doppler"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 20
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list(
		"doppler"
	)

/datum/technology/engineering/basic_engineering_wt
	name = "JANITORIAL DESIGNS (Ward-Takahashi)"
	desc = "Janitorial equipment and safety systems from Ward-Takahashi GMB."
	id = "basic_engineering_wt"
	tech_type = RESEARCH_ENGINEERING
	x = 0.1
	y = 0.5
	icon = "wrench"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 0
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list(
		"advmop",
		"janitor_hud",
		"holosign"
	)

/datum/technology/engineering/advanced_tools_wt
	name = "MISCELLANEOUS BOARDS (Ward-Takahashi)"
	desc = "Assorted electronics and control boards from Ward-Takahashi GMB."
	id = "advanced_tools_wt"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.5
	icon = "holosign"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 5
	required_tech_levels = list()
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

/datum/technology/engineering/hydroponics_and_kitchen_wt
	name = "HYDROPONICS AND KITCHEN APPLIANCE (Ward-Takahashi)"
	desc = "Hydroponics systems and culinary equipment from Ward-Takahashi GMB. Agricultural and food preparation technology for stations and vessels."
	id = "hydroponics_and_kitchen_wt"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.5
	icon = "biogen"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 15
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"biogenerator",
		"plant_scanner",
		"flora_disk",
		"seed_extractor",
		"hydrotray",
		"microwave",
		"cooker",
		"gibber",
		"honey_extractor"
	)

/datum/technology/engineering/modular_computer_frames_wt
	name = "MODULAR COMPUTER FRAMES (Ward-Takahashi)"
	desc = "Modular computer frame construction blueprints from Ward-Takahashi GMB. Comprehensive range of computer chassis for various applications."
	id = "modular_computer_frames_wt"
	tech_type = RESEARCH_ENGINEERING

	x = 0.4
	y = 0.5
	icon = "console"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 10
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"pda_frame",
		"tablet_frame",
		"laptop_frame",
		"telescreen_frame"
	)

/datum/technology/engineering/basic_engineering_grayson
	name = "Basic Production and Recycling (Grayson)"
	desc = "Basic production equipment and recycling systems from Grayson Manufactories."
	id = "basic_engineering_grayson"
	tech_type = RESEARCH_ENGINEERING

	x = 0.1
	y = 0.5
	icon = "autolathe"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 0
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list(
		"autolathe",
		"pile_ripper",
		"crusher",
		"recycler"
	)

/datum/technology/engineering/industrial_processing_grayson
	name = "Airlock Bracing (Grayson)"
	desc = "Airlock bracing and maintenance equipment from Grayson Manufactories."
	id = "industrial_processing_grayson"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.5
	icon = "brace"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 5
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"brace",
		"bracejack"
	)

/datum/technology/engineering/basic_mining_grayson
	name = "Basic Mining and Excavation (Grayson)"
	desc = "Mining and excavation equipment from Grayson Manufactories."
	id = "basic_mining_grayson"
	tech_type = RESEARCH_ENGINEERING
	x = 0.3
	y = 0.5
	icon = "pickaxe"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 10
	required_tech_levels = list()
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
	desc = "Automated mining ore processing systems from Grayson Manufactories."
	id = "mining_production_grayson"
	tech_type = RESEARCH_ENGINEERING
	x = 0.4
	y = 0.5
	icon = "smelter"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 15
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list(
		"mining_console",
		"mining_processor",
		"mining_unloader",
		"mining_stacker"
	)

/datum/technology/engineering/advanced_mining_grayson
	name = "Advanced Mining and Excavation (Grayson)"
	desc = "High-grade diamond mining tools, plasma cutting and excavation equipment from Grayson Manufactories."
	id = "advanced_mining_grayson"
	tech_type = RESEARCH_ENGINEERING
	x = 0.5
	y = 0.5
	icon = "cutter"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 20
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"pick_diamond",
		"drill_diamond",
		"plasmacutter",
		"xeno_cutter"
	)

/datum/technology/engineering/basic_engineering_aether
	name = "Atmosphere Monitoring (Aether)"
	desc = "Atmospheric monitoring and control systems from Aether Atmospherics."
	id = "basic_engineering_aether"
	tech_type = RESEARCH_ENGINEERING
	x = 0.1
	y = 0.5
	icon = "monitoring"

	required_corp_id = RND_MISSION_CORP_AETHER
	min_reputation = 0
	required_tech_levels = list()
	cost = 700

	unlocks_designs = list(
		"atmosalertconsole",
		"air_management",
		"atmos_control"
	)

/datum/technology/engineering/gas_systems_aether
	name = "Gas Heating and Cooling (Aether)"
	desc = "Gas heating and cooling systems from Aether Atmospherics."
	id = "gas_systems_aether"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.5
	icon = "spaceheater"

	required_corp_id = RND_MISSION_CORP_AETHER
	min_reputation = 5
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list(
		"gasheater",
		"gascooler",
		"sauna"
	)

/datum/technology/engineering/portable_atmos_aether
	name = "Gas Portable (Aether)"
	desc = "Portable atmospheric equipment from Aether Atmospherics."
	id = "portable_atmos_aether"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.5
	icon = "pump"

	required_corp_id = RND_MISSION_CORP_AETHER
	min_reputation = 10
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list(
		"portascrubberstat",
		"portascrubberhuge",
		"portapump",
		"portascrubber",
		"area_atmos"
	)

/datum/technology/engineering/jetpack_aether
	name = "Atmosphere Machinery and Equipment (Aether)"
	desc = "Advanced atmospheric machinery, piping systems and propulsion equipment from Aether Atmospherics."
	id = "jetpack_aether"
	tech_type = RESEARCH_ENGINEERING

	x = 0.4
	y = 0.5
	icon = "jetpack"

	required_corp_id = RND_MISSION_CORP_AETHER
	min_reputation = 15
	required_tech_levels = list()
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

/datum/technology/engineering/basic_engineering_einstein
	name = "PORTABLE POWER GENERATION (Einstein)"
	desc = "Portable power generation and monitoring systems from Einstein Engines."
	id = "basic_engineering_einstein"
	tech_type = RESEARCH_ENGINEERING

	x = 0.1
	y = 0.5
	icon = "monitoring"

	required_corp_id = RND_MISSION_CORP_EINSTEIN
	min_reputation = 0
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"pacman",
		"superpacman",
		"powermonitor",
		"pacmanpotato"
	)

/datum/technology/engineering/super_power_generation_einstein
	name = "SUPER POWER GENERATION (Einstein)"
	desc = "Advanced power generation systems from Einstein Engines."
	id = "super_power_generation_einstein"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.5
	icon = "supermatterbin"

	required_corp_id = RND_MISSION_CORP_EINSTEIN
	min_reputation = 5
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"mrspacman",
		"pacmanreactor"
	)

/datum/technology/engineering/experimental_power_generation_einstein
	name = "EXPERIMENTAL POWER GENERATION (Einstein)"
	desc = "Experimental fusion power generation and control systems from Einstein Engines."
	id = "experimental_power_generation_einstein"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.5
	icon = "anom"

	required_corp_id = RND_MISSION_CORP_EINSTEIN
	min_reputation = 10
	required_tech_levels = list()
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

/datum/technology/engineering/basic_engineering_xion
	name = "ADVANCED PARTS (Xion)"
	desc = "Advanced stock parts and components from Xion Industrial."
	id = "basic_engineering_xion"
	tech_type = RESEARCH_ENGINEERING

	x = 0.1
	y = 0.5
	icon = "monitoring"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 0
	required_tech_levels = list()
	cost = 1200

	unlocks_designs = list(
		"nano_mani",
		"adv_matter_bin",
		"high_micro_laser",
		"adv_sensor"
	)

/datum/technology/engineering/integrated_circuits_xion
	name = "INTEGRATED CIRCUITRY (Xion)"
	desc = "Integrated circuit printer and upgrade systems from Xion Industrial."
	id = "integrated_circuits_xion"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.5
	icon = "icprinter"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 5
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"icprinter"
	)

/datum/technology/engineering/ic_upgrade_xion
	name = "INTEGRATED DESIGN UPGRADE (Xion)"
	desc = "Integrated circuit printer upgrade systems from Xion Industrial."
	id = "ic_upgrade_xion"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.5
	icon = "icupgradv"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 10
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"icupgradv"
	)

/datum/technology/engineering/advanced_engineering_xion
	name = "ADVANCED TOOLS AND ENGINEERING (Xion)"
	desc = "Advanced engineering tools and nanomaterial repair systems from Xion Industrial."
	id = "advanced_engineering_xion"
	tech_type = RESEARCH_ENGINEERING

	x = 0.4
	y = 0.5
	icon = "rped"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 15
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"rped",
		"nanopaste",
		"arc_welder",
		"jaws_of_life",
		"power_drill",
		"experimental_welder"
	)

/datum/technology/engineering/super_parts_xion
	name = "SUPER PARTS (Xion)"
	desc = "Next-generation ultra-precise components and phasic sensors from Xion Industrial."
	id = "super_parts_xion"
	tech_type = RESEARCH_ENGINEERING

	x = 0.5
	y = 0.5
	icon = "supermatterbin"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 20
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"pico_mani",
		"super_matter_bin",
		"ultra_micro_laser",
		"phasic_sensor"
	)

/datum/technology/engineering/ship_equipment_slate
	name = "SHIP MONITORING SYSTEMS (Slate Sisters)"
	desc = "Ship monitoring and alert systems from Slate Sisters Engineering."
	id = "ship_equipment_slate"
	tech_type = RESEARCH_ENGINEERING

	x = 0.1
	y = 0.5
	icon = "monitoring"

	required_corp_id = RND_MISSION_CORP_SLATE
	min_reputation = 0
	required_tech_levels = list()
	cost = 800

	unlocks_designs = list(
		"alerts",
		"shipmap"
	)

/datum/technology/engineering/ship_coordination_slate
	name = "SHIP COORDINATION SYSTEMS (Slate Sisters)"
	desc = "Ship coordination, sensors, and beacon systems from Slate Sisters Engineering."
	id = "ship_coordination_slate"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.5
	icon = "nav"

	required_corp_id = RND_MISSION_CORP_SLATE
	min_reputation = 5
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"sensors",
		"radio_beacon",
		"drone_pad"
	)

/datum/technology/engineering/ship_control_slate
	name = "SHIP CONTROL SYSTEMS (Slate Sisters)"
	desc = "Ship control, shuttle, and propulsion systems from Slate Sisters Engineering."
	id = "ship_control_slate"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.5
	icon = "nav"

	required_corp_id = RND_MISSION_CORP_SLATE
	min_reputation = 10
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"shuttle",
		"shuttle_long",
		"helms",
		"thruster"
	)

/datum/technology/engineering/ion_thrusters_slate
	name = "ION THRUSTING SYSTEMS (Slate Sisters)"
	desc = "Advanced ion propulsion systems from Slate Sisters Engineering."
	id = "ion_thrusters_slate"
	tech_type = RESEARCH_ENGINEERING

	x = 0.4
	y = 0.5
	icon = "nav"

	required_corp_id = RND_MISSION_CORP_SLATE
	min_reputation = 15
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"ionengine"
	)

/datum/technology/engineering/shield_systems_slate
	name = "SHIELD SYSTEMS (Slate Sisters)"
	desc = "Shield generator and diffuser systems from Slate Sisters Engineering."
	id = "shield_systems_slate"
	tech_type = RESEARCH_ENGINEERING

	x = 0.5
	y = 0.5
	icon = "shield"

	required_corp_id = RND_MISSION_CORP_SLATE
	min_reputation = 20
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list(
		"shield_generator",
		"shield_diffuser"
	)

/datum/technology/engineering/advanced_power_solar_focal
	name = "ADVANCED POWER AND SOLAR SYSTEMS (Focal Point)"
	desc = "Advanced power generation and solar control systems from Focal Point Energetics."
	id = "advanced_power_solar_focal"
	tech_type = RESEARCH_ENGINEERING

	x = 0.1
	y = 0.5
	icon = "wrench"

	required_corp_id = RND_MISSION_CORP_FOCAL
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"high_cell",
		"device_cell_high",
		"adv_capacitor",
		"solarcontrol"
	)

/datum/technology/engineering/super_power_storage_focal
	name = "SUPER POWER AND POWER STORAGE SYSTEMS (Focal Point)"
	desc = "Super capacity power storage systems from Focal Point Energetics."
	id = "super_power_storage_focal"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.5
	icon = "supermatterbin"

	required_corp_id = RND_MISSION_CORP_FOCAL
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"super_cell",
		"super_capacitor",
		"inducer",
		"batteryrack"
	)

/datum/technology/engineering/hyper_power_induction_focal
	name = "HYPER POWER AND POWER INDUCTION SYSTEMS (Focal Point)"
	desc = "Hyper capacity power and induction systems from Focal Point Energetics."
	id = "hyper_power_induction_focal"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.5
	icon = "advmatterbin"

	required_corp_id = RND_MISSION_CORP_FOCAL
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"inducer",
		"hyper_cell"
	)

/datum/technology/engineering/advanced_storage_focal
	name = "ADVANCED POWER STORAGE (Focal Point)"
	desc = "Advanced power storage and magnetic systems from Focal Point Energetics."
	id = "advanced_storage_focal"
	tech_type = RESEARCH_ENGINEERING

	x = 0.4
	y = 0.5
	icon = "supermatterbin"

	required_corp_id = RND_MISSION_CORP_FOCAL
	min_reputation = 15
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list(
		"smes_cell",
		"smes_coil_standard",
		"smes_coil_super_capacity",
		"smes_coil_super_io",
		"rcon_console"
	)

/datum/technology/engineering/gas_heat
	name = "Gas Heating and Cooling"
	desc = "Gas Heating and Cooling"
	id = "gas_heat"

	x = 0.2
	y = 0.6
	icon = "spaceheater"

	required_technologies = list()
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("gasheater", "gascooler", "stasis_clamp", "pipe_disposal" , "pipe_dispenser","sauna" )

/datum/technology/engineering/gas_heat_portable
	name = "Gas Portable"
	desc = "Gas Portable"
	id = "pump"

	x = 0.2
	y = 0.7
	icon = "pump"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("portascrubberstat", "portascrubberhuge", "portapump", "portascrubber", "oxyregen", "cracer","rpd","area_atmos")

/datum/technology/engineering/jetpack
	name = "Jetpacks"
	desc = "Jetpacks"
	id = "jetpack"

	x = 0.3
	y = 0.7
	icon = "jetpack"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("jetpack")

/datum/technology/engineering/adv_parts
	name = "Advanced Parts"
	desc = "Advanced Parts"
	id = "adv_parts"

	x = 0.2
	y = 0.4
	icon = "advmatterbin"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("nano_mani", "adv_matter_bin", "high_micro_laser", "adv_sensor","floodlight","holosign","advmop")

/datum/technology/engineering/super_parts
	name = "Super Parts"
	desc = "Super Parts"
	id = "super_parts"

	x = 0.6
	y = 0.5
	icon = "supermatterbin"

	required_technologies = list()
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

	required_technologies = list()
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("atmosalerts", "air_management","alerts", "atmos_control", "supermatter_control","injector")

/datum/technology/engineering/res_tech
	name = "Research Technologies"
	desc = "Research Technologies"
	id = "res_tech"

	x = 0.3
	y = 0.5
	icon = "rd"

	required_technologies = list()
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("destructive_analyzer", "protolathe", "circuit_imprinter", "rdservercontrol", "rdserver", "rdconsole","robocontrol", "urm")


/datum/technology/engineering/basic_mining
	name = "Basic Mining"
	desc = "Basic Mining"
	id = "basic_mining"

	x = 0.4
	y = 0.5
	icon = "pickaxe"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("drill", "jackhammer",  "mining drill head", "mining drill brace")


/datum/technology/engineering/xenoarch
	name = "Xenoarcheology"
	desc = "Xenoarcheology"
	id = "xenoarch"

	x = 0.4
	y = 0.6
	icon = "anom"

	required_technologies = list()
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("depth_scanner", "ano_scanner", "pick_set", "collector", "anomaly_detector", "electro_beacon")


/datum/technology/engineering/excavation_drill
	name = "Excavation Drill"
	desc = "Excavation Drill"
	id = "excavation_drill"

	x = 0.4
	y = 0.7
	icon = "drill"

	required_technologies = list()
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("xeno_drill", "suspension_gen", "anomaly_container", "stasis cage")


/datum/technology/engineering/excavation_drill_diamond
	name = "Diamond Excavation Drill"
	desc = "Diamond Excavation Drill"
	id = "excavation_drill_diamond"

	x = 0.5
	y = 0.7
	icon = "diamond_drill"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list("xeno_cutter")


/datum/technology/engineering/mining_prod
	name = "Mining Production"
	desc = "Mining Production"
	id = "mining_prod"

	x = 0.4
	y = 0.3
	icon = "smelter"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("mining_console", "mining_processor", "mining_unloader", "mining_stacker")

/datum/technology/engineering/adv_mining
	name = "Advanced Mining"
	desc = "Advanced Mining"
	id = "adv_mining"

	x = 0.4
	y = 0.2
	icon = "cutter"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("pick_diamond", "drill_diamond", "plasmacutter")


/datum/technology/engineering/ship
	name = "Ship Equipment"
	desc = "Ship Equipment"
	id = "nav"

	x = 0.5
	y = 0.4
	icon = "nav"

	required_technologies = list()
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("thruster", "helms", "nav", "nav_tele", "sensors", "shipengine", "shuttle","shuttle_long","ionengine","shipsensors","radio_beacon","drone_pad","shipmap")

/datum/technology/engineering/adv_eng
	name = "Advanced Engineering"
	desc = "Advanced Engineering"
	id = "adv_eng"

	x = 0.7
	y = 0.5
	icon = "rped"

	required_technologies = list()
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("rped", "mesons", "mesons_material", "nanopaste","securedoor","doppler")

/datum/technology/engineering/adv_tools
	name = "Advanced Tools"
	desc = "Advanced Tools"
	id = "adv_tools"

	x = 0.8
	y = 0.5
	icon = "jawsoflife"

	required_technologies = list()
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("arc_welder", "power_drill", "jaws_of_life", "experimental_welder", "price_scanner","hand_rcd","multimeter")

/datum/technology/engineering/crusher
	name = "Crusher"
	desc = "Crusher"
	id = "crusher"

	x = 0.3
	y = 0.4
	icon = "brace"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("brace", "bracejack","crusher","pile_ripper","recycler",)

/datum/technology/engineering/icprinter
	name = "Integrated Circuit Printer"
	desc = "Integrated Circuit Printer"
	id = "icprinter"

	x = 0.7
	y = 0.3
	icon = "icprinter"

	required_technologies = list()
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

	required_technologies = list()
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("icupgradv")

/datum/technology/engineering/icupclo
	name = "INTEGRATED DESIGN CLONING (Xion)"
	desc = "Integrated circuit design cloning systems from Xion Industrial."
	id = "icupclo"

	x = 0.8
	y = 0.3
	icon = "icupclo"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("icupclo")

/datum/technology/engineering/tracking_devices_mahimaku
	name = "TRACKING DEVICES (MAHIMAKU)"
	desc = "Tracking and localization systems from MAHIMAKU Corporation. Includes triangulation, GPS, and beacon-based tracking technologies."
	id = "tracking_devices_mahimaku"
	tech_type = RESEARCH_ENGINEERING

	x = 0.1
	y = 0.5
	icon = "gps"

	required_corp_id = RND_MISSION_CORP_MAHIMAKU
	min_reputation = 0
	required_tech_levels = list()
	cost = 1200

	unlocks_designs = list(
		"gps",
		"telesci-gps",
		"beacon_locator"
	)

/datum/technology/engineering/telecom_parts_mahimaku
	name = "TELECOMMUNICATION PARTS (MAHIMAKU)"
	desc = "Subspace communication components and amplification systems from MAHIMAKU Corporation. Advanced parts for long-range communication."
	id = "telecom_parts_mahimaku"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.5
	icon = "telecom_part"

	required_corp_id = RND_MISSION_CORP_MAHIMAKU
	min_reputation = 5
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"s-amplifier",
		"s-filter",
		"s-ansible",
		"s-crystal",
		"s-treatment",
		"s-analyzer",
		"s-transmitter"
	)
