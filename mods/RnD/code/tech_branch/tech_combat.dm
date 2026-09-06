// Combat technology branch — corporate nodes only

// ========== NanoTrasen ==========

/datum/technology/combat
	name = "Security Equipment (NanoTrasen)"
	desc = "Non-lethal security equipment and surveillance tools."
	id = "security_equipment_nt"
	tech_type = RESEARCH_COMBAT

	x = 0.1
	y = 0.5
	icon = "adflash"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"advancedflash",
		"stunbaton",
		"security_hud",
		"prisonmanage"
	)

/datum/technology/combat/nonlethal_weapons_nt
	name = "Non-Lethal Weapons (NanoTrasen)"
	desc = "Advanced non-lethal weaponry and tactical equipment."
	id = "nonlethal_weapons_nt"

	x = 0.2
	y = 0.5
	icon = "stunbaton"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"neutralizer",
		"nt_pistol",
		"tactical_goggles",
		"electrolaser_carbine"
	)

/datum/technology/combat/experimental_weapons_nt
	name = "Experimental Weapons (NanoTrasen)"
	desc = "Experimental scientific defense systems."
	id = "experimental_weapons_nt"

	x = 0.3
	y = 0.5
	icon = "decloner"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 10
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"flora_gun",
		"ppistol",
		"anti_photon",
		"decloner"
	)

/datum/technology/combat/nt_combat_weapons
	name = "NT Combat Weapons (NanoTrasen)"
	desc = "NanoTrasen-manufactured combat weapons and ion systems."
	id = "nt_combat_weapons"

	x = 0.4
	y = 0.5
	icon = "c20"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 15
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list(
		"nt41_smg",
		"c20a",
		"ion_pistol",
		"ion_rifle"
	)


// ========== Al-Maliki & Mosley ==========

/datum/technology/combat/frontier_revolvers_am
	name = "Frontier Revolvers (Al-Maliki)"
	desc = "Classic revolvers and basic ammunition."
	id = "frontier_revolvers_am"

	x = 0.1
	y = 0.5
	icon = "revolver"

	required_corp_id = RND_MISSION_CORP_ALMALIKI
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"revolver",
		"holdout_revolver",
		"ammo_small",
		"stunrevolver"
	)

/datum/technology/combat/frontier_ordnance_am
	name = "Frontier Ordnance (Al-Maliki)"
	desc = "Specialized ammunition and stun weapons."
	id = "frontier_ordnance_am"

	x = 0.2
	y = 0.5
	icon = "shock"

	required_corp_id = RND_MISSION_CORP_ALMALIKI
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"stun_rifle",
		"stunshell",
		"ammo_emp_small",
		"ammo_emp_pistol"
	)

/datum/technology/combat/specialized_am_weapons
	name = "Specialized Weapons (Al-Maliki)"
	desc = "Incendiary lasers and exotic ammunition."
	id = "specialized_am_weapons"

	x = 0.3
	y = 0.5
	icon = "emiammo"

	required_corp_id = RND_MISSION_CORP_ALMALIKI
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"ammo_emp_slug",
		"ammo_flechette"
	)

// ========== Hephaestus Industries ==========

/datum/technology/combat/basic_military_heph
	name = "Military Platforms (Hephaestus)"
	desc = "Standard military weapon systems."
	id = "basic_military_heph"

	x = 0.1
	y = 0.5
	icon = "g40"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"laser_carbine",
		"machine_pistol",
		"combat_shotgun"
	)

/datum/technology/combat/advanced_military_heph
	name = "Advanced Weapon Systems (Hephaestus)"
	desc = "Energy weapons, rifles and laser systems."
	id = "advanced_military_heph"

	x = 0.2
	y = 0.5
	icon = "lasercanon"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 5
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list(
		"bullpup",
		"lasercannon",
		"xraypistol"
	)

/datum/technology/combat/heavy_weapons_heph
	name = "Heavy Weapons (Hephaestus)"
	desc = "Railguns, marksman rifles and disperser systems."
	id = "heavy_weapons_heph"

	x = 0.3
	y = 0.5
	icon = "xray"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"flechette",
		"xrayrifle",
		"sniper_rifle",
		"spatha_railgun",
		"disperserfront",
		"dispersermiddle",
		"disperser_console",
		"bsaback"
	)

/datum/technology/combat/strategic_systems_heph
	name = "Strategic Systems (Hephaestus)"
	desc = "Guided missile systems and area denial."
	id = "strategic_systems_heph"

	x = 0.4
	y = 0.5
	icon = "empcharge"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 15
	required_tech_levels = list()
	cost = 10000

	unlocks_designs = list(
		"EMP",
		"high explosive",
		"anti-missile",
		"missile-hunter",
		"shield diffuser",
		"pointdefense",
		"pointdefense_control"
	)

// ========== Ward-Takahashi ==========

/datum/technology/combat/mass_produced_wt
	name = "Mass-Produced Weapons (Ward-Takahashi)"
	desc = "Cost-effective mass-produced security solutions."
	id = "mass_produced_wt"

	x = 0.1
	y = 0.5
	icon = "smg"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"smg",
		"wt550",
		"disorientator"
	)

/datum/technology/combat/ordnance_wt
	name = "Ordnance (Ward-Takahashi)"
	desc = "Grenade launchers and explosive ordnance."
	id = "ordnance_wt"

	x = 0.2
	y = 0.5
	icon = "riotgun"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"grenadelauncher",
		"large_Grenade"
	)

// ========== HelTek Arms ==========

/datum/technology/combat/heltek_sidearms
	name = "Sidearms (HelTek)"
	desc = "HelTek pistols and compact anti-drone weapons."
	id = "heltek_sidearms"

	x = 0.1
	y = 0.5
	icon = "heltek_optimus"

	required_corp_id = RND_MISSION_CORP_HELTEK
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"heltek_optimus",
		"heltek_magnus",
		"heltek_stupor"
	)

/datum/technology/combat/heltek_assault
	name = "Assault Weapons (HelTek)"
	desc = "HelTek assault rifles and laser carbines."
	id = "heltek_assault"

	x = 0.2
	y = 0.5
	icon = "la700"

	required_corp_id = RND_MISSION_CORP_HELTEK
	min_reputation = 5
	required_tech_levels = list()
	cost = 4000

	unlocks_designs = list(
		"heltek_la700",
		"heltek_mr735",
		"heltek_mbr",
		"heltek_bonfire"
	)

/datum/technology/combat/heltek_heavy
	name = "Heavy Weapons (HelTek)"
	desc = "HelTek railgun systems."
	id = "heltek_heavy"

	x = 0.3
	y = 0.5
	icon = "railgun"

	required_corp_id = RND_MISSION_CORP_HELTEK
	min_reputation = 10
	required_tech_levels = list()
	cost = 3500

	unlocks_designs = list(
		"heltek_thunderclap"
	)

// ========== Free Trade Union ==========

/datum/technology/combat/ftu_sidearms
	name = "Sidearms (FTU)"
	desc = "Affordable pistols and compact energy weapons."
	id = "ftu_sidearms"

	x = 0.1
	y = 0.5
	icon = "smallegun"

	required_corp_id = RND_MISSION_CORP_FTU
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"ftu_holdout_pistol",
		"ftu_grosser",
		"small_energy_gun"
	)

/datum/technology/combat/ftu_longarms
	name = "Longarms (FTU)"
	desc = "Shotguns and energy guns from various manufacturers."
	id = "ftu_longarms"

	x = 0.2
	y = 0.5
	icon = "egun"

	required_corp_id = RND_MISSION_CORP_FTU
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"energy_gun",
		"ftu_shotgun",
		"ftu_riot_shotgun",
		"ftu_double_barrel"
	)

/datum/technology/combat/ftu_military
	name = "Military Surplus (FTU)"
	desc = "Military-grade weapons available through trade networks."
	id = "ftu_military"

	x = 0.3
	y = 0.5
	icon = "c20r"

	required_corp_id = RND_MISSION_CORP_FTU
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"ftu_c20r"
	)
