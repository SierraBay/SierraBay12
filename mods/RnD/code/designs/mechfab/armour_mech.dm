/datum/design/item/mechfab/mech_armour
	category = list("Mech external armour")

/datum/design/item/mechfab/mech_armour/basic_armour
	name = "civil armor plates"
	id = "mech_armour_civil"
	build_path = /obj/item/mech_external_armor/civil
	time = 30
	materials = list(MATERIAL_STEEL = 4000)

/datum/design/item/mechfab/mech_armour/laserproof
	name = "abilative armor plates"
	id = "mech_armour_laserproof"
	build_path = /obj/item/mech_external_armor/laserproof
	time = 50
	req_tech = list(TECH_MATERIAL = 4, TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 10000, MATERIAL_GLASS = 20000)

/datum/design/item/mechfab/mech_armour/buletproof
	name = "buletproof armor plates"
	id = "mech_armour_buletproof"
	build_path = /obj/item/mech_external_armor/buletproof
	time = 50
	req_tech = list(TECH_MATERIAL = 4, TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 10000, MATERIAL_PLASTEEL = 10000, MATERIAL_ALUMINIUM = 10000)
