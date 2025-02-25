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

/datum/design/item/mechfab/exosuit/combat_head
	name = "combat mech sensors"
	id = "combat_head"
	time = 30
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)
	build_path = /obj/item/mech_component/sensors/combat
	req_tech = list(TECH_COMBAT = 4)

/datum/design/item/mechfab/exosuit/combat_torso
	name = "combat mech chassis"
	materials = list(MATERIAL_STEEL = 135000, MATERIAL_PLASTEEL = 10000, MATERIAL_ALUMINIUM = 40000)
	req_tech = list(TECH_COMBAT = 4)

/datum/design/item/mechfab/exosuit/combat_arms/right
	name = "right combat mech manipulator"
	id = "right_combat_arm"
	build_path = /obj/item/mech_component/manipulators/combat/right

/datum/design/item/mechfab/exosuit/combat_arms
	name = "left combat mech manipulator"
	id = "left_combat_arm"
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)
	req_tech = list(TECH_COMBAT = 4)

/datum/design/item/mechfab/exosuit/combat_legs/right
	name = "right combat mech motivator"
	id = "right_combat_leg"
	build_path =  /obj/item/mech_component/propulsion/combat/right

/datum/design/item/mechfab/exosuit/combat_legs
	name = "left combat mech motivator"
	id = "left_combat_leg"
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)
	req_tech = list(TECH_COMBAT = 4)

/datum/design/item/exosuit/circuit
	name = "exosuit circuit rack"
	id = "exosuit_circuit"
	build_path = /obj/item/mech_equipment/mounted_system/circuit

/datum/design/item/mechfab/exosuit/powerloader_head
	materials = list(MATERIAL_STEEL = 5000)

/datum/design/item/mechfab/exosuit/powerloader_torso
	materials = list(MATERIAL_STEEL = 20000)

/datum/design/item/mechfab/exosuit/powerloader_arms/right
	name = "right power loader manipulator"
	id = "right_powerloader_arm"
	build_path =  /obj/item/mech_component/manipulators/powerloader/right

/datum/design/item/mechfab/exosuit/powerloader_arms
	name = "left power loader manipulator"
	id = "left_powerloader_arm"
	materials = list(MATERIAL_STEEL = 5000)

/datum/design/item/mechfab/exosuit/powerloader_legs/right
	name = "right power loader motivator"
	id = "right_powerloader_leg"
	build_path =  /obj/item/mech_component/propulsion/light/right

/datum/design/item/mechfab/exosuit/powerloader_legs
	name = "left power loader motivator"
	id = "left_powerloader_leg"
	materials = list(MATERIAL_STEEL = 5000)

/datum/design/item/mechfab/exosuit/light_head
	materials = list(MATERIAL_STEEL = 24000, MATERIAL_ALUMINIUM = 10000, MATERIAL_PLASTIC = 10000, MATERIAL_GLASS = 10000)

/datum/design/item/mechfab/exosuit/light_torso
	materials = list(MATERIAL_STEEL = 100000, MATERIAL_ALUMINIUM = 20000, MATERIAL_PLASTIC = 10000)

/datum/design/item/mechfab/exosuit/light_arms/right
	name = "right light mech manipulator"
	id = "right_light_arm"
	build_path =  /obj/item/mech_component/manipulators/light/right

/datum/design/item/mechfab/exosuit/light_arms
	name = "left light mech manipulator"
	id = "left_light_arm"
	materials = list(MATERIAL_STEEL = 30000, MATERIAL_PLASTIC = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/exosuit/light_legs/right
	name = "right light mech motivator"
	id = "right_light_leg"
	build_path =  /obj/item/mech_component/propulsion/light/right

/datum/design/item/mechfab/exosuit/light_legs
	name = "left light mech motivator"
	id = "left_light_leg"
	materials = list(MATERIAL_STEEL = 30000, MATERIAL_PLASTIC = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/exosuit/heavy_head
	name = "heavy mech sensors"
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)

/datum/design/item/mechfab/exosuit/heavy_torso
	name = "heavy mech chassis"
	materials = list(MATERIAL_STEEL = 210000, MATERIAL_URANIUM = 10000, MATERIAL_PLASTEEL = 40000, MATERIAL_ALUMINIUM = 40000)

/datum/design/item/mechfab/exosuit/heavy_arms/right
	name = "right heavy mech manipulator"
	id = "right_heavy_arm"
	build_path =  /obj/item/mech_component/manipulators/heavy/right

/datum/design/item/mechfab/exosuit/heavy_arms
	name = "left heavy mech manipulator"
	id = "left_heavy_arm"
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)

/datum/design/item/mechfab/exosuit/heavy_legs/right
	name = "right heavy mech motivator"
	id = "right_heavy_leg"
	build_path = /obj/item/mech_component/propulsion/heavy/right

/datum/design/item/mechfab/exosuit/heavy_legs
	name = "left heavy mech motivator"
	id = "left_heavy_leg"
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)

/datum/design/item/mechfab/exosuit/spider
	name = "spider-type motivators"
	build_path = /obj/item/mech_component/doubled_legs/spider
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_ALUMINIUM = 5000, MATERIAL_PLASTIC = 5000)

/datum/design/item/mechfab/exosuit/track
	build_path = /obj/item/mech_component/doubled_legs/tracks
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

/datum/design/item/exosuit/weapon/grad
	name = "mounted GRAD system"
	id = "mech_GRAD"
	req_tech = list(TECH_COMBAT = 7, TECH_MAGNET = 7, TECH_MATERIAL = 7)
	materials = list(MATERIAL_STEEL = 60000, MATERIAL_URANIUM = 25000, MATERIAL_ALUMINIUM = 40000, MATERIAL_GOLD = 2500, MATERIAL_SILVER = 2500, )
	build_path = /obj/item/mech_equipment/mounted_system/taser/ballistic/launcher


/datum/design/item/exosuit/weapon/grad_ammo_crate
	name = "GRAD pepper rockets"
	id = "mech_GRAD_peper"
	req_tech = list(TECH_COMBAT = 7, TECH_MAGNET = 7, TECH_MATERIAL = 7)
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_PHORON = 20000)
	build_path = /obj/item/ammo_magazine/rockets_casing/pepper

/datum/design/item/exosuit/weapon/flashbang_ammo_crate
	name = "GRAD flashbang rockets"
	id = "mech_GRAD_flashbang"
	req_tech = list(TECH_COMBAT = 7, TECH_MAGNET = 7, TECH_MATERIAL = 7)
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_PHORON = 2500, MATERIAL_PLASTIC = 10000, MATERIAL_ALUMINIUM = 10000)
	build_path = /obj/item/ammo_magazine/rockets_casing/flashbang

/datum/design/item/exosuit/weapon/fire_ammo_crate
	name = "GRAD fire rockets"
	id = "mech_GRAD_fire"
	req_tech = list(TECH_COMBAT = 7, TECH_MAGNET = 7, TECH_MATERIAL = 7)
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_PHORON = 20000, MATERIAL_PLASTIC = 20000, MATERIAL_ALUMINIUM = 20000)
	build_path = /obj/item/ammo_magazine/rockets_casing/fire
