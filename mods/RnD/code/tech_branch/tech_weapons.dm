// Weapons technology branch

/datum/technology/weapons
	tech_type = RESEARCH_WEAPONS

/datum/technology/weapons/basic_weapons_nt
	name = "BASIC WEAPONS (NanoTrasen)"
	desc = "Basic weapon systems and security equipment from NanoTrasen. Foundation for advanced weaponry development."
	id = "basic_weapons_nt"
	tech_type = RESEARCH_WEAPONS

	x = 0.1
	y = 0.2
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"advancedflash",
		"sflash",
		"chemsprayer",
		"flora_gun",
		"stunbaton"
	)

/datum/technology/weapons/advanced_weapons_nt
	name = "ADVANCED WEAPONS (NanoTrasen)"
	desc = "Advanced energy-based weapon systems from NanoTrasen. Stun technology and specialized launchers for security operations."
	id = "advanced_weapons_nt"
	tech_type = RESEARCH_WEAPONS

	x = 0.2
	y = 0.2
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"small_energy_gun",
		"energy_gun"
	)

/datum/technology/weapons/energy_weapons_nt
	name = "ENERGY WEAPONS (NanoTrasen)"
	desc = "Cutting-edge directed energy weapon systems from NanoTrasen. High-powered laser and X-ray technology for extreme situations."
	id = "energy_weapons_nt"
	tech_type = RESEARCH_WEAPONS

	x = 0.3
	y = 0.2
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"xraypistol",
		"xrayrifle"
	)

/datum/technology/weapons/basic_ballistic_am
	name = "BASIC BALLISTIC WEAPONS (Al-Maliki & Mosley)"
	desc = "Basic ballistic weapons and ammunition from Al-Maliki & Mosley. Reliable firearms for security operations."
	id = "basic_ballistic_am"
	tech_type = RESEARCH_WEAPONS

	x = 0.1
	y = 0.35
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_ALMALIKI
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"revolver",
		"holdout_revolver",
		"ammo_small"
	)

/datum/technology/weapons/advanced_ballistic_am
	name = "ADVANCED BALLISTIC WEAPONS (Al-Maliki & Mosley)"
	desc = "Advanced ballistic weapons from Al-Maliki & Mosley. Military-grade SMGs and rifles with armor-piercing ammunition."
	id = "advanced_ballistic_am"
	tech_type = RESEARCH_WEAPONS

	x = 0.2
	y = 0.35
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_ALMALIKI
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"stunrevolver",
		"stun_rifle",
		"smg"
	)

/datum/technology/weapons/specialized_weapons_am
	name = "SPECIALIZED WEAPONS (Al-Maliki & Mosley)"
	desc = "Specialized weapons systems from Al-Maliki & Mosley. Magnetic rifles and EMP ammunition for tactical operations."
	id = "specialized_weapons_am"
	tech_type = RESEARCH_WEAPONS

	x = 0.3
	y = 0.35
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_ALMALIKI
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"flechette",
		"ammo_emp_small",
		"ammo_emp_pistol",
		"ammo_emp_slug"
	)

/datum/technology/weapons/basic_heavy_weapons_heph
	name = "BASIC HEAVY WEAPONS (Hephaestus Industries)"
	desc = "Basic heavy weapons systems from Hephaestus Industries. Grenade launchers and advanced explosives for combat operations."
	id = "basic_heavy_weapons_heph"
	tech_type = RESEARCH_WEAPONS

	x = 0.1
	y = 0.5
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"grenadelauncher",
		"large_Grenade",
		"anti_photon",
		"ppistol"
	)

/datum/technology/weapons/advanced_heavy_weapons_heph
	name = "ADVANCED HEAVY WEAPONS (Hephaestus Industries)"
	desc = "Advanced weapons systems from Hephaestus Industries. Missile payloads and specialized energy weapons for tactical superiority."
	id = "advanced_heavy_weapons_heph"
	tech_type = RESEARCH_WEAPONS

	x = 0.2
	y = 0.5
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"EMP",
		"high explosive",
		"anti-missile",
		"lasercannon"
	)

/datum/technology/weapons/tactical_weapons_heph
	name = "TACTICAL WEAPONS (Hephaestus Industries)"
	desc = "High-end tactical weapons from Hephaestus Industries. Guided missile systems and exotic energy weapons for elite combat units."
	id = "tactical_weapons_heph"
	tech_type = RESEARCH_WEAPONS

	x = 0.3
	y = 0.5
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_HEPHAESTUS
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"missile-hunter",
		"shield diffuser",
		"decloner"
	)


/datum/technology/weapons/basic_defensive_weapons_wt
	name = "BASIC DEFENSIVE WEAPONS (Ward-Takahashi)"
	desc = "Basic defensive weapon systems from Ward-Takahashi. Cost-effective security solutions for corporate protection."
	id = "basic_defensive_weapons_wt"
	tech_type = RESEARCH_WEAPONS

	x = 0.1
	y = 0.95
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 0
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list(
		"wt550",
		"stunshell",
		"ammo_small"
	)

/datum/technology/weapons/advanced_defensive_weapons_wt
	name = "ADVANCED DEFENSIVE WEAPONS (Ward-Takahashi)"
	desc = "Advanced defensive weapons from Ward-Takahashi. Military-grade SMGs and rifles for enhanced security."
	id = "advanced_defensive_weapons_wt"
	tech_type = RESEARCH_WEAPONS

	x = 0.2
	y = 0.95
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 5
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list(
		"bullpup",
		"ammo_flechette"
	)

/datum/technology/weapons/tactical_defense_systems_wt
	name = "TACTICAL DEFENSE SYSTEMS (Ward-Takahashi)"
	desc = "Tactical defense systems from Ward-Takahashi. Grenade launchers and explosive devices for area denial and crowd control."
	id = "tactical_defense_systems_wt"
	tech_type = RESEARCH_WEAPONS

	x = 0.3
	y = 0.95
	icon = "gun"

	required_corp_id = RND_MISSION_CORP_WARD_TAKAHASHI
	min_reputation = 10
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list(
		"ammo_emp_slug"
	)
