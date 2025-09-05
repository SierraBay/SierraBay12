/datum/design/item/mechfab/mech_body
	category = list("Mech cockpit")

/datum/design/item/mechfab/mech_body/powerloader
	name = "powerloader mech chassis"
	id = "powerloader_body"
	time = 30
	build_path = /obj/item/mech_component/chassis/powerloader
	materials = list(MATERIAL_STEEL = 20000)

/datum/design/item/mechfab/mech_body/light
	name = "light mech chassis"
	id = "light_body"
	time = 30
	build_path = /obj/item/mech_component/chassis/light
	materials = list(MATERIAL_STEEL = 100000, MATERIAL_ALUMINIUM = 20000, MATERIAL_PLASTIC = 10000)

/datum/design/item/mechfab/mech_body/sphere
	name = "sphere mech chassis"
	id = "sphere_body"
	time = 45
	build_path = /obj/item/mech_component/chassis/pod
	materials = list(MATERIAL_STEEL = 54000, MATERIAL_ALUMINIUM = 10000, MATERIAL_PLASTIC = 10000)

/datum/design/item/mechfab/mech_body/combat
	name = "combat mech chassis"
	id = "combat_body"
	time = 60
	build_path = /obj/item/mech_component/chassis/combat
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 135000, MATERIAL_PLASTEEL = 10000, MATERIAL_ALUMINIUM = 40000)

/datum/design/item/mechfab/mech_body/heavy
	name = "heavy mech chassis"
	id = "heavy_body"
	time = 75
	build_path = /obj/item/mech_component/chassis/heavy
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 210000, MATERIAL_URANIUM = 10000, MATERIAL_PLASTEEL = 40000, MATERIAL_ALUMINIUM = 40000)
