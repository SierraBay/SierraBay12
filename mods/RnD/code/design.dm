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

