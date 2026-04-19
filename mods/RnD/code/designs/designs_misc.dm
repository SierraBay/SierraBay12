

/datum/design/item/weapon/energy_gun
	id = "energy_gun"
	req_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2, TECH_POWER = 3)
	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 2000, MATERIAL_SILVER = 1000)
	build_path = /obj/item/gun/energy/gun
	sort_string = "TADAE"

/datum/design/item/weapon/small_energy_gun
	id = "small_energy_gun"
	req_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2, TECH_POWER = 2)
	materials = list(MATERIAL_STEEL = 3000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 500)
	build_path = /obj/item/gun/energy/gun/small
	sort_string = "TADAF"

// Al-Maliki & Mosley weapons
/datum/design/item/weapon/revolver
	id = "revolver"
	req_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_PLASTEEL = 4500, MATERIAL_SILVER = 1500)
	build_path = /obj/item/gun/projectile/revolver
	sort_string = "TAPAE"

/datum/design/item/weapon/holdout_revolver
	id = "holdout_revolver"
	req_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_PLASTEEL = 3000)
	build_path = /obj/item/gun/projectile/revolver/holdout
	sort_string = "TAPAF"
