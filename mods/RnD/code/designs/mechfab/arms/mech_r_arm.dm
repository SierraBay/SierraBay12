/datum/design/item/mechfab/mech_r_arm
	category = list("Mech right arm")

/datum/design/item/mechfab/mech_r_arm/powerloader
	name = "right power loader manipulator"
	id = "right_powerloader_arm"
	time = 15
	build_path =  /obj/item/mech_component/manipulators/powerloader/right
	materials = list(MATERIAL_STEEL = 10000)

/datum/design/item/mechfab/mech_r_arm/light
	name = "right light mech manipulator"
	id = "right_light_arm"
	time = 15
	build_path =  /obj/item/mech_component/manipulators/light/right
	materials = list(MATERIAL_STEEL = 30000, MATERIAL_PLASTIC = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/mech_r_arm/combat
	name = "right combat mech manipulator"
	id = "right_combat_arm"
	time = 30
	build_path = /obj/item/mech_component/manipulators/combat/right
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/mech_r_arm/heavy
	name = "right heavy mech manipulator"
	id = "right_heavy_arm"
	time = 45
	build_path =  /obj/item/mech_component/manipulators/heavy/right
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)
