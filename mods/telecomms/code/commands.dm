
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

	if(!LAZYLEN(T))
		return "[name]: error, not enough arguments."
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
				terminal.history += "<br>[name] ⇐ [i]"
				terminal.history += "terminal ⇒ [output]"
			return "<font color='00ff00'>[name]: execution complete.</font>"

	return "[name]: options not found."
///BATCH Compilator
