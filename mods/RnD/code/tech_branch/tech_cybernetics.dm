// Cybernetics technology branch

/datum/technology/cybernetics
	tech_type = RESEARCH_CYBERNETICS

/datum/technology/cybernetics/hardsuit_mining_grayson
	name = "HARDSUIT MINING EQUIPMENT (Grayson)"
	desc = "Hardsuit-mounted mining equipment and scanners from Grayson Manufactories. Advanced sensory systems for geological analysis and ore extraction."
	id = "hardsuit_mining_grayson"

	x = 0.1
	y = 0.5
	icon = "hardsuit"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"rig_meson",
		"drill",
		"rig_orescanner"
	)

/datum/technology/cybernetics/advanced_hardsuit_mining_grayson
	name = "ADVANCED HARDSUIT MINING EQUIPMENT (Grayson)"
	desc = "Advanced hardsuit-mounted mining tools from Grayson Manufactories. High-energy plasma cutters and matter decompilation systems for demanding geological operations."
	id = "advanced_hardsuit_mining_grayson"

	x = 0.2
	y = 0.5
	icon = "hardsuit"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"plasmacutter",
		"rig_decompiler"
	)

/datum/technology/cybernetics/heavy_duty_mining_grayson
	name = "HEAVY-DUTY MINING EQUIPMENT (Grayson)"
	desc = "Heavy-duty mining and excavation equipment from Grayson Manufactories. Industrial-grade tools for large-scale mining operations and ambitious geological surveys."
	id = "heavy_duty_mining_grayson"

	x = 0.3
	y = 0.5
	icon = "pickaxe"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 10
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"drill",
		"floodlight",
		"plasmacutter"
	)

/datum/technology/cybernetics/basic_robotech_morpheus
	name = "BASIC ROBOTECH (Morpheus Cybernetics)"
	desc = "Fundamental robotics and automation systems from Morpheus Cybernetics. Basic construction kits for autonomous machines and cyborg maintenance infrastructure."
	id = "basic_robotech_morpheus"

	x = 0.1
	y = 0.5
	icon = "robot"

	required_corp_id = RND_MISSION_CORP_MORPHEUS
	min_reputation = 0
	required_tech_levels = list()
	cost = 1800

	unlocks_designs = list(
		"dronecontrol",
		"recharge_station",
		"robot_scanner",
		"scan_robotic",
		"sflash",
		"robot_exoskeleton",
		"robot_exoskeleton_hover"
	)

/datum/technology/cybernetics/robots_upgrade_morpheus
	name = "ROBOTS UPGRADE (Morpheus Cybernetics)"
	desc = "Advanced upgrade modules and enhancement systems for robots and cyborgs from Morpheus Cybernetics. Performance enhancements, maintenance tools, and protective systems."
	id = "robots_upgrade_morpheus"

	x = 0.2
	y = 0.5
	icon = "robot"

	required_corp_id = RND_MISSION_CORP_MORPHEUS
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"borg_rename_module",
		"borg_reset_module",
		"borg_floodlight_module",
		"borg_restart_module",
		"borg_vtec_module",
		"borg_flash_protection_module"
	)

/datum/technology/cybernetics/advanced_synth_morpheus
	name = "ADVANCED SYNTH TECHNOLOGY (Morpheus Cybernetics)"
	desc = "Advanced synthetic organism systems and cutting-edge automation technology from Morpheus Cybernetics. Includes high-tier combat modules, mobility enhancements, and positronic consciousness substrates."
	id = "advanced_synth_morpheus"

	x = 0.3
	y = 0.5
	icon = "robot"

	required_corp_id = RND_MISSION_CORP_MORPHEUS
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"borg_rcd_module",
		"borg_jetpack_module",
		"borg_taser_module",
		"borg_party_module",
		"posibrain"
	)

/datum/technology/cybernetics/ai_construction_morpheus
	name = "AI CONSTRUCTION (Morpheus Cybernetics)"
	desc = "Artificial intelligence core construction and deployment systems from Morpheus Cybernetics. Cutting-edge technology for creating and housing advanced synthetic intelligences."
	id = "ai_construction_morpheus"

	x = 0.4
	y = 0.5
	icon = "ai"

	required_corp_id = RND_MISSION_CORP_MORPHEUS
	min_reputation = 15
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list(
		"aicore",
		"rig_ai_container"
	)

/datum/technology/cybernetics/exosuit_fabrication_xion
	name = "EXOSUIT FABRICATION (Xion Industrial)"
	desc = "Exosuit and mecha construction technology from Xion Industrial. Advanced systems for building and customizing powered exoskeletons and mechanized combat platforms."
	id = "exosuit_fabrication_xion"

	x = 0.1
	y = 0.5
	icon = "mechloader"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 0
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"mechfab",
		"mech_software_engineering",
		"mech_software_utility",
		"mech_frame",
		"mech_armour_civil",
		"mech_control_module",
		"powerloader_head",
		"powerloader_body",
		"powerloader_arms",
		"powerloader_legs"
	)

/datum/technology/cybernetics/mech_machinery_xion
	name = "MECH MACHINERY AND EQUIPMENT (Xion Industrial)"
	desc = "Essential machinery and equipment systems for mechas from Xion Industrial. Recharging stations, utility tools, and specialized propulsion systems for diverse operational needs."
	id = "mech_machinery_xion"

	x = 0.2
	y = 0.5
	icon = "mechlight"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 5
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"mech_recharger",
		"hydraulic_clamp",
		"mech_camera",
		"mech_extinguisher",
		"quad_legs"
	)

/datum/technology/cybernetics/advanced_mech_modules_xion
	name = "ADVANCED MECH MODULES (Xion Industrial)"
	desc = "Advanced modular systems and enhancements for mechas and exosuits from Xion Industrial. High-performance movement systems, specialized tools, and environmental adaptation modules."
	id = "advanced_mech_modules_xion"

	x = 0.3
	y = 0.5
	icon = "mechcombat"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 5
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"mech_ionjets",
		"mech_rcd",
		"mech_extinguisher",
		"gravity_catapult"
	)

/datum/technology/cybernetics/basic_engineering_augments_xion
	name = "BASIC ENGINEERING AUGMENTS (Xion Industrial)"
	desc = "Fundamental cybernetic augmentations for engineering personnel from Xion Industrial. Basic toolsets and visual enhancements for industrial work."
	id = "basic_engineering_augments_xion"

	x = 0.4
	y = 0.5
	icon = "wrench"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"augment_toolset_engineering",
		"augment_glare_dampeners"
	)

/datum/technology/cybernetics/advanced_engineering_augments_xion
	name = "ADVANCED ENGINEERING AUGMENTS (Xion Industrial)"
	desc = "Advanced cybernetic augmentations for engineering specialists from Xion Industrial. Enhanced toolsets and integrated circuitry for complex technical operations."
	id = "advanced_engineering_augments_xion"

	x = 0.5
	y = 0.5
	icon = "wrench"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"augment_circuitry",
		"augment_toolset_engineering_advanced"
	)

/datum/technology/cybernetics/utility_implants_bishop
	name = "UTILITY IMPLANTS (Bishop Cybernetics)"
	desc = "Basic utility cybernetic implants from Bishop Cybernetics. Practical augmentations for maintenance and utility personnel."
	id = "utility_implants_bishop"

	x = 0.1
	y = 0.5
	icon = "wrench"

	required_corp_id = RND_MISSION_CORP_BISHOP
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"augment_blade_small",
		"augment_jani_hud"
	)

/datum/technology/cybernetics/cyber_sonar_bishop
	name = "CYBER-SONAR (Bishop Cybernetics)"
	desc = "Advanced echolocation cybernetic implants from Bishop Cybernetics. Sophisticated sensory augmentation for spatial awareness and navigation in low-visibility environments."
	id = "cyber_sonar_bishop"

	x = 0.2
	y = 0.5
	icon = "eye"

	required_corp_id = RND_MISSION_CORP_BISHOP
	min_reputation = 5
	required_tech_levels = list()
	cost = 1800

	unlocks_designs = list(
		"augment_sonar"
	)

/datum/technology/cybernetics/medical_augmentations_veymed
	name = "MEDICAL AUGMENTATIONS (Veymed Medical Corporation)"
	desc = "Advanced medical cybernetic augmentations from Veymed Medical Corporation. Comprehensive suite of health monitoring, surgical assistance, and physiological enhancement systems."
	id = "medical_augmentations_veymed"

	x = 0.1
	y = 0.5
	icon = "heart"

	required_corp_id = RND_MISSION_CORP_VEYMED
	min_reputation = 0
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"augment_med_hud",
		"augment_toolset_surgery",
		"augment_scanner",
		"augment_iatric_monitor",
		"augment_leukocyte_breeder",
		"augment_corrective_lenses",
		"augment_booster_muscles"
	)

/datum/technology/cybernetics/medical_hardsuit_systems_veymed
	name = "MEDICAL HARDSUIT SYSTEMS (Veymed Medical Corporation)"
	desc = "Medical hardsuit module systems from Veymed Medical Corporation. Advanced diagnostic and monitoring equipment for hardsuit integration."
	id = "medical_hardsuit_systems_veymed"

	x = 0.2
	y = 0.5
	icon = "hardsuit"

	required_corp_id = RND_MISSION_CORP_VEYMED
	min_reputation = 5
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"rig_medhud",
		"rig_healthscanner"
	)

/datum/technology/cybernetics/medical_exosuit_systems_veymed
	name = "MEDICAL EXOSUIT SYSTEMS (Veymed Medical Corporation)"
	desc = "Medical exosuit equipment and control systems from Veymed Medical Corporation. Advanced medical treatment platforms and specialized software for combat medic mechas."
	id = "medical_exosuit_systems_veymed"

	x = 0.3
	y = 0.5
	icon = "mechsleeper"

	required_corp_id = RND_MISSION_CORP_VEYMED
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"mech_sleeper",
		"mech_software_medical"
	)

/datum/technology/cybernetics/exosuit_weapon_control_shellguard
	name = "EXOSUIT WEAPON CONTROL SYSTEMS (SHELLGUARD)"
	desc = "Combat exosuit weapon control systems from SHELLGUARD. Basic targeting and firing control software for armed mechanized platforms."
	id = "exosuit_weapon_control_shellguard"

	x = 0.1
	y = 0.5
	icon = "mechcombat"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 0
	required_tech_levels = list()
	cost = 1800

	unlocks_designs = list(
		"mech_software_weapons"
	)

/datum/technology/cybernetics/heavy_energy_weapons_shellguard
	name = "HEAVY-DUTY ENERGY WEAPONS (SHELLGUARD)"
	desc = "Heavy-duty energy weapon systems for combat exosuits from SHELLGUARD. Advanced directed-energy weaponry including ion rifles, laser guns, and electrolaser systems."
	id = "heavy_energy_weapons_shellguard"

	x = 0.2
	y = 0.5
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 5
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"mech_ion",
		"mech_laser",
		"mech_taser"
	)

/datum/technology/cybernetics/heavy_ballistic_weapons_shellguard
	name = "HEAVY-DUTY BALLISTIC WEAPONS (SHELLGUARD)"
	desc = "Heavy-duty ballistic weapon systems for combat exosuits from SHELLGUARD. Advanced submachine gun platforms and ammunition supply systems for sustained firefights."
	id = "heavy_ballistic_weapons_shellguard"

	x = 0.3
	y = 0.5
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"mech_SMG",
		"SMG_ammo"
	)

/datum/technology/cybernetics/defence_systems_shellguard
	name = "DEFENCE SYSTEMS (SHELLGUARD)"
	desc = "Advanced defensive systems for combat exosuits from SHELLGUARD. Heavy plasteel shielding for protection against ballistic threats."
	id = "defence_systems_shellguard"

	x = 0.4
	y = 0.5
	icon = "shield"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 15
	required_tech_levels = list()
	cost = 2800

	unlocks_designs = list(
		"mech_shield_ballistic",
		"mech_shield"
	)

/datum/technology/cybernetics/security_augments_shellguard
	name = "SECURITY AUGMENTS (SHELLGUARD)"
	desc = "Security-focused cybernetic augmentations from SHELLGUARD. Advanced HUD systems and subdermal protection for security and combat personnel."
	id = "security_augments_shellguard"

	x = 0.5
	y = 0.5
	icon = "shield"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 0
	required_tech_levels = list()
	cost = 1800

	unlocks_designs = list(
		"augment_sec_hud",
		"augment_armor"
	)

/datum/technology/cybernetics/augment_weaponry_shellguard
	name = "AUGMENT WEAPONRY (SHELLGUARD)"
	desc = "Combat-focused cybernetic weapon augmentations from SHELLGUARD. Advanced integrated melee weapons including cyberclaws, armblades, powerfists, and knuckles."
	id = "augment_weaponry_shellguard"

	x = 0.6
	y = 0.5
	icon = "sword"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 5
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"augment_wolverine",
		"augment_blade",
		"augment_powerfist",
		"augment_knuckles"
	)

/datum/technology/cybernetics/exosuit_armoured_tracks_shellguard
	name = "EXOSUIT ARMOURED TRACKS (SHELLGUARD)"
	desc = "Heavy-duty armoured track propulsion systems from SHELLGUARD. Reinforced treads for combat exosuits operating in hostile terrain."
	id = "exosuit_armoured_tracks_shellguard"

	x = 0.7
	y = 0.5
	icon = "mechloader"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 0
	required_tech_levels = list()
	cost = 1800

	unlocks_designs = list(
		"treads"
	)

/datum/technology/cybernetics/hi_koloss_design_shellguard
	name = "HI-KOLOSS DESIGN (SHELLGUARD)"
	desc = "Complete heavy combat exosuit construction blueprints from SHELLGUARD. All components for assembling the formidable Hi-Koloss heavy mech platform."
	id = "hi_koloss_design_shellguard"

	x = 0.8
	y = 0.5
	icon = "mechheavy"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 5
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"heavy_head",
		"heavy_body",
		"heavy_arms",
		"heavy_legs"
	)

/datum/technology/cybernetics/personal_ai_dais
	name = "PERSONAL AI (DAIS)"
	desc = "Personal AI device technology from DAIS. Compact artificial intelligence units for personal use and integration into portable computer systems."
	id = "personal_ai_dais"

	x = 0.1
	y = 0.5
	icon = "ai"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"paicard"
	)

/datum/technology/cybernetics/ai_maintenance_dais
	name = "AI MAINTENANCE (DAIS)"
	desc = "AI maintenance and integration systems from DAIS. InteliCard storage devices and specialized slots for AI unit management and deployment."
	id = "ai_maintenance_dais"

	x = 0.2
	y = 0.5
	icon = "ai"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"intelicard",
		"aislot"
	)

/datum/technology/cybernetics/basic_modular_computers_dais
	name = "BASIC MODULAR COMPUTERS (DAIS)"
	desc = "Fundamental modular computer components from DAIS. Basic hardware for constructing custom computer systems including drives, network cards, batteries, and processing units."
	id = "basic_modular_computers_dais"

	x = 0.3
	y = 0.5
	icon = "console"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"hdd_basic",
		"netcard_basic",
		"bat_normal",
		"portadrive_basic",
		"cpu_normal",
		"pc_motherboard",
		"netcard_wired"
	)

/datum/technology/cybernetics/power_effective_electronics_dais
	name = "POWER EFFECTIVE ELECTRONICS (DAIS)"
	desc = "Power-efficient miniaturized computer components from DAIS. Compact drives, low-power batteries, and microprocessors for portable and embedded systems."
	id = "power_effective_electronics_dais"

	x = 0.4
	y = 0.5
	icon = "battery"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 5
	required_tech_levels = list()
	cost = 1800

	unlocks_designs = list(
		"hdd_micro",
		"hdd_small",
		"bat_nano",
		"bat_micro",
		"cpu_small"
	)

/datum/technology/cybernetics/advanced_electronics_dais
	name = "ADVANCED ELECTRONICS (DAIS)"
	desc = "Advanced computer components and high-performance electronics from DAIS. Enhanced network cards, drives, data storage, and cutting-edge photonic processors."
	id = "advanced_electronics_dais"

	x = 0.5
	y = 0.5
	icon = "console"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 10
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"netcard_advanced",
		"hdd_advanced",
		"portadrive_advanced",
		"bat_advanced",
		"pcpu_small"
	)

/datum/technology/cybernetics/hiend_electronics_dais
	name = "HI-END ELECTRONICS (DAIS)"
	desc = "Premium high-end computer components and AI integration systems from DAIS. Super hard drives, advanced data storage, super batteries for sustained operation, photonic processors, Tesla power links, and inteliCard systems for AI deployment."
	id = "hiend_electronics_dais"

	x = 0.6
	y = 0.5
	icon = "processor"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 15
	required_tech_levels = list()
	cost = 2800

	unlocks_designs = list(
		"hdd_super",
		"portadrive_super",
		"bat_super",
		"pcpu_normal",
		"tesla_link"
	)
