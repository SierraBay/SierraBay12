// Combat weapon designs for corporate tech tree
// Only designs that don't already exist elsewhere

// ========== NanoTrasen ==========

/datum/design/item/weapon/nt_pistol
	id = "nt_pistol"
	req_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 3000)
	build_path = /obj/item/gun/projectile/pistol/sec
	sort_string = "TBAAA"

/datum/design/item/weapon/nt41_smg
	id = "nt41_smg"
	req_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 3)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_SILVER = 3000, MATERIAL_DIAMOND = 1500)
	build_path = /obj/item/gun/projectile/automatic/nt41
	sort_string = "TBAAB"

/datum/design/item/weapon/ion_rifle
	id = "ion_rifle"
	req_tech = list(TECH_COMBAT = 2, TECH_MAGNET = 4)
	materials = list(MATERIAL_STEEL = 7500, MATERIAL_GLASS = 2000, MATERIAL_SILVER = 1500)
	build_path = /obj/item/gun/energy/ionrifle
	sort_string = "TBAAC"

/datum/design/item/weapon/ion_pistol
	id = "ion_pistol"
	req_tech = list(TECH_COMBAT = 2, TECH_MAGNET = 4)
	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 1000)
	build_path = /obj/item/gun/energy/ionrifle/small
	sort_string = "TBAAD"

/datum/design/item/weapon/electrolaser_carbine
	id = "electrolaser_carbine"
	req_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_POWER = 3)
	materials = list(MATERIAL_STEEL = 4000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 500)
	build_path = /obj/item/gun/energy/taser/carbine
	sort_string = "TBAAE"

// ========== Hephaestus Industries ==========

/datum/design/item/weapon/laser_carbine
	id = "laser_carbine"
	req_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_GLASS = 3000, MATERIAL_DIAMOND = 2000)
	build_path = /obj/item/gun/energy/laser
	sort_string = "TBBAA"

/datum/design/item/weapon/combat_shotgun
	id = "combat_shotgun"
	req_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 18000, MATERIAL_PLASTEEL = 8000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/gun/projectile/shotgun/pump/combat
	sort_string = "TBBAB"

/datum/design/item/weapon/machine_pistol
	id = "machine_pistol"
	req_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 4000, MATERIAL_SILVER = 1000)
	build_path = /obj/item/gun/projectile/automatic/machine_pistol
	sort_string = "TBBAC"

/datum/design/item/weapon/assault_rifle
	id = "assault_rifle"
	req_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 3)
	materials = list(MATERIAL_STEEL = 24000, MATERIAL_PLASTEEL = 9000, MATERIAL_SILVER = 6000)
	build_path = /obj/item/gun/projectile/automatic/assault_rifle
	sort_string = "TBBAD"

/datum/design/item/weapon/sniper_rifle
	id = "sniper_rifle"
	req_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 5, TECH_POWER = 4)
	materials = list(MATERIAL_STEEL = 16000, MATERIAL_GLASS = 6000, MATERIAL_DIAMOND = 6000, MATERIAL_URANIUM = 4500)
	build_path = /obj/item/gun/energy/sniperrifle
	sort_string = "TBBAE"

/datum/design/item/weapon/spatha_railgun
	id = "spatha_railgun"
	req_tech = list(TECH_COMBAT = 7, TECH_MATERIAL = 4, TECH_MAGNET = 5)
	materials = list(MATERIAL_STEEL = 15000, MATERIAL_GOLD = 6000, MATERIAL_SILVER = 6000, MATERIAL_DIAMOND = 5000)
	build_path = /obj/item/gun/magnetic/railgun/spatha
	sort_string = "TBBAF"

// ========== Al-Maliki & Mosley ==========

/datum/design/item/weapon/incendiary_laser
	id = "incendiary_laser"
	req_tech = list(TECH_COMBAT = 7, TECH_MAGNET = 4, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_GLASS = 2000, MATERIAL_PHORON = 2000, MATERIAL_DIAMOND = 1000)
	build_path = /obj/item/gun/energy/incendiary_laser
	sort_string = "TBCAA"

// ========== Ward-Takahashi ==========

/datum/design/item/weapon/disorientator
	id = "disorientator"
	req_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2, TECH_POWER = 2)
	materials = list(MATERIAL_STEEL = 4000, MATERIAL_GLASS = 1000)
	build_path = /obj/item/gun/energy/confuseray
	sort_string = "TBDAA"

// ========== HelTek Arms ==========

/datum/design/item/weapon/heltek_optimus
	id = "heltek_optimus"
	req_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_PLASTEEL = 2000)
	build_path = /obj/item/gun/projectile/pistol/optimus
	sort_string = "TBEAA"

/datum/design/item/weapon/heltek_magnus
	id = "heltek_magnus"
	req_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3)
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_PLASTEEL = 2500)
	build_path = /obj/item/gun/projectile/pistol/magnum_pistol
	sort_string = "TBEAB"

/datum/design/item/weapon/heltek_la700
	id = "heltek_la700"
	req_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 3)
	materials = list(MATERIAL_STEEL = 16000, MATERIAL_PLASTEEL = 6000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/gun/projectile/automatic/assault_rifle/heltek
	sort_string = "TBEAC"

/datum/design/item/weapon/heltek_mr735
	id = "heltek_mr735"
	req_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 13000, MATERIAL_PLASTEEL = 4500)
	build_path = /obj/item/gun/projectile/automatic/mr735
	sort_string = "TBEAD"

/datum/design/item/weapon/heltek_mbr
	id = "heltek_mbr"
	req_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 13000, MATERIAL_PLASTEEL = 4500)
	build_path = /obj/item/gun/projectile/automatic/mbr
	sort_string = "TBEAE"

/datum/design/item/weapon/heltek_bonfire
	id = "heltek_bonfire"
	req_tech = list(TECH_COMBAT = 5, TECH_MAGNET = 4)
	materials = list(MATERIAL_STEEL = 18000, MATERIAL_GLASS = 6000, MATERIAL_SILVER = 4000, MATERIAL_PHORON = 3000)
	build_path = /obj/item/gun/energy/laser/bonfire
	sort_string = "TBEAF"

/datum/design/item/weapon/heltek_stupor
	id = "heltek_stupor"
	req_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 3)
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_GLASS = 2000, MATERIAL_URANIUM = 500)
	build_path = /obj/item/gun/energy/ionrifle/small/stupor
	sort_string = "TBEAG"

/datum/design/item/weapon/heltek_thunderclap
	id = "heltek_thunderclap"
	req_tech = list(TECH_COMBAT = 7, TECH_MATERIAL = 4, TECH_MAGNET = 5)
	materials = list(MATERIAL_STEEL = 10000, MATERIAL_GOLD = 4000, MATERIAL_SILVER = 4000, MATERIAL_DIAMOND = 2000)
	build_path = /obj/item/gun/magnetic/railgun/thunderclap
	sort_string = "TBEAH"

// ========== Free Trade Union ==========

/datum/design/item/weapon/ftu_shotgun
	id = "ftu_shotgun"
	req_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 15000, MATERIAL_PLASTEEL = 4500)
	build_path = /obj/item/gun/projectile/shotgun/pump
	sort_string = "TBFAA"

/datum/design/item/weapon/ftu_riot_shotgun
	id = "ftu_riot_shotgun"
	req_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_PLASTEEL = 4500)
	build_path = /obj/item/gun/projectile/shotgun/pump/sawn
	sort_string = "TBFAB"

/datum/design/item/weapon/ftu_double_barrel
	id = "ftu_double_barrel"
	req_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 1)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_PLASTEEL = 3000, MATERIAL_SILVER = 1000)
	build_path = /obj/item/gun/projectile/shotgun/doublebarrel
	sort_string = "TBFAC"

/datum/design/item/weapon/ftu_holdout_pistol
	id = "ftu_holdout_pistol"
	req_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_PLASTEEL = 3000)
	build_path = /obj/item/gun/projectile/pistol/holdout
	sort_string = "TBFAD"

/datum/design/item/weapon/ftu_grosser
	id = "ftu_grosser"
	req_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 3000)
	build_path = /obj/item/gun/projectile/pistol/grosser
	sort_string = "TBFAE"

/datum/design/item/weapon/ftu_c20r
	id = "ftu_c20r"
	req_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_STEEL = 16000, MATERIAL_SILVER = 6000, MATERIAL_DIAMOND = 4000)
	build_path = /obj/item/gun/projectile/automatic/merc_smg
	sort_string = "TBFAF"
