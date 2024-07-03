// /binary/ files store information that shouldn't be editable by players.
// Think autolathe designs, R&D patterns, DNA, neurographs, etc.
/datum/computer_file/binary
	filetype = "BIN"


/proc/sanitizeFileName(input)
	input = replace_characters(input, list(" "="_", "\\" = "_", "\""="'", "/" = "_", ":" = "_", "*" = "_", "?" = "_", "|" = "_", "<" = "_", ">" = "_", "#" = "_"))
	if(findtext(input,"_") == 1)
		input = copytext(input, 2)
	return input

/obj/item/stock_parts/computer/hard_drive/proc/find_files_by_type(typepath)
	var/list/files = list()

	if(!check_functionality())
		return files

	if(!typepath)
		return files

	for(var/f in stored_files)
		if(istype(f, typepath))
			files += f

	return files
