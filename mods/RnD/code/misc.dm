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

/area/lar_maria
	name = "Lar Maria"

/area/casino
	name = "Casino"

/area/meatstation
	name = "Meat Station"

/area/lost_supply_base
	name = "Abandoned Supply Station"

/area/magshield
	name = "Magshield"

/obj/item/stock_parts/computer/hard_drive/proc/check_away_zone()
	var/area/area = get_area(src)
	if(area)
		var/list/reserchpointareas = list(/area/lar_maria, /area/casino, /area/meatstation, /area/mine, /area/bluespaceriver,
		/area/constructionsite, /area/lost_supply_base, /area/magshield, /area/map_template/oldlab2, /area/map_template/marooned)
		// Тут можно добавлять новые зоны где могут спавнится флешки и дизайны в компах
		for(var/a in reserchpointareas)
			if(area.type in subtypesof(a))
				return TRUE



/obj/machinery/computer/modular/Initialize()
	. = ..()
	var/obj/item/stock_parts/computer/hard_drive/disk = get_component_of_type(PART_HDD)
	if(disk.check_away_zone())
		if(prob(20))
			disk.install_away_designs()


// Xenobiology stuff

/obj/item/storage/xenobio
	name = "xenobiology satchel"
	desc = "This insulated bag can be used to store slime extracts and other potentially contaminated materials."
	icon = 'mods/RnD/icons/biobag.dmi'
	icon_state = "biobag"
	slot_flags = SLOT_BELT
	max_storage_space = 100
	max_w_class = ITEM_SIZE_NORMAL
	w_class = ITEM_SIZE_NORMAL
	contents_allowed = list(
		/obj/item/slime_extract,
		/obj/item/slimesteroid,
		/obj/item/slimesteroid2,
		/obj/item/slimepotion,
		/obj/item/slimepotion2,
		/obj/item/slimepotion3,
		/obj/item/reagent_containers/food/snacks/monkeycube
	)
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE

// ТУДУ Ебануть сюда спрайт с Ауроры

/obj/item/device/weather_sensor
	name = "weather data collection sensor"
	desc = "A portable atmospheric and environmental data collection device. Deploy it in various locations to record local weather patterns."
	icon = 'icons/obj/modular_components.dmi'
	icon_state = "power_cell"
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 100, MATERIAL_PLASTIC = 50)
	var/deployed = FALSE
	var/datum/rnd_mission/linked_mission

/obj/item/device/weather_sensor/attack_self(mob/user)
	if(deployed)
		to_chat(user, SPAN_WARNING("\The [src] has already been deployed and locked!"))
		return

	if(!istype(get_area(src), /area/exoplanet))
		to_chat(user, SPAN_WARNING("\The [src] must be deployed on a planetary surface!"))
		return

	to_chat(user, SPAN_NOTICE("You begin deploying \the [src]..."))
	if(!do_after(user, 3 SECONDS, src))
		return

	deployed = TRUE
	anchored = TRUE
	to_chat(user, SPAN_NOTICE("You deploy and activate \the [src]. It begins recording environmental data."))

/*
	for(var/obj/machinery/computer/rd_mission_console/console in world)
		for(var/datum/rnd_mission/mission in console.active_missions)
			if(mission.mission_type == RND_MISSION_TYPE_WEATHER_DATA && mission.state == RND_MISSION_STATE_ACCEPTED)
				mission.register_weather_sensor(src, user)
				break
*/
	if(deployed)
		to_chat(user, SPAN_NOTICE("The sensor is deployed and actively recording data."))
		var/turf/T = get_turf(src)
		var/area/A = get_area(src)
		if(T && A)
			to_chat(user, SPAN_NOTICE("Location: [A.name] ([T.x], [T.y], [T.z])"))
	else
		to_chat(user, SPAN_NOTICE("The sensor can be deployed on a planetary surface."))
