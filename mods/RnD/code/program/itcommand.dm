/// Shows and manipulates programs running on the computer
/datum/terminal_command/prog
	man_entry = list(
		"Format: prog \[-flag pid|filename\]",
		"Without options, list all programs currently running.",
		"With -f followed by pid (number), toggle the program between running in foreground or background.",
		"With -k and no further arguments, terminates all running programs.",
		"With -k followed by pid (number), terminates the specified program.",
		"With -x followed by filename, attempt to execute filename as a program.",
		"With -a and no further arguments, clears the autorun setting.",
		"With -a followed by filename, set autorun to use the specified filename.",
		"With -b and no further arguments, sets the backdoor access flag is on, for some running programs.",
		"NOTICE: Programs are executed using access credentials of the original terminal session."
	)

/datum/terminal_command/prog/proper_input_entered(text, mob/user, datum/terminal/terminal)
	. = syntax_error()
	var/list/arguments = get_arguments(text)
	if(isnull(arguments))
		return
	// Program list
	if(!length(arguments))
		. = list()
		. += "[name]: Listing running programs..."
		. += "PID Status Filename"
		for(var/datum/computer_file/program/P in terminal.computer.running_programs)
			if(P.program_state)
				. += "[P.uid] - [(P.program_state == PROGRAM_STATE_ACTIVE ? "active" : "bckgrn")] - [P.filename]"
		. += ""
	// Run command with flag only
	else if(length(arguments) == 1)
		if(arguments[1] == "-k")
			for(var/datum/computer_file/program/P in terminal.computer.running_programs)
				terminal.computer.kill_program_remote(P, 1)
			return "[name]: All running programs terminated."
		else if(arguments[1] == "-a")
			if(!terminal.computer.set_autorun(null))
				return "[name]: Error; could not modify autorun data."
			return "[name]: Autorun disabled"
		else if(arguments[1] == "-b")
			for(var/datum/computer_file/program/ntnetdesign/P in terminal.computer.running_programs)
				P.backdoor_access = !P.backdoor_access
				return "[P.filedesc]: Backdoor access set to [P.backdoor_access]."

	// Run command on a pid or filename
	else if(length(arguments) == 2)
		if(arguments[1] == "-f")
			var/datum/computer_file/program/P = get_program_by_pid(arguments[2], terminal)
			if(!istype(P))
				return "[name]: Error; invalid pid."
			(P.program_state == PROGRAM_STATE_ACTIVE ? terminal.computer.minimize_program() : terminal.computer.activate_program(P))
			return "[name]: Program focus toggled."
		else if(arguments[1] == "-k")
			var/datum/computer_file/program/P = get_program_by_pid(arguments[2], terminal)
			if(!istype(P))
				return "[name]: Error; invalid pid."
			terminal.computer.kill_program_remote(P, 1)
			return "[name]: Program [P.filename] terminated."
		else if(arguments[1] == "-x")
			var/datum/computer_file/program/P = terminal.computer.run_program_remote(arguments[2], user, 0)
			if(!istype(P))
				return "[name]: Error; unable to execute program '[arguments[2]]'."
			return "[name]: Program '[P.filename]' running with pid [P.uid]."
		else if(arguments[1] == "-a")
			if(!terminal.computer.set_autorun(arguments[2]))
				return "[name]: Error; could not modify autorun data."
			return "[name]: Autorun updated to '[arguments[2]]'"


/datum/computer_file/program/filemanager/Topic(href, href_list)
	if(..())
		return TOPIC_HANDLED

	if(href_list["PRG_openfile"])
		. = TOPIC_HANDLED
		open_file = href_list["PRG_openfile"]
	if(href_list["PRG_newtextfile"])
		. = TOPIC_HANDLED
		var/newtype = input(usr, "Choose file type.") in list("BATCH", "TXT", "CFG")
		var/newname = sanitize(input(usr, "Enter file name or leave blank to cancel:", "File rename"))
		if(!newname)
			return
		if(!computer.create_data_file(newname, file_type = /datum/computer_file/data/text))
			error = "File error: Unable to create file on disk."
			return
		switch(newtype)
			if("TXT")
				computer.create_data_file(newname, file_type = /datum/computer_file/data/text)
			if("BATCH")
				computer.create_data_file(newname, file_type = /datum/computer_file/data/coding/batch)
			if("CFG")
				computer.create_data_file(newname, file_type = /datum/computer_file/data/config)
	if(href_list["PRG_deletefile"])
		. = TOPIC_HANDLED
		computer.delete_file(href_list["PRG_deletefile"])
	if(href_list["PRG_clone"])
		. = TOPIC_HANDLED
		computer.clone_file(href_list["PRG_clone"])
	if(href_list["PRG_rename"])
		. = TOPIC_HANDLED
		var/newname = sanitize(input(usr, "Enter new file name:", "File rename", href_list["PRG_rename"]))
		if(!newname)
			return
		if(!computer.rename_file(href_list["PRG_rename"], newname))
			error = "File error: Unable to rename file."
			return
	if(href_list["PRG_usbdeletefile"])
		. = TOPIC_HANDLED
		if(istype(computer.holder, /obj/machinery/computer/modular))
			var/obj/machinery/computer/modular/modular_machine = computer.holder
			computer.delete_file(href_list["PRG_usbdeletefile"], modular_machine.portable_drive)
		else
			computer.delete_file(href_list["PRG_usbdeletefile"], computer.get_component(PART_DRIVE))
	if(href_list["PRG_copytousb"])
		. = TOPIC_HANDLED
		if(istype(computer.holder, /obj/machinery/computer/modular))
			var/obj/machinery/computer/modular/modular_machine = computer.holder
			computer.copy_between_disks(href_list["PRG_copytousb"], computer.get_component(PART_HDD), modular_machine.portable_drive)
		else
			computer.copy_between_disks(href_list["PRG_copytousb"], computer.get_component(PART_HDD), computer.get_component(PART_DRIVE))
	if(href_list["PRG_copyfromusb"])
		. = TOPIC_HANDLED
		if(istype(computer.holder, /obj/machinery/computer/modular))
			var/obj/machinery/computer/modular/modular_machine = computer.holder
			computer.copy_between_disks(href_list["PRG_copyfromusb"], modular_machine.portable_drive, computer.get_component(PART_HDD))
		else
			computer.copy_between_disks(href_list["PRG_copyfromusb"], computer.get_component(PART_DRIVE), computer.get_component(PART_HDD))
	if(href_list["PRG_closefile"])
		. = TOPIC_HANDLED
		open_file = null
		error = null
	if(href_list["PRG_edit"])
		. = TOPIC_HANDLED
		if(!open_file)
			return
		var/datum/computer_file/data/F = computer.get_file(open_file)
		if(!istype(F))
			return
		if(F.do_not_edit && (alert("WARNING: This file is not compatible with editor. Editing it may result in permanently corrupted formatting or damaged data consistency. Edit anyway?", "Incompatible File", "No", "Yes") == "No"))
			return
		if(F.read_only)
			error = "This file is read only. You cannot edit it."
			return

		var/oldtext = html_decode(F.stored_data)
		oldtext = replacetext(oldtext, "\[br\]", "\n")

		var/newtext = sanitize(replacetext(input(usr, "Editing file [open_file]. You may use most tags used in paper formatting:", "Text Editor", oldtext) as message|null, "\n", "\[br\]"), MAX_TEXTFILE_LENGTH)
		if(!newtext)
			return

		computer.update_data_file(F.filename, newtext, F.type, replace_content = TRUE)
	if(href_list["PRG_printfile"])
		. = TOPIC_HANDLED
		if(!open_file)
			return
		var/datum/computer_file/data/F = computer.get_file(open_file)
		var/datum/computer_file/binary/photo/P = computer.get_file(open_file)
		var/datum/computer_file/data/bodyscan/B = computer.get_file(open_file)
		if(istype(B))
			if(!computer.print_bodyscan())
				error = "Hardware error: Unable to print the file."
				return
			else
				var/obj/item/paper/bodyscan/paper =	new /obj/item/paper/bodyscan(usr.loc, "Printout error.", "Body scan report - [B.filename]", B.generate_print_data())
				paper.metadata = B.stored_data
		else if(istype(F))
			if(!computer.print_paper(F.generate_file_data(),F.filename,F.papertype, F.metadata))
				error = "Hardware error: Unable to print the file."
				return
		if(istype(P))
			if(!computer.print_photo(P.photo, P.filename))
				error = "Hardware error: Unable to print the photo."
				return
	if(.)
		SSnano.update_uis(NM)

// ─── R&D System Drive Management ─────────────────────────────────────────────
// rndsys — manage the R&D core server System HDD.
//
// Usage:
//   rndsys           — show system drive status for all reachable core servers
//   rndsys -init     — fabricate a blank System HDD and drop it at this terminal.
//                      Insert the drive into the core server manually.
//                      WARNING: does NOT restore lost research progress.
//
// Requires network admin access.
// ─────────────────────────────────────────────────────────────────────────────

/datum/terminal_command/rndsys
	name = "rndsys"
	man_entry = list(
		"Format: rndsys \[-init\]",
		"Without options: report System HDD status for all reachable R&D core servers.",
		"-init: format this terminal's internal HDD as a System R&D Drive.",
		"  Extract the HDD and insert it into the R&D core server.",
		"  WARNING: does NOT restore lost research progress.",
		"Requires network admin access."
	)
	pattern = "^rndsys"
	req_access = list(list(access_network_admin))

/datum/terminal_command/rndsys/proper_input_entered(text, mob/user, datum/terminal/terminal)
	var/list/arguments = get_arguments(text)
	if(isnull(arguments))
		return syntax_error()

	var/atom/host = terminal.computer.get_physical_host()
	var/host_z = host ? host.z : user.z

	// Status report — no arguments
	if(!length(arguments))
		var/list/out = list()
		out += "rndsys: Scanning for R&D core servers..."
		var/found = 0
		for(var/obj/machinery/r_n_d/server/core/S in SSresearch.rnd_server_list)
			if(GLOB.using_map.use_overmap && !(host_z in GetConnectedZlevels(S.z)))
				continue
			found++
			var/obj/item/stock_parts/computer/hard_drive/sys = S.get_system_drive()
			if(sys)
				var/datum/computer_file/data/rnd_state/state_file = sys.find_file_by_name("rnd_state")
				var/state_ok = (state_file && state_file.stored_data)
				out += "  Server ID [S.server_id] ([S.name]): System HDD installed — state [state_ok ? "OK" : "EMPTY"]"
			else
				out += "  Server ID [S.server_id] ([S.name]): NO SYSTEM HDD — insert one via server panel or run 'rndsys -init'"
		if(!found)
			out += "  No R&D core servers found on this network."
		return out

	// -init: format this terminal's internal HDD as a System R&D Drive
	if(length(arguments) == 1 && arguments[1] == "-init")
		var/obj/item/stock_parts/computer/hard_drive/hdd = terminal.computer.get_component(PART_HDD)
		if(!istype(hdd))
			return "[name]: Error; no internal hard drive detected in this terminal."
		if(hdd.rnd_category == "System")
			return "[name]: This drive is already formatted as a System R&D Drive."
		// Mark as System drive and write an empty-but-valid state file
		hdd.rnd_category = "System"
		hdd.SetName("System R&D Drive")
		var/datum/computer_file/data/rnd_state/F = new
		F.stored_data = json_encode(list("researched" = list(), "levels" = list(), "reputation" = list(), "designs" = list()))
		hdd.save_file(F)
		message_admins("[key_name(user)] formatted terminal HDD as System R&D Drive via rndsys.")
		return list(
			"rndsys: Internal HDD formatted as System R&D Drive.",
			"WARNING: This drive contains no research data. All tech nodes must be re-unlocked.",
			"Extract the HDD from this terminal (screwdriver the panel),",
			"then insert it into the R&D core server.",
			"rndsys: Done."
		)

	return syntax_error()
