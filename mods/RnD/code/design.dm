/datum/computer_file/binary/design
	filetype = "CD" // Construction Design
	size = 4
	var/datum/design/design

/datum/computer_file/binary/design/clone()
	var/datum/computer_file/binary/design/F = ..()
	F.design = design
	return F

/datum/computer_file/binary/design/proc/set_filename(new_name)
	filename = sanitizeFileName("[new_name]")
	if(findtext(filename, "datum_design_") == 1)
		filename = copytext(filename, 14)

/datum/computer_file/binary/design/ui_data()
	var/list/data = design.ui_data()
	data["filename"] = filename
	return data
