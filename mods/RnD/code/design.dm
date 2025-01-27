/datum/computer_file/binary/design
	filetype = "CD" // Construction Design
	size = 2
	var/datum/design/design

/datum/computer_file/binary/design/clone()
	var/datum/computer_file/binary/design/F = ..()
	F.design = design
	return F

/datum/computer_file/binary/design/proc/setsize()
	if(design.req_tech)
		for(var/I in design.req_tech)
			size += 1
	return size

/datum/computer_file/binary/design/proc/on_design_set()
	if(design)
		set_filename(design.name)

/datum/computer_file/binary/design/proc/set_filename(new_name)
	filename = sanitizeFileName("[new_name]")
	if(findtext(filename, "datum_design_") == 1)
		filename = copytext(filename, 14)

/datum/computer_file/binary/design/proc/set_design_type(design_type)
	set_filename(design_type)
	design = design_type // Temporarily assign that to pass the type down into research controller
	SSresearch.initialize_design_file(src)


/datum/computer_file/binary/design/ui_data()
	var/list/data = design.ui_data()
	data["filename"] = filename
	return data


/datum/computer_file/binary/photo
	filetype = "DNG"
	size = 4
	var/obj/item/photo/photo
	var/assetname

/datum/computer_file/binary/photo/clone()
	var/datum/computer_file/binary/photo/F = ..()
	F.photo = photo
	F.assetname = assetname
	return F

/datum/computer_file/binary/photo/proc/set_filename(new_name)
	filename = sanitizeFileName("photo [new_name]")

/datum/computer_file/binary/photo/proc/generate_photo_data(mob/user, photo)
	send_asset(user.client, assetname)
	return "<img src='[assetname]' width='90%'><br>"

/datum/computer_file/binary/sci
	filetype = "SF" // Science Folded
	size = 1
	var/uniquekey

/datum/computer_file/binary/sci/proc/set_filename(new_name)
	filename = sanitizeFileName("folded_science [new_name]")


/datum/computer_file/binary/sci/clone()
	var/datum/computer_file/binary/sci/F = ..()
	F.uniquekey = uniquekey
	return F


/datum/design/item/tool/jetpack
	shortname = "Jetpack"
	name = "Jetpack"
	desc = "The O'Neill Manufacturing VMU-11-C is a tank-based propulsion unit that utilizes compressed carbon dioxide for moving in zero-gravity areas. <span class='danger'>The label on the side indicates it should not be used as a source for internals.</span>."
	id = "jetpack"
	req_tech = list(TECH_ENGINEERING = 5, TECH_MATERIAL = 5)
	materials = list(MATERIAL_STEEL = 12000, MATERIAL_GLASS = 10000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/tank/jetpack/carbondioxide
	sort_string = "VAGAM"

/datum/design/circuit/area_atmos
	name = "area atmos"
	id = "area_atmos"
	req_tech = list(TECH_DATA = 2)
	build_path = /obj/item/stock_parts/circuitboard/area_atmos
	sort_string = "KCAAR"



/datum/design/item/away/radio_jammer

	name = "small remote"
	desc = "A small remote control covered in a number of lights, with several antennae extending from the top."
	req_tech = list(TECH_ENGINEERING = 5, TECH_DATA = 5)
	materials = list(MATERIAL_GOLD = 8000, MATERIAL_GLASS = 8000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/device/radio_jammer
	sort_string = "ZAAAA"

/datum/design/item/away/hacktool
	name = "hacktool"
	desc = "This small, handheld device is made of durable, insulated plastic, and tipped with electrodes, perfect for interfacing with numerous machines."
	req_tech = list(TECH_ENGINEERING = 4, TECH_DATA = 3)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_GLASS = 8000, MATERIAL_SILVER = 2000, MATERIAL_PLASTIC = 5000)
	build_path = /obj/item/device/multitool/hacktool
	sort_string = "ZAAAB"

/datum/design/item/away/energyshield
	name = "energy shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/item/shield/energy
	sort_string = "ZAAAC"

/datum/design/item/away/personal_shield
	name = "personal shield"
	desc = "Truly a life-saver: this device protects its user from being hit by objects moving very, very fast, as long as it holds a charge."
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/item/device/personal_shield
	sort_string = "ZAAAD"

/datum/design/item/away/ai_mask
	name = "ai mask"
	desc = "A mask that can be used to hide the identity of an AI."
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/item/clothing/mask/ai
	sort_string = "ZAAAE"

/datum/design/item/away/anti_photon
	desc = "An experimental device for temporarily removing light in a limited area."
	name = "photon disruption grenade"
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/item/grenade/anti_photon
	sort_string = "ZAAAF"

/datum/design/item/away/empgrenade
	name = "classic emp grenade"
	desc = "A classic emp grenade, with a high yield and a long range."
	req_tech = list(TECH_MATERIAL = 2, TECH_MAGNET = 3)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/item/grenade/empgrenade
	sort_string = "ZAAAG"

/datum/design/item/away/frag
	name = "fragmentation grenade"
	desc = "A military fragmentation grenade, designed to explode in a deadly shower of fragments, while avoiding massive structural damage."
	req_tech = list(TECH_MATERIAL = 2, TECH_MAGNET = 3)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/item/grenade/frag
	sort_string = "ZAAAH"

/datum/design/item/away/supermatter
	name = "supermatter grenade"
	desc = "A highly experimental supermatter grenade."
	req_tech = list(TECH_MATERIAL = 2, TECH_MAGNET = 3)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/item/grenade/supermatter
	sort_string = "ZAAAI"

/datum/design/item/away/rigvoice
	name = "hardsuit voice synthesiser"
	desc = "A speaker box and sound processor."
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/item/rig_module/voice
	sort_string = "ZAAAJ"

/datum/design/item/away/disperser_charge/explosive
	name = "explosive disperser charge"
	desc = "An explosive disperser charge."
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/structure/ship_munition/disperser_charge/explosive
	sort_string = "ZAAAK"

/datum/design/item/away/disperser_charge/fire
	name = "fire disperser charge"
	desc = "A fire disperser charge."
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/structure/ship_munition/disperser_charge/fire
	sort_string = "ZAAAL"

/datum/design/item/away/disperser_charge/emp
	name = "emp disperser charge"
	desc = "An emp disperser charge."
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/structure/ship_munition/disperser_charge/emp
	sort_string = "ZAAAM"

/datum/design/item/away/disperser_charge/mining
	name = "mining disperser charge"
	desc = "A mining disperser charge."
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_GOLD = 10000, MATERIAL_PHORON = 8000, MATERIAL_SILVER = 2000, MATERIAL = 8000)
	build_path = /obj/structure/ship_munition/disperser_charge/mining
	sort_string = "ZAAAN"
