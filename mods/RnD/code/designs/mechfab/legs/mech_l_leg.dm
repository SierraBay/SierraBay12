/datum/design/item/mechfab/mech_l_leg
	category = list("Mech left leg")

/datum/design/item/mechfab/mech_l_leg/powerloader
	name = "left power loader motivator"
	id = "left_powerloader_leg"
	time = 15
	build_path =  /obj/item/mech_component/propulsion/powerloader
	materials = list(MATERIAL_STEEL = 10000)

/datum/design/item/mechfab/mech_l_leg/light
	name = "left light mech motivator"
	id = "left_light_leg"
	time = 15
	build_path =  /obj/item/mech_component/propulsion/light
	materials = list(MATERIAL_STEEL = 30000, MATERIAL_PLASTIC = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/mech_l_leg/combat
	name = "left combat mech motivator"
	id = "left_combat_leg"
	time = 30
	build_path =  /obj/item/mech_component/propulsion/combat
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/mech_l_leg/heavy
	name = "left heavy mech motivator"
	id = "left_heavy_leg"
	time = 45
	build_path = /obj/item/mech_component/propulsion/heavy
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)
