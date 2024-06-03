/obj/machinery/robotics_fabricator
	materials = list(MATERIAL_STEEL = 0, MATERIAL_PLASTEEL = 0, MATERIAL_TITANIUM = 0, MATERIAL_ALUMINIUM = 0, MATERIAL_PLASTIC = 0, MATERIAL_GLASS = 0, MATERIAL_GOLD = 0, MATERIAL_SILVER = 0, MATERIAL_PHORON = 0, MATERIAL_URANIUM = 0, MATERIAL_DIAMOND = 0)

/datum/design/item/mechfab/exosuit
	materials = list(MATERIAL_STEEL = 60000, MATERIAL_PLASTEEL = 10000)

/datum/design/item/mechfab/exosuit/basic_armour
	materials = list(MATERIAL_STEEL = 21500)


/datum/design/item/mechfab/exosuit/radproof_armour
	materials = list(MATERIAL_STEEL = 37500)

/datum/design/item/mechfab/exosuit/em_armour
	req_tech = list(TECH_MATERIAL = 4, TECH_POWER = 4)
	materials = list(MATERIAL_STEEL = 37500, MATERIAL_SILVER = 2000, MATERIAL_PLASTIC = 5000, MATERIAL_GLASS = 5000)

/datum/design/item/mechfab/exosuit/combat_armour
	materials = list(MATERIAL_STEEL = 60000, MATERIAL_DIAMOND = 5000, MATERIAL_PLASTEEL = 10000)

/datum/design/item/mechfab/exosuit/control_module
	materials = list(MATERIAL_STEEL = 15000, MATERIAL_PLASTIC = 5000, MATERIAL_ALUMINIUM = 5000, MATERIAL_GLASS = 5000)

/datum/design/item/mechfab/exosuit/combat_torso
	materials = list(MATERIAL_STEEL = 135000, MATERIAL_PLASTEEL = 10000, MATERIAL_ALUMINIUM = 40000)
	req_tech = list(TECH_COMBAT = 4)

/datum/design/item/mechfab/exosuit/combat_arms
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)
	req_tech = list(TECH_COMBAT = 4)

/datum/design/item/mechfab/exosuit/combat_legs
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)
	req_tech = list(TECH_COMBAT = 4)

/datum/design/item/mechfab/exosuit/combat_head
	name = "combat exosuit sensors"
	id = "combat_head"
	time = 30
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)
	build_path = /obj/item/mech_component/sensors/combat
	req_tech = list(TECH_COMBAT = 4)

/datum/design/item/mechfab/exosuit/powerloader_head
	materials = list(MATERIAL_STEEL = 15000)

/datum/design/item/mechfab/exosuit/powerloader_torso
	materials = list(MATERIAL_STEEL = 60000)

/datum/design/item/mechfab/exosuit/powerloader_arms
	materials = list(MATERIAL_STEEL = 18000)

/datum/design/item/mechfab/exosuit/powerloader_legs
	materials = list(MATERIAL_STEEL = 18000)

/datum/design/item/mechfab/exosuit/light_head
	materials = list(MATERIAL_STEEL = 24000, MATERIAL_ALUMINIUM = 10000, MATERIAL_PLASTIC = 10000, MATERIAL_GLASS = 10000)

/datum/design/item/mechfab/exosuit/light_torso
	materials = list(MATERIAL_STEEL = 100000, MATERIAL_ALUMINIUM = 20000, MATERIAL_PLASTIC = 10000)

/datum/design/item/mechfab/exosuit/light_arms
	materials = list(MATERIAL_STEEL = 30000, MATERIAL_PLASTIC = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/exosuit/light_legs
	materials = list(MATERIAL_STEEL = 30000, MATERIAL_PLASTIC = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/exosuit/heavy_head
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)

/datum/design/item/mechfab/exosuit/heavy_torso
	materials = list(MATERIAL_STEEL = 210000, MATERIAL_URANIUM = 10000, MATERIAL_PLASTEEL = 40000, MATERIAL_ALUMINIUM = 40000)

/datum/design/item/mechfab/exosuit/heavy_arms
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)

/datum/design/item/mechfab/exosuit/heavy_legs
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)

/datum/design/item/mechfab/exosuit/spider
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_ALUMINIUM = 5000, MATERIAL_PLASTIC = 5000)

/datum/design/item/mechfab/exosuit/track
	materials = list(MATERIAL_STEEL = 75000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/exosuit/sphere_torso
	materials = list(MATERIAL_STEEL = 54000, MATERIAL_ALUMINIUM = 10000, MATERIAL_PLASTIC = 10000)

/datum/design/item/exosuit/weapon/smg
	name = "mounted SMG"
	id = "mech_SMG"
	req_tech = list(TECH_COMBAT = 5, TECH_MAGNET = 4, TECH_MATERIAL = 5)
	materials = list(MATERIAL_STEEL = 60000, MATERIAL_URANIUM = 5000, MATERIAL_ALUMINIUM = 20000,MATERIAL_DIAMOND = 10000 )
	build_path = /obj/item/mech_equipment/mounted_system/taser/ballistic/smg

/datum/design/item/exosuit/weapon/smg_ammo_crate
	name = "SMG ammo box"
	id = "SMG_ammo"
	req_tech = list(TECH_COMBAT = 5, TECH_MAGNET = 4, TECH_MATERIAL = 5)
	materials = list(MATERIAL_STEEL = 40000, MATERIAL_URANIUM = 10000, MATERIAL_ALUMINIUM = 20000)
	build_path = /obj/item/ammo_magazine/proto_smg/mech
