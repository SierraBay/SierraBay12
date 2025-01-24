/// Shows and manipulates programs running on the computer
/datum/terminal_command/prog
	name = "prog"
	man_entry = list(
		"Format: prog \[-flag pid|filename\]",
		"Without options, list all programs currently running.",
		"With -f followed by pid (number), toggle the program between running in foreground or background.",
		"With -k and no further arguments, terminates all running programs.",
		"With -k followed by pid (number), terminates the specified program.",
		"With -x followed by filename, attempt to execute filename as a program.",
		"With -a and no further arguments, clears the autorun setting.",
		"With -a followed by filename, set autorun to use the specified filename.",
		"With -b and no further arguments, sets the backdoor access flah is on.",
		"NOTICE: Programs are executed using access credentials of the original terminal session."
	)
	pattern = "^prog"
	skill_needed = SKILL_TRAINED

/datum/terminal_command/prog/proper_input_entered(text, mob/user, datum/terminal/terminal)
	. = syntax_error()
	var/list/arguments = get_arguments(text)
	if(isnull(arguments))
		return
	else if(length(arguments) == 1)
		if(arguments[1] == "-b")
			for(var/datum/computer_file/program/ntnetdesign/P in terminal.computer.running_programs)
				P.backdoor_access = !P.backdoor_access
				return "[P.filedesc]: Backdoor access set to [P.backdoor_access]."
