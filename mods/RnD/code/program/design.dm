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


/datum/computer_file/binary/design/corrupted
	filetype = "CCD" // Corrupted Construction Design
	filename = "ERROR"


///////////////////////////////// Designs //////////////////////////////////////////////////////////////////////////

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
	id = "radio_jammer"
	req_tech = list(TECH_ENGINEERING = 5, TECH_DATA = 5)
	materials = list(MATERIAL_STEEL = 12000, MATERIAL_GLASS = 10000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/device/radio_jammer
	sort_string = "ZAAAA"

/datum/design/item/away/hacktool
	name = "hacktool"
	desc = "This small, handheld device is made of durable, insulated plastic, and tipped with electrodes, perfect for interfacing with numerous machines."
	id = "hacktool"
	req_tech = list(TECH_ENGINEERING = 4, TECH_DATA = 3)
	materials = list(MATERIAL_STEEL = 12000, MATERIAL_GLASS = 10000, MATERIAL_SILVER = 2000, MATERIAL_GOLD = 2000)
	build_path = /obj/item/device/multitool/hacktool
	sort_string = "ZAAAB"

/datum/design/item/away/energyshield
	name = "energy shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	id = "energyshield"
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_STEEL = 12000, MATERIAL_URANIUM = 10000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/shield/energy
	sort_string = "ZAAAC"

/datum/design/item/away/personal_shield
	name = "personal shield"
	desc = "Truly a life-saver: this device protects its user from being hit by objects moving very, very fast, as long as it holds a charge."
	id = "personal_shield"
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_STEEL = 12000, MATERIAL_URANIUM = 10000, MATERIAL_GOLD = 2000)
	build_path = /obj/item/device/personal_shield
	sort_string = "ZAAAD"

/datum/design/item/away/ai_mask
	name = "ai mask"
	desc = "A mask that can be used to hide the identity of an AI."
	id = "ai_mask"
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_STEEL = 12000, MATERIAL_GOLD = 10000, MATERIAL_SILVER = 4000)
	build_path = /obj/item/clothing/mask/ai
	sort_string = "ZAAAE"

/datum/design/item/away/anti_photon
	desc = "An experimental device for temporarily removing light in a limited area."
	name = "photon disruption grenade"
	id = "anti_photon"
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_STEEL = 4000, MATERIAL_GLASS = 2000, MATERIAL_SILVER = 1000)
	build_path = /obj/item/grenade/anti_photon
	sort_string = "ZAAAF"

/datum/design/item/away/empgrenade
	name = "classic emp grenade"
	desc = "A classic emp grenade, with a high yield and a long range."
	id = "empgrenade"
	req_tech = list(TECH_MATERIAL = 2, TECH_MAGNET = 3)
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 2000, MATERIAL_URANIUM = 2000)
	build_path = /obj/item/grenade/empgrenade
	sort_string = "ZAAAG"

/datum/design/item/away/frag
	name = "fragmentation grenade"
	desc = "A military fragmentation grenade, designed to explode in a deadly shower of fragments, while avoiding massive structural damage."
	id = "frag"
	req_tech = list(TECH_MATERIAL = 2, TECH_MAGNET = 3)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_GLASS = 4000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/grenade/frag
	sort_string = "ZAAAH"

/datum/design/item/away/supermatter
	name = "supermatter grenade"
	desc = "A highly experimental supermatter grenade."
	id = "supermatter"
	req_tech = list(TECH_MATERIAL = 2, TECH_MAGNET = 3)
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_PHORON = 40000, MATERIAL_SILVER = 8000)
	build_path = /obj/item/grenade/supermatter
	sort_string = "ZAAAI"

/datum/design/item/away/rigvoice
	name = "hardsuit voice synthesiser"
	desc = "A speaker box and sound processor."
	id = "rigvoice"
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ESOTERIC = 4)
	materials = list(MATERIAL_STEEL = 12000, MATERIAL_GLASS = 10000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/rig_module/voice
	sort_string = "ZAAAJ"

/datum/design/item/away/disperser_charge/explosive
	name = "explosive disperser charge"
	desc = "An explosive disperser charge."
	id = "explosive_disperser_charge"
	req_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3)
	materials = list(MATERIAL_STEEL = 40000, MATERIAL_GLASS = 30000, MATERIAL_PHORON = 15000)
	build_path = /obj/structure/ship_munition/disperser_charge/explosive
	sort_string = "ZAAAK"

/datum/design/item/away/disperser_charge/fire
	name = "fire disperser charge"
	desc = "A fire disperser charge."
	id = "fire_disperser_charge"
	req_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3)
	materials = list(MATERIAL_STEEL = 40000, MATERIAL_GLASS = 30000, MATERIAL_PHORON = 10000)
	build_path = /obj/structure/ship_munition/disperser_charge/fire
	sort_string = "ZAAAL"

/datum/design/item/away/disperser_charge/emp
	name = "emp disperser charge"
	desc = "An emp disperser charge."
	id = "emp_disperser_charge"
	req_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3)
	materials = list(MATERIAL_STEEL = 40000, MATERIAL_GLASS = 30000, MATERIAL_URANIUM = 10000)
	build_path = /obj/structure/ship_munition/disperser_charge/emp
	sort_string = "ZAAAM"

/datum/design/item/away/disperser_charge/mining
	name = "mining disperser charge"
	desc = "A mining disperser charge."
	id = "mining_disperser_charge"
	req_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3)
	materials = list(MATERIAL_STEEL = 50000, MATERIAL_GLASS = 40000)
	build_path = /obj/structure/ship_munition/disperser_charge/mining
	sort_string = "ZAAAN"

/datum/design/item/away/military_sec
	name = "pistol"
	desc = "The NT Mk58 is a cheap, ubiquitous sidearm, produced by a NanoTrasen subsidiary. Found pretty much everywhere humans are."
	id = "military_sec"
	req_tech = list(TECH_MATERIAL = 4)
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_GLASS = 3000, MATERIAL_PLASTIC = 5000)
	build_path = /obj/item/gun/projectile/pistol/sec
	sort_string = "ZAAAO"

/datum/design/item/away/military_pistol_magnum
	name = "military pistol"
	desc = "The HelTek Magnus, a robust handgun that uses high-caliber ammo. Issued to Confederation Pioneers for holster sized defence."
	id = "military_pistol_magnum"
	req_tech = list(TECH_MATERIAL = 4)
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_GLASS = 5000, MATERIAL_PLASTIC = 8000)
	build_path = /obj/item/gun/projectile/pistol/magnum_pistol
	sort_string = "ZAAAP"

/datum/design/item/away/gyropistol
	name = "gyrojet pistol"
	desc = "A bulky pistol designed to fire self propelled rounds."
	id = "military_pistol_bobcat"
	req_tech = list(TECH_MATERIAL = 4)
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_GLASS = 4000, MATERIAL_PLASTIC = 4000)
	build_path = /obj/item/gun/projectile/pistol/gyropistol
	sort_string = "ZAAAQ"

/datum/design/item/away/battlerifle
	name = "battle rifle"
	desc = "The battle rifle hasn't changed much since its inception in the mid 20th century. Built to last in the toughest conditions, the select fire rifle is well reguarded as a dependable weapon."
	id = "battlerifle"
	req_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 1, TECH_ESOTERIC = 5)
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_DIAMOND = 8000, MATERIAL_SILVER = 12000)
	build_path = /obj/item/gun/projectile/automatic/battlerifle
	sort_string = "ZAAAR"

/datum/design/item/away/machine_pistol
	name = "machine pistol"
	desc = "A machine pistol, with a high capacity and a high rate of fire."
	id = "machine_pistol"
	req_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 1, TECH_ESOTERIC = 3)
	materials = list(MATERIAL_STEEL = 15000, MATERIAL_GLASS = 6000, MATERIAL_SILVER = 10000)
	build_path = /obj/item/gun/projectile/automatic/machine_pistol
	sort_string = "ZAAAS"

/datum/design/item/away/retro_laser
	name = "retro laser"
	desc = "An older model of the basic lasergun. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	id = "retro_laser"
	req_tech = list(TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_GLASS = 8000, MATERIAL_GOLD = 2000)
	build_path = /obj/item/gun/energy/retro
	sort_string = "ZAAAT"

/datum/design/item/away/doublebarrel
	name = "doublebarrel shotgun"
	desc = "A classic double-barreled shotgun. In production for centuries, it has proliferated across human space, earning a sizable reputation for being simple and effective. Produced by Novaya Zemlya Arms."
	id = "doublebarrel"
	req_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_WOOD = 12000, MATERIAL_PLASTIC = 2000)
	build_path = /obj/item/gun/projectile/shotgun/doublebarrel
	sort_string = "ZAAAU"

/datum/design/item/away/mine
	name = "mine"
	desc = "An explosive device that tends to detonate if you look at it wrong."
	id = "mine"
	req_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 6000, MATERIAL_GLASS = 8000, MATERIAL_URANIUM = 6000)
	build_path = /obj/structure/mine
	sort_string = "ZAAAV"

/datum/design/item/stunbaton
	name = "stun baton"
	desc = "A baton that can stun a target."
	id = "stunbaton"
	category = list("Weapon")
	req_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_PLASTIC = 10000)
	build_path = /obj/item/melee/baton
	sort_string = "ZAAAW"

/datum/design/item/away/katana
	name = "katana"
	desc = "A katana, a traditional Japanese sword."
	id = "katana"
	req_tech = list(TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 20000, MATERIAL_SILVER = 10000)
	build_path = /obj/item/material/sword/katana
	sort_string = "ZAAAX"

/datum/design/item/data_disk
	name = "data disk"
	desc = "A disk used to store data."
	id = "data_disk"
	category = list("Misc")
	req_tech = list(TECH_DATA = 2, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 200, MATERIAL_PLASTIC = 400)
	build_path = /obj/item/stock_parts/computer/hard_drive/portable/design/printable
	sort_string = "ZAAAY"

/datum/design/item/blutrash
	name = "Trashbag of Holding"
	desc = "An advanced trash bag with bluespace properties; capable of holding a plethora of garbage."
	id = "blutrash"
	req_tech = list(TECH_BLUESPACE = 5, TECH_MATERIAL = 6)
	materials = list(MATERIAL_PLASTIC = 5000, MATERIAL_GOLD = 1500, MATERIAL_URANIUM = 250, MATERIAL_PHORON = 1500)
	build_path = /obj/item/storage/bag/trash/bluespace
	category = list("Misc")


/datum/design/item/optical
	materials = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
	category = list("Optical")


/datum/design/item/weapon/large_grenade
	category = list("Misc")

/datum/design/circuit/dnaforensics

	name = "DNA analyzer"
	desc = "A high tech machine that is designed to read DNA samples properly."
	id = "dnaforensics"
	req_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4)
	build_path = /obj/item/stock_parts/circuitboard/dnaforensics
	sort_string = "VBGAM"

/obj/item/stock_parts/circuitboard/dnaforensics
	name = "circuit board (DNA analyzer)"
	build_path = /obj/machinery/computer/dnaforensics
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4)

/datum/design/circuit/microscope
	name = "high powered electron microscope"
	desc = "A highly advanced microscope capable of zooming up to 3000x."
	id = "microscope"
	req_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4)
	build_path = /obj/item/stock_parts/circuitboard/microscope
	sort_string = "VBGAN"

/obj/item/stock_parts/circuitboard/microscope
	name = "circuit board (microscope)"
	build_path = /obj/machinery/computer/microscope
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4)

/obj/item/net_shell
	matter = list(MATERIAL_STEEL = 50, MATERIAL_PLASTIC = 50)

/datum/stack_recipe/furniture/flaps
	title = "flaps"
	result_type = /obj/structure/plasticflaps
	req_amount = 5
	time = 50

/obj/item/device/t_scanner
	name = "T-ray scanner"
