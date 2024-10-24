/datum/design/item/disk
	category = list("Misc")

	materials = list(MATERIAL_PLASTIC = 30, MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)

/datum/design/item/disk/tech
	name = "technology data"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	req_tech = list(TECH_DATA = 1)
	build_path = /obj/item/disk/tech_disk
	sort_string = "AAAAB"

/datum/design/item/disk/flora
	name = "flora data"
	desc = "Produce additional disks for storing flora genetic data."
	id = "flora_disk"
	req_tech = list(TECH_DATA = 1)
	build_path = /obj/item/disk/botany
	sort_string = "AAAAC"
