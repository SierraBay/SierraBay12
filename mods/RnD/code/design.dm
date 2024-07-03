/datum/computer_file/binary/design
	filetype = "CD" // Construction Design
	size = 4
	var/datum/design/design
	var/copy_protected = FALSE

/datum/computer_file/binary/design/clone()
	var/datum/computer_file/binary/design/F = ..()
	F.design = design
	F.copy_protected = copy_protected
	return F

/datum/computer_file/binary/design/proc/set_filename(new_name)
	filename = sanitizeFileName("[new_name]")
	if(findtext(filename, "datum_design_") == 1)
		filename = copytext(filename, 14)

/datum/computer_file/binary/design/proc/set_design_type(design_type)
	set_filename(design_type)
	design = design_type // Temporarily assign that to pass the type down into research controller

/datum/computer_file/binary/design/proc/on_design_set()
	set_filename(design.id)

/datum/computer_file/binary/design/ui_data()
	var/list/data = design.ui_data()
	data["copy_protected"] = copy_protected
	data["filename"] = filename
	return data
