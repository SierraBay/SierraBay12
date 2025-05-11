/datum/design/item/mech/hydraulic_clamp
	name = "hydraulic clamp"
	id = "hydraulic_clamp"
	build_path = /obj/item/mech_equipment/clamp

/datum/design/item/mech/gravity_catapult
	name = "gravity catapult"
	id = "gravity_catapult"
	build_path = /obj/item/mech_equipment/catapult

/datum/design/item/mech/drill
	name = "drill"
	id = "mech_drill"
	build_path = /obj/item/mech_equipment/drill

/datum/design/item/mech/weapon/plasma
	name = "mounted plasma cutter"
	id = "mech_plasma"
	materials = list(MATERIAL_STEEL = 20000)
	req_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 4, TECH_ENGINEERING = 3)
	build_path = /obj/item/mech_equipment/mounted_system/taser/plasma

/datum/design/item/mech/weapon/plasma/auto
	name = "mounted rotatory plasma cutter"
	id = "mech_plasma_auto"
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_SILVER = 2000, MATERIAL_GOLD = 2000)
	req_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 5, TECH_ENGINEERING = 3)
	build_path = /obj/item/mech_equipment/mounted_system/taser/autoplasma

/datum/design/item/mech/floodlight
	name = "floodlight"
	id = "mech_floodlight"
	req_tech = list(TECH_ENGINEERING = 1)
	build_path = /obj/item/mech_equipment/light

/datum/design/item/mech/camera
	name = "mounter mech camera"
	id = "mech_camera"
	req_tech = list(TECH_ENGINEERING = 1)
	build_path = /obj/item/mech_equipment/camera

/datum/design/item/mech/circuit
	name = "mech circuit rack"
	id = "mech_circuit"
	build_path = /obj/item/mech_equipment/mounted_system/circuit
