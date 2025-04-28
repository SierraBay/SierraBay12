/datum/design/item/mech/rcd
	name = "RCD"
	id = "mech_rcd"
	time = 90
	materials = list(MATERIAL_STEEL = 30000, MATERIAL_PHORON = 25000, MATERIAL_SILVER = 15000, MATERIAL_GOLD = 15000)
	req_tech = list(TECH_MATERIAL = 4, TECH_BLUESPACE = 3, TECH_MAGNET = 4, TECH_POWER = 4, TECH_ENGINEERING = 4)
	build_path = /obj/item/mech_equipment/mounted_system/rcd

/datum/design/item/mech/extinguisher
	name = "mounted extinguisher"
	id   = "mech_extinguisher"
	build_path = /obj/item/mech_equipment/mounted_system/extinguisher

/datum/design/item/mech/ionjets
	name = "exosuit manouvering unit"
	id = "mech_ionjets"
	time = 30
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_ALUMINIUM = 10000, MATERIAL_PHORON = 2500)
	req_tech = list(TECH_ENGINEERING = 2, TECH_MAGNET = 2)
	build_path = /obj/item/mech_equipment/ionjets

/datum/design/item/mech/mechshields/air
	name = "exosuit atmospheric shields"
	id = "mech_atmoshields"
	time = 30
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_ALUMINIUM = 5000, MATERIAL_GLASS = 5000, MATERIAL_PHORON = 2500)
	req_tech = list(TECH_ENGINEERING = 2, TECH_MAGNET = 2)
	build_path = /obj/item/mech_equipment/atmos_shields
