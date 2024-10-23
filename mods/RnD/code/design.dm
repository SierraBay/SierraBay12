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
