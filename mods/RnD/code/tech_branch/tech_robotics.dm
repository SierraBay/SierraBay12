/datum/technology/robo
	name = "Basic Robotech"
	desc = "Basic Robotech"
	id = "robo"
	tech_type = RESEARCH_MAGNETS

	x = 0.4
	y = 0.3
	icon = "roboscanner"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list("dronecontrol","recharge_station","robot_scanner", "paicard", "sflash","robot_exoskeleton","robot_exoskeleton_hover","robot_torso","robot_head","robot_l_arm","robot_r_arm","robot_l_leg","robot_r_leg","binary_communication_device","radio","actuator","diagnosis_unit","camera","armour","light_armour")

/datum/technology/robo/basic_augments
	name = "Basic Augments"
	desc = "Basic Augments"
	id = "basic_augments"

	x = 0.3
	y = 0.4
	icon = "cpu_small"

	required_technologies = list(/datum/technology/robo)
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("augment_med_hud","augment_sci_hud","augment_jani_hud","augment_sec_hud","augment_it_hud","augment_toolset_engineering","augment_toolset_surgery","augment_blade_small","augment_scanner","augment_leukocyte_breeder","augment_iatric_monitor","augment_adaptive_binoculars","augment_glare_dampeners","augment_corrective_lenses",)

/datum/technology/robo/basic_hardsuitmods
	name = "Basic Hardsuit Mods"
	desc = "Basic Hardsuit Mods"
	id = "basic_hardsuitmods"

	x = 0.4
	y = 0.4
	icon = "circuit"

	required_technologies = list(/datum/technology/robo)
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("rig_meson","rig_medhud","rig_sechud","rig_healthscanner","rig_drill", "rig_orescanner","rig_anomaly_scanner","rig_flash","ai_basic")


/datum/technology/robo/advanced_repairs_robo
	name = "Advanced Repairs"
	desc = "Advanced Repairs"
	id = "advanced_repairs"
	tech_type = RESEARCH_MAGNETS

	x = 0.2
	y = 0.3
	icon = "roboscanner"

	required_technologies = list(/datum/technology/robo)
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list("integrity_repair_tool", "integrity_repair_tool_tank", "prosthetic_wiring_layerer")

/datum/technology/robo/loader_mech
	name = "Basic Mech Designs"
	desc = "Basic Mech Designs"
	id = "basic_mech"

	x = 0.6
	y = 0.4
	icon = "mechloader"

	required_technologies = list(/datum/technology/robo)
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("mechfab","mech_software_engineering","mech_software_utility","treads","mech_frame", "mech_armour_civil", "mech_control_module", "powerloader_head", "powerloader_body", "right_powerloader_arm", "left_powerloader_arm", "right_powerloader_leg", "left_powerloader_leg", "quad_legs", "sphere_body")

/datum/technology/robo/adv_augments
	name = "Advanced Augments"
	desc = "Advanced Augments"
	id = "advanced_augments"

	x = 0.3
	y = 0.6
	icon = "pcpu_small"

	required_technologies = list(/datum/technology/robo/basic_augments)
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list("augment_circuitry","augment_sonar","augment_nanounit","augment_wolverine","augment_blade","augment_powerfist","augment_knuckles","augment_booster_reflex","augment_booster_gunnery","augment_booster_muscles","augment_armor","augment_toolset_engineering_advanced")

/datum/technology/robo/adv_hardsuits
	name = "Advanced Hardsuits Mods"
	desc = "Advanced Hardsuits Mods"
	id = "adv_hardsuits"

	x = 0.4
	y = 0.6
	icon = "hardsuitmodule"

	required_technologies = list(/datum/technology/robo/basic_hardsuitmods)
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list("null _suit","rig_nvg","rig_plasmacutter", "rig_rcd","rig_jets","rig_decompiler","rig_powersink","rig_ai_container","rig_taser","rig_egun","rig_cooler","rig_kinetic", "self_repair", "ai_advanced")

/datum/technology/robo/heavy_mech
	name = "Heavy Mech Design"
	desc = "Heavy Mech Design"
	id = "heavy_mechs"

	x = 0.5
	y = 0.7
	icon = "mechheavy"

	required_technologies = list(/datum/technology/robo/loader_mech)
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("heavy_head", "heavy_body", "right_heavy_arm", "left_heavy_arm", "right_heavy_leg", "left_heavy_leg")

/datum/technology/robo/light_mech
	name = "Light Mech Design"
	desc = "Light Mech Design"
	id = "light_mechs"

	x = 0.6
	y = 0.7
	icon = "mechlight"

	required_technologies = list(/datum/technology/robo/loader_mech)
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("light_head", "light_body", "right_light_arm", "left_light_arm", "right_light_leg", "left_light_leg")

/datum/technology/robo/combat_mechs
	name = "Combat Mech Design"
	desc = "Combat Mech Design"
	id = "combat_mechs"

	x = 0.7
	y = 0.7
	icon = "mechcombat"

	required_technologies = list(/datum/technology/robo/loader_mech)
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list("combat_head", "combat_body", "right_combat_arm", "left_combat_arm", "right_combat_leg", "left_combat_leg", "mech_armour_combat", "mech_armour_buletproof","mech_armour_laserproof")


/datum/technology/robo/mech_equipment
	name = "Mech Equipment"
	desc = "Mech Equipment"
	id = "mech_equipment"

	x = 0.8
	y = 0.4
	icon = "mechclaw"

	required_technologies = list(/datum/technology/robo/loader_mech)
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("mech_recharger","hydraulic_clamp","gravity_catapult","mech_drill","mech_machete", "mech_floodlight","mech_camera","mech_flash", "mech_plasma","mech_shield_ballistic","mech_extinguisher")

/datum/technology/robo/adv_mech_tools
	name = "Advanced Mech Tools"
	desc = "Advanced Mech Tools"
	id = "adv_mech_tools"

	x = 0.8
	y = 0.5
	icon = "eva"

	required_technologies = list(/datum/technology/robo/mech_equipment)
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("mech_rcd","mech_ionjets","mech_atmoshields","mech_plasma_auto","mech_circuit")

/datum/technology/robo/mech_weapons
	name = "Mech Weapons"
	desc = "Mech Weapons"
	id = "mech_weapons"

	x = 0.9
	y = 0.4
	icon = "mechlaser"

	required_technologies = list(/datum/technology/robo/mech_equipment)
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("mech_ion","mech_laser","mech_flamer","mech_taser","mech_software_weapons","mech_SMG","SMG_ammo","mech_shield","mech_GRAD", "mech_GRAD_peper", "mech_GRAD_flashbang", "mech_GRAD_fire")

/datum/technology/robo/mech_med_tools
	name = "Mech Medical Tools"
	desc = "Mech Medical Tools"
	id = "mech_med"

	x = 0.8
	y = 0.3
	icon = "mechsleeper"

	required_technologies = list(/datum/technology/robo/mech_equipment)
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("mech_sleeper","mech_software_medical")

/datum/technology/robo/roboupgrade
	name = "Robots Upgrade"
	desc = "Robots Upgrade"
	id = "roboupgrade"

	x = 0.4
	y = 0.2
	icon = "aicircuit"

	required_technologies = list(/datum/technology/robo)
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("borg_rename_module","borg_reset_module","borg_floodlight_module","borg_restart_module","borg_vtec_module","borg_flash_protection_module")

/datum/technology/robo/robotconstruction
	name = "Advanced Synth Tecnology"
	desc = "Advanced Synth Tecnology"
	id = "robot"

	x = 0.3
	y = 0.2
	icon = "posibrain"

	required_technologies = list(/datum/technology/robo/roboupgrade)
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("borg_rcd_module","borg_jetpack_module","borg_taser_module","roboprinter","borg_party_module","posibrain","intelicard")

/datum/technology/robo/ai
	name = "AI Construction"
	desc = "AI Construction"
	id = "ai"

	x = 0.2
	y = 0.2
	icon = "ai"

	required_technologies = list(/datum/technology/robo/robotconstruction)
	required_tech_levels = list()
	cost = 3500

	unlocks_designs = list("aicore")
