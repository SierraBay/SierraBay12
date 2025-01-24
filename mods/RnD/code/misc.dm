/obj/item/photo/use_tool(obj/item/P, mob/living/user)
	. = ..()
	if(istype(P, /obj/item/flame))
		burnphoto(P, user)

/obj/item/photo/proc/burnphoto(obj/item/flame/P, mob/user)
	var/class = "warning"

	if(P.lit && !user.restrained())
		if(istype(P, /obj/item/flame/lighter/zippo))
			class = "rose"

		user.visible_message("<span class='[class]'>[user] holds \the [P] up to \the [src], it looks like \he's trying to burn it!</span>", \
		"<span class='[class]'>You hold \the [P] up to \the [src], burning it slowly.</span>")

		if (do_after(user, 5 SECONDS, src, DO_PUBLIC_UNIQUE))
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("<span class='[class]'>[user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
				"<span class='[class]'>You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")
				new /obj/decal/cleanable/ash(get_turf(src))
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")
		else
			to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")

/obj/item/stock_parts/computer/hard_drive/ui_data()
	var/list/data = list(
		"disk_name" = get_disk_name(),
		"max_capacity" = max_capacity,
		"used_capacity" = used_capacity
	)

	var/list/files = list()
	for(var/datum/computer_file/F in stored_files)
		files.Add(list(list(
			"filename" = F.filename,
			"filetype" = F.filetype,
			"size" = F.size,
			"undeletable" = F.undeletable
		)))
	data["files"] = files
	return data

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

/area/lar_maria
	name = "Lar Maria"

/area/casino
	name = "Casino"

/area/meatstation
	name = "Meat Station"

/obj/item/stock_parts/computer/hard_drive/proc/check_away_zone()
	var/area/area = get_area(src)
	var/list/reserchpointareas = list(/area/lar_maria, /area/casino, /area/meatstation, /area/mine, /area/bluespaceriver)
	// Тут можно добавлять новые зоны где могут спавнится флешки и дизайны в компах
	for(var/a in reserchpointareas)
		if(area.type in subtypesof(a))
			return TRUE



/obj/item/stock_parts/computer/hard_drive/portable/away/research_data
	name = "Research Data"
	disk_name = "research data"
	var/min_points = 2000
	var/max_points = 10000

/obj/item/stock_parts/computer/hard_drive/portable/away/research_data/install_default_programs()
	. = ..()
	var/datum/computer_file/binary/sci/F = new
	create_file(F)
	F.size = rand(min_points / 1000, max_points / 1000)

/obj/item/stock_parts/computer/hard_drive/portable/away/research_data/rare
	min_points = 15000
	max_points = 25000

/obj/machinery/computer/modular/Initialize()
	. = ..()
	var/obj/item/stock_parts/computer/hard_drive/disk = get_component_of_type(PART_HDD)
	if(disk.check_away_zone())
		if(prob(10))
			if(prob(20))
				portable_drive = new /obj/item/stock_parts/computer/hard_drive/portable/away/research_data/rare
			else
				portable_drive = new /obj/item/stock_parts/computer/hard_drive/portable/away/research_data
			verbs += /obj/machinery/computer/modular/proc/eject_usb
		else if(prob(20))
			disk.install_away_designs()
