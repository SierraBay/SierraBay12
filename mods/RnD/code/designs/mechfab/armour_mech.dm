/datum/design/item/mechfab/mech_armour
	category = list("Mech armour")

/datum/design/item/mechfab/mech_armour/basic_armour
	name = "basic mech armour"
	id = "mech_armour_basic"
	build_path = /obj/item/robot_parts/robot_component/armour/exosuit
	time = 30
	materials = list(MATERIAL_STEEL = 21500)

/datum/design/item/mechfab/mech_armour/radproof_armour
	name = "radiation-proof mech armour"
	id = "mech_armour_radproof"
	build_path = /obj/item/robot_parts/robot_component/armour/exosuit/radproof
	time = 50
	req_tech = list(TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 37500)

/datum/design/item/mechfab/mech_armour/em_armour
	name = "EM-shielded mech armour"
	id = "mech_armour_em"
	build_path = /obj/item/robot_parts/robot_component/armour/exosuit/em
	time = 50
	req_tech = list(TECH_MATERIAL = 4, TECH_POWER = 4)
	materials = list(MATERIAL_STEEL = 37500, MATERIAL_SILVER = 2000, MATERIAL_PLASTIC = 5000, MATERIAL_GLASS = 5000)

/datum/design/item/mechfab/mech_armour/combat_armour
	name = "Combat mech armour"
	id = "mech_armour_combat"
	build_path = /obj/item/robot_parts/robot_component/armour/exosuit/combat
	time = 50
	req_tech = list(TECH_MATERIAL = 4)
	materials = list(MATERIAL_STEEL = 60000, MATERIAL_DIAMOND = 5000, MATERIAL_PLASTEEL = 10000)
