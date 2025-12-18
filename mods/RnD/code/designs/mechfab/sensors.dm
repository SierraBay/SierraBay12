/datum/design/item/mechfab/mech_sensors
	category = list("Mech sensors")

/datum/design/item/mechfab/mech_sensors/powerloader
	name = "powerloader mech sensors"
	id = "powerloader_head"
	time = 15
	build_path = /obj/item/mech_component/sensors/powerloader
	materials = list(MATERIAL_STEEL = 5000)

/datum/design/item/mechfab/mech_sensors/light
	name = "light mech sensors"
	id = "light_head"
	time = 15
	build_path = /obj/item/mech_component/sensors/light
	materials = list(MATERIAL_STEEL = 24000, MATERIAL_ALUMINIUM = 10000, MATERIAL_PLASTIC = 10000, MATERIAL_GLASS = 10000)

/datum/design/item/mechfab/mech_sensors/combat
	name = "combat mech sensors"
	id = "combat_head"
	time = 30
	build_path = /obj/item/mech_component/sensors/combat
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)

/datum/design/item/mechfab/mech_sensors/heavy
	name = "heavy mech sensors"
	id = "heavy_head"
	time = 45
	build_path = /obj/item/mech_component/sensors/heavy
	req_tech = list(TECH_COMBAT = 4)
	materials = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)
