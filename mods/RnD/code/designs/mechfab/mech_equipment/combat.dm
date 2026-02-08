/datum/design/item/mech/weapon/ion
	name = "mounted ion rifle"
	id = "mech_ion"
	materials = list(MATERIAL_STEEL = 12000, MATERIAL_ALUMINIUM = 2000, MATERIAL_GLASS = 2000)
	req_tech = list(TECH_COMBAT = 4, TECH_MAGNET = 4)
	build_path = /obj/item/mech_equipment/mounted_system/taser/ion

/datum/design/item/mech/weapon/laser
	name = "mounted laser gun"
	id = "mech_laser"
	materials = list(MATERIAL_STEEL = 14000, MATERIAL_GLASS = 6000)
	req_tech = list(TECH_COMBAT = 4, TECH_MAGNET = 4)
	build_path = /obj/item/mech_equipment/mounted_system/taser/laser

/datum/design/item/mech/weapon/machete
	name = "Mechete"
	id = "mech_machete"
	materials = list(MATERIAL_STEEL = 20000)
	req_tech = list(TECH_COMBAT = 2)
	build_path = /obj/item/mech_equipment/mounted_system/melee/mechete

/datum/design/item/mech/weapon/flamethrower
	name = "mounted flamethrower"
	id = "mech_flamer"
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_PLASTIC = 10000, MATERIAL_ALUMINIUM = 2000)
	req_tech = list(TECH_COMBAT = 1, TECH_MATERIAL = 2)
	build_path = /obj/item/mech_equipment/mounted_system/flamethrower

/datum/design/item/mech/flash
	name = "mech flash"
	id = "mech_flash"
	req_tech = list(TECH_COMBAT = 1)
	build_path = /obj/item/mech_equipment/flash

/datum/design/item/mech/taser
	name = "mounted electrolaser"
	id = "mech_taser"
	materials = list(MATERIAL_STEEL = 12000, MATERIAL_GLASS = 4000)
	req_tech = list(TECH_COMBAT = 1)
	build_path = /obj/item/mech_equipment/mounted_system/taser

/datum/design/item/mech/mechshields
	name = "energy shield drone"
	id = "mech_shield"
	time = 90
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_SILVER = 12000, MATERIAL_GOLD = 12000)
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 4, TECH_POWER = 4, TECH_COMBAT = 2)
	build_path = /obj/item/mech_equipment/shields

/datum/design/item/mech/mechshields/ballistic
	name = "plasteel mech shield"
	id = "mech_shield_ballistic"
	time = 45
	materials = list(MATERIAL_STEEL = 40000, MATERIAL_ALUMINIUM = 5000)
	req_tech = list(TECH_MATERIAL = 3)
	build_path = /obj/item/mech_equipment/ballistic_shield

/datum/design/item/mech/weapon/smg
	name = "mounted SMG"
	id = "mech_SMG"
	req_tech = list(TECH_COMBAT = 5, TECH_MAGNET = 4, TECH_MATERIAL = 5)
	materials = list(MATERIAL_STEEL = 60000, MATERIAL_URANIUM = 5000, MATERIAL_ALUMINIUM = 20000,MATERIAL_DIAMOND = 10000 )
	build_path = /obj/item/mech_equipment/mounted_system/taser/ballistic/smg

/datum/design/item/mech/weapon/smg_ammo_crate
	name = "SMG ammo box"
	id = "SMG_ammo"
	req_tech = list(TECH_COMBAT = 5, TECH_MAGNET = 4, TECH_MATERIAL = 5)
	materials = list(MATERIAL_STEEL = 40000, MATERIAL_URANIUM = 10000, MATERIAL_ALUMINIUM = 20000)
	build_path = /obj/item/ammo_magazine/proto_smg/mech

/datum/design/item/mech/weapon/grad
	name = "mounted GRAD system"
	id = "mech_GRAD"
	req_tech = list(TECH_COMBAT = 7, TECH_MAGNET = 7, TECH_MATERIAL = 7)
	materials = list(MATERIAL_STEEL = 60000,  MATERIAL_ALUMINIUM = 40000, MATERIAL_PLASTIC = 10000,)
	build_path = /obj/item/mech_equipment/mounted_system/taser/ballistic/launcher


/datum/design/item/mech/weapon/grad_ammo_crate
	name = "GRAD pepper rockets"
	id = "mech_GRAD_peper"
	req_tech = list(TECH_COMBAT = 7, TECH_MAGNET = 7, TECH_MATERIAL = 7)
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_PHORON = 5000)
	build_path = /obj/item/ammo_magazine/rockets_casing/pepper

/datum/design/item/mech/weapon/flashbang_ammo_crate
	name = "GRAD flashbang rockets"
	id = "mech_GRAD_flashbang"
	req_tech = list(TECH_COMBAT = 7, TECH_MAGNET = 7, TECH_MATERIAL = 7)
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_PLASTIC = 10000, MATERIAL_ALUMINIUM = 10000)
	build_path = /obj/item/ammo_magazine/rockets_casing/flashbang

/datum/design/item/mech/weapon/fire_ammo_crate
	name = "GRAD fire rockets"
	id = "mech_GRAD_fire"
	req_tech = list(TECH_COMBAT = 7, TECH_MAGNET = 7, TECH_MATERIAL = 7)
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_PHORON = 10000, MATERIAL_URANIUM = 25000, MATERIAL_GOLD = 2500, MATERIAL_SILVER = 2500,)
	build_path = /obj/item/ammo_magazine/rockets_casing/fire
