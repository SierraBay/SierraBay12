/datum/design/item/mechfab/mech_l_arm
	category = list("Mech left arm")

/datum/design/item/mechfab/mech_l_arm/powerloader
	name = "left power loader manipulator"
	id = "left_powerloader_arm"
	time = 15
	build_path =  /obj/item/mech_component/manipulators/powerloader
	materials = list(MATERIAL_STEEL = 10000)

/datum/design/item/mechfab/mech_l_arm/light
	name = "left light mech manipulator"
	id = "left_light_arm"
	time = 15
	build_path =  /obj/item/mech_component/manipulators/light
	materials = list(MATERIAL_STEEL = 30000, MATERIAL_PLASTIC = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/mech_l_arm/combat
	name = "left combat mech manipulator"
	id = "left_combat_arm"
	time = 30
	build_path = /obj/item/mech_component/manipulators/combat
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/mech_l_arm/heavy
	name = "left heavy mech manipulator"
	id = "left_heavy_arm"
	time = 45
	build_path =  /obj/item/mech_component/manipulators/heavy
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)
