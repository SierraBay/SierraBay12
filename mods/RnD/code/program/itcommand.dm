#define regex_replace(RE, ARGS...) RE.Replace(ARGS)

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


/datum/terminal_command/ntsh
	name = "ntsh"
	man_entry = list(
					"NanoTrasen Secure Shell, a secure remote access protocol.",
					"Format: ntsh \[NID] \[LOGIN] \[PASSWORD].",
					"Connects to a remote terminal.")
	pattern = "^ntsh"

/datum/terminal_command/ntsh/proper_input_entered(text, mob/user, datum/terminal/terminal)
	var/datum/extension/interactive/ntos/CT = terminal.computer
	if(!CT.get_ntnet_status()) return "[name]: NetworkError\[0x12932910] Unable to establishe connection."
	var/list/T = splittext(text, " ")
	T = T.Copy(2)

	var/obj/item/stock_parts/computer/network_card/NC = CT.get_component(PART_NETWORK)
	if(!NC)
		return "[name]: unable to connect to the remote terminal"

	if(!LAZYLEN(T)?.len) return "[name]: error, not enough arguments."
	if(istype(terminal, /datum/terminal/remote)) return "[name] is not supported on remote terminals."

	var/nid = T[1]
	nid = text2num(nid)
	var/datum/extension/interactive/ntos/comp = ntnet_global.get_os_by_nid(nid)

	if(comp == CT) return "[name]: Error; can not open remote terminal to self."
	if(!comp || !comp.host_status() || !comp.get_ntnet_status()) return "[name]: No active device with this nid found."
	if(comp.has_terminal(user)) return "[name]: A remote terminal to this device is already active."

	var/obj/item/stock_parts/computer/hard_drive/HDD = comp.get_component(PART_HDD)
	if(!HDD) return "[name]: no local storage found"
	if(!HDD.check_functionality()) return "[name]: Access attempt to local storage failed. Check integrity of your hard drive"
	var/datum/computer_file/data/config/cfg_file = HDD.find_file_by_name("config")
	if(cfg_file)
		var/list/loginpassword = splittext(cfg_file.get_setting(MODULAR_CONFIG_REMCON_SETTING),"@")
		if(loginpassword && LAZYLEN(loginpassword) >= 2)
			var/login = loginpassword[1]
			var/password = loginpassword[2]
			if(T[2] == login)
				if(T[3] == password)
					var/datum/terminal/remote/new_term = new (user, comp, CT)
					LAZYADD(comp.terminals, new_term)
					LAZYADD(CT.terminals, new_term)
					ntnet_global.add_log("[NC.get_network_tag()] open [name] tunnel to [comp.get_network_tag()]")
					return "[name]: <font color='#00ff00'>Connection established with login: [login], and password: [password].</font>"
				else return "<font color='#ff0000'>[name]: INCORRECT PASSWORD.</font>"
			else return "<font color='#ff0000'>[name]: INCORRECT LOGIN.</font>"
		else return "[name]: login and password needed."
	else
		var/datum/terminal/remote/new_term = new(user, comp, CT)
		LAZYADD(comp.terminals, new_term)
		LAZYADD(CT.terminals, new_term)
		ntnet_global.add_log("[NC.get_network_tag()] open [name] tunnel to [NC.get_network_tag()]")
		return "[name]: Connection established."

//BATCH Compilator
/datum/terminal_command/alias
	name = "alias"
	man_entry = list("Format: alias -ex \[filename]",
					"Read and compile batch code from local files.",
					"Use 'alias -cr -bat \[filename]' to create bat file. To write code from terminal use 'man echo'.",
					"Use 'alias -mn -bat' to get help about batch."
					)
	pattern = "^alias"

/datum/terminal_command/alias/proper_input_entered(text, mob/user, datum/terminal/terminal)
	var/option = copytext(text, 7, 10)

	var/obj/item/stock_parts/computer/hard_drive/HDD = terminal.computer.get_component(PART_HDD)
	if(!HDD)
		return "<font color='00ff00'>[name]: local storage is missed.</font>"
	if(!HDD.check_functionality())
		return "<font color='00ff00'>[name]: check integrity of your hard drive.</font>"

	if(option == "-cr")
		if(copytext(text, 11, 15) == "-bat")
			var/ent_filename = copytext(text, 16)
			if(length(ent_filename) != 0)
				var/datum/computer_file/data/coding/batch/B = new()
				B.filename = ent_filename
				HDD.save_data_file(B)
				return "<font color='00ff00'>[name]: file '[B.filename]' was created.</font>"
			else
				return "<font color='#ffa000'>[name]: error, expected file name.</font>"
		return "<font color='#ffa000'>[name]: language marking option not found.</font>"


	if(option == "-mn")
		if(copytext(text, 11, 15) == "-bat")
			var/datum/computer_file/data/text/batch_manual/BRM = new()
			HDD.save_data_file(BRM)
			return "[name]: batch manual created."


	if(option == "-ex")
		var/inp_file_name = copytext(text, 11)
		if(length(inp_file_name) != 0)
			var/datum/computer_file/data/coding/batch/F = HDD.find_file_by_name(inp_file_name)
			if(F.filetype != "BAT")
				return "<font color='#ffa000'>[name]: incorrect file. Expected batch file.</font>"
			var/code = F.stored_data
			if(!findtext(code, ";"))
				return "<font color='#ff0000'>[name]: compile error, lack this ';'.</font>"
			if(findtext(code, inp_file_name) || findtext(code, "alias"))
				var/obj/item/stock_parts/computer/hdd = terminal.computer.get_component(PART_HDD)
				hdd.damage_health(rand (5, 15))
				return "<font color='#ff0000'> compile error, possible recursion detected.</font>"
			if(length(code) > 500)
				var/obj/item/stock_parts/computer/hdd = terminal.computer.get_component(PART_HDD)
				hdd.damage_health(rand (5, 15))
				return "<font color='#ff0000'> compile error, too much commands.</font>"

			var/regex/RegexHTML = new("<\[^<>]*>", "g")
			var/regex/RegexFileHTML = new("\\\[\[^\\\[\\\]]*\\\]", "g")
			code = regex_replace(RegexHTML, code)
			code = regex_replace(RegexFileHTML, code)
			code = replacetext_char(code, "\n", "")

			var/list/code_list = splittext(code, "; ")

			for(var/i in code_list)
				var/output = terminal.parse(i, user)
				terminal.history += "<br>[name] << [i]"
				terminal.history += "terminal >> [output]"
			return "<font color='00ff00'>[name]: execution complite.</font>"

	return "[name]: options not found."
///BATCH Compilator

#undef regex_replace(RE, ARGS...) RE.Replace(ARGS)
