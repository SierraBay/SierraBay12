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

/datum/computer_file/binary/design/proc/set_filename(new_name)
	filename = sanitizeFileName("[new_name]")
	if(findtext(filename, "datum_design_") == 1)
		filename = copytext(filename, 14)

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

/datum/design/circuit/scrap_crusher
	name = "crusher"
	id = "crusher"
	req_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 3, TECH_DATA = 3)
	build_path = /obj/item/stock_parts/circuitboard/crusher
	sort_string = "KCASA"

/datum/design/circuit/scrap_ripper
	name = "pile ripper"
	id = "pile_ripper"
	req_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 2)
	build_path = /obj/item/stock_parts/circuitboard/pile_ripper
	sort_string = "KCASB"

/datum/design/circuit/srcap_recycler
	name = "recycler"
	id = "recycler"
	req_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 2)
	build_path = /obj/item/stock_parts/circuitboard/recycler
	sort_string = "KCASC"

/datum/design/circuit/area_atmos
	name = "area atmos"
	id = "area_atmos"
	req_tech = list(TECH_DATA = 2)
	build_path = /obj/item/stock_parts/circuitboard/area_atmos
	sort_string = "KCAAR"

/datum/design/circuit/emitter
	name = "emitter"
	id = "emitter"
	req_tech = list(TECH_POWER = 4, TECH_ENGINEERING = 3)
	build_path = /obj/item/stock_parts/circuitboard/emitter
	sort_string = "KCASE"

/obj/item/stock_parts/circuitboard/emitter
	name = "circuit board (emitter)"
	board_type = "machine"
	origin_tech = list(TECH_POWER = 4, TECH_ENGINEERING = 3)
	build_path = /obj/machinery/power/emitter
	req_components = list(
		/obj/item/stock_parts/capacitor/ = 2,
		/obj/item/stock_parts/micro_laser/ = 3
	)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/datum/design/circuit/rad_collector
	name = "radiation collector"
	id = "radiation_collector"
	req_tech = list(TECH_POWER = 4, TECH_ENGINEERING = 4, TECH_PHORON = 3)
	build_path = /obj/item/stock_parts/circuitboard/rad_collector
	sort_string = "KCASR"

/obj/item/stock_parts/circuitboard/rad_collector
	name = "circuit board (radiation collector array)"
	board_type = "machine"
	origin_tech = list(TECH_POWER = 4, TECH_ENGINEERING = 4, TECH_PHORON = 3)
	build_path = /obj/machinery/power/rad_collector
	req_components = list(
		/obj/item/stock_parts/manipulator/ = 2,
		/obj/item/stock_parts/capacitor/ = 2
	)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/datum/design/circuit/traffic_console
	name = "telecommunications traffic control console"
	id = "teletraffic"
	req_tech = list(TECH_DATA = 3)
	build_path = /obj/item/stock_parts/circuitboard/comm_traffic
	sort_string = "KCAST"

/obj/item/stock_parts/circuitboard/comm_traffic
	name = "circuit board (telecommunications traffic control console)"
	build_path = /obj/machinery/computer/telecomms/traffic
	origin_tech = list(TECH_DATA = 3)
