// ─── RnD категория на базовом hard_drive ─────────────────────────────────────
// Категория назначается через интерфейс R&D сервера (панель управления).

/obj/item/stock_parts/computer/hard_drive
	/// R&D категория дизайнов на этом диске. Null = не назначено.
	var/rnd_category = null


/obj/structure/noticeboard/science_nt
	name = "Доска объявлений НИО"

/obj/structure/noticeboard/science_nt/Initialize()
	. = ..()
	var/obj/item/paper/science_account/P = new()
	P.stamped = list(/obj/item/stamp/rd)
	P.AddOverlays("paper_stamp-circle")
	add_paper(P)


// Бумажка с реквизитами счёта НИО — показывает актуальный счёт в момент чтения
/obj/item/paper/science_account
	name = "реквизиты счёта НИО"
	info = "<h3>Реквизиты счёта НИО</h3>"

/obj/item/paper/science_account/show_content(mob/user, force, editable)
	// Подставляем актуальные данные счёта прямо перед показом
	var/datum/money_account/A = department_accounts["Научный"]
	if(A)
		info = "<h3>Реквизиты счёта НИО</h3><hr><b>Название счёта:</b> [A.account_name]<br><b>Номер счёта:</b> [A.account_number]<br>"
	else
		info = "<h3>Реквизиты счёта НИО</h3><hr><i>Счёт ещё не создан (раунд не начался).</i>"
	return ..()

/obj/item/paper/science_account/examine(mob/user, distance)
	var/datum/money_account/A = department_accounts["Научный"]
	if(A)
		info = "<h3>Реквизиты счёта НИО</h3><hr><b>Название счёта:</b> [A.account_name]<br><b>Номер счёта:</b> [A.account_number]<br>"
	return ..()

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


/obj/item/rig_module/datajack/accepts_item(obj/item/input_device, mob/living/user)

	if(istype(input_device, /obj/machinery))
		var/datum/research/incoming_files
		if(istype(input_device, /obj/machinery/computer/rdconsole))
			var/obj/machinery/computer/rdconsole/input_machine = input_device
			incoming_files = input_machine.get_server_files()
		else if(istype(input_device, /obj/machinery/r_n_d/server))
			var/obj/machinery/r_n_d/server/input_machine = input_device
			incoming_files = input_machine.files

		if(!incoming_files || !length(incoming_files.researched_tech))
			to_chat(user, SPAN_WARNING("Memory failure. There is nothing accessible stored on this terminal."))
		else
			if(load_data(incoming_files))
				to_chat(user, SPAN_INFO("Download successful; local and remote repositories synchronized."))
			else
				to_chat(user, SPAN_WARNING("Scan complete. There is nothing useful stored on this terminal."))
		return 1
	return 0

/obj/item/stock_parts/circuitboard/rdserver/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(!isScrewdriver(I))
		return ..()
	if(istype(loc, /obj/machinery))
		return ..()
	if(build_path == /obj/machinery/r_n_d/server)
		build_path = /obj/machinery/r_n_d/server/core
		SetName("circuit board (R&D core server)")
		to_chat(user, SPAN_NOTICE("Вы перенастраиваете плату под core сервер."))
	else
		build_path = /obj/machinery/r_n_d/server
		SetName("circuit board (R&D server)")
		to_chat(user, SPAN_NOTICE("Вы перенастраиваете плату под стандартный сервер."))
	playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
	return TRUE
