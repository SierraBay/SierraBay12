/datum/design/item/mechfab/mech_r_leg
	category = list("Mech right leg")

/datum/design/item/mechfab/mech_r_leg/powerloadert
	name = "right power loader motivator"
	id = "right_powerloader_leg"
	time = 15
	build_path =  /obj/item/mech_component/propulsion/powerloader/right
	materials = list(MATERIAL_STEEL = 10000)

/datum/design/item/mechfab/mech_r_leg/light
	name = "right light mech motivator"
	id = "right_light_leg"
	time = 15
	build_path =  /obj/item/mech_component/propulsion/light/right
	materials = list(MATERIAL_STEEL = 30000, MATERIAL_PLASTIC = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/mech_r_leg/combat
	name = "right combat mech motivator"
	id = "right_combat_leg"
	time = 30
	build_path =  /obj/item/mech_component/propulsion/combat/right
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/mech_r_leg/heavy
	name = "right heavy mech motivator"
	id = "right_heavy_leg"
	time = 45
	build_path = /obj/item/mech_component/propulsion/heavy/right
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)
