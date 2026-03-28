// Design disk management and away-site design spawning

/obj/item/stock_parts/computer/hard_drive/proc/get_disk_name()
	var/datum/computer_file/data/text/D = find_file_by_name("DISK_NAME")
	if(!istype(D))
		return null

	return sanitizeSafe(D.stored_data, max_length = MAX_LNAME_LEN)


/obj/item/stock_parts/computer/hard_drive/portable/
	var/disk_name

/obj/item/stock_parts/computer/hard_drive/portable/design/
	name = "design disk"
	desc = "Data disk used to store autolathe designs."
	icon = 'mods/RnD/icons/discs.dmi'
	icon_state = "yellow"
	max_capacity = 512	// Up to 255 designs, automatically reduced to the nearest power of 2
	origin_tech = list(TECH_DATA = 3) // Most design disks end up being 64 to 128 GQ
	matter = list(MATERIAL_STEEL = 100, MATERIAL_PLASTIC = 200, MATERIAL_GOLD = 50)
	var/list/designs = list()

/obj/item/stock_parts/computer/hard_drive/portable/design/printable
	name = "design disk"
	desc = "Data disk used to store autolathe designs."
	icon = 'mods/RnD/icons/discs.dmi'

	max_capacity = 512	// Up to 255 designs, automatically reduced to the nearest power of 2

/obj/item/stock_parts/computer/hard_drive/portable/design/printable/New()
	. = ..()
	name = "Data disk"
	icon_state = pick("yellow", "blue", "green", "red", "purple", "black")
	max_capacity = 128

/obj/item/stock_parts/computer/hard_drive/portable/design/printable/install_default_programs()
	return


/obj/item/stock_parts/computer/hard_drive/portable/LateInitialize(mapload)
	install_default_programs()

/obj/item/stock_parts/computer/hard_drive/portable/design/install_default_programs()
	// Add design files to the disk
	if(name)
		var/datum/computer_file/data/text/D = new
		D.filename = "DISK_NAME"
		D.stored_data = name
		create_file(D)

	for(var/D in designs)
		var/datum/design/dsgn = D
		var/build = dsgn.build_path

		if(!dsgn)
			continue
		var/datum/design/autolathe/design = SSresearch.get_autolathe_design_by_build_path(build)
		if(!design)
			continue
		var/datum/computer_file/binary/design/design_file = design.file

		create_file(design_file)


	// Shave off the extra space so a disk with two designs doesn't show up as 1024 GQ
	while(max_capacity > 16 && max_capacity / 2 > used_capacity)
		max_capacity /= 2

	// Prevent people from breaking DRM by copying files across protected disks.
	// Stops people from screwing around with unprotected disks too.
	return TRUE

// Disks formated as /designpath = pointcost , if no point cost is specified it defaults to 1.


/obj/item/stock_parts/computer/hard_drive/portable/away/
	name = "Research Files"
	disk_name = "research files"


/obj/item/stock_parts/computer/hard_drive/proc/install_away_designs()
	var/numberdesigns = rand(1,10)
	var/datum/computer_file/data/text/D = new
	D.filename = "DISK_NAME"
	D.stored_data = name
	create_file(D)
	while(numberdesigns > 0)
		numberdesigns -= 1
		var/datum/design/design = pick(SSresearch.all_designs)
		if(!design)
			continue
		var/datum/computer_file/binary/design/design_file = design.file
		create_file(design_file)


	// Shave off the extra space so a disk with two designs doesn't show up as 1024 GQ
	while(max_capacity > 16 && max_capacity / 2 > used_capacity)
		max_capacity /= 2

	// Prevent people from breaking DRM by copying files across protected disks.
	// Stops people from screwing around with unprotected disks too.
	return TRUE

/obj/item/stock_parts/computer/hard_drive/proc/check_away_zone()
	var/area/A = get_area(src)
	if(!A)
		return FALSE
	// String-based check to avoid compile errors when away-site area types are not included
	var/area_path = "[A.type]"
	var/list/away_zone_prefixes = list(
		"/area/lar_maria",
		"/area/casino",
		"/area/meatstation",
		"/area/mine",
		"/area/bluespaceriver",
		"/area/constructionsite",
		"/area/lost_supply_base",
		"/area/magshield",
		"/area/map_template/oldlab2",
		"/area/map_template/marooned"
	)
	for(var/prefix in away_zone_prefixes)
		if(findtext(area_path, prefix, 1, length(prefix) + 1))
			return TRUE



/obj/machinery/computer/modular/Initialize()
	. = ..()
	var/obj/item/stock_parts/computer/hard_drive/disk = get_component_of_type(PART_HDD)
	if(disk.check_away_zone())
		if(prob(20))
			disk.install_away_designs()
