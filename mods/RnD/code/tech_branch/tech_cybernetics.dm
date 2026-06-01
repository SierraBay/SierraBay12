// Cybernetics technology branch — corporate nodes only

// ========== Grayson ==========

/datum/technology/cybernetics
	name = "Hardsuit Mining Equipment (Grayson)"
	desc = "Hardsuit-mounted mining equipment and scanners."
	id = "hardsuit_mining_grayson"
	tech_type = RESEARCH_CYBERNETICS

	x = 0.1
	y = 0.5
	icon = "meson"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"rig_meson",
		"rig_orescanner",
		"rig_drill"
	)

/datum/technology/cybernetics/advanced_hardsuit_mining_grayson
	name = "Advanced Hardsuit Mining (Grayson)"
	desc = "Advanced hardsuit-mounted mining tools."
	id = "advanced_hardsuit_mining_grayson"

	x = 0.2
	y = 0.5
	icon = "circuit"

	required_corp_id = RND_MISSION_CORP_GRAYSON
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"rig_decompiler",
		"rig_anomaly_scanner",
		"rig_plasmacutter",
		"mining_hardsuit"
	)

/datum/technology/cybernetics/heavy_duty_mining_grayson
	name = "Heavy-Duty Mining (Grayson)"
	desc = "Heavy-duty mining and excavation equipment."
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

// ========== Morpheus ==========

/datum/technology/cybernetics/basic_robotech_morpheus
	name = "Basic Robotech (Morpheus)"
	desc = "Fundamental robotics and automation systems."
	id = "basic_robotech_morpheus"

	x = 0.1
	y = 0.5
	icon = "wrench"

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
		"robot_exoskeleton_hover",
		"robot_torso",
		"robot_head",
		"robot_l_arm",
		"robot_r_arm",
		"robot_l_leg",
		"robot_r_leg",
		"binary_communication_device",
		"radio",
		"actuator",
		"diagnosis_unit",
		"camera",
		"armour",
		"light_armour"
	)

/datum/technology/cybernetics/robots_upgrade_morpheus
	name = "Robots Upgrade (Morpheus)"
	desc = "Advanced upgrade modules for robots and cyborgs."
	id = "robots_upgrade_morpheus"

	x = 0.2
	y = 0.5
	icon = "circuit"

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
		"borg_flash_protection_module",
		"roboprinter"
	)

/datum/technology/cybernetics/advanced_synth_morpheus
	name = "Advanced Synth Technology (Morpheus)"
	desc = "Advanced synthetic organism systems and positronic consciousness."
	id = "advanced_synth_morpheus"

	x = 0.3
	y = 0.5
	icon = "jetpack"

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
	name = "AI Construction (Morpheus)"
	desc = "Artificial intelligence core construction and deployment."
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
		"rig_ai_container",
		"aiupload",
		"borgupload"
	)

// ========== Xion ==========

/datum/technology/cybernetics/exosuit_fabrication_xion
	name = "Exosuit Fabrication (Xion)"
	desc = "Exosuit and mecha construction technology."
	id = "exosuit_fabrication_xion"

	x = 0.1
	y = 0.5
	icon = "mechlight"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 0
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"mechfab",
		"mech_software_engineering",
		"mech_software_utility",
		"mech_frame",
		"mech_control_module",
		"powerloader_head",
		"powerloader_body",
		"powerloader_arms",
		"powerloader_legs",
		"light_head",
		"light_body",
		"right_light_arm",
		"left_light_arm",
		"right_light_leg",
		"left_light_leg",
		"sphere_body",
		"treads",
		"mech_armour_basic"
	)

/datum/technology/cybernetics/mech_machinery_xion
	name = "Mech Machinery & Equipment (Xion)"
	desc = "Essential machinery and equipment for mechas."
	id = "mech_machinery_xion"

	x = 0.2
	y = 0.5
	icon = "circuit"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 5
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"mech_recharger",
		"hydraulic_clamp",
		"mech_camera",
		"mech_extinguisher",
		"quad_legs",
		"mech_drill",
		"mech_machete",
		"mech_floodlight",
		"mech_flash",
		"mech_circuit"
	)

/datum/technology/cybernetics/advanced_mech_modules_xion
	name = "Advanced Mech and RIG Modules (Xion)"
	desc = "High-performance movement and specialized tools."
	id = "advanced_mech_modules_xion"

	x = 0.3
	y = 0.5
	icon = "jetpack"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"mech_ionjets",
		"mech_rcd",
		"gravity_catapult",
		"mech_atmoshields",
		"mech_plasma",
		"mech_plasma_auto",
		"rig_rcd",
		"rig_jets",
		"self_repair",
		"rig_powersink",
		"mech_armour_radproof"
	)

/datum/technology/cybernetics/basic_engineering_augments_xion
	name = "Basic Engineering (Xion)"
	desc = "Fundamental cybernetic augmentations for engineering."
	id = "basic_engineering_augments_xion"

	x = 0.5
	y = 0.5
	icon = "engaugment"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"augment_toolset_engineering",
		"augment_glare_dampeners",
		"engi_eva_rig",
		"null _suit"
	)

/datum/technology/cybernetics/advanced_engineering_augments_xion
	name = "Advanced Engineering Augments (Xion)"
	desc = "Advanced cybernetic augmentations for engineering."
	id = "advanced_engineering_augments_xion"

	x = 0.6
	y = 0.5
	icon = "augment"

	required_corp_id = RND_MISSION_CORP_XION
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"augment_circuitry",
		"augment_toolset_engineering_advanced"
	)

// ========== Bishop ==========

/datum/technology/cybernetics/utility_implants_bishop
	name = "Utility Implants (Bishop)"
	desc = "Utility cybernetic implants."
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
		"augment_jani_hud",
		"augment_adaptive_binoculars",
		"augment_nanounit"
	)

/datum/technology/cybernetics/prosthetic_repairs_bishop
	name = "Prosthetic Repairs (Bishop)"
	desc = "Advanced prosthetic repair and maintenance tools."
	id = "prosthetic_repairs_bishop"

	x = 0.2
	y = 0.5
	icon = "advprostheticrepairs"

	required_corp_id = RND_MISSION_CORP_BISHOP
	min_reputation = 0
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"integrity_repair_tool",
		"integrity_repair_tool_tank",
		"prosthetic_wiring_layerer"
	)


/datum/technology/cybernetics/cyber_sonar_bishop
	name = "Cyber-Sonar (Bishop)"
	desc = "Advanced echolocation cybernetic implants."
	id = "cyber_sonar_bishop"

	x = 0.3
	y = 0.5
	icon = "ecybersonare"

	required_corp_id = RND_MISSION_CORP_BISHOP
	min_reputation = 5
	required_tech_levels = list()
	cost = 1800

	unlocks_designs = list(
		"augment_sonar",
		"augment_corrective_lenses"
	)

// ========== VeyMed ==========

/datum/technology/cybernetics/medical_augmentations_veymed
	name = "Medical Augmentations (VeyMed)"
	desc = "Medical cybernetic augmentations."
	id = "medical_augmentations_veymed"

	x = 0.1
	y = 0.5
	icon = "augment"

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
	name = "Medical Hardsuit Systems (VeyMed)"
	desc = "Medical hardsuit module systems."
	id = "medical_hardsuit_systems_veymed"

	x = 0.2
	y = 0.5
	icon = "medhud"

	required_corp_id = RND_MISSION_CORP_VEYMED
	min_reputation = 5
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"rig_medhud",
		"rig_healthscanner",
		"medical_hardsuit"
	)

/datum/technology/cybernetics/medical_exosuit_systems_veymed
	name = "Medical Exosuit Systems (VeyMed)"
	desc = "Medical exosuit equipment and control."
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

// ========== Shellguard ==========

/datum/technology/cybernetics/exosuit_weapon_control_shellguard
	name = "Exosuit Weapon Control (Shellguard)"
	desc = "Combat exosuit weapon control systems."
	id = "exosuit_weapon_control_shellguard"

	x = 0.1
	y = 0.5
	icon = "mechcombat"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 0
	required_tech_levels = list()
	cost = 800

	unlocks_designs = list(
		"mech_software_weapons",
		"mech_armour_em",
	)

/datum/technology/cybernetics/heavy_energy_weapons_shellguard
	name = "Heavy Energy Weapons (Shellguard)"
	desc = "Heavy-duty energy weapon systems for exosuits."
	id = "heavy_energy_weapons_shellguard"

	x = 0.2
	y = 0.5
	icon = "empmech"

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
	name = "Heavy Ballistic Weapons (Shellguard)"
	desc = "Heavy-duty ballistic weapon systems for exosuits."
	id = "heavy_ballistic_weapons_shellguard"

	x = 0.3
	y = 0.5
	icon = "smgmech"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"mech_SMG",
		"SMG_ammo"
	)

/datum/technology/cybernetics/defence_systems_shellguard
	name = "Defence Systems (Shellguard)"
	desc = "Advanced defensive systems for combat exosuits."
	id = "defence_systems_shellguard"

	x = 0.4
	y = 0.5
	icon = "shieldmech"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 15
	required_tech_levels = list()
	cost = 2800

	unlocks_designs = list(
		"mech_shield_ballistic",
		"mech_shield"
	)

/datum/technology/cybernetics/security_augments_shellguard
	name = "Security Augments (Shellguard)"
	desc = "Security-focused cybernetic augmentations."
	id = "security_augments_shellguard"

	x = 0.5
	y = 0.5
	icon = "augment"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 0
	required_tech_levels = list()
	cost = 1800

	unlocks_designs = list(
		"augment_sec_hud",
		"augment_armor",
		"rig_sechud",
		"rig_flash",
		"rig_nvg"
	)

/datum/technology/cybernetics/augment_weaponry_shellguard
	name = "Augment Weaponry (Shellguard)"
	desc = "Combat-focused cybernetic weapon augmentations."
	id = "augment_weaponry_shellguard"

	x = 0.6
	y = 0.5
	icon = "clawsaugment"

	required_corp_id = RND_MISSION_CORP_SHELLGUARD
	min_reputation = 5
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"augment_wolverine",
		"augment_blade",
		"augment_powerfist",
		"augment_knuckles",
		"rig_kinetic",
		"rig_cooler"
	)


/datum/technology/cybernetics/hi_koloss_design_shellguard
	name = "Hi-Koloss Design (Shellguard)"
	desc = "Heavy combat exosuit construction blueprints."
	id = "hi_koloss_design_shellguard"

	x = 0.7
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
		"heavy_legs",
		"right_heavy_arm",
		"left_heavy_arm",
		"right_heavy_leg",
		"left_heavy_leg"
	)

// ========== Hephaestus (Combat Mech) ==========

/datum/technology/cybernetics/combat_mech_design_heph
	name = "Combat Mech Design (Hephaestus)"
	desc = "Combat exosuit construction and armour systems."
	id = "combat_mech_design_heph"

	x = 0.1
	y = 0.5
	icon = "mechcombat"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 0
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"combat_head",
		"combat_body",
		"right_combat_arm",
		"left_combat_arm",
		"right_combat_leg",
		"left_combat_leg",
		"mech_armour_combat",
	)

/datum/technology/cybernetics/combat_rig_design_heph
	name = "RIG (Hephaestus)"
	desc = "Combat RIG construction."
	id = "combat_rig_design_heph"

	x = 0.2
	y = 0.5
	icon = "hardsuitmodule"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 0
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list(
		"hazzard_suit",
		"rig_taser",
		"rig_egun",
	)

/datum/technology/cybernetics/mech_heavy_weapons_heph
	name = "Mech Heavy Weapons (Hephaestus)"
	desc = "Heavy weapon systems for combat exosuits."
	id = "mech_heavy_weapons_heph"

	x = 0.3
	y = 0.5
	icon = "mechlaser"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 5
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"mech_flamer",
		"mech_GRAD",
		"mech_GRAD_peper",
		"mech_GRAD_flashbang",
		"mech_GRAD_fire"
	)

/datum/technology/cybernetics/military_augments_heph
	name = "Military Augments (Hephaestus)"
	desc = "Military-grade cybernetic combat augmentations."
	id = "military_augments_heph"

	x = 0.4
	y = 0.5
	icon = "augment"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 10
	required_tech_levels = list()
	cost = 2800

	unlocks_designs = list(
		"augment_booster_reflex",
		"augment_booster_gunnery",
		"augment_sci_hud",
		"augment_it_hud"
	)

// ========== DAIS (Electronics) ==========

/datum/technology/cybernetics/personal_ai_dais
	name = "Personal AI (DAIS)"
	desc = "Personal AI device technology."
	id = "personal_ai_dais"

	x = 0.1
	y = 0.5
	icon = "cpu_small"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"paicard",
		"pai_memstd",
		"pai_holo",
		"pai_holoskin_woman",
		"pai_memadv"
	)

/datum/technology/cybernetics/ai_maintenance_dais
	name = "AI Maintenance (DAIS)"
	desc = "AI maintenance and integration systems."
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
		"aislot",
		"cardslot",
		"cardbroadcaster",
		"pai_memlambda",
		"pai_camo",
		"pai_hackstd",
		"pai_hackadv"
	)

/datum/technology/cybernetics/basic_modular_computers_dais
	name = "Basic Modular Computers (DAIS)"
	desc = "Fundamental modular computer components."
	id = "basic_modular_computers_dais"

	x = 0.3
	y = 0.5
	icon = "nanoprinter"

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
		"netcard_wired",
		"ship_interface",
		"nanoprinter",
		"scan_paper"
	)

/datum/technology/cybernetics/power_effective_electronics_dais
	name = "Power Effective Electronics (DAIS)"
	desc = "Power-efficient miniaturized computer components."
	id = "power_effective_electronics_dais"

	x = 0.4
	y = 0.5
	icon = "cpu_small"

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
	name = "Advanced Electronics (DAIS)"
	desc = "Advanced computer components and networking."
	id = "advanced_electronics_dais"

	x = 0.5
	y = 0.5
	icon = "pcpu_small"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 10
	required_tech_levels = list()
	cost = 2200

	unlocks_designs = list(
		"netcard_advanced",
		"hdd_advanced",
		"portadrive_advanced",
		"bat_advanced",
		"pcpu_small",
		"scan_atmos"
	)

/datum/technology/cybernetics/hiend_electronics_dais
	name = "Hi-End Electronics (DAIS)"
	desc = "Premium high-end computer components and AI integration."
	id = "hiend_electronics_dais"

	x = 0.6
	y = 0.5
	icon = "modular_bat_ultra"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 15
	required_tech_levels = list()
	cost = 2800

	unlocks_designs = list(
		"hdd_super",
		"portadrive_super",
		"bat_super",
		"pcpu_normal",
		"tesla_link",
		"hdd_cluster",
		"data_disk",
		"bat_ultra"
	)
